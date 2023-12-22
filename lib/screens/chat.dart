import "package:flutter/material.dart";
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/gemini_chat_provider.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var geminiChat = ref.watch(geminiChatProvider);

    if (geminiChat is InitialLoadingState) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.blueAccent, size: 50),
      );
    }

    return Chat(
        inputOptions: InputOptions(
          enabled: !geminiChat.isTyping,
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
        messages: geminiChat.messages,
        onSendPressed: (p0) async {
          await ref.read(geminiChatProvider.notifier).getFromText(p0.text);
        },
        typingIndicatorOptions: TypingIndicatorOptions(
          typingMode: TypingIndicatorMode.name,
          typingUsers: geminiChat.isTyping ? [geminiChat.users[0]] : [],
        ),
        user: geminiChat.users[0]);
  }
}
