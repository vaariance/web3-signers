import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  runApp(Web3Signer());
}

class Web3Signer extends StatefulWidget {
  const Web3Signer({super.key});

  @override
  State<Web3Signer> createState() => _Web3SignerState();
}

class _Web3SignerState extends State<Web3Signer> {
  final TextEditingController _textField1Controller = TextEditingController();
  final TextEditingController _textField2Controller = TextEditingController();
  final TextEditingController _textField3Controller = TextEditingController();

  final PassKeySigner _pkpSigner = PassKeySigner(
    "variance.space", // id
    "variance", // name
    "https://variance.space", // origin
  );

  final HardwareSigner _seSigner = HardwareSigner.withTag("variance");

  String? _calldata;
  PassKeyPair? _pkp;
  P256Credential? _seCredential;

  void _auth() async {
    _pkp = await _pkpSigner.register("user@variance.space", "test user");
    _updatePkpPublicKey();
  }

  void _updatePkpPublicKey() => setState(() {
        _textField1Controller.text = _pkp!.publicKey.item1.toHex();
        _textField2Controller.text = _pkp!.publicKey.item2.toHex();
      });

  void _updateSePublicKey() => setState(() async {
        _seCredential = await _seSigner.generateKeyPair();
        _textField1Controller.text = _seCredential!.publicKey.item1.toHex();
        _textField2Controller.text = _seCredential!.publicKey.item2.toHex();
      });

  void _updatePkpSignature() => setState(() async {
        final sig = await _pkpSigner.signToPasskeySignature(Uint8List(32));
        _textField3Controller.text =
            "[r:${sig.signature.item1.toHex()}, s:${sig.signature.item2.toHex()}]";

        // extracting calldata
        final hb64e = b64e(Uint8List(32));
        final cldj = sha256Hash(
            utf8.encode(sig.clientDataPrefix + hb64e + sig.clientDataSuffix));
        sig.authData.toList().addAll(cldj);
        print(hexlify(sha256Hash(sig.authData)));
        _calldata = hexlify(abi.encode([
          "bytes32",
          "uint256",
          "uint256",
          "uint256",
          "uint256"
        ], [
          sha256Hash(sig.authData),
          sig.signature.item1.value,
          sig.signature.item2.value,
          _pkp?.publicKey.item1.value,
          _pkp?.publicKey.item2.value
        ]));
      });

  void _updateSeSignature() => setState(() async {
        final sig = await _seSigner.signToEc(Uint8List(32));
        _textField3Controller.text =
            "[r:${Uint256(sig.r).toHex()}, s:${Uint256(sig.s).toHex()}]";
        print(hexlify(sha256Hash(Uint8List(32))));
        _calldata = hexlify(abi.encode([
          "bytes32",
          "uint256",
          "uint256",
          "uint256",
          "uint256"
        ], [
          sha256Hash(Uint8List(32)),
          sig.r,
          sig.s,
          _seCredential?.publicKey.item1.value,
          _seCredential?.publicKey.item2.value
        ]));
      });

  void _clearAllFields() => setState(() {
        _textField1Controller.clear();
        _textField2Controller.clear();
        _textField3Controller.clear();
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Web3 Signer',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'PublicKeyX:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _textField1Controller,
                      decoration: const InputDecoration(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'PublicKeyY:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textField2Controller,
                      decoration: const InputDecoration(),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Signature:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textField3Controller,
                      decoration: const InputDecoration(),
                      onChanged: (value) {
                        //detect user input
                      },
                      onSubmitted: (value) {
                        //when the user indicates they are done with editing textfield
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _auth,
                      child: const Text('Register with Passkey'),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _updatePkpSignature,
                      child: const Text('Sign with Passkey'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _updateSePublicKey,
                      child: const Text('Register with Secure enclave'),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _updateSeSignature,
                      child: const Text('Sign with Secure enclave'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _clearAllFields,
                    child: const Text('Clear field'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 1,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    onPressed: () async {
                      Clipboard.setData(ClipboardData(text: _calldata ?? ""));
                    },
                    child: const Row(children: [
                      Text('Copy callData'),
                      Icon(Icons.copy_all)
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
