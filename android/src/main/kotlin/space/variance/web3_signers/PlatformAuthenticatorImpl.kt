package space.variance.web3_signers

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager.FEATURE_STRONGBOX_KEYSTORE
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.biometric.BiometricManager.Authenticators
import androidx.biometric.BiometricManager.BIOMETRIC_SUCCESS
import androidx.biometric.BiometricManager.from
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okio.Buffer
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.interfaces.ECPublicKey
import java.util.concurrent.Executor

class PlatformAuthenticatorImpl(private val context: Context) : PlatformAuthenticator {
    private var activity: FragmentActivity? = null
    private var coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.Main)
    private var keyAlgorithm: String = KeyProperties.KEY_ALGORITHM_EC
    private var sigAlgorithm: String = "SHA256withECDSA"
    private var provider: String = "AndroidKeyStore"

    private fun getActivity(): FragmentActivity {
        return activity ?: throw NO_ACTIVITY
    }

    fun setActivity(act: Activity) {
        activity = act as FragmentActivity
    }

    fun clearActivity() {
        this.activity = null
    }

    override fun createKey(
        keyTag: String, options: AndroidOptions, callback: (Result<ByteArray>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                val secKey = getSecKey(keyTag)
                if (secKey != null) {
                    callback(Result.failure(KEY_ALREADY_EXISTS))
                    return@launch
                }

                val keypair = withContext(Dispatchers.IO) {
                    val kp = createKeyPair(keyTag, options)
                    val publicKey = kp?.public as ECPublicKey
                    parsePublicKey(publicKey)
                }
                callback(Result.success(keypair))
            } catch (e: Exception) {
                callback(Result.failure(KEY_GENERATION_FAILED(e.localizedMessage)))
            }
        }
    }

    override fun deleteKey(keyTag: String, callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val keyStore = KeyStore.getInstance(provider)
                    keyStore.load(null)
                    keyStore.deleteEntry(keyTag)
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(PLATFORM_ERROR(e.localizedMessage)))
            }
        }
    }

    private suspend fun sign(
        signature: Signature, data: ByteArray, callback: (Result<ByteArray>) -> Unit
    ) {
        try {
            val signatureBytes = withContext(Dispatchers.IO) {
                signature.update(data)
                signature.sign()
            }
            callback(Result.success(signatureBytes))
        } catch (e: Exception) {
            callback(Result.failure(SIGNING_FAILED(e.localizedMessage)))
        }

    }

    override fun sign(
        keyTag: String,
        data: ByteArray,
        options: AndroidOptions,
        callback: (Result<ByteArray>) -> Unit
    ) {
        coroutineScope.launch {
            val signer = withContext(Dispatchers.IO) {
                createSigner(keyTag)
            }
            if (options.requireUserAuthentication) {
                try {
                    val canAuthenticate = BiometricHelper.canAuthenticate(getActivity())
                    if (!canAuthenticate) {
                        callback(Result.failure(BIOMETRICS_NOT_AVAILABLE))
                        return@launch
                    }

                    withContext(Dispatchers.Main) {
                        BiometricHelper.authenticate(
                            activity = getActivity(),
                            cryptoObject = BiometricPrompt.CryptoObject(signer),
                            options = options,
                            onSuccess = { resultCryptoObject ->
                                coroutineScope.launch {
                                    sign(resultCryptoObject.signature!!, data, callback)
                                }
                            },
                            onError = { error ->
                                callback(Result.failure(error))
                            })
                    }
                } catch (e: Exception) {
                    callback(Result.failure(PLATFORM_ERROR(e.localizedMessage)))
                }
            } else {
                sign(signer, data, callback)
            }
        }
    }

    override fun getPublicKey(
        keyTag: String, callback: (Result<ByteArray?>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                val publicKey = withContext(Dispatchers.IO) {
                    val secKey = getSecKey(keyTag) ?: throw KEY_NOT_FOUND
                    val publicKey = secKey.certificate.publicKey
                    parsePublicKey(publicKey as ECPublicKey)
                }
                callback(Result.success(publicKey))
            } catch (e: Exception) {
                callback(Result.failure(PUBLIC_KEY_RETRIEVAL_FAILED(e.localizedMessage)))
            }
        }
    }

    private fun createKeyPair(keyTag: String, options: AndroidOptions): KeyPair? {
        val kpg: KeyPairGenerator = KeyPairGenerator.getInstance(
            keyAlgorithm, provider
        )
        val builder = KeyGenParameterSpec.Builder(
            keyTag, KeyProperties.PURPOSE_SIGN
        ).setDigests(KeyProperties.DIGEST_SHA256)
            .setUserAuthenticationRequired(options.requireUserAuthentication)
            .setInvalidatedByBiometricEnrollment(options.invalidateOnBiometricChange)
            .setUserConfirmationRequired(options.userConfirmationRequired)
            .setUserAuthenticationParameters(
                options.authTimeoutSeconds.toInt(), getAuthFlag(options.allowFallbackAuthentication)
            )

        if (options.attestationChallenge != null) {
            builder.setAttestationChallenge(options.attestationChallenge)
        }

        if (options.useStrongBoxKeyMint && supportsStrongBox()) {
            builder.setIsStrongBoxBacked(true)
        }


        kpg.initialize(builder.build())
        val kp = kpg.generateKeyPair()
        return kp
    }

    private fun createSigner(keyTag: String): Signature {
        val secKey = getSecKey(keyTag) ?: throw KEY_NOT_FOUND
        val signer = Signature.getInstance(sigAlgorithm)
        signer.initSign(secKey.privateKey)
        return signer
    }

    private fun getAuthFlag(allowFallbackAuthentication: Boolean): Int {
        if (allowFallbackAuthentication) {
            return KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL
        }
        return KeyProperties.AUTH_BIOMETRIC_STRONG
    }

    private fun parsePublicKey(publicKey: ECPublicKey): ByteArray {
        val w = publicKey.w
        val xBytes = w.affineX.toUnsigned32Bytes()
        val yBytes = w.affineY.toUnsigned32Bytes()

        return Buffer().writeByte(0x04).write(xBytes).write(yBytes).readByteArray()
    }

    private fun supportsStrongBox(): Boolean {
        return context.packageManager.hasSystemFeature(FEATURE_STRONGBOX_KEYSTORE)
    }

    private fun getSecKey(keyTag: String): KeyStore.PrivateKeyEntry? {
        val keyStore = KeyStore.getInstance(provider)
        keyStore.load(null)
        val secKey = keyStore.getEntry(keyTag, null)
        if (secKey !is KeyStore.PrivateKeyEntry) {
            return null
        }
        return secKey
    }

    fun java.math.BigInteger.toUnsigned32Bytes(): ByteArray {
        val bytes = this.toByteArray()
        return when {
            bytes.size == 32 -> bytes
            bytes.size > 32 -> bytes.copyOfRange(bytes.size - 32, bytes.size)
            else -> ByteArray(32 - bytes.size) + bytes
        }
    }

}

