import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

var appSettingsProvider =
    StateNotifierProvider<AppSettingsStateNotifier, AppSettingsState>(
        (ref) => AppSettingsStateNotifier());

@immutable
class AppSettingsState {
  const AppSettingsState({required this.geminiApiKey, required this.isLoading});

  final String geminiApiKey;
  final bool isLoading;

  copyWith({String? geminiApiKey, bool? isLoading}) {
    return AppSettingsState(
        geminiApiKey: geminiApiKey ?? this.geminiApiKey,
        isLoading: isLoading ?? this.isLoading);
  }
}

class AppSettingsStateNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsStateNotifier()
      : super(const AppSettingsState(geminiApiKey: '', isLoading: true)) {
    init();
  }

  init() async {
    log("INITIALIZING APP SETTINGS PROVIDER");
    await getApiKey();
    log("INITIALIZED APP SETTINGS PROVIDER");
  }

  getApiKey() async {
    var storage = await SharedPreferences.getInstance();
    String apiKey = storage.getString('gemini_api_key') ?? '';
    state = state.copyWith(geminiApiKey: apiKey, isLoading: false);
  }

  Future<bool> setApiKey(String apiKey) async {
    var storage = await SharedPreferences.getInstance();
    var isSet = await storage.setString('gemini_api_key', apiKey);
    if (isSet) {
      state = state.copyWith(geminiApiKey: apiKey, isLoading: false);
    }
    return isSet;
  }
}
