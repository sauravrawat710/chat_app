import 'dart:convert';
import 'dart:typed_data';

class HelperClass {
  static Uint8List decodeBase64(String text) {
    // Add padding to the Base64 string if the length is not a multiple of 4
    while (text.length % 4 != 0) {
      text += '=';
    }

    // Decode the padded Base64 string
    return base64.decode(text);
  }
}
