import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:convogen/providers/theme_provider.dart';
import 'package:provider/provider.dart' as provider;

import 'package:toastification/toastification.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var inputController = TextEditingController();
    var appSettings = ref.watch(appSettingsProvider);

    inputController.text = appSettings.geminiApiKey;

    log("NEW API KEY: ${inputController.text}");

    handleSave() {
      ref.read(appSettingsProvider.notifier).setApiKey(inputController.text);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(const SnackBar(content: Text("Saved")));
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: 'Settings Saved',
        description: 'New settings has been saved',
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
        boxShadow: lowModeShadow,
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: handleSave,
          label: const Text("Save Details"),
          icon: const Icon(CupertinoIcons.checkmark_alt_circle)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: inputController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: const Text("API Key"),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: inputController.text));
                    toastification.show(
                      context: context,
                      type: ToastificationType.success,
                      style: ToastificationStyle.flat,
                      title: 'Copied',
                      description: 'API key copied to clipboard',
                      alignment: Alignment.bottomCenter,
                      autoCloseDuration: const Duration(seconds: 4),
                      boxShadow: lowModeShadow,
                    );
                  },
                ),
                hintText: 'Add your gemini api key here',
                contentPadding: const EdgeInsets.all(15),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(CupertinoIcons.moon_stars),
              title: const Text("Dark Theme"),
              trailing: CupertinoSwitch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  provider.Provider.of<ThemeNotifier>(context, listen: false)
                      .toggleTheme();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
