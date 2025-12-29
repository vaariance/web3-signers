import 'dart:developer';

import 'package:example/sign_message_screen.dart';
import 'package:example/signers.dart';
import 'package:flutter/material.dart';

typedef SetStateFunction = void Function(VoidCallback fn);

class CreateSignersScreen extends StatefulWidget {
  const CreateSignersScreen({super.key});
  static const routeName = '/create-signers';

  @override
  State<CreateSignersScreen> createState() => _CreateSignersScreenState();
}

class _CreateSignersScreenState extends State<CreateSignersScreen> {
  bool? isPasskeyGenerating = false;
  bool? isPlatformKeyGenerating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              child: const Text("Local Key Signer"),
              onPressed: () => localKeyMethod(setState),
            ),
            if (isPasskeyGenerating ?? false) ...[
              const CircularProgressIndicator(),
            ] else ...[
              TextButton(
                  child: const Text("Pass Key Signer"),
                  onPressed: () => passkeyMethod(setState)),
            ],
            TextButton(
              child: const Text("Platform Key Signer"),
              onPressed: () => platformKeyMethod(setState),
            ),
          ]),
    );
  }

  void passkeyMethod(SetStateFunction setState) {
    setState(() {
      isPasskeyGenerating = true;
    });
    Signers().usePassKey().then((value) {
      setState(() {
        isPasskeyGenerating = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                SignMessageScreen(signerType: value.kind, signer: value)),
      );
    }, onError: (error) {
      setState(() {
        isPasskeyGenerating = false;
      });
    });
  }

  void platformKeyMethod(SetStateFunction setState) {
    setState(() {
      isPlatformKeyGenerating = true;
    });
    Signers().usePlatformKey().then((value) {
      setState(() {
        isPlatformKeyGenerating = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                SignMessageScreen(signerType: value.kind, signer: value)),
      );
    }, onError: (error) {
      setState(() {
        isPlatformKeyGenerating = false;
      });
    });
  }

  void localKeyMethod(SetStateFunction setState) {
    setState(() {
      isPasskeyGenerating = true;
    });
    Future.delayed(const Duration(seconds: 1));
    final signer = Signers().useLocalKey();
    setState(() {
      isPasskeyGenerating = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              SignMessageScreen(signerType: signer.kind, signer: signer)),
    );
  }
}