object BiometricHelper {

    private var allowedAuthFlags =
        Authenticators.BIOMETRIC_STRONG or Authenticators.DEVICE_CREDENTIAL

    fun authenticate(
        activity: FragmentActivity,
        cryptoObject: BiometricPrompt.CryptoObject,
        options: AndroidOptions,
        onSuccess: (BiometricPrompt.CryptoObject) -> Unit,
        onError: (FlutterError) -> Unit
    ) {
        val executor: Executor = activity.mainExecutor
        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                val resultCryptoObject = result.cryptoObject
                if (resultCryptoObject != null) {
                    onSuccess(resultCryptoObject)
                } else {
                    onError(AUTH_ERROR("Authentication succeeded but crypto object was null"))
                }
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                when (errorCode) {
                    BiometricPrompt.ERROR_NEGATIVE_BUTTON, BiometricPrompt.ERROR_USER_CANCELED -> {
                        onError(USER_CANCELED("User canceled: $errString"))
                    }

                    BiometricPrompt.ERROR_LOCKOUT, BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> {
                        onError(LOCKED_OUT("Locked out: $errString"))
                    }

                    else -> {
                        onError(AUTH_ERROR("Error $errorCode: $errString"))
                    }
                }
            }
        }

        val promptBuilder = BiometricPrompt.PromptInfo.Builder()
            .setTitle(options.biometricPromptTitle)
            .setSubtitle(options.biometricPromptSubtitle)
            .setDescription(options.biometricPromptDescription)
            .setConfirmationRequired(options.userConfirmationRequired)

        if (options.allowFallbackAuthentication) {
            promptBuilder.setAllowedAuthenticators(allowedAuthFlags)
        } else {
            promptBuilder.setAllowedAuthenticators(
                Authenticators.BIOMETRIC_STRONG
            ).setNegativeButtonText(options.biometricPromptNegativeButtonText)
        }

        val promptInfo = promptBuilder.build()
        val prompt = BiometricPrompt(activity, executor, callback)
        prompt.authenticate(promptInfo, cryptoObject)

    }

    fun canAuthenticate(
        context: Context, allowedAuthenticators: Int = allowedAuthFlags
    ): Boolean {
        val biometricManager = from(context)
        return when (biometricManager.canAuthenticate(allowedAuthenticators)) {
            BIOMETRIC_SUCCESS -> true
            else -> false
        }
    }
}
