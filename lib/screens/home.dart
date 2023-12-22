import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:convogen/screens/chat.dart';
import 'package:convogen/screens/chats.dart';
import 'package:convogen/screens/settings.dart';
import 'package:convogen/screens/splash.dart';

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

  List<NavItem> navItems = [
    NavItem(
        label: "Chats",
        icon: CupertinoIcons.chat_bubble_2,
        activeIcon: CupertinoIcons.chat_bubble_2_fill),
    NavItem(
        label: "Gemini",
        icon: CupertinoIcons.bolt,
        activeIcon: CupertinoIcons.bolt_fill),
    NavItem(
        label: "Settings",
        icon: CupertinoIcons.settings,
        activeIcon: CupertinoIcons.settings),
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
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.share),
            )
          ],
          toolbarHeight: 80,
          title: const ApplicationLogo(
            height: 30,
          ),
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
      body: LayoutBuilder(builder: (context, constrains) {
        if (constrains.maxWidth > 700) {
          return Row(
            children: [
              NavigationRail(
                labelType: NavigationRailLabelType.all,
                destinations: navItems
                    .map((e) => NavigationRailDestination(
                        icon: Icon(e.icon),
                        selectedIcon: Icon(e.activeIcon),
                        label: Text(e.label)))
                    .toList(),
                selectedIndex: currentIndex,
                onDestinationSelected: (value) {
                  onChatPageChanged(value);
                },
              ),
              const VerticalDivider(),
              Expanded(child: pages[currentIndex])
            ],
          );
        }
        return PageView(controller: _pageController, children: pages);
      }),
      bottomNavigationBar: MediaQuery.of(context).size.width > 700
          ? null
          : BottomNavigationBar(
              onTap: (index) => onChatPageChanged(index),
              currentIndex: currentIndex,
              items: navItems
                  .map((e) => BottomNavigationBarItem(
                      activeIcon: Icon(e.activeIcon),
                      icon: Icon(e.icon),
                      label: e.label))
                  .toList()),
    );
  }
}

class NavItem {
  String label;
  IconData icon;
  IconData activeIcon;
  NavItem({required this.label, required this.icon, required this.activeIcon});
}
