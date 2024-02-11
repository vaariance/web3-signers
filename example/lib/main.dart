import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void _updatePublicKeyX() =>
      setState(() => _textField1Controller.text = 'This is dummy text!');

  void _updatePublicKeyY() =>
      setState(() => _textField2Controller.text = 'This is also dummy text!');

  void _updateField3() =>
      setState(() => _textField3Controller.text = 'This is also dummy text!');

  void _clearBothFields() => setState(() {
        _textField1Controller.clear();
        _textField2Controller.clear();
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
                      onPressed: _updatePublicKeyX,
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
                      onPressed: _updatePublicKeyY,
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
                      onPressed: _updateField3,
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
                      onPressed: _updatePublicKeyY,
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
                    onPressed: _clearBothFields,
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
                      Clipboard.setData(
                          ClipboardData(text: _textField3Controller.text));
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
