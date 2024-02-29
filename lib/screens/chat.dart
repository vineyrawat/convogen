import "package:flutter/material.dart";
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/gemini_chat_provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shimmer/shimmer.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var geminiChat = ref.watch(geminiChatProvider);

    if (geminiChat is InitialLoadingState) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.teal, size: 50),
      );
    }

    return Chat(
        customStatusBuilder: (message, {required context}) {
          return const SizedBox();
        },
        emptyState: EmptyStateWidget(onSendPressed: (p0) async {
          FocusManager.instance.primaryFocus?.unfocus();
          await ref.read(geminiChatProvider.notifier).getFromText(p0);
        }),
        theme: Theme.of(context).brightness == Brightness.dark
            ? DarkChatTheme(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                primaryColor: Theme.of(context).colorScheme.primary,
                secondaryColor: Theme.of(context).canvasColor,
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
        onSendPressed: (p0) async {},
        customBottomWidget: CustomBottomInputBar(onSendPressed: (p0) async {
          FocusManager.instance.primaryFocus?.unfocus();
          await ref.read(geminiChatProvider.notifier).getFromText(p0);
        }),
        typingIndicatorOptions: TypingIndicatorOptions(
          customTypingIndicator: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: 200.0,
              child: Shimmer.fromColors(
                  baseColor: Colors.blueGrey.withAlpha(100),
                  highlightColor: Colors.tealAccent.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...[1, 2, 3]
                          .map((i) => Container(
                                width: i == 3 ? 100 : 200,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(100),
                                    borderRadius: BorderRadius.circular(20)),
                                margin: const EdgeInsets.only(bottom: 10),
                              ))
                          .toList()
                    ],
                  )),
            ),
          ),
          typingMode: TypingIndicatorMode.name,
          typingUsers: geminiChat.isTyping ? [geminiChat.users[0]] : [],
        ),
        user: geminiChat.users[0]);
  }
}

class EmptyStateWidget extends StatelessWidget {
  final Function onSendPressed;
  const EmptyStateWidget({super.key, required this.onSendPressed});

  @override
  Widget build(BuildContext context) {
    String getGreeting() {
      var hour = DateTime.now().hour;

      if (hour < 12) {
        return 'Good morning';
      } else if (hour < 17) {
        return 'Good afternoon';
      } else {
        return 'Good evening';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GradientText(
            getGreeting(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 30.0,
            ),
            colors: const [
              Colors.blue,
              Colors.teal,
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(
                width: 20,
              ),
              ...[
                "Settle a debate: how should you store a bread?",
                "Help explaina  concept in a kid-friendly way",
                "Make a content strategy for a newsletter featuring free local weekend events"
              ]
                  .map((e) => SizedBox(
                        height: 150,
                        width: 200,
                        child: InkWell(
                          onTap: () => onSendPressed(e),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text(e, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              const SizedBox(
                width: 20,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                ...[
                  "Cloud gaming",
                  "Fastest way to learn Python",
                  "DSA Courses"
                ]
                    .map((e) => InkWell(
                          onTap: () => onSendPressed(e),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.history_outlined),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(e,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis)),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class CustomBottomInputBar extends StatelessWidget {
  final bool collapsed;
  final Function onSendPressed;
  const CustomBottomInputBar(
      {super.key, this.collapsed = false, required this.onSendPressed});

  @override
  Widget build(BuildContext context) {
    var inputController = TextEditingController();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // height: 100,
      decoration: BoxDecoration(
        // boxShadow: const [BoxShadow(blurRadius: 5, offset: Offset(0, 8))],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                onSubmitted: (value) {
                  onSendPressed(inputController.text);
                },
                controller: inputController,
                decoration: InputDecoration(
                    hintStyle: const TextStyle(
                      fontSize: 18,
                    ),
                    hintText: 'Type, talk, or share \na photo',
                    hintMaxLines: 2,
                    suffix: IconButton(
                        onPressed: () {
                          onSendPressed(inputController.text);
                        },
                        icon: const Icon(Icons.send_rounded)),
                    border: InputBorder.none)),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  // color: Colors.red,
                  style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(8))),
                  onPressed: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mic_none_outlined)),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
