library;

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:eip712/eip712.dart' as eip712;
import 'package:eip712/eip712.dart';
import 'package:eip7702/eip7702.dart' hide Signer;
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart' hide PublicKey, Signature;
// ignore: implementation_imports
import 'package:web3dart/src/utils/uuid.dart';
import 'package:web3dart/web3dart.dart';

import 'src/api/platform_authenticator.dart';
import 'src/utils/constants.dart';
import 'src/utils/enums.dart';

export 'src/api/platform_authenticator.dart';
export 'src/utils/enums.dart';
export 'src/vendor/safe.dart';

part 'src/core/bip32_light.dart';
part 'src/core/bip39_light.dart';
part 'src/core/bip39_wordlist.dart';
part 'src/core/cbor_light.dart';
part 'src/core/core.dart';
part 'src/core/ec_api.dart';

part 'src/signing/localkey_signer.dart';
part 'src/signing/passkey_signer.dart';
part 'src/signing/platformkey_signer.dart';

part 'src/types/abi_coder.dart';
part 'src/types/bytes.dart';
part 'src/types/signer.dart';
part 'src/types/verifier.dart';
part 'src/types/p256_config.dart';
part 'src/types/uint.dart';

part 'src/utils/crypto.dart';
