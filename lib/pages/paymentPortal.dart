import "package:flutter/material.dart";
import 'package:tab_container/tab_container.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "utils_datum.dart";
import 'package:uuid/uuid.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart';

class Paymentportal extends StatefulWidget {
  final double totalAmount;

  const Paymentportal({super.key, required this.totalAmount});

  @override
  State<Paymentportal> createState() => _PaymentportalState();
}

class _PaymentportalState extends State<Paymentportal> with SingleTickerProviderStateMixin {
  late final TabController _controller;
  Map _userInfo ={};
  Map _storeInfo ={};
  @override
  void initState() {
    _userInfo = userInfo;
    _storeInfo = storeInfo;
    super.initState();
    _controller = TabController(vsync: this, length: 2);
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // intiate Transaction
  Future<Map<String, dynamic>> initiatePayment() async {
    final url = Uri.parse("https://api.merchant.staging.ercaspay.com/api/v1/payment/initiate");

    // Headers
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer ${api_secret}"
    };

    // Request body
    final body = json.encode({
      "amount": widget.totalAmount,
      "paymentReference": "${Uuid().v1()}",
      "paymentMethods": "bank-transfer,card",
      "customerName": "${_userInfo['name']}",
      "customerEmail": "${_userInfo['email']}",
      "customerPhoneNumber": "${_userInfo['phoneNumber']}",
      "redirectUrl": "https://selfCheckout.com",
      "description": "payment for shoping on selfCheckout",
      "currency": "${_storeInfo['currency']}",
      "feeBearer": "customer",
      "metadata": {
        "firstname": "${_userInfo['name']}",
        "lastname": "${_userInfo['name']}",
        "email": "${_userInfo['email']}"
      }
    });
    try {
      // Send the POST request
      final response = await http.post(url, headers: headers, body: body);

      // Check the response status and return the response as a map
      if (response.statusCode == 200) {
        return json.decode(response.body); // Parse the response body as a map
      } else {
        return {
          'error': 'Failed to initiate payment',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'error': 'Exception: $e',
      };
    }
  }
  // initialize bank transfer
  Future<Map<String, dynamic>> initializeBankTransfer(String trx_ref) async {
    final url = Uri.parse("https://api.merchant.staging.ercaspay.com/api/v1/payment/bank-transfer/request-bank-account/${trx_ref}");

    // Headers
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer ${api_secret}"
    };

    // Request body
    final body = json.encode({
    });
    try {
      // Send the POST request
      final response = await http.get(url, headers: headers);

      // Check the response status and return the response as a map
      if (response.statusCode == 200) {
        return json.decode(response.body); // Parse the response body as a map
      } else {
        return {
          'error': 'Failed to initiate payment',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'error': 'Exception: $e',
      };
    }
  }
  // verify transaction
  // Future<Map<String, dynamic>> vertifyTransaction(String trx_ref) async {
  //   final url = Uri.parse("https://api.merchant.staging.ercaspay.com/api/v1/payment/transaction/verify/${trx_ref}");
  //
  //   final headers = {
  //     "Accept": "application/json",
  //     "Content-Type": "application/json",
  //     "Authorization": "Bearer ${api_secret}"
  //   };
  //   try {
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       return {
  //         'error': 'Failed to initiate payment',
  //         'statusCode': response.statusCode,
  //         "data": json.decode(response.body)
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'error': 'Exception: $e',
  //     };
  //   }
  // }
  bool _isVerifyingTransaction = false;
  bool _isTransactionComplete = false;
  Future<Map<String, dynamic>> verifyTransaction(String trxRef) async {
    setState(() {
      _isVerifyingTransaction = true;
    });
    final url = Uri.parse(
        "https://api.merchant.staging.ercaspay.com/api/v1/payment/transaction/verify/$trxRef");

    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer ${api_secret}"
    };

    // final startTime = DateTime.now();

    try {
      while (true) {
        print(1);
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print(responseData);
          if (responseData['responseBody']?['status'] == 'SUCCESSFUL') {
            setState(() {
              _isVerifyingTransaction = false;
              _isTransactionComplete = true;
            });
            return {
              'status': 'success',
              'data': responseData,
            };

          } else {
            print(
                "Transaction status: ${responseData['responseBody']?['status']} - Retrying...");
          }
        } else {
          print("Request failed with status: ${response.statusCode}");
          return {
            'error': 'Failed to verify transaction',
            'statusCode': response.statusCode,
            'data': json.decode(response.body),
          };
        }
        // final elapsed = DateTime.now().difference(startTime).inSeconds;
        // if (elapsed >= timeoutSeconds) {
        //   return {
        //     'error': 'Timeout: Transaction verification took too long',
        //     'elapsed': '$elapsed seconds',
        //   };
        // }
        // await Future.delayed(Duration(seconds: intervalSeconds));
      }
    } catch (e) {

      return {
        'error': 'Exception: $e',
      };
    }
  }

Map _bankDetails = {};
  bool _bankLoading = false;
  bool _isbankRouteSuccess = true;
  String _bankTrxRef = "";
  void bankTransferRoute() async{
    setState(() {
      _bankLoading = true;
    });
     var res1 = await initiatePayment();
     print(res1);
     print(res1['responseCode']);
     if (res1['responseCode'] == "success"){
       var res2 = await initializeBankTransfer(res1["responseBody"]["transactionReference"]);
       print(res2);
       if (res2['responseCode'] == "success"){
         setState(() {
           _bankDetails = res2["responseBody"];
           _bankTrxRef = res2["responseBody"]["transactionReference"];
           _bankLoading = false;
         });
       }else{
         setState(() {
           _bankLoading = false;
           _isbankRouteSuccess = false;
         });
       }
     }else{
       setState(() {
         _bankLoading = false;
         _isbankRouteSuccess = false;
       });
     }
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
      margin: EdgeInsets.only(top: 15),
      child: AspectRatio(
        aspectRatio: 10 / 8,
        child: TabContainer(
          borderRadius: BorderRadius.circular(20),
          tabEdge: TabEdge.top,
          curve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            animation = CurvedAnimation(
                curve: Curves.easeIn, parent: animation);
            return SlideTransition(
              position: Tween(
                begin: const Offset(0.2, 0.0),
                end: const Offset(0.0, 0.0),
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          colors: const <Color>[
            Color.fromARGB(255, 38, 41, 48),
            Color.fromARGB(255, 38, 41, 48),
          ],
          selectedTextStyle:
          TextStyle(fontSize: 13,fontWeight: FontWeight.w900,color:Color.fromARGB(250, 255,255,255)),
          unselectedTextStyle:
          TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
          tabs: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.credit_card_rounded,color:Color.fromARGB(150, 255, 255, 255),size:20),
                  SizedBox(
                      width:5
                  ),
                  AutoSizeText(
                    textAlign: TextAlign.start,
                    "Debit card",
                    minFontSize: 5,
                    maxFontSize: 13,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
            ),
            InkWell(
              onTap: (){
                bankTransferRoute();
              },
              child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.money,color:Color.fromARGB(150, 255, 255, 255),size:20),
                    SizedBox(
                        width:5
                    ),
                    AutoSizeText(
                      textAlign: TextAlign.start,
                      "Bank transfer",
                      minFontSize: 5,
                      maxFontSize: 13,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
              )
            ),
          ],
          children: [
            Column(
              children: [
                SizedBox(
                    height:heighty*0.05
                ),
                Container(
                  margin: EdgeInsets.only(left:20,right:20),
                  height: heighty*0.05,
                  width: widthy,
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    textAlign: TextAlign.start,
                    "New Card Information",
                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.w900,color:Color.fromARGB(200, 255,255,255)),
                    minFontSize: 5,
                    maxFontSize: 13,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  height:heighty*0.15,
                  width: widthy,
                  margin:EdgeInsets.only(left:20,right:20),
                  decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color:Color.fromARGB(50, 255, 255, 255),width:1)
                  ),
                  child:Column(
                    children: [
                      Container(
                        height:((heighty*0.15)/2)-1.5,
                        width: widthy,
                          alignment:Alignment.centerLeft,
                          padding: EdgeInsets.only(left:10,right:10),
                          child:Row(
                            children:[
                              Expanded(
                                child:AutoSizeText(
                                  textAlign: TextAlign.start,
                                  "5123 2646 2696 1555",
                                  style: TextStyle(fontSize: 20,letterSpacing:3,fontWeight: FontWeight.w900,color:Color.fromARGB(250, 255,255,255)),
                                  minFontSize: 5,
                                  maxFontSize: 20,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ),
                              Container(
                                height:((heighty*0.15)/2)-1.5,
                                width: widthy*0.2,
                              )
                            ]
                          )
                      ),
                      Container(
                        height:1,
                        width: widthy,
                        color: Color.fromARGB(50, 255, 255, 255),
                      ),
                      Container(
                        height:((heighty*0.15)/2)-1.5,
                        width: widthy,
                        child: Row(
                          children:[
                            Container(
                              height:((heighty*0.15)/2)-1.5,
                              width: widthy*0.4,
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                textAlign: TextAlign.start,
                                "  Exp: 12/24",
                                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(250, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 15,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ),
                            Container(
                              height:((heighty*0.15)/2)-1.5,
                              width: 1,
                              color: Color.fromARGB(50, 255, 255, 255),
                            ),
                            Expanded(
                              child: AutoSizeText(
                                textAlign: TextAlign.start,
                                "    cvv: 181",
                                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(250, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 15,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ]
                        ),
                      )
                    ],
                  )
                ),
                Spacer(),
                InkWell(
                    onTap:(){

                    },
                    child:Container(
                        height: heighty*0.05,
                        width: widthy*0.7,
                        alignment:Alignment.center,
                        padding: EdgeInsets.only(left:5,right:5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:Color.fromARGB(255, 255, 77, 23),
                          // border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                        ),child:AutoSizeText(
                      textAlign: TextAlign.center,
                      "Pay NGN5,600",
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color:Color.fromARGB(250, 255,255,255)),
                      minFontSize: 5,
                      maxFontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    )),
                SizedBox(
                    height:heighty*0.03
                ),
                Container(
                    height:heighty*0.05,
                    width:widthy*0.8,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          height: heighty*0.04,
                          width: widthy*0.2,
                          alignment: Alignment.center,
                          child:AutoSizeText(
                            textAlign: TextAlign.start,
                            "Secured by",
                            style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(255, 255,255,255)),
                            minFontSize: 5,
                            maxFontSize: 13,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          height: heighty*0.04,
                          width: widthy*0.2,
                          decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage("assets/img/ercaslogo.png"),fit:BoxFit.contain),
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ],
                    )
                )
              ],
            ),
            _bankLoading?Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Colors.white,
                  size: 50,
                )) : _bankDetails.isEmpty?Container(

                child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Container(
                          height:heighty*0.25,
                          width:widthy,margin: EdgeInsets.only(left:30,right:30),
                          child: Image.asset("assets/img/empty_tray.png",fit:BoxFit.contain)
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
                            "Your network has nothing to offer",
                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                            minFontSize: 5,
                            maxFontSize: 15,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                      )
                    ]
                )
            ):_isVerifyingTransaction?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left:20,right:20),
                      height: heighty*0.06,
                      width: widthy,
                      alignment: Alignment.center,
                      child: AutoSizeText(
                        textAlign: TextAlign.center,
                        "Please wait we are verifying your transaction",
                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color:Color.fromARGB(150, 255,255,255)),
                        minFontSize: 5,
                        maxFontSize: 20,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height:20
                    ),
                    InkWell(
                        onTap:(){
                          Clipboard.setData(ClipboardData(text: "https://sandbox-checkout.ercaspay.com/${_bankTrxRef}"));
                        },
                        child:Container(
                        height: heighty*0.05,
                        width: widthy*0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 28, 31, 38),
                        ),
                        padding:EdgeInsets.only(left:10,right:10),
                        alignment:Alignment.center,
                        child:AutoSizeText(
                          textAlign: TextAlign.center,
                          "${_bankTrxRef}",
                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
                          minFontSize: 5,
                          maxFontSize: 15,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                    )),
                    SizedBox(
                        height:20
                    ),
                    Container(
                        height: heighty*0.05,
                        width: widthy*0.5,
                        alignment:Alignment.center,
                        child: LoadingAnimationWidget.stretchedDots(
                          color: Colors.white,
                          size: 50,
                        )
                    ),
                  ],
                ) :_isTransactionComplete?
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
            Container(
            margin: EdgeInsets.only(left:20,right:20),
      height: heighty*0.25,
      width: heighty*0.25,
      alignment: Alignment.center,
      child: Image.asset("assets/img/success.png",fit:BoxFit.contain),
    ),
    SizedBox(
    height:20,
      width:widthy
    ),
    InkWell(
    onTap:(){

    },
    child:Container(
    height: heighty*0.05,
    width: widthy*0.8,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: Color.fromARGB(255, 28, 31, 38),
    ),
    padding:EdgeInsets.only(left:10,right:10),
    alignment:Alignment.center,
    child:AutoSizeText(
    textAlign: TextAlign.center,
    "payment successful",
    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(200, 255,255,255)),
    minFontSize: 5,
    maxFontSize: 15,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    )
    )),])
                : Column(
                children:[
                  SizedBox(
                    height:heighty*0.05
                  ),
                  Container(
                    margin: EdgeInsets.only(left:20,right:20),
                    height: heighty*0.05,
                    width: widthy,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      "Expires in ${_bankDetails['expires_in']}",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color:Color.fromARGB(200, 255,255,255)),
                      minFontSize: 5,
                      maxFontSize: 20,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left:20,right:20),
                    height: heighty*0.06,
                    width: widthy,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      textAlign: TextAlign.center,
                      "Please transfer the exact amount into the provided account",
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(150, 255,255,255)),
                      minFontSize: 5,
                      maxFontSize: 15,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left:20,right:20),
                    height: heighty*0.15,
                    width: widthy,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          Container(
                              height: heighty*0.15,
                              width: widthy*0.3,
                              alignment: Alignment.centerLeft,
                              child:AutoSizeText(
                                textAlign: TextAlign.start,
                                "${_bankDetails['amount']}",
                                style: TextStyle(fontSize: 35,fontWeight: FontWeight.w900,color:Color.fromARGB(255, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 35,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                        ]
                    )
                  ),
                  Container(
                    height: 1,
                    width: widthy,
                    color:Color.fromARGB(100, 255, 255, 255)
                  ),
                  SizedBox(
                      height:20
                  ),
                  Container(
                    height: heighty*0.15,
                    width: widthy,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Icon(Iconsax.bank,color:Color.fromARGB(150, 255, 255, 255),size:heighty*0.1),
                        SizedBox(
                          width:10
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                height: heighty*0.03,
                                width: widthy*0.5,
                                alignment:Alignment.centerLeft,
                                child: AutoSizeText(
                                  textAlign: TextAlign.start,
                                  "${_bankDetails['bankName']}",
                                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color:Color.fromARGB(150, 255,255,255)),
                                  minFontSize: 5,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                            ),
                            InkWell(
                                onTap:(){
                                  Clipboard.setData(ClipboardData(text: "https://sandbox-checkout.ercaspay.com/${_bankTrxRef}"));
                                },
                                child:Container(
                              height: heighty*0.05,
                              width: widthy*0.5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromARGB(255, 28, 31, 38),
                              ),
                              padding:EdgeInsets.only(left:10,right:10),
                              alignment:Alignment.centerLeft,
                              child:AutoSizeText(
                                textAlign: TextAlign.start,
                                "${_bankDetails['accountNumber']}",
                                style: TextStyle(fontSize: 20,letterSpacing:3,fontWeight: FontWeight.w900,color:Color.fromARGB(200, 255,255,255)),
                                minFontSize: 5,
                                maxFontSize: 20,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            )),
                            Container(
                                height: heighty*0.05,
                                width: widthy*0.5,
                                alignment:Alignment.centerLeft,
                                child: AutoSizeText(
                                  textAlign: TextAlign.start,
                                  "${_bankDetails['accountName']}",
                                  style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color:Color.fromARGB(255, 255,255,255)),
                                  minFontSize: 5,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                            ),
                          ],
                        )
                      ]
                    ),
                  ),
                  Spacer(),
                  InkWell(
                      onTap:() async{
                        var res = await verifyTransaction(_bankTrxRef);
                      },
                      child:Container(
                          height: heighty*0.05,
                          width: widthy*0.7,
                          alignment:Alignment.center,
                          padding: EdgeInsets.only(left:5,right:5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:Color.fromARGB(255, 255, 77, 23),
                            // border: Border.all(width: 2,color:Color.fromARGB(100, 255, 255, 255))
                          ),child:AutoSizeText(
                        textAlign: TextAlign.center,
                        "I have made the transfer",
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color:Color.fromARGB(250, 255,255,255)),
                        minFontSize: 5,
                        maxFontSize: 15,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      )),
                  SizedBox(
                    height:heighty*0.03
                  ),
                  Container(
                    height:heighty*0.05,
                    width:widthy*0.8,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          height: heighty*0.04,
                          width: widthy*0.2,
                          alignment: Alignment.center,
                          child:AutoSizeText(
                            textAlign: TextAlign.start,
                            "Secured by",
                            style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color:Color.fromARGB(255, 255,255,255)),
                            minFontSize: 5,
                            maxFontSize: 13,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          height: heighty*0.04,
                          width: widthy*0.2,
                          decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage("assets/img/ercaslogo.png"),fit:BoxFit.contain),
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ],
                    )
                  )
                ]
            )
          ],
        ),
      ),

    );
  }
}
