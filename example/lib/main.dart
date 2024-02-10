import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3_signers/web3_signers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passkeys Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Passkeys Demo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PassKeySigner _signer = PassKeySigner(
    "variance.space", // id
    "variance", // name
    "https://variance.space", // origin
  );

  bool _registered = true;

  void _auth() async {
    if (_registered) {
      await _signer.signToPasskeySignature(Uint8List(32), index: 2);
    } else {
      await _signer.register("user@test.com", "test user");
      _registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _registered ? 'Click to sign' : 'Register new passkey',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _auth,
        tooltip: 'passkey',
        child: const Icon(Icons.account_circle),
      ),
    );
  }
}
