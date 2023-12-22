import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:google_gemini/google_gemini.dart';

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

  getFromText(String prompt) async {
    addMessage(types.TextMessage(
        author: state.users[0],
        id: DateTime.now().toString(),
        text: prompt,
        createdAt: DateTime.now().millisecondsSinceEpoch));
    state = state.copyWith(isTyping: true);
    var gemini =
        GoogleGemini(apiKey: ref.read(appSettingsProvider).geminiApiKey);
    var res = await gemini.generateFromText(prompt);
    log(res.toString());
    addMessage(types.TextMessage(
        author: state.users[1],
        id: DateTime.now().toString(),
        text: res.text,
        createdAt: DateTime.now().millisecondsSinceEpoch));
    state = state.copyWith(isTyping: false);
  }
}
