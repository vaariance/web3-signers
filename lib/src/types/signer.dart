part of '../../web3_signers.dart';

@Deprecated("use Signer")
typedef MSI = Signer;

@Deprecated("use Signer")
typedef MultiSignerInterface = Signer;

@Deprecated("use Signer")
typedef EOAWalletInterface = Signer;

@Deprecated("use Signer")
typedef PasskeySignerInterface = Signer;

/// Base interface for Smart Account signers.
///
/// Implementations may wrap different backing keys or mechanisms (EOA,
/// passkeys/WebAuthn, hardware, custodial, etc.). The capabilities flags
/// describe user‑presence/verification behavior and whether the signer can
/// operate synchronously.
abstract class Signer extends CustomSigner {
  /// Logical type/category of the signer (e.g., SecureEnclave, Passkey, LocalKey).
  SignerType get kind;

  /// Whether this signer can enforce user presence (e.g., prompt/confirm).
  ///
  /// If `true`, the platform can require a user gesture before signing.
  bool get supportsUserPresence;

  /// Whether this signer supports strong user verification (e.g., biometrics).
  ///
  /// If `true`, the platform can require biometric/PIN verification.
  bool get supportsUserVerification;

  /// Whether signatures produced by this signer are recoverable.
  ///
  /// Recoverable signatures include enough information to recover the signer
  /// address from `(r, s, v)`. For Smart Account validations this may be
  /// `false`, as verification can be performed on‑chain.
  bool get isRecoverable;

  /// Whether this signer can produce signatures synchronously.
  ///
  /// Passkey/WebAuthn signers typically require async flows due to OS UI.
  bool get supportsSyncSigning;

  /// Returns a safe, deterministic placeholder signature.
  ///
  /// Used for preflight/estimation flows where a signature shape is required
  /// but a real signature should not be produced. Do not broadcast.
  Signature getDummySignature();

  /// Returns the primary address associated with this signer.
  HexString getAddress();

  /// Signs a personal message digest (EIP‑191 style) and returns raw bytes.
  ///
  /// The input is expected to be the exact bytes to be signed (digest or
  /// preimage depending on the implementation). The output encoding is
  /// implementation‑specific.
  Future<Signature> personalSign(Bytes message);

  /// Signs a digest using elliptic curve and returns `(r, s[, v])`.
  ///
  /// Deprecated: prefer unified `sign` or `signAsync` in implementing classes.
  @Deprecated("Use sign or/and signAsync")
  Future<MsgSignature> signToEc(Bytes preImage);

  /// Signs EIP‑712 typed data with the provided version.
  ///
  /// `jsonData` is the structured definition, and `version` selects the
  /// encoding/standard variant. Returns the encoded signature bytes.
  Future<Signature> signTypedData(
    TypedMessage jsonData,
    TypedDataVersion version,
  );
}
