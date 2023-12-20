import 'dart:developer';

import "package:flutter/material.dart";
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    firstName: "Gemini",
    lastName: "Client",
  );

  bool isTyping = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Chat(
        inputOptions: InputOptions(
          enabled: !isTyping,
          sendButtonVisibilityMode: SendButtonVisibilityMode.always,
        ),
        customStatusBuilder: (message, {required context}) {
          return const SizedBox();
        },
        theme: Theme.of(context).brightness == Brightness.dark
            ? DarkChatTheme(
                backgroundColor: Theme.of(context).canvasColor,
                primaryColor: Colors.black,
                secondaryColor: Colors.black,
                inputBackgroundColor: Colors.black,
              )
            : DefaultChatTheme(
                backgroundColor: Theme.of(context).canvasColor,
                primaryColor: Theme.of(context).colorScheme.primary,
                inputBackgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                inputTextColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        messages: _messages,
        onSendPressed: (p0) {
          log(p0.text);
        },
        typingIndicatorOptions: TypingIndicatorOptions(
          typingMode: TypingIndicatorMode.name,
          typingUsers: isTyping ? [_user] : [],
        ),
        user: _user);
  }
}
