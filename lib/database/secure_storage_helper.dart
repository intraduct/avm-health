import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const secureStorage = FlutterSecureStorage();

  static Future<String?> read(String key) async {
    return secureStorage.read(key: key);
  }

  static Future<void> write(String key, String? value) async {
    return secureStorage.write(key: key, value: value);
  }

  static Future<bool?> readQuickUnlock() async {
    return read('quick-unlock').then((value) {
      if (value == null) {
        return null;
      }

      return value == 'true';
    });
  }

  static Future<void> writeQuickUnlock(bool quickUnlock) async {
    return write('quick-unlock', '$quickUnlock');
  }
}
