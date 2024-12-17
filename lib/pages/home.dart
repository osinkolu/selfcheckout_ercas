import "package:flutter/material.dart";
import "backgroundDisplay.dart";
import "mainScreen.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double widthy = MediaQuery.of(context).size.width;
    double heighty = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: heighty,
        width: widthy,
        child: Stack(
          children: [
            BackgroundDisplay(),
            MainScreen()
          ],
        ),
      ),
    );
  }
}
