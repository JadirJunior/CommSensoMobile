import 'package:commsensomobile/core/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:commsensomobile/core/services/session_service.dart';

class SettingsPageUi extends StatelessWidget {
  const SettingsPageUi({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Tema'),
          onTap: () => _showThemeSheet(context),
        ),
        const ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Conta'),
        ),
        const Divider(),

        // --- Logout ---
        ListTile(
          leading: Icon(Icons.logout, color: cs.error),
          title: Text('Sair', style: TextStyle(color: cs.error)),
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará fazer login novamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await Get.find<SessionService>().clear(); // apaga access/refresh
      Get.offAllNamed('/login');                // volta pro login e limpa a pilha
    }
  }

  void _showThemeSheet(BuildContext context) {
    final c = Get.find<ThemeController>();
    showModalBottomSheet(
      context: context,
      builder: (_) => Obx(() {
        final m = c.themeMode.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
                title: const Text('Seguir sistema'),
                value: ThemeMode.system, groupValue: m, onChanged: (v) => c.set(v!)),
            RadioListTile(
                title: const Text('Claro'),
                value: ThemeMode.light, groupValue: m, onChanged: (v) => c.set(v!)),
            RadioListTile(
                title: const Text('Escuro'),
                value: ThemeMode.dark, groupValue: m, onChanged: (v) => c.set(v!)),
          ],
        );
      }),
    );
  }
}