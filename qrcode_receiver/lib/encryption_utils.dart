import 'dart:convert';

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// decrypts the provided encrypted string. The provider string should contain the salt, iv/nonce, actual content and the mac/tag.
/// This provides string should be base64 encoded, encrypted with AES265GCM which uses pbkdf2 SHA-256 with 100000 cycles
/// 16 bytes salt, 12 bytes nonce/vi, N bytes content, 16 bytes mac/tag
///
Future<String> decrypt(String cipherText, String passphrase) async{
  final encrypted = base64Decode(cipherText);
  // final encrypted = base64Decode('AEgQquiRsy/xXEuSGQDBsMYAXP0A9YxP7Nf/ANTHRLKsKoeG1E5X6SJNdkns4gPT8A==');
  // final encrypted = base64Decode('AEgQquiRsy/xXEuSGQDBsA==xgBc/QD1jE/s1/8A1MdEsqwqh4bUTlfpIk12SeziA9Pw');
  // final secretBox = SecretBox.fromConcatenation(encrypted, nonceLength: 12, macLength: 16); does not work due to a bug

  Uint8List ciphertext  = encrypted.sublist(28, encrypted.length - 16);
  Uint8List mac = encrypted.sublist(encrypted.length - 16);
  Uint8List iv = encrypted.sublist(16, 28);
  Uint8List salt = encrypted.sublist(0, 16);
  SecretBox secretBox = new SecretBox(ciphertext, nonce: iv, mac: new Mac(mac));

  // Decrypt
  Cipher algorithm = AesGcm.with256bits();
  Uint8List data = await algorithm.decrypt(
      secretBox,
      secretKey: await _getKey(salt, passphrase),
  );

  return utf8.decode(data);

}

Future<SecretKey> _getKey(Uint8List salt, String passphrase) async{
  Pbkdf2 pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  // Password we want to hash
  SecretKey secretKey = SecretKey(utf8.encode(passphrase));

  // Calculate a hash that can be stored in the database
  SecretKey newSecretKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: salt,
  );

  return newSecretKey;
}
