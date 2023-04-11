import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:basic_utils/basic_utils.dart';

//this is the generatekeypair function
AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = <int>[];
  for (var i = 0; i < 32; i++) {
    seeds.add(seedSource.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom));

  return keyGen.generateKeyPair();
}

String privateKeyToPem(RSAPrivateKey privateKey) {
  var pem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privateKey);
  return pem;
}

String publicKeyToPem(RSAPublicKey publicKey) {
  var pem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(publicKey);
  return pem;
}

RSAPrivateKey decodePrivateKeyFromPem(String pem) {
  var privateKey = CryptoUtils.rsaPrivateKeyFromPemPkcs1(pem);
  return privateKey;
}

RSAPublicKey decodePublicKeyFromPem(String pem) {
  var publicKey = CryptoUtils.rsaPublicKeyFromPemPkcs1(pem);
  return publicKey;
}
