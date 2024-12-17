import "package:flutter/material.dart";
import 'package:auto_size_text/auto_size_text.dart';

class Receipts extends StatefulWidget {
  const Receipts({super.key});

  @override
  State<Receipts> createState() => _ReceiptsState();
}

class _ReceiptsState extends State<Receipts> {


  OverlayEntry? _overlayEntry;

  void _showPopup(BuildContext context, String info, Offset position) {
    _hidePopup();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        double widthy = MediaQuery
            .of(context)
            .size
            .width;
        double heighty = MediaQuery
            .of(context)
            .size
            .height;
        return Positioned(
          top: position.dy - 50, // Slightly above the touch point
          left: position.dx - 50, // Centered horizontally with some adjustment
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 700),
              curve: Curves.elasticInOut,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              height: heighty*0.4,
              width: widthy*0.7,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 38, 41, 48),
                border: Border.all(
                  color:Color.fromARGB(55, 255, 255, 255),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Container(
                    height: (heighty*0.45)*0.4,
                    width: (widthy*0.7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment:Alignment.center,
                      children: [
                        Image.network("https://firebasestorage.googleapis.com/v0/b/checkoutmerchant-8cc2f.appspot.com/o/selfchk%2Fjuice.png?alt=media&token=e0a22980-56ff-442f-ba25-7a10244c8847",fit:BoxFit.contain),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              height: heighty*0.08,
                              width: heighty*0.08,
                              alignment:Alignment.center,
                              padding:EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color:Color.fromARGB(255, 38, 41, 48),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child:AutoSizeText(
                                textAlign: TextAlign.center,
                                "11",
                                style: TextStyle(fontSize: 50,fontWeight: FontWeight.w900,color:Color.fromARGB(200, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 50,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height:5),
                  Container(
                      alignment:Alignment.centerLeft,
                      height: (heighty*0.45)*0.1,
                      width: (widthy*0.7),
                      child: AutoSizeText(
                        textAlign: TextAlign.start,
                        "Berry Juice",
                        style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                        minFontSize: 5,
                        maxFontSize: 25,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                  ),
                  Container(
                      height: (heighty*0.45)*0.15,
                      width: (widthy*0.7),
                      child: AutoSizeText(
                        textAlign: TextAlign.start,
                        "Sweet berry blast juice 1lt. Made in Nigeria",
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                        minFontSize: 5,
                        maxFontSize: 15,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                  ),
                  Spacer(),
                  Container(
                    height: (heighty*0.45)*0.15,
                    width: (widthy*0.7),
                    child: Row(
                        children:[
                          Container(
                            height: (heighty*0.02),
                            width: widthy*0.07,
                            alignment:Alignment.centerRight,
                            child:AutoSizeText(
                              textAlign: TextAlign.end,
                              "NGN",
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color:Color.fromARGB(100, 255,255,255)),
                              minFontSize: 5,
                              maxFontSize: 20,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                              child:AutoSizeText(
                                textAlign: TextAlign.start,
                                "5,600.00",
                                style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 25,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                        ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    double widthy = MediaQuery
        .of(context)
        .size
        .width;
    double heighty = MediaQuery
        .of(context)
        .size
        .height;
    return Container(
        height: heighty,
        width: widthy,
        child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                height: heighty *0.3,
                width: widthy,
                margin: EdgeInsets.only(bottom: 30),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:Color.fromARGB(255, 38, 41, 48)
                ),
                child: Column(
                  children: [
                    Container(
                      height: heighty *0.08,
                      width: widthy,
                      child: Row(
                        children: [
                          Container(
                            height: heighty *0.08,
                            width: widthy*0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    height: heighty *0.04,
                                    width: widthy*0.5,
                                    child: Row(
                                        children:[
                                          Container(
                                            height: (heighty*0.02),
                                            width: widthy*0.07,
                                            alignment:Alignment.centerRight,
                                            child:AutoSizeText(
                                              textAlign: TextAlign.end,
                                              "NGN",
                                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color:Color.fromARGB(100, 255,255,255)),
                                              minFontSize: 5,
                                              maxFontSize: 20,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                              child:AutoSizeText(
                                                textAlign: TextAlign.start,
                                                "5,600.00",
                                                style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                                minFontSize: 5,
                                                maxFontSize: 25,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                          ),
                                        ]
                                    )
                                ),
                                Container(
                                    height: heighty *0.03,
                                    width: widthy*0.4,
                                    alignment:Alignment.center,
                                    decoration: BoxDecoration(
                                        color:Color.fromARGB(55, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: AutoSizeText(
                                      textAlign: TextAlign.center,
                                      "2 Nov.2024 @ 2:10PM",
                                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
                                      minFontSize: 5,
                                      maxFontSize: 13,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                )
                              ],
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: heighty *0.08,
                            width: widthy*0.3,
                            child:Column(
                              children:[
                                Spacer(),
                                Container(
                                  height: heighty *0.03,
                                  width: widthy*0.3,
                                  child: AutoSizeText(
                                    textAlign: TextAlign.center,
                                    "FoodCo RingRd.",
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(255, 255,255,255)),
                                    minFontSize: 5,
                                    maxFontSize: 15,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ),
                                Container(
                                  height: heighty *0.04,
                                  width: widthy*0.3,
                                  child: Row(
                                      children:[
                                        Container(
                                          height: heighty*0.04,
                                          width: widthy*0.15,
                                          alignment:Alignment.centerRight,
                                          child:AutoSizeText(
                                            textAlign: TextAlign.end,
                                            "34",
                                            style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                            minFontSize: 5,
                                            maxFontSize: 25,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width:5),
                                        Expanded(
                                            child:AutoSizeText(
                                              textAlign: TextAlign.start,
                                              "items",
                                              style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(100, 255,255,255)),
                                              minFontSize: 5,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                        ),
                                      ]
                                  )
                                ),
                              ]
                            )
                          ),
                        ],
                      )
                    ),
                    Spacer(),
                    Container(
                      height: heighty *0.17,
                      width: widthy,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color:Color.fromARGB(255, 28, 31, 38)
                      ),
                      child: ListView.builder(
                        scrollDirection:Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onLongPressStart: (details) {
                              _showPopup(context, 'Info about him', details.globalPosition);
                            },
                              onLongPressEnd: (details) {
                              _hidePopup();
                            },
                            child:Container(
                              height: heighty *0.15,
                              width: heighty *0.15,
                              margin:EdgeInsets.only(right: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:Color.fromARGB(255, 38, 41, 48)
                              ),
                              child: Column(
                                children: [
                                  Container(
                                      height: heighty *0.03,
                                      width: widthy,
                                      child: AutoSizeText(
                                        textAlign: TextAlign.start,
                                        "Berry juice",
                                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                        minFontSize: 5,
                                        maxFontSize: 15,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                  ),
                                  Spacer(),
                                  Container(
                                      height: heighty *0.08,
                                      width: widthy,
                                      child: Stack(
                                        alignment:Alignment.center,
                                        children: [
                                          Image.network("https://firebasestorage.googleapis.com/v0/b/checkoutmerchant-8cc2f.appspot.com/o/selfchk%2Fjuice.png?alt=media&token=e0a22980-56ff-442f-ba25-7a10244c8847",fit:BoxFit.contain),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                                height: heighty*0.03,
                                                width: heighty*0.03,
                                                alignment:Alignment.center,
                                                padding:EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    color:Color.fromARGB(255, 58, 41, 48),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child:AutoSizeText(
                                                  textAlign: TextAlign.center,
                                                  "11",
                                                  style: TextStyle(fontSize: 50,fontWeight: FontWeight.w900,color:Color.fromARGB(200, 255,255,255)),
                                                  minFontSize: 5,
                                                  maxFontSize: 50,
                                                  maxLines: 4,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  )
                                ],
                              ),
                            )
                          );
                        },
                      ) ,
                    )
                  ],
                ),
              );
            }
        )
    );
  }
}
