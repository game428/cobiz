import 'package:cobiz_client/tools/cobiz.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';

import 'package:cobiz_client/http/common.dart' as commonApi;

class AESUtils {
  // ignore: non_constant_identifier_names
  static String _KEY = '';
  // ignore: non_constant_identifier_names
  static String _IV = '208zk699rv5n3o21';

  static String _localKey = 'e184b95e02ad4d969f31ecfe072a12c4';

  static String encrypt(String plainText, {bool isLocal = false}) {
    try {
      final key = Key.fromUtf8(isLocal ? _localKey : _KEY);
      final iv = IV.fromUtf8(_IV);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (err) {
      print("aes encode error:$err");
      return null;
    }
  }

  static String decrypt(String encrypted, {bool isLocal = false}) {
    try {
      final key = Key.fromUtf8(isLocal ? _localKey : _KEY);
      final iv = IV.fromUtf8(_IV);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
      return decrypted;
    } catch (err) {
      print("aes decode error:$err");
      return null;
    }
  }

  static Future<void> getSharedSecret() async {
    final localKeyPair = await x25519.newKeyPair();
    final publicKeyHex = hex.encode(localKeyPair.publicKey.bytes);

    String remotePublicKeyHex = await commonApi.swapCipher(publicKeyHex);
    if (strNoEmpty(remotePublicKeyHex)) {
      final remotePublicKey = PublicKey(hex.decode(remotePublicKeyHex));
      var sharedSecret = await x25519.sharedSecret(
        localPrivateKey: localKeyPair.privateKey,
        remotePublicKey: remotePublicKey,
      );
      _KEY = hex.encode(md5.convert(sharedSecret.extractSync()).bytes);
    } else {
      Future.delayed(Duration(milliseconds: 500), () async {
        getSharedSecret();
      });
    }
  }
}
