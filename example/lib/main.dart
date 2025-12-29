import 'package:example/create_signers_screen.dart';
import 'package:example/sign_message_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Web3SignerApp());
}

class Web3SignerApp extends StatelessWidget {
  const Web3SignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 Signers Demo',
      home: const CreateSignersScreen(),
      initialRoute: CreateSignersScreen.routeName,
      routes: {
        CreateSignersScreen.routeName: (context) => const CreateSignersScreen(),
        SignMessageScreen.routeName: (context) => const SignMessageScreen(),
      },
    );
  }
}
