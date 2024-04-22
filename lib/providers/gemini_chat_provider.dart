import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

var geminiChatProvider =
    StateNotifierProvider<GeminiChatProvider, GeminiChatState>(
        (ref) => GeminiChatProvider(ref));

@immutable
class GeminiChatState {
  final bool isLoading;
  final List<types.Message> messages;
  final bool isTyping;
  final List<types.User> users = const [
    types.User(id: '1', firstName: 'Gemini', role: types.Role.user),
    types.User(id: '2', firstName: 'User', role: types.Role.user)
  ];

  const GeminiChatState(
      {required this.isLoading,
      required this.messages,
      required this.isTyping});
  copyWith({bool? isLoading, List<types.Message>? messages, bool? isTyping}) {
    return GeminiChatState(
        isTyping: isTyping ?? this.isTyping,
        isLoading: isLoading ?? this.isLoading,
        messages: messages ?? this.messages);
  }
}

class InitialLoadingState extends GeminiChatState {
  InitialLoadingState() : super(isLoading: true, messages: [], isTyping: false);
}

class GeminiChatProvider extends StateNotifier<GeminiChatState> {
  final StateNotifierProviderRef<GeminiChatProvider, GeminiChatState> ref;

  GeminiChatProvider(this.ref) : super(InitialLoadingState()) {
    init();
  }

  set isLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  set isTyping(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }

  reset() {
    state = state.copyWith(isLoading: false, messages: [], isTyping: false);
  }

  init() async {
    // create a timeout
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isLoading: false);
  }

  addMessage(types.Message message) {
    state = state.copyWith(messages: [message, ...state.messages]);
  }

  addMessages(List<types.Message> messages) {
    state = state.copyWith(messages: [
      ...messages.reversed,
      ...state.messages,
    ]);
  }

  clearMessages() {
    state = state.copyWith(messages: []);
  }

  setMessages(List<types.Message> messages) {
    state = state.copyWith(messages: messages);
  }

  getPrompt(String prompt, XFile? result) async {
    var model = GenerativeModel(
        model: result == null ? 'gemini-pro' : 'gemini-pro-vision',
        apiKey: ref.read(appSettingsProvider).geminiApiKey);
    var filteredMessage = state.messages.whereType<types.TextMessage>();
    // return;
    var history = filteredMessage
        .map((dynamic e) => e.author == state.users[1]
            ? Content.model([TextPart(e.text)])
            : Content.text(e.text))
        .toList()
        .reversed
        .toList();

    var chat = model.startChat(history: history);
    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      addMessage(types.ImageMessage(
        name: result.name,
        size: bytes.length,
        author: state.users[0],
        id: DateTime.now().toString(),
        uri: result.path,
        height: image.height.toDouble(),
        width: image.width.toDouble(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    addMessage(types.TextMessage(
        author: state.users[0],
        id: DateTime.now().toString(),
        text: prompt,
        createdAt: DateTime.now().millisecondsSinceEpoch));

    state = state.copyWith(isTyping: true);

    try {
      if (prompt.isEmpty && result == null) return;
      if (result != null) {}
      var res = result == null
          ? await chat.sendMessage(Content.text(prompt))
          : await model.generateContent([
              Content.multi([
                TextPart(prompt),
                ...[DataPart("image/jpeg", await result.readAsBytes())]
              ])
            ]);
      log(res.text!);
      addMessage(types.TextMessage(
          author: state.users[1],
          id: DateTime.now().toString(),
          text: res.text ?? "No response",
          createdAt: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      addMessage(types.TextMessage(
        author: state.users[1],
        id: DateTime.now().toString(),
        text: e.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      log(e.toString());
    }
    state = state.copyWith(isTyping: false);
  }
}
