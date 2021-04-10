import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

Future<bool> isAuthenticated(String message) async {
  var localAuth = LocalAuthentication();
  if (!await localAuth.canCheckBiometrics) {
    return true;
  }

  try {
    return await localAuth.authenticate(localizedReason: message);
  } on PlatformException catch (e) {
    debugPrint(e.code);
    debugPrint(e.message);
    if (e.code == auth_error.notAvailable ||
        e.code == auth_error.notEnrolled ||
        e.code == auth_error.otherOperatingSystem ||
        e.code == auth_error.passcodeNotSet) {
      return true;
    }
  }
  return false;
}
