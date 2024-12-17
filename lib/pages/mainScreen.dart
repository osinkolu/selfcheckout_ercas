import "package:flutter/material.dart";
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'receipts.dart';
import 'paymentportal.dart';
import 'utils_datum.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final PageController _cartController = PageController(viewportFraction: 0.7);
  final TextEditingController _userInputController = TextEditingController();

  final MobileScannerController _scanController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    autoStart: false,
    torchEnabled: false,
  );

  BarcodeCapture? barcode;
  bool _torchstate = false;
  void _parsecode() {
    final firstBarcode = barcode?.barcodes.first.rawValue;
    _checkBarcode(firstBarcode!);
    print(firstBarcode!);
  }

  double _currentPage = 0.0;
  bool _openBottom = false;
  bool _showPaymentPortal = false;
  bool _showReceipts = false;
  bool _openCart = false;
  bool _isScanWindowActive = false;
  bool _isCheckingBarcode = false;

  Map _newProduct ={};



  List<Map> _userCart = [

  ];


  void _checkBarcode(String productBarcode) async {
    if (await Vibration.hasCustomVibrationsSupport() == true) {
      Vibration.vibrate(duration: 200);
    } else if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 200);
    }

    setState(() {
      _isCheckingBarcode = true;
    });

    // Find the product in the database
    final product = _productDatabase.firstWhere(
          (item) => item['barcode'] == productBarcode,
      orElse: () => {}, // Return an empty map if not found
    );

    // Check if the product was found
    if (product.isNotEmpty) {
      // Check if the product already exists in the user cart
      int existingIndex = _userCart.indexWhere(
            (cartItem) => cartItem['barcode'] == productBarcode,
      );

      if (existingIndex != -1) {
        // Increase the quantity if the product is already in the cart
        setState(() {
          _userCart[existingIndex]['quantity'] += 1;
          _isCheckingBarcode = false;
        });
      } else {
        // Add the product to the cart with an initial quantity of 1
        product["quantity"] = 1;
        setState(() {
          _newProduct = product;
        });
      }
    } else {
      print('Product with barcode $productBarcode not found in the database.');
      setState(() {
        _isCheckingBarcode = false;
      });
    }

    
  }


  String _formatnumber(dynamic number) {
    final numberFormatter = NumberFormat('#,###.00');
    return numberFormatter.format(number);
  }
  void _changequantity(String type, int itemIndex) {
    if (type == "add") {
      setState(() {
        _userCart[itemIndex]['quantity'] = _userCart[itemIndex]['quantity'] + 1;
      });
    }
    if ((type == "minus") && (_userCart[itemIndex]['quantity'] > 0)) {
      setState(() {
        _userCart[itemIndex]['quantity'] = _userCart[itemIndex]['quantity'] - 1;
      });
    }
  }
  double totalprice = 0;
  void _totalprice() {
    double tp = 0;
    if (_userCart.isNotEmpty) {
      for (int i = 0; i < _userCart.length; i++) {
        double price =
            (_userCart[i]['price'] + 0.0) * _userCart[i]['quantity'];
        tp = tp + price;
      }
    }
    setState(() {
      totalprice = tp;
    });
  }
  void _removeItem(int index){
    setState(() {
      _userCart.removeAt(index);
    });
    _totalprice();
  }


 Map _userInfo ={};
 Map _storeInfo ={};
 List<Map> _productDatabase =[];
  @override
  void initState() {
    _userInfo = userInfo;
    _storeInfo = storeInfo;
    _productDatabase = productDatabase;
    _scanController.stop();
    super.initState();
    _cartController.addListener(() {
      setState(() {
        _currentPage = _cartController.page!;
      });
    });
  }

  @override
  void dispose() {
    _cartController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthy = MediaQuery.of(context).size.width;
    double heighty = MediaQuery.of(context).size.height;
    _totalprice();
    return Container(
      height: heighty,
      width: widthy,
      child: Stack(
        children:[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: heighty*0.2,
                  width: widthy,
                  padding: EdgeInsets.only(left:15,right:15),
                  color: Color.fromARGB(0, 25, 28, 33),
                  child:Column(
                    children: [
                      SizedBox(
                        height:heighty*0.06,
                        width:widthy,
                      ),
                      Container(
                        height:heighty*0.06,
                        width:widthy,
                        child: Row(
                          children: [
                            Container(
                              height: heighty*0.04,
                              width: heighty*0.04,
                              decoration: BoxDecoration(
                                  color:Colors.grey,
                                  image: DecorationImage(image: NetworkImage("${_storeInfo['logo']}"),fit:BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            SizedBox(
                              width:5
                            ),
                            Expanded(
                              child:AutoSizeText(
                                textAlign: TextAlign.start,
                                "${_storeInfo['name']}",
                                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 20,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                                width:5
                            ),
                            Container(
                              height: heighty*0.05,
                              width: heighty*0.05,
                              decoration: BoxDecoration(
                                  color:Colors.grey,
                                image: DecorationImage(image: NetworkImage("${_userInfo['image']}"),fit:BoxFit.cover),
                                borderRadius: BorderRadius.circular(10)
                              ),
                            )
                          ],
                        )
                      ),
                      Spacer(),
                      Container(
                        height:heighty*0.06,
                        width:widthy,
                        child:Row(
                          children: [
                            Expanded(
                              child:Container(
                                height: heighty*0.06,
                                padding: EdgeInsets.only(left:15,right:15),
                                decoration: BoxDecoration(
                                    color:Color.fromARGB(55, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children:[
                                    Icon(Icons.tag,color:Color.fromARGB(150, 255, 255, 255),size:20),
                                    SizedBox(
                                        width:5
                                    ),
                                    Expanded(
                                      child:
                                      TextField(
                                        textAlign: TextAlign.start,
                                        onChanged: (val){

                                        },
                                        onSubmitted: (val){
                                          setState(() {
                                            _userInputController.clear();
                                          });
                                        },
                                        controller: _userInputController,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          hintText: "Enter store ID or scan Qr code",
                                          hintStyle: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
                                          border: InputBorder.none,
                                        ),
                                        cursorColor: Color.fromARGB(255, 248, 32, 79),
                                        cursorWidth: 3,
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(255, 255,255,255)),
                                      )
                                    ),
                                  ]
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: heighty*0.06,
                              width: heighty*0.06,
                              alignment:Alignment.center,
                              decoration: BoxDecoration(
                                  color:Color.fromARGB(55, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Icon(Icons.qr_code_2_rounded,color:Color.fromARGB(150, 255, 255, 255),size:20)
                            )
                          ],
                        )
                      ),
                      Spacer()
                    ],
                  )
                ),
                Container(
                  height: heighty*0.7,
                  width: widthy,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 25, 28, 33),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                    border: Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 59, 52, 66), // Border color
                        width: 2.0, // Border width
                      ),
                    ),
                  ),
                  child:Column(
                    children:[
                      Container(
                        height: heighty*0.1,
                        width: widthy,
                        margin: EdgeInsets.only(left:15,right:15),
                        child:Row(
                          children:[
                            InkWell(
                                onTap:(){
                                  setState(() {
                                    _openCart = !_openCart;
                                  });
                                },
                                child:Container(
                                height: heighty*0.075,
                                width: widthy*0.57,
                                alignment:Alignment.centerRight,
                                child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                  Expanded(child:
                                    AutoSizeText(
                                      textAlign: TextAlign.start,
                                      "view cart",
                                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                      minFontSize: 5,
                                      maxFontSize: 20,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ),
                                  SizedBox(height:13),
                                      _userCart.length >0? AvatarStack(
                                  height: heighty*0.04,
                                  avatars: [
                                    for (var n = 0; n < _userCart.length; n++)
                                      NetworkImage("${_userCart[n]['image']}"),
                                  ],
                                ):Container(
                                        height: heighty*0.04,
                                        width:widthy,
                                          alignment:Alignment.center,
                                          padding: EdgeInsets.only(left:5,right:5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color:Color.fromARGB(20, 255, 255, 255),
                                            // border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                                          ),child:Row(
                                          children:[
                                            Icon(Icons.shopping_cart_outlined,color:Color.fromARGB(150, 255, 255, 255),size:20),
                                            SizedBox(width:5),
                                            Expanded(
                                                child:AutoSizeText(
                                                  textAlign: TextAlign.center,
                                                  "empty cart",
                                                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
                                                  minFontSize: 5,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                            )
                                          ]
                                      )
                                      )
                                    ])
                            )),
                            Spacer(),
                            Container(
                              height: heighty*0.03,
                              width: 1,
                              color:Color.fromARGB(100, 255, 255, 255)
                            ),
                            SizedBox(width:20),
                            Container(
                                height: heighty*0.075,
                                width: widthy*0.25,
                                alignment:Alignment.centerRight,
                                child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children:[
                                      Expanded(child:
                                        AutoSizeText(
                                          textAlign: TextAlign.end,
                                          "settings",
                                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                          minFontSize: 5,
                                          maxFontSize: 20,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ),
                                      SizedBox(height:5),
                                      Row(
                                        children:[
                                          Spacer(),
                                          InkWell(
                                            onTap:(){
                                              if(_isScanWindowActive){
                                                _scanController.switchCamera();
                                              }
                                            },
                                            child: Container(
                                                height: heighty*0.05,
                                                width: heighty*0.05,
                                                alignment:Alignment.center,
                                                decoration: BoxDecoration(
                                                    color:Color.fromARGB(20, 255, 255, 255),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Icon(Icons.flip_camera_android_rounded,color:Color.fromARGB(150, 255, 255, 255),size:20)
                                            )
                                          ),
                                          SizedBox(width:10),
                                          InkWell(
                                              onTap:(){
                                                if(_isScanWindowActive) {
                                                  _scanController.toggleTorch();
                                                  setState(() {
                                                    _torchstate = !_torchstate;
                                                  });
                                                }
                                              },
                                              child:Container(
                                              height: heighty*0.05,
                                              width: heighty*0.05,
                                              alignment:Alignment.center,
                                              decoration: BoxDecoration(
                                                  color:!_torchstate ?Color.fromARGB(20, 255, 255, 255):Color.fromARGB(255, 255, 255, 255),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Icon(Icons.flashlight_on_rounded,color:!_torchstate?Color.fromARGB(150, 255, 255, 255):Color.fromARGB(255, 50, 50, 50),size:20)
                                          ))
                                        ]
                                      )
                                    ])
                            )
                          ]
                        )
                      ),
                      Expanded(
                        child:_openCart?
                        _userCart.length<1?
                            Container(
                              child:Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  Container(
                                    height:heighty*0.25,
                                    width:widthy*0.7,
                                    child: Image.asset("assets/img/empty_cart.png",fit:BoxFit.contain)
                                  ),
                                  SizedBox(
                                    height:20
                                  ),
                                  Container(
                                      height: heighty*0.03,
                                      width: widthy*0.6,
                                      alignment:Alignment.center,
                                      decoration: BoxDecoration(
                                      ),
                                      child:AutoSizeText(
                                        textAlign: TextAlign.center,
                                        "Your cart looks like this...",
                                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                        minFontSize: 5,
                                        maxFontSize: 15,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                  )
                                ]
                              )
                            )
                            :Container(
                          alignment:Alignment.center,
                          child: PageView.builder(
                            controller: _cartController,
                            itemCount: _userCart.length, // Number of items
                            itemBuilder: (context, index) {
                              double scale = (_currentPage - index).abs() < 1 ? 1.0 : 0.85;
                              return Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.elasticInOut,
                                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                                  height: scale * heighty*0.45,
                                  width: scale * widthy*0.7,
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

                                      InkWell(
                                        onTap:(){
                                          _removeItem(index);
                                        },
                                        child:Container(
                                            height: (scale * heighty*0.45)*0.1,
                                            width: (scale * widthy*0.7),
                                            child:Row(
                                                children:[
                                                  Expanded(
                                                      child:AutoSizeText(
                                                      textAlign: TextAlign.end,
                                                      "Remove",
                                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                                      minFontSize: 5,
                                                      maxFontSize: 15,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                )
                                                  ),
                                                  Icon(Icons.close_rounded,color:Color.fromARGB(200, 255, 255, 255),size:25),
                                            ])
                                        )
                                      ),

                                      Container(
                                          height: (scale * heighty*0.45)*0.4,
                                          width: (scale * widthy*0.7),
                                          decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          ),
                                        child: Stack(
                                          alignment:Alignment.center,
                                          children: [
                                            Image.network("${_userCart[index]['image']}",fit:BoxFit.contain),
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
                                                    "${_userCart[index]['quantity']}",
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
                                          height: (scale * heighty*0.45)*0.1,
                                          width: (scale * widthy*0.7),
                                        child: AutoSizeText(
                                          textAlign: TextAlign.start,
                                          "${_userCart[index]['name']}",
                                          style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                          minFontSize: 5,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                        ),
                                      Container(
                                          height: (scale * heighty*0.45)*0.15,
                                          width: (scale * widthy*0.7),
                                          child: AutoSizeText(
                                            textAlign: TextAlign.start,
                                            "${_userCart[index]['description']}",
                                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                            minFontSize: 5,
                                            maxFontSize: 15,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ),
                                      Spacer(),
                                      Container(
                                          height: (scale * heighty*0.45)*0.15,
                                          width: (scale * widthy*0.7),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: (scale * heighty*0.45)*0.15,
                                              width: (scale * widthy*0.7) * 0.45,
                                              child: Row(
                                                  children:[
                                                    Container(
                                                      height: (heighty*0.02),
                                                      width: widthy*0.07,
                                                      alignment:Alignment.centerRight,
                                                      child:AutoSizeText(
                                                        textAlign: TextAlign.end,
                                                        "${_storeInfo['currency']}",
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
                                                          "${_formatnumber(_userCart[index]['price'])}",
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
                                            InkWell(
                                                onTap:(){
                                                  _changequantity("add",index);
                                                },
                                                child:Container(
                                                    height: heighty*0.05,
                                                    width: heighty*0.05,
                                                    alignment:Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:Color.fromARGB(255, 250, 171, 0),
                                                        borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child: Icon(Icons.add,color:Color.fromARGB(150, 0, 0, 0),size:20)
                                                )),
                                            Spacer(),
                                            InkWell(
                                                onTap:(){
                                                  _changequantity("minus",index);
                                                },
                                                child:Container(
                                                    height: heighty*0.05,
                                                    width: heighty*0.05,
                                                    alignment:Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:Color.fromARGB(255,255, 200, 71),
                                                        borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child: Icon(Icons.remove,color:Color.fromARGB(150, 0, 0, 0),size:20)
                                                )),

                                          ],
                                        ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                            : Container(
                          alignment:Alignment.center,
                          child:Container(
                            height: heighty*0.5,
                            width: widthy*0.7,
                            alignment:Alignment.center,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(255, 38, 41, 48),
                                border: Border.all(
                                  color:Color.fromARGB(55, 255, 255, 255),
                                  width: 1,
                                )
                            ),
                            child: _newProduct.isNotEmpty?

                            Container(
                              
                              height:  heighty*0.45,
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

                                  InkWell(
                                      onTap:(){
                                        setState(() {
                                          _newProduct = {};
                                          _isCheckingBarcode = false;
                                        });
                                      },
                                      child:Container(
                                          height: (heighty*0.45)*0.1,
                                          width: (widthy*0.7),
                                          child:Row(
                                              children:[
                                                Expanded(
                                                    child:AutoSizeText(
                                                      textAlign: TextAlign.end,
                                                      "Cancel",
                                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                                                      minFontSize: 5,
                                                      maxFontSize: 15,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    )
                                                ),
                                                Icon(Icons.close_rounded,color:Color.fromARGB(200, 255, 255, 255),size:25),
                                              ])
                                      )
                                  ),

                                  Container(
                                    height: (heighty*0.45)*0.4,
                                    width: (widthy*0.7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Image.network("${_newProduct['image']}",fit:BoxFit.contain),
                                  ),
                                  SizedBox(height:5),
                                  Container(
                                      alignment:Alignment.centerLeft,
                                      height: (heighty*0.45)*0.1,
                                      width: (widthy*0.7),
                                      child: AutoSizeText(
                                        textAlign: TextAlign.start,
                                        "${_newProduct['name']}",
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
                                        "${_newProduct['description']}",
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
                                      children: [
                                        Container(
                                            height: (heighty*0.45)*0.15,
                                            width: (widthy*0.7) * 0.45,
                                            child: Row(
                                                children:[
                                                  Container(
                                                    height: (heighty*0.02),
                                                    width: widthy*0.07,
                                                    alignment:Alignment.centerRight,
                                                    child:AutoSizeText(
                                                      textAlign: TextAlign.end,
                                                      "${_storeInfo['currency']}",
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
                                                        "${_formatnumber(_newProduct['price'])}",
                                                        style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                                        minFontSize: 5,
                                                        maxFontSize: 25,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                  ),
                                                ]
                                            )
                                        ),Spacer(),
                                        InkWell(
                                            onTap:() async{
                                              setState(() {
                                                 _userCart.add(_newProduct);
                                                _newProduct = {};
                                                _isCheckingBarcode = false;
                                              });
                                            },
                                            child:Container(
                                                height: heighty*0.06,
                                                width: heighty*0.06,
                                                alignment:Alignment.center,
                                                decoration: BoxDecoration(
                                                    color:Color.fromARGB(255, 200, 31, 20),
                                                    borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Icon(Icons.check,color:Colors.white,size:20)
                                            )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                
                                :_isScanWindowActive? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:MobileScanner(
                                controller: _scanController,
                                onDetect: (barcode) {
                                  setState(() {
                                    this.barcode = barcode;
                                  });
                                  if (!_isCheckingBarcode) {
                                    _parsecode();
                                  }
                                },
                              )
                            ):Column(
                              children:[
                                Spacer(),
                                Container(
                                  height: heighty*0.2,
                                  width: widthy*0.7,
                                  child:Image.asset("assets/img/barcodeExample_2.png", fit:BoxFit.contain)
                                ),
                                Spacer(),
                                Container(
                                  height: heighty*0.1,
                                  width: widthy*0.7,
                                  child: AutoSizeText(
                                    textAlign: TextAlign.start,
                                    "activate the scan window, pick up the items you want to purchase, place the item barcodes in view of the scan window. Click pay once you are done",
                                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
                                    minFontSize: 5,
                                    maxFontSize: 13,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ),
                                Container(
                                    height: heighty*0.05,
                                    width: widthy*0.7,
                                    alignment:Alignment.centerLeft,
                                    child: Row(children:[Expanded(child:AutoSizeText(
                                      textAlign: TextAlign.start,
                                      "Activate Scan Window",
                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(250, 255,255,255)),
                                      minFontSize: 5,
                                      maxFontSize: 15,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),Icon(Icons.arrow_forward_ios_rounded,color:Color.fromARGB(200, 255, 255, 255),size:25),
                                    SizedBox(width:heighty*0.02)
                                    ])
                                ),
                              ]
                            )
                          )
                        )
                      ),
                      !_openCart? Container(): Container(
                        height: 10,
                        width: widthy,
                        alignment: Alignment.center,
                        child: SmoothPageIndicator(
                            controller: _cartController,
                            count:  _userCart.length<1?1:_userCart.length,
                            effect:  ExpandingDotsEffect(
                                dotWidth: 7,
                                dotHeight: 7,
                                dotColor: Color.fromARGB(20, 255, 255, 255),
                                activeDotColor: Color.fromARGB(200, 255, 255, 255)
                            ),
                            onDotClicked: (index){
                            }
                        )
                      ),
                      SizedBox(
                        height: heighty*0.03,
                      )
                    ]
                  )
                ),
                Container(
                  height: (heighty*0.1)+1,
                  width: widthy,
                  color: Color.fromARGB(255, 25, 28, 33),
                ),
              ],
            ),
          ),
          Container(
            height:heighty,
              width:widthy,
              child:Column(
            children:[
              Expanded(
                child: !_openBottom?Container(): InkWell(
                    onTap:(){
                      setState(() {
                        _openBottom = false;
                        _showReceipts = false;
                        _showPaymentPortal = false;
                      });
                    },
                  child:BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(10, 255, 255, 255),
                        ),
                      ))
                )
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                height: _openBottom?heighty*0.7 :heighty*0.1,
                width: widthy,
                padding: EdgeInsets.only(left:15,right:15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 25, 28, 33),
                  border: Border(
                    top: BorderSide(
                      color: Color.fromARGB(55, 255, 255, 255), // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                ),
                child:
                _showReceipts?Receipts()
                    :_showPaymentPortal?Paymentportal(totalAmount: totalprice):
                Row(
                    children:[
                      InkWell(
                          onTap:(){
                            setState(() {
                              _openBottom = true;
                              _showReceipts = true;
                              _showPaymentPortal = false;
                              _isScanWindowActive = false;
                              _scanController.stop();
                              _torchstate =false;
                            });
                          },
                          child:Container(
                              height: heighty*0.05,
                              width: widthy*0.25,
                              alignment:Alignment.center,
                              padding: EdgeInsets.only(left:5,right:5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:Color.fromARGB(20, 255, 255, 255),
                                // border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                              ),child:Row(
                              children:[
                                Icon(Iconsax.receipt,color:Color.fromARGB(150, 255, 255, 255),size:25),
                                SizedBox(width:5),
                                Expanded(
                                    child:AutoSizeText(
                                      textAlign: TextAlign.center,
                                      "receipts",
                                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(250, 255,255,255)),
                                      minFontSize: 5,
                                      maxFontSize: 15,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                )
                              ]
                          )
                          )),
                      SizedBox(width:15),
                      Expanded(
                        child:Row(
                            children:[
                              Container(
                                height: (heighty*0.02),
                                width: widthy*0.07,
                                alignment:Alignment.centerRight,
                                child:AutoSizeText(
                                  textAlign: TextAlign.end,
                                  "${_storeInfo['currency']}",
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
                                    "${_formatnumber(totalprice)}",
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
                      SizedBox(width:15),
                      InkWell(
                          onTap:(){
                            setState(() {
                              _openBottom = true;
                              _showReceipts = false;
                              _showPaymentPortal = true;
                              _isScanWindowActive = false;
                              _scanController.stop();
                              _torchstate =false;
                            });
                          },
                          child:Container(
                              height: heighty*0.05,
                              width: widthy*0.25,
                              alignment:Alignment.center,
                              padding: EdgeInsets.only(left:5,right:5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:Color.fromARGB(255, 242, 12, 47),
                                // border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                              ),child:Row(
                              children:[
                                Icon(Iconsax.wallet_1,color:Color.fromARGB(200, 255, 255, 255),size:25),
                                SizedBox(width:5),
                                Expanded(
                                    child:AutoSizeText(
                                      textAlign: TextAlign.center,
                                      "pay now",
                                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w900,color:Color.fromARGB(250, 255,255,255)),
                                      minFontSize: 5,
                                      maxFontSize: 13,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                ),
                              ]
                          )
                          )),
                    ]
                ),
              )
            ]
          )),
          Align(
            alignment:Alignment.bottomRight,
            child: _newProduct.isNotEmpty || _openBottom ?Container() :Container(
                  height: heighty*0.07,
                  width: heighty*0.07,
                  alignment:Alignment.center,
                  margin:EdgeInsets.only(bottom: heighty*0.15,right:20),
                  decoration: BoxDecoration(
                    // color:Color.fromARGB(255, 242, 12, 47),
                      color:_isScanWindowActive?Color.fromARGB(255, 50, 50, 50):Color.fromARGB(255, 0, 67, 252),
                      borderRadius: BorderRadius.circular((heighty*0.07)/2.5),
                      border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                  ),
                  child: InkWell(
                    onTap:(){
                        setState(() {
                          _isScanWindowActive = !_isScanWindowActive;
                        });
                        if(_isScanWindowActive){
                          _openCart =false;
                          _scanController.start();
                        }else{
                          _scanController.stop();
                          setState(() {
                            _torchstate =false;
                          });
                        }
                      
                    },
                      child:Icon(Iconsax.barcode,color:Color.fromARGB(255, 255, 255, 255),size:30)
                  )
              )
            
          )
        ]
      ),
    );
  }
}
