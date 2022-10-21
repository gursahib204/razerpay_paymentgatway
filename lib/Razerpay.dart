import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Razorpay razorpay;
  var msg;
  TextEditingController textEditingController = new TextEditingController();
  FocusNode textFocusController = FocusNode();

  @override
  void initState() {
    super.initState();

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => textFocusController.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Razor Pay"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: TextField(
                  focusNode: textFocusController,
                  cursorRadius: Radius.zero,
                  textAlign: TextAlign.center,
                  controller: textEditingController,
                  decoration: const InputDecoration(hintText: "Amount",),
                  style: const TextStyle(fontSize: 35.0),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                child: RaisedButton(
                  color: Colors.deepPurple,
                  child: Text(
                    "Pay",
                    style: const TextStyle(color: Colors.white,fontSize: 30),
                  ),
                  onPressed: () {
                    openCheckout();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print("Pament success");
    msg = "SUCCESS: " + response.paymentId!;
    showToast(msg);
  }
  void handlerErrorFailure(PaymentFailureResponse response) {
    msg = "ERROR: " + response.code.toString() + " - " + jsonDecode(response.message!)['error']['description'];
    showToast(msg);
  }
  void handlerExternalWallet(ExternalWalletResponse response) {
    msg = "EXTERNAL_WALLET: " + response.walletName!;
    showToast(msg);
  }

  void showToast(msg) {

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.withOpacity(0.1),
      textColor: Colors.black54,
    );
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_lZroAZTGs0e2iX",
      "amount": num.parse(textEditingController.text) * 100, // Convert Paisa to Rupees
      "name": "oms-infotech",
      "description": "This is a Test Payment",
      "timeout": "180",
      "theme.color": "#03be03",
      "currency": "INR",
      "prefill": {"contact": "9582821347", "email": "testByKamlesh@razorpay.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }
}
