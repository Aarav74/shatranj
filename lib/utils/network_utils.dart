import 'package:flutter/foundation.dart';
import 'dart:io';

const String computerIp = '192.168.1.8:8000'; // UPDATE THIS if your IP changes

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else if (Platform.isAndroid) {
    // return 'http://10.0.2.2:8000'; // Uncomment if using emulator
    return 'http://$computerIp';      // Physical device
  } else if (Platform.isIOS) {
    // return 'http://localhost:8000'; // Uncomment if using simulator
    return 'http://$computerIp';      // Physical device
  } else {
    return 'http://localhost:8000';
  }
}
