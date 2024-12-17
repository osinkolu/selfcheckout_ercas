import "package:flutter/material.dart";
class BackgroundDisplay extends StatefulWidget {
  const BackgroundDisplay({super.key});

  @override
  State<BackgroundDisplay> createState() => _BackgroundDisplayState();
}

class _BackgroundDisplayState extends State<BackgroundDisplay> {
  @override
  Widget build(BuildContext context) {
    double widthy = MediaQuery.of(context).size.width;
    double heighty = MediaQuery.of(context).size.height;
    return Container(
      height: heighty,
      width: widthy,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Color.fromARGB(255, 67, 18, 74),
            Color.fromARGB(255, 242, 12, 47),
            Color.fromARGB(255, 32, 3, 33),
            Color.fromARGB(255, 25, 28, 33),
            Color.fromARGB(255, 25, 28, 33),
          ],
        )
      ),
    );
  }
}
