import 'package:chat_app/core/utlis/encryption_generator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

class FlutterSecureStorageService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

// Store keys
  Future<void> storeKeys(AsymmetricKeyPair keyPair) async {
    // Encode private and public keys to PEM format
    final privateKeyPem = EncryptionGenerator.encodePrivateKeyToPemPKCS1(
        keyPair.privateKey as RSAPrivateKey);
    final publicKeyPem = EncryptionGenerator.encodePublicKeyToPemPKCS1(
        keyPair.publicKey as RSAPublicKey);

    // Store private key securely
    await secureStorage.write(key: 'privateKey', value: privateKeyPem);

    // Store public key (for Firebase)
    await secureStorage.write(key: 'publicKey', value: publicKeyPem);
  }

  // Retrieve public key
  Future<String?> getPublicKey() async {
    return await secureStorage.read(key: 'publicKey');
  }

  // Retrieve decoded public key
  Future<RSAPublicKey> getDecodedPublicKey() async {
    final value = await secureStorage.read(key: 'publicKey');
    return EncryptionGenerator.decodePublicKeyFromPem(value!);
  }

  // Retrieve private key
  Future<String?> getPrivateKey() async {
    return await secureStorage.read(key: 'privateKey');
  }

  // Retrieve decoded private key
  Future<RSAPrivateKey> getDecodedPrivateKey() async {
    final value = await secureStorage.read(key: 'privateKey');
    return EncryptionGenerator.decodePrivateKeyFromPem(value!);
  }
}
