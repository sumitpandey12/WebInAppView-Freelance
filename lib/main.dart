import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'web_view_container.dart';
import 'atom_pay_helper.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start To Grow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, primary: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Start To Grow"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late InAppWebViewController _controller;
  double _progress = 0;

  // merchant configuration data
  final String login = "317157"; //mandatory
  final String password = 'Test@123'; //mandatory
  final String prodid = 'NSE'; //mandatory
  final String requestHashKey = 'KEY1234567234'; //mandatory
  final String responseHashKey = 'KEYRESP123657234'; //mandatory
  final String requestEncryptionKey =
      'A4476C2062FFA58980DC8F79EB6A799E'; //mandatory
  final String responseDecryptionKey =
      '75AEF0FA1B94B3C10D4F5B268F757F11'; //mandatory
  final String txnid =
      'test240223'; // mandatory // this should be unique each time
  final String clientcode = "NAVIN"; //mandatory
  final String txncurr = "INR"; //mandatory
  final String mccCode = "5499"; //mandatory
  final String merchType = "R"; //mandatory
  final String amount = "1.00"; //mandatory

  final String mode = "uat"; // change live for production

  final String custFirstName = 'test'; //optional
  final String custLastName = 'user'; //optional
  final String mobile = '8888888888'; //optional
  final String email = 'test@gmail.com'; //optional
  final String address = 'mumbai'; //optional
  final String custacc = '639827'; //optional
  final String udf1 = "udf1"; //optional
  final String udf2 = "udf2"; //optional
  final String udf3 = "udf3"; //optional
  final String udf4 = "udf4"; //optional
  final String udf5 = "udf5"; //optional

  final String authApiUrl = "https://caller.atomtech.in/ots/aipay/auth"; // uat

  // final String auth_API_url =
  //     "https://payment1.atomtech.in/ots/aipay/auth"; // prod

  final String returnUrl =
      "https://pgtest.atomtech.in/mobilesdk/param"; //return url uat
  // final String returnUrl =
  //     "https://payment.atomtech.in/mobilesdk/param"; ////return url production

  final String payDetails = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              accountName: Text("Sumit Pandey"),
              accountEmail: Text("sumitpandey@gmail.com"),
              currentAccountPicture: CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.wechat),
              title: const Text("WhatsApp"),
              onTap: () async {
                var contact = "+919874459293";
                var androidUrl =
                    "whatsapp://send?phone=$contact&text=Hi, I need some help";
                var iosUrl =
                    "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

                try {
                  if (Platform.isIOS) {
                    await launchUrl(Uri.parse(iosUrl));
                  } else {
                    await launchUrl(Uri.parse(androidUrl));
                  }
                } on Exception {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("WhatsApp are not install!"),
                  ));
                }
              },
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
            ),
            ListTile(
              leading: const Icon(
                Icons.phone,
                color: Colors.redAccent,
              ),
              title: const Text("Phone Call",
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                var url = Uri.parse("tel:9874459293");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Could not lunch $url"),
                  ));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment"),
              onTap: () => _initNdpsPayment(
                  context, responseHashKey, responseDecryptionKey),
            ),
            const ListTile(
              leading: Icon(Icons.login),
              title: Text("Logout"),
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: Center(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse("https://edts.in")),
              onWebViewCreated: (controller) => _controller,
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
            _progress < 1
                ? SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      )),
    );
  }

  void _initNdpsPayment(BuildContext context, String responseHashKey,
      String responseDecryptionKey) {
    _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey);
  }

  _getEncryptedPayUrl(context, responseHashKey, responseDecryptionKey) async {
    String reqJsonData = _getJsonPayloadData();
    debugPrint(reqJsonData);
    const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
    try {
      final String result = await platform.invokeMethod('NDPSAESInit', {
        'AES_Method': 'encrypt',
        'text': reqJsonData, // plain text for encryption
        'encKey': requestEncryptionKey // encryption key
      });
      String authEncryptedString = result.toString();
      // here is result.toString() parameter you will receive encrypted string
      // debugPrint("generated encrypted string: '$authEncryptedString'");
      _getAtomTokenId(context, authEncryptedString);
    } on PlatformException catch (e) {
      debugPrint("Failed to get encryption string: '${e.message}'.");
    }
  }

  _getAtomTokenId(context, authEncryptedString) async {
    var request = http.Request(
        'POST', Uri.parse("https://caller.atomtech.in/ots/aipay/auth"));
    request.bodyFields = {'encData': authEncryptedString, 'merchId': login};

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var authApiResponse = await response.stream.bytesToString();
      final split = authApiResponse.trim().split('&');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };
      final splitTwo = values[1]!.split('=');
      if (splitTwo[0] == 'encData') {
        const platform = MethodChannel('flutter.dev/NDPSAESLibrary');
        try {
          final String result = await platform.invokeMethod('NDPSAESInit', {
            'AES_Method': 'decrypt',
            'text': splitTwo[1].toString(),
            'encKey': responseDecryptionKey
          });
          debugPrint(result.toString()); // to read full response
          var respJsonStr = result.toString();
          Map<String, dynamic> jsonInput = jsonDecode(respJsonStr);
          if (jsonInput["responseDetails"]["txnStatusCode"] == 'OTS0000') {
            final atomTokenId = jsonInput["atomTokenId"].toString();
            debugPrint("atomTokenId: $atomTokenId");
            final String payDetails =
                '{"atomTokenId" : "$atomTokenId","merchId": "$login","emailId": "$email","mobileNumber":"$mobile", "returnUrl":"$returnUrl"}';
            _openNdpsPG(
                payDetails, context, responseHashKey, responseDecryptionKey);
          } else {
            debugPrint("Problem in auth API response");
          }
        } on PlatformException catch (e) {
          debugPrint("Failed to decrypt: '${e.message}'.");
        }
      }
    }
  }

  _openNdpsPG(payDetails, context, responseHashKey, responseDecryptionKey) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(
                mode, payDetails, responseHashKey, responseDecryptionKey)));
  }

  _getJsonPayloadData() {
    var payDetails = {};
    payDetails['login'] = login;
    payDetails['password'] = password;
    payDetails['prodid'] = prodid;
    payDetails['custFirstName'] = custFirstName;
    payDetails['custLastName'] = custLastName;
    payDetails['amount'] = amount;
    payDetails['mobile'] = mobile;
    payDetails['address'] = address;
    payDetails['email'] = email;
    payDetails['txnid'] = txnid;
    payDetails['custacc'] = custacc;
    payDetails['requestHashKey'] = requestHashKey;
    payDetails['responseHashKey'] = responseHashKey;
    payDetails['requestencryptionKey'] = requestEncryptionKey;
    payDetails['responseencypritonKey'] = responseDecryptionKey;
    payDetails['clientcode'] = clientcode;
    payDetails['txncurr'] = txncurr;
    payDetails['mccCode'] = mccCode;
    payDetails['merchType'] = merchType;
    payDetails['returnUrl'] = returnUrl;
    payDetails['mode'] = mode;
    payDetails['udf1'] = udf1;
    payDetails['udf2'] = udf2;
    payDetails['udf3'] = udf3;
    payDetails['udf4'] = udf4;
    payDetails['udf5'] = udf5;
    String jsonPayLoadData = getRequestJsonData(payDetails);
    return jsonPayLoadData;
  }
}
