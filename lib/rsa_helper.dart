import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:rsa_project/rsa_key_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// use this function in the initState function or in a button it depend on when you want to generate the keypair
void generateAndSaveKeyPair() async {
  final keyPair = generateKeyPair();
  final publicKey = keyPair.publicKey as RSAPublicKey;
  final privateKey = keyPair.privateKey as RSAPrivateKey;
  // Convert public key to String PEM
  final publicKeyPem = publicKeyToPem(publicKey);
  // Convert private key to String PEM
  final privateKeyPem = privateKeyToPem(privateKey);
// save to sharedprefernces (local database)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('publicKey', publicKeyPem);
  await prefs.setString('privateKey', privateKeyPem);
  print('save done');
}

//this method returns a Map of String (keypairs) from sharedprefernce
//you dont have to use it
Future<Map<String, String>> getKeysFromPrefs() async {
  try {
    //get keypair from sharedprefernces
    final prefs = await SharedPreferences.getInstance();
    String publicKey = prefs.getString('publicKey')!;
    String privateKey = prefs.getString('privateKey')!;
    return {'publicKey': publicKey, 'privateKey': privateKey};
  } catch (e) {
    print('Error retrieving keys from shared preferences: $e');
    return {'publicKey': "", 'privateKey': ""};
  }
}

// you have to use async and await when using this function or the thenFunction
//RSAPublicKey? publickey = await getPubliceKey();

Future<RSAPublicKey?> getPubliceKey() async {
  try {
    var publicKey = getKeysFromPrefs().then((value) {
      return decodePublicKeyFromPem(value['publicKey']!);
    });
    return await publicKey;
  } catch (e) {
    print('error : $e');
  }
  return null;
}
// you have to use async and await when using this function or the thenFunction
//RSAPrivateKey? privateKey = await getPirvateKey();

Future<RSAPrivateKey?> getPirvateKey() async {
  try {
    var privateKey = getKeysFromPrefs().then((value) {
      return decodePrivateKeyFromPem(value['privateKey']!);
    });
    return await privateKey;
  } catch (e) {
    print('error : $e');
  }
  return null;
}

// you have to use async and await when using this function or the thenFunction
// var enrypted = await encryptText(_plainTextController);
Future<String> encryptText(TextEditingController plainTextController) async {
  try {
    final plainText = plainTextController.text;
    RSAPublicKey publicKey;
    return getKeysFromPrefs().then((value) {
      publicKey = decodePublicKeyFromPem(value['publicKey']!);
      final encrypter =
          Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));
      final encrypted = encrypter.encrypt(plainText);
      return encrypted.base64;
    });
  } catch (e) {
    print('Error encrypting text: $e');
    return " ";
  }
}

// you have to use async and await when using this function or the thenFunction
// var decrypted = await decryptText(_encryptedTextController);

Future<String> decryptText(
    TextEditingController encryptedTextController) async {
  try {
    final encryptedText = encryptedTextController.text;
    RSAPrivateKey privateKey;
    return getKeysFromPrefs().then((value) {
      privateKey = decodePrivateKeyFromPem(value['privateKey']!);
      final encrypter =
          Encrypter(RSA(privateKey: privateKey, encoding: RSAEncoding.PKCS1));
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = encrypter.decrypt(encrypted);
      return decrypted;
    });
  } catch (e) {
    print('Error encrypting text: $e');
    return " ";
  }
}
