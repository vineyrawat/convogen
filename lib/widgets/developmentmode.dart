import 'package:flutter/cupertino.dart';

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
