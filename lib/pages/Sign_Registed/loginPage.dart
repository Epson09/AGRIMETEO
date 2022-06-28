import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tp_app/pages/Sign_Registed/signIn.dart';

import 'package:tp_app/service/auth.dart';

import 'package:tp_app/util/font/background.dart';

import 'package:url_launcher/url_launcher.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({Key? key}) : super(key: key);

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  //initialisation
  Future<FirebaseApp> _initialisefirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialisefirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const LoginScreen();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String domain = "@agrimeteo.com";
  String phoneNumber = '+22994772347';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> map = {};
  List<dynamic> list = [];
  //bool _laoding = true;
  openwhatsapp() async {
    var whatsapp = phoneNumber;
    var whatsappURl_android =
        "whatsapp://send?phone=" + whatsapp + "&text=hello";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatappURL_ios))) {
        // ignore: deprecated_member_use
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp non pas installer")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURl_android))) {
        // ignore: deprecated_member_use
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp non installé")));
      }
    }
  }

  openCalling() async {
    final call = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(call))) {
      // ignore: deprecated_member_use
      await launch(call);
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Inscription"),
            content: const Text("Contactez nous pour vous inscrire"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        openCalling();
                      },
                      icon: const Icon(Icons.call),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        openwhatsapp();
                      },
                      icon: const Icon(Icons.whatsapp_outlined),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  AuthService service = AuthService();
  final _usernameController = TextEditingController();
  final _passwordControler = TextEditingController();
  Widget buildPortrail() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Background(
            height: 430.0,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      //logo
                      Expanded(
                        flex: 6,
                        child: Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, right: 10),
                            child: Image.asset(
                              'assets/images/logo.png',
                            )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      Form(
                        child: Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 32, right: 32, top: 7.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Identifiant',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(183, 94, 171, 56),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                SizedBox(
                                  height: 45,
                                  child: TextField(
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      hintText: 'azoveC203',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFBABABA),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFBEC5D1),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFBEC5D1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                RichText(
                                  textAlign: TextAlign.right,
                                  text: const TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Code secret',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Color.fromARGB(183, 94, 171, 56),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                SizedBox(
                                  height: 45,
                                  child: TextField(
                                    controller: _passwordControler,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: '************',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFBABABA),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFBEC5D1),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Color(0xFFBEC5D1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        _showDialog(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: const Text(
                                          'S\'inscrire',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color.fromARGB(
                                                  183, 94, 171, 56)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MaterialButton(
                                        height: 40,
                                        minWidth: 285,
                                        color: const Color.fromARGB(
                                            183, 94, 171, 56),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        child: const Text(
                                          'Se connecter',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          String email = "";
                                          if (_usernameController
                                                  .text.isNotEmpty &&
                                              _passwordControler
                                                  .text.isNotEmpty) {
                                            email = _usernameController.text +
                                                domain;
                                            service.loginUser(context, email,
                                                _passwordControler.text);
                                            firestore
                                                .collection('userData')
                                                .doc(auth.currentUser!.uid)
                                                .update({
                                              "users":
                                                  FieldValue.arrayUnion(list)
                                            });
                                          } else {
                                            service.errorBox(context,
                                                'Remplissez tous les champs svp');
                                          }
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPaysage() {
    return Background(
      height: 400.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0, right: 10),
                child: Image.asset(
                  'assets/images/logo.png',
                )),
          ),
          Expanded(
            flex: 3,
            child: Form(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Identifiant',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(183, 94, 171, 56),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'azoveC203',
                                hintStyle: TextStyle(
                                  color: Color(0xFFBABABA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.right,
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Code secret',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(183, 94, 171, 56),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _passwordControler,
                              autocorrect: false,
                              enableSuggestions: false,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: '************',
                                hintStyle: TextStyle(
                                  color: Color(0xFFBABABA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _showDialog(context);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: const Text(
                                  'S\'inscrire',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(183, 94, 171, 56)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: MaterialButton(
                                  height: 50,
                                  minWidth: 285,
                                  color: const Color.fromARGB(183, 94, 171, 56),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    String email = "";
                                    if (_usernameController.text.isNotEmpty &&
                                        _passwordControler.text.isNotEmpty) {
                                      email = _usernameController.text + domain;
                                      service.loginUser(context, email,
                                          _passwordControler.text);
                                      firestore
                                          .collection('userData')
                                          .doc(auth.currentUser!.uid)
                                          .update({
                                        "users": FieldValue.arrayUnion(list)
                                      });
                                    } else {
                                      service.errorBox(context,
                                          'Remplissez tous les champs svp');
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          maintainBottomViewPadding: true,
          minimum: EdgeInsets.zero,
          child: Scaffold(
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollDirection: Axis.vertical,
              child: buildPortrail(),
            ),
          ),
        ),
      );
}
