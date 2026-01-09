package space.variance.web3_signers

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class PlatformAuthenticatorPlugin : FlutterPlugin, ActivityAware {
    private var implementation: PlatformAuthenticatorImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        implementation = PlatformAuthenticatorImpl(binding.applicationContext)
        PlatformAuthenticator.setUp(binding.binaryMessenger, implementation)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        PlatformAuthenticator.setUp(binding.binaryMessenger, null)
        implementation = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        updateImplementation(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        updateImplementation(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        clearImplementation()
    }

    override fun onDetachedFromActivity() {
        clearImplementation()
    }

    private fun updateImplementation(binding: ActivityPluginBinding) {
        implementation?.setActivity(binding.activity)
    }

    private fun clearImplementation() {
        implementation?.clearActivity()
    }
}
