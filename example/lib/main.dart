import 'dart:developer';

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
  final TextEditingController _textField4Controller = TextEditingController();

  final PassKeySigner _pkpSigner = PassKeySigner(
    "variance.space", // id
    "variance", // name
    "https://variance.space", // origin
  );

  PassKeyPair? _pkp;

  void _auth() async {
    _pkp = await _pkpSigner.register("user@variance.space", "test user");
    _updatePkpPublicKey();
  }

  void _updatePkpPublicKey() => setState(() {
        _textField1Controller.text = _pkp!.authData.publicKey.item1.toHex();
        _textField2Controller.text = _pkp!.authData.publicKey.item2.toHex();
      });

  void _updatePkpSignature() => setState(() async {
        final sig = await _pkpSigner.signToPasskeySignature(Uint8List(32));
        _textField3Controller.text =
            "[r:${sig.signature.item1.toHex()}, s:${sig.signature.item2.toHex()}]";
        final calldata = hexlify(sig.toUint8List());
        log(calldata);
      });

  void _clearAllFields() => setState(() {
        _textField1Controller.clear();
        _textField2Controller.clear();
        _textField3Controller.clear();
        _textField4Controller.clear();
      });

  void _getDummySig() => setState(() {
        final prefix = hexlify(Uint8List(0));
        final dummy = _pkpSigner.getDummySignature(prefix: prefix, getOptions: {
          "signer": "0xfD90FAd33ee8b58f32c00aceEad1358e4AFC23f9",
          "userVerification": "required"
        });
        log(dummy);
        _textField4Controller.text = dummy;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Signature:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textField4Controller,
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
                      ),
                    ),
                    onPressed: _getDummySig,
                    child: const Text('get dummy data'),
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
