import 'package:flutter/material.dart';

import 'package:pointycastle/pointycastle.dart' as castle;
import 'package:rsa_project/rsa_helper.dart';

import 'package:rsa_project/rsa_key_generator.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _plainTextController = TextEditingController();
  final _encryptedTextController = TextEditingController();
  final _decryptedTextController = TextEditingController();

  final _keyPair = generateKeyPair();
  var privatedisplay = TextEditingController();
  var pubilcdisplay = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateAndSaveKeyPair();
  }

  void saveKeyPairToPrefs(
    castle.AsymmetricKeyPair keyPair,
  ) async {
    final publicKey = keyPair.publicKey as castle.RSAPublicKey;
    final privateKey = keyPair.privateKey as castle.RSAPrivateKey;

    // Convert public key to PEM

    final publicKeyPem = publicKeyToPem(publicKey);

    // Convert private key to PEM
    final privateKeyPem = privateKeyToPem(privateKey);
    print(publicKeyPem);
    print(privateKeyPem);

    setState(() {
      pubilcdisplay.text = publicKeyPem;
      privatedisplay.text = privateKeyPem;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('publicKey', publicKeyPem);
    await prefs.setString('privateKey', privateKeyPem);
    print('save done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter plain text to encrypt:'),
              TextFormField(
                controller: _plainTextController,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  var enrypted = await encryptText(_plainTextController);
                  setState(() {
                    _encryptedTextController.text = enrypted;
                  });
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                ),
                child: const Text('Encrypt'),
              ),
              const SizedBox(height: 16.0),
              const Text('Encrypted text:'),
              TextFormField(
                controller: _encryptedTextController,
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  var decrypted = await decryptText(_encryptedTextController);
                  setState(() {
                    _decryptedTextController.text = decrypted;
                  });
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                ),
                child: const Text('Decrypt'),
              ),
              const SizedBox(height: 16.0),
              const Text('Decrypted text:'),
              TextFormField(
                controller: _decryptedTextController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      saveKeyPairToPrefs(_keyPair);
                      pubilcdisplay.text =
                          await getKeysFromPrefs().then((value) {
                        return value['publicKey']!;
                      });
                      privatedisplay.text =
                          await getKeysFromPrefs().then((value) {
                        return value['privateKey']!;
                      });
                    },
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    child: const Text('Save'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 3000,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const InkWell(
                      child: SelectableText(
                        'Public Key:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    InkWell(
                      child: SelectableText(
                        pubilcdisplay.text,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const SelectableText(
                      'Private Key:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    InkWell(
                      child: SelectableText(
                        privatedisplay.text,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plainTextController.dispose();
    _encryptedTextController.dispose();
    _decryptedTextController.dispose();
    pubilcdisplay.dispose();
    privatedisplay.dispose();
    super.dispose();
  }
}
