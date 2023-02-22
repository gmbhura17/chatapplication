import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OnlinePaymentExample extends StatefulWidget {

  @override
  State<OnlinePaymentExample> createState() => _OnlinePaymentExampleState();
}

class _OnlinePaymentExampleState extends State<OnlinePaymentExample> {
  TextEditingController _amt = TextEditingController();

  void handlePaymentErrorResponse(PaymentFailureResponse response){
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */

    //API Order
    //Thank You Redirect
    //showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }
  void showAlertDialog(BuildContext context, String title, String message){
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed:  () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Payment "),
      ),
      body: Container(
        height: 400,
        width: 400,
        color: Colors.greenAccent,
        child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(
            child: Text(
            " Amount : ",
              style: TextStyle(fontSize: 20.0),
            )),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
              ),
            ),
            child: TextField(
              controller: _amt,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.name,
            ),
          ),
        ),
                ElevatedButton(onPressed: (){
                  var amt = _amt.text.toString();
                  Razorpay razorpay = Razorpay();
                  var options = {
                    'key': 'rzp_test_Tl4SYZLdp4SZIu',
                    'amount': double.parse(amt) * 100,
                    'name': 'Gulam',
                    'description': 'Fine T-Shirt',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
                    'external': {
                      'wallets': ['paytm']
                    }
                  };
                  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
                  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
                  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
                  razorpay.open(options);
                }, child: Text("Pay"))
        ]
      ),
    ),
    ),
    );
  }
}
