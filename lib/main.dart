import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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
      home: const MyHomePage(title: 'Start To Grow'),
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
}
