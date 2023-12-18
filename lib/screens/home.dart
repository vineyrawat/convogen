import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_client/providers/app_settings_provider.dart';
import 'package:gemini_client/providers/theme_provider.dart';
import 'package:gemini_client/screens/chat.dart';
import 'package:gemini_client/screens/chats.dart';
import 'package:gemini_client/screens/settings.dart';
import 'package:provider/provider.dart' as provider;

class RootPage extends ConsumerStatefulWidget {
  const RootPage({
    super.key,
  });

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
  int currentIndex = 1;
  final _pageController = PageController(initialPage: 1);

  void onChatPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }

  List<Widget> pages = [
    const ChatsScreen(),
    const ChatPage(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    ref.read(appSettingsProvider);
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
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: ListTile(
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
                      );
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
