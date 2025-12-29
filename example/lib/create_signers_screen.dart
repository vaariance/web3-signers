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
  bool isKeyGenerating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isKeyGenerating) ...[
              const CircularProgressIndicator(),
            ] else ...[
              TextButton(
                child: const Text("Local Key Signer"),
                onPressed: () => localKeyMethod(setState),
              ),
              TextButton(
                  child: const Text("Pass Key Signer"),
                  onPressed: () => passkeyMethod(setState)),
              TextButton(
                child: const Text("Platform Key Signer"),
                onPressed: () => platformKeyMethod(setState),
              ),
            ],
          ]),
    );
  }

  void passkeyMethod(SetStateFunction setState) {
    setState(() {
      isKeyGenerating = true;
    });
    Signers().usePassKey().then((value) {
      setState(() {
        isKeyGenerating = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SignMessageScreen(signer: value)),
      );
    }, onError: (error) {
      setState(() {
        isKeyGenerating = false;
      });
    });
  }

  void platformKeyMethod(SetStateFunction setState) {
    setState(() {
      isKeyGenerating = true;
    });
    Signers().usePlatformKey().then((value) {
      setState(() {
        isKeyGenerating = false;
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SignMessageScreen(signer: value)),
      );
    }, onError: (error) {
      setState(() {
        isKeyGenerating = false;
      });
    });
  }

  void localKeyMethod(SetStateFunction setState) {
    setState(() {
      isKeyGenerating = true;
    });
    Future.delayed(const Duration(seconds: 1));
    final signer = Signers().useLocalKey();
    setState(() {
      isKeyGenerating = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => SignMessageScreen(signer: signer)),
    );
  }
}
