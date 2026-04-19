import 'package:flutter/material.dart';

/// PIN numérico do app (4 dígitos).
Future<bool> showAppPinDialog(
  BuildContext context, {
  required String expectedPin,
  String title = 'PIN do app',
  String subtitle = 'Digite o PIN de 4 dígitos:',
}) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 16),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            onSubmitted: (_) {
              if (controller.text == expectedPin) {
                Navigator.pop(ctx, true);
              }
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          onPressed: () {
            if (controller.text != expectedPin) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('PIN incorreto!'), backgroundColor: Colors.red),
              );
              return;
            }
            Navigator.pop(ctx, true);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
  controller.dispose();
  return ok == true;
}
