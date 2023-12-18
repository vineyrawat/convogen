import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

void main() {
  runApp(ProviderScope(
    child: provider.ChangeNotifierProvider(
        create: (context) => ThemeNotifier(), child: const MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Client',
      themeMode: provider.Provider.of<ThemeNotifier>(context).themeMode,
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const Scaffold(body: RootPage()),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({
    super.key,
  });

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentIndex = 1;
  final _pageController = PageController(initialPage: 1);

  void onChatPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const DevelopmentMode(),
      const ChatPage(),
      const DevelopmentMode()
    ];
    _pageController.addListener(() {
      setState(() {
        currentIndex = _pageController.page!.round();
      });
    });

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.share),
            )
          ],
          leading: IconButton(
              onPressed: () {
                showBottomSheet(
                    enableDrag: true,
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      maxWidth: 500,
                    ),
                    context: context,
                    builder: (context) {
                      return Column(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text("Dark Theme"),
                          trailing: GestureDetector(
                            onTap: () {
                              provider.Provider.of<ThemeNotifier>(context,
                                      listen: false)
                                  .toggleTheme();
                            },
                            child: CupertinoSwitch(
                                value: Theme.of(context).brightness ==
                                    Brightness.dark,
                                onChanged: null),
                          ),
                        ),
                      ]);
                    });
              },
              icon: const Icon(CupertinoIcons.command)),
          toolbarHeight: 80,
          title: const Text('Gemini Client'),
          shadowColor: Colors.blueAccent,
          bottom: PreferredSize(
              preferredSize: Size.zero,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: currentIndex == 1 ? 10 : 0,
                color: Colors.blueAccent,
              )),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: currentIndex == 1 &&
                  Theme.of(context).brightness == Brightness.dark
              ? 30
              : 0),
      body: PageView(controller: _pageController, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => onChatPageChanged(index),
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2), label: "Chats"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bolt), label: "Gemini"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: "Settings")
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

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
          print(p0);
        },
        user: _user);
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class DevelopmentMode extends StatelessWidget {
  const DevelopmentMode({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle),
          SizedBox(
            height: 10,
          ),
          Text("Feature in development")
        ],
      ),
    );
  }
}
