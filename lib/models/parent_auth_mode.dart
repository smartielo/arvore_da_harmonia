/// Como desbloquear acessos de responsável no app.
enum ParentAuthMode {
  biometricOnly,
  appPinOnly,
  biometricAndAppPin,
}

String parentAuthModeToStorage(ParentAuthMode m) {
  switch (m) {
    case ParentAuthMode.biometricOnly:
      return 'biometric_only';
    case ParentAuthMode.appPinOnly:
      return 'app_pin_only';
    case ParentAuthMode.biometricAndAppPin:
      return 'both';
  }
}

ParentAuthMode parentAuthModeFromStorage(String? v) {
  switch (v) {
    case 'biometric_only':
      return ParentAuthMode.biometricOnly;
    case 'both':
      return ParentAuthMode.biometricAndAppPin;
    case 'app_pin_only':
    default:
      return ParentAuthMode.appPinOnly;
  }
}
