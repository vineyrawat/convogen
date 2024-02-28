import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:convogen/screens/chat.dart';
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
  int currentIndex = 0;
  final _pageController = PageController(initialPage: 0);

  void onChatPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }

  List<Widget> pages = [const ChatPage(), const SettingsScreen()];

  List<NavItem> navItems = [
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
            onPressed: () {
              onChatPageChanged(1);
            },
            icon: const Icon(CupertinoIcons.settings),
          )
        ],
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        title: const ApplicationLogo(
          height: 30,
        ),
        // shadowColor: Colors.blueAccent,
      ),
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
    );
  }
}

class NavItem {
  String label;
  IconData icon;
  IconData activeIcon;
  NavItem({required this.label, required this.icon, required this.activeIcon});
}
