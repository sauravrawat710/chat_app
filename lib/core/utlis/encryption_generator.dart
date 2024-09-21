import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class EncryptionGenerator {
  // Generate a secure random AES key (256 bits)
  static Uint8List generateAESKey() {
    final secureRandom = _getSecureRandom();
    final key = secureRandom.nextBytes(256 ~/ 8); // 32 bytes
    return key;
  }

  // Generate RSA key pair (asymmetric encryption)
  static Future<AsymmetricKeyPair> generateRSAKeyPair({
    int bitLength = 2048,
  }) async {
    final secureRandom = _getSecureRandom();
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), bitLength, 64),
        secureRandom,
      ));

    final pair = keyGen.generateKeyPair();
    return pair;
  }

  // Generate a secure random number generator (FortunaRandom)
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final seed = _getSeed();
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  // Generate a random seed for secure key generation
  static Uint8List _getSeed() {
    final random = Random.secure();
    final seed = Uint8List(32); // 32 bytes = 256 bits
    for (int i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256); // Fill each byte with random data
    }
    return seed;
  }

// AES encryption (CBC mode with PKCS7 padding)
  static Uint8List aesEncrypt(String plainText, Uint8List key) {
    final iv = _getSecureRandom().nextBytes(16); // Random 16-byte IV
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(key), iv));

    final encryptedData =
        _processBlocks(cipher, Uint8List.fromList(utf8.encode(plainText)));

    // Combine IV and encrypted data
    return Uint8List.fromList(iv + encryptedData);
  }

// AES decryption (CBC mode with PKCS7 padding)
  static String aesDecrypt(Uint8List cipherTextWithIv, Uint8List key) {
    final iv = cipherTextWithIv.sublist(0, 16); // Extract the IV
    final cipherText = cipherTextWithIv.sublist(16); // Extract the ciphertext

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));

    final decryptedData = _processBlocks(cipher, cipherText);
    // final unpaddedData = _removePadding(decryptedData); // Remove PKCS7 padding

    // Convert decrypted bytes back to the original string (UTF-8 decoding)
    return utf8.decode(decryptedData);
  }

// Helper function to process the input blocks for encryption/decryption
  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final blockSize = cipher.blockSize;

    // Add padding to input to match block size
    final paddedInput = _addPadding(input, blockSize);

    final output = Uint8List(paddedInput.length);

    for (var offset = 0; offset < paddedInput.length;) {
      final blockSize =
          cipher.processBlock(paddedInput, offset, output, offset);
      offset += blockSize;
    }

    return output;
  }

// Add PKCS7 padding
  static Uint8List _addPadding(Uint8List data, int blockSize) {
    final padder = PKCS7Padding();
    final paddedLength = (data.length + blockSize - 1) ~/ blockSize * blockSize;
    final paddedData = Uint8List(paddedLength)..setRange(0, data.length, data);

    padder.addPadding(paddedData, data.length);
    return paddedData;
  }

// Remove PKCS7 padding after decryption
  static Uint8List _removePadding(Uint8List paddedData) {
    int paddingLength = paddedData.last;
    return paddedData.sublist(0, paddedData.length - paddingLength);
  }

  // Encrypt AES session key with RSA public key
  static Uint8List rsaEncryptWithPublicKey(
      Uint8List aesKey, RSAPublicKey publicKey) {
    final rsaEngine = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return rsaEngine.process(aesKey);
  }

  // Decrypt AES session key with RSA private key
  static Uint8List rsaDecryptWithPrivateKey(
      Uint8List encryptedKey, RSAPrivateKey privateKey) {
    final rsaEngine = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    return rsaEngine.process(encryptedKey);
  }

  // Convert RSA public key to PEM format
  static String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var topLevel = ASN1Sequence();
    topLevel.add(ASN1Integer(publicKey.n!));
    topLevel.add(ASN1Integer(publicKey.exponent!));

    var encodedBytes = topLevel.encode();
    var base64Key = base64Encode(encodedBytes);

    return '-----BEGIN RSA PUBLIC KEY-----\n$base64Key\n-----END RSA PUBLIC KEY-----';
  }

  // Convert PEM format to RSAPublicKey
  static RSAPublicKey decodePublicKeyFromPem(String pem) {
    pem = pem.replaceAll('-----BEGIN RSA PUBLIC KEY-----', '');
    pem = pem.replaceAll('-----END RSA PUBLIC KEY-----', '');
    pem = pem.replaceAll('\n', '');

    var decodedBytes = base64Decode(pem);

    var asn1Parser = ASN1Parser(decodedBytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    var modulus = (topLevelSeq.elements![0] as ASN1Integer).integer;
    var exponent = (topLevelSeq.elements![1] as ASN1Integer).integer;

    return RSAPublicKey(modulus!, exponent!);
  }

  // Convert RSA private key to PEM format (PKCS#1)
  static String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
    var topLevel = ASN1Sequence();

    topLevel.add(ASN1Integer(BigInt.from(0))); // Version
    topLevel.add(ASN1Integer(privateKey.n!)); // Modulus
    topLevel.add(ASN1Integer(privateKey.publicExponent!)); // Public Exponent
    topLevel.add(ASN1Integer(privateKey.privateExponent!)); // Private Exponent
    topLevel.add(ASN1Integer(privateKey.p!)); // Prime P
    topLevel.add(ASN1Integer(privateKey.q!)); // Prime Q
    topLevel.add(ASN1Integer(
        privateKey.privateExponent! % (privateKey.p! - BigInt.one))); // dp
    topLevel.add(ASN1Integer(
        privateKey.privateExponent! % (privateKey.q! - BigInt.one))); // dq
    topLevel
        .add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!))); // InverseQ

    var encodedBytes = topLevel.encode();
    var base64Key = base64Encode(encodedBytes);

    return '-----BEGIN RSA PRIVATE KEY-----\n$base64Key\n-----END RSA PRIVATE KEY-----';
  }

  // Convert PEM format to RSAPrivateKey
  static RSAPrivateKey decodePrivateKeyFromPem(String pem) {
    pem = pem.replaceAll('-----BEGIN RSA PRIVATE KEY-----', '');
    pem = pem.replaceAll('-----END RSA PRIVATE KEY-----', '');
    pem = pem.replaceAll('\n', '');

    var decodedBytes = base64Decode(pem);

    var asn1Parser = ASN1Parser(decodedBytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    var modulus = (topLevelSeq.elements![1] as ASN1Integer).integer;
    var publicExponent = (topLevelSeq.elements![2] as ASN1Integer).integer;
    var privateExponent = (topLevelSeq.elements![3] as ASN1Integer).integer;
    var prime1 = (topLevelSeq.elements![4] as ASN1Integer).integer;
    var prime2 = (topLevelSeq.elements![5] as ASN1Integer).integer;

    return RSAPrivateKey(modulus!, privateExponent!, prime1!, prime2!);
  }
}
