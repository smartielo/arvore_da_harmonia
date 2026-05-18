import 'package:flutter/material.dart';
 
import '../data/app_repository.dart';
import '../models/parent_auth_mode.dart';
import 'device_auth_gate.dart';


/// Fluxo de desbloqueio conforme preferência nas configurações.
class ParentAccess {
  ParentAccess._();

  static const String legacyDefaultAppPin = '1234';

  static Future<bool> run(
    BuildContext context, {
    String title = 'Confirmar',
    String subtitle = 'Autenticação do dispositivo:',
  }) async {
    return DeviceAuthGate.unlockDeviceCredentials();
  }
}

