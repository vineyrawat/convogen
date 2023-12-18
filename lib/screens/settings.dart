import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var inputController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          TextField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              label: const Text("API Key"),
              hintText: 'Add your gemini api key here',
              contentPadding: const EdgeInsets.all(15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FilledButton(onPressed: () {}, child: const Text("Save"))
        ],
      ),
    );
  }
}
