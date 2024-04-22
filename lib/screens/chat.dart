import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/gemini_chat_provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:toastification/toastification.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  XFile? selectedImage;

  @override
  Widget build(BuildContext context) {
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
        textMessageBuilder: (p0, {required messageWidth, required showName}) {
          if (p0.author.id == '1') {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(p0.text, style: const TextStyle(color: Colors.white)),
            );
          }
          return Markdown(
            data: p0.text,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          );
        },
        listBottomWidget: AnimatedContainer(
          height: geminiChat.isTyping ? 0 : 80,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0)
                .copyWith(bottom: 20),
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      ref.read(geminiChatProvider.notifier).reset();
                    },
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.bolt_circle,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 5),
                        const Text("Start New Chat"),
                      ],
                    )),
                IconButton(
                    onPressed: () {
                      var text =
                          (geminiChat.messages.first.toJson()["type"] == 'text')
                              ? geminiChat.messages.first.toJson()["text"]
                              : '';
                      log(text);
                      Clipboard.setData(ClipboardData(text: text));
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.flat,
                        title: const Text('Copied'),
                        description: const Text('Copied to clipboard'),
                        alignment: Alignment.bottomCenter,
                        autoCloseDuration: const Duration(seconds: 4),
                        boxShadow: lowModeShadow,
                      );
                    },
                    icon: Icon(Icons.copy_rounded,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        ),
        emptyState: EmptyStateWidget(onSendPressed: (p0) async {
          FocusManager.instance.primaryFocus?.unfocus();
          await ref
              .read(geminiChatProvider.notifier)
              .getPrompt(p0, selectedImage);
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
        customBottomWidget: CustomBottomInputBar(
            selectedImage: selectedImage,
            setImage: (XFile? image) {
              setState(() {
                selectedImage = image;
                log("SET IMAGE TO: ${image!.path}");
              });
            },
            onSendPressed: (p0) async {
              FocusManager.instance.primaryFocus?.unfocus();
              if (selectedImage != null) {
                var p = selectedImage;
                setState(() {
                  selectedImage = null;
                });
                await ref.read(geminiChatProvider.notifier).getPrompt(p0, p!);
              } else if (p0.isNotEmpty) {
                await ref
                    .read(geminiChatProvider.notifier)
                    .getPrompt(p0, selectedImage);
              }
              log("SEND PRESSED: $p0");
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

class CustomBottomInputBar extends StatefulWidget {
  final bool collapsed;
  final Function onSendPressed;
  final Function setImage;
  final XFile? selectedImage;
  const CustomBottomInputBar(
      {super.key,
      this.selectedImage,
      this.collapsed = false,
      required this.onSendPressed,
      required this.setImage});

  @override
  State<CustomBottomInputBar> createState() => _CustomBottomInputBarState();
}

class _CustomBottomInputBarState extends State<CustomBottomInputBar> {
  var inputController = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (result.finalResult) {
        inputController.text = _lastWords;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    handleMicPress() async {
      log("Mic Pressed");
      if (_speechEnabled) {
        _startListening();
      } else {
        // show snackbar
        log("Speech not enabled");
      }
    }

    handleCameraPressed() {
      log("Camera pressed");
      ImagePicker().pickImage(source: ImageSource.gallery).then((image) {
        if (image != null) {
          log("IMAGE SELECTED: ${image.path}");
          widget.setImage(image);
        }
      });
    }

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
                  widget.onSendPressed(inputController.text);
                  inputController.clear();
                },
                minLines: 1,
                maxLines: 5,
                controller: inputController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintStyle: const TextStyle(
                      fontSize: 18,
                    ),
                    hintText: _speechToText.isListening
                        ? 'Listening...'
                        : 'Type, talk, or share \na photo',
                    hintMaxLines: 2,
                    suffix: IconButton(
                        onPressed: () {
                          widget.onSendPressed(inputController.text);
                          inputController.clear();
                        },
                        icon: const Icon(Icons.send_rounded)),
                    border: InputBorder.none)),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.selectedImage != null
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(widget.selectedImage!.path),
                            width: 50,
                            height: 50,
                          ),
                        ),
                      )
                    : const SizedBox(),
                widget.selectedImage != null
                    ? IconButton(
                        onPressed: () => widget.setImage(null),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ))
                    : const SizedBox(),
                widget.selectedImage != null
                    ? const Spacer()
                    : const SizedBox(),
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
                      _speechToText.isListening
                          ? IconButton(
                              onPressed: () async {
                                _stopListening();
                              },
                              icon: const Icon(Icons.stop_circle_outlined))
                          : IconButton(
                              onPressed: handleMicPress,
                              icon: const Icon(Icons.mic_none_outlined)),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          onPressed: handleCameraPressed,
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
