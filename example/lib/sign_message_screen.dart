import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3_signers/web3_signers.dart';

class SignMessageScreen<T> extends StatefulWidget {
  const SignMessageScreen({super.key, this.signerType, this.signer});
  final SignerType? signerType;
  final T? signer;

  static const routeName = '/sign-message';

  @override
  State<SignMessageScreen<T>> createState() => _SignMessageScreenState<T>();
}

class _SignMessageScreenState<T> extends State<SignMessageScreen<T>> {
  final TextEditingController _messageController = TextEditingController();
  String? _signature;
  bool _isSigning = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getPublicKey() {
    final signer = widget.signer;
    if (signer is LocalKeySigner) {
      final pk = signer.publicKey;
      return 'x: ${pk.x.toHex()}\ny: ${pk.y.toHex()}';
    } else if (signer is PassKeySigner) {
      final pk = signer.publicKey;
      return 'x: ${pk.x.toHex()}\ny: ${pk.y.toHex()}';
    } else if (signer is PlatformKeySigner) {
      final pk = signer.publicKey;
      return 'x: ${pk.x.toHex()}\ny: ${pk.y.toHex()}';
    }
    return 'No signer provided';
  }

  String getAddress() {
    final signer = widget.signer;
    if (signer is LocalKeySigner) {
      return signer.getAddress();
    } else if (signer is PassKeySigner) {
      return signer.getAddress();
    } else if (signer is PlatformKeySigner) {
      return signer.getAddress();
    }
    return 'No signer provided';
  }

  Future<void> signMessage(String message) async {
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message to sign')),
      );
      return;
    }

    setState(() {
      _isSigning = true;
      _signature = null;
    });

    try {
      final signer = widget.signer;
      final messageBytes = message.codeUnits;
      Signature signature;

      if (signer is LocalKeySigner) {
        signature = await signer.personalSign(Uint8List.fromList(messageBytes));
      } else if (signer is PassKeySigner) {
        signature = await signer.personalSign(Uint8List.fromList(messageBytes));
      } else if (signer is PlatformKeySigner) {
        signature = await signer.personalSign(Uint8List.fromList(messageBytes));
      } else {
        throw Exception('Invalid signer type');
      }

      setState(() {
        _signature = signature.clientDataJson;
        _isSigning = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message signed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error signing message: $e');
      setState(() {
        _isSigning = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        "Sign Message",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ResultCardInterface(
                    publicKey: getPublicKey(),
                    address: getAddress(),
                    signerType: widget.signerType,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Message to Sign:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSigning
                          ? null
                          : () => signMessage(_messageController.text),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSigning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Sign Message',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  if (_signature != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Signature:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Signed Successfully',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }
}

class _ResultCardInterface extends StatelessWidget {
  const _ResultCardInterface({
    super.key,
    required this.publicKey,
    required this.address,
    this.signerType,
  });

  final String publicKey;
  final String address;
  final SignerType? signerType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Signer Type: ${signerType?.name ?? "Unknown"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                size: 20,
                Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Public Key:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            publicKey,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Address:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
