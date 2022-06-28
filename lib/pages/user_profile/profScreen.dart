import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:overlay_support/overlay_support.dart';

import 'package:readmore/readmore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tp_app/pages/Sign_Registed/loginPage.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:tp_app/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:tp_app/util/affichage_Methode/TextPlug/textCustom.dart';
import 'package:tp_app/util/affichage_Methode/audioPlayer.dart';
import 'package:tp_app/util/affichage_Methode/showImage.dart';
import 'package:tp_app/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:tp_app/util/pushNotification/pushNotification.dart';
import 'package:tp_app/util/pushNotification/notification_page.dart';

import 'package:url_launcher/url_launcher.dart';

Future<void> _firebaseMessaging(RemoteMessage message) async {
  print("Manipulation des messages en arrière plan ${message.messageId}");
}

class ViewMessages extends StatefulWidget {
  const ViewMessages({Key? key}) : super(key: key);

  @override
  State<ViewMessages> createState() => _ViewMessagesState();
}

class _ViewMessagesState extends State<ViewMessages>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseMessaging _messaging;
  // late int _totalNotifications;
  PushNotification? _notificationInfo;

  String phoneNumber = '+22994772347';
/*  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessaging);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data},',
        );

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title),
            subtitle: Text(_notificationInfo!.body),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
*/
  /*checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }
*/
  storeNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    _firestore
        .collection('sending')
        .doc(_auth.currentUser!.displayName)
        .collection('envoyers')
        .doc()
        .set({'token': token}, SetOptions(merge: true));
  }

  @override
  void initState() {
    //_totalNotifications = 0;
    storeNotification();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen(
      (event) {
        LocalNotification.display(event);
      },
    );
    sendNotification(String title, String token) async {
      final data = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': 1,
        'status': 'done',
        'message': title,
      };
      try {
        http.Response response =
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Autorization':
                      'key=AAAASR1zXIo:APA91bFWSbo2GM1V-tE0Wb6tvFNjfGm0FYzrgdLL14uvVS8tNkX222ZvaknHVkb7dwXa6E49CNltSbz9v7kM52Q0xVAlRKuijNb_LBF4DPM4EtrwdqzBNwyHhtGyv0UmtM06jYtv1nDs'
                },
                body: jsonEncode(<String, dynamic>{
                  'notification': <String, dynamic>{
                    'title': title,
                    'body': 'vous avez un nouveau message',
                    'priority': 'high',
                    'data': data,
                    'to': '$token'
                  }
                }));
        if (response.statusCode == 200) {
          print('Notification reçu');
        } else
          print('error');
      } catch (e) {}
    }
    //registerNotification();
    //checkForInitialMessage();

    /* FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });*/

    super.initState();
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("A propos"),
            content: const Text(
                "Cette application est développée par HEDI ONG et DIGITAL FARM ."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showDialog1(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nous Contacter"),
            content: const Text("Appelez nous ou écrivez nous via Whatsapp  "),
            buttonPadding: const EdgeInsets.only(bottom: 5),
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

  String formatTime(Duration duration) {
    String toDigits(int n) => n.toString().padLeft(2, '0');
    final hours = toDigits(duration.inHours);
    final minutes = toDigits(duration.inMinutes.remainder(60));
    final secondes = toDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      secondes,
    ].join(':');
  }

  var isLargeScreen = false;
  ScrollController scrollController = ScrollController();
  openwhatsapp() async {
    var whatsapp = phoneNumber;
    var whatsappURl_android =
        "whatsapp://send?phone=" + whatsapp + "&text=hello";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
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

  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            persistentFooterButtons: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                        onPressed: () {
                          openwhatsapp();
                        },
                        icon: const Icon(
                          Icons.whatsapp,
                          color: Color.fromARGB(183, 43, 97, 16),
                        )),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          openCalling();
                        },
                        icon: const Icon(
                          Icons.call,
                          color: Color.fromARGB(183, 43, 97, 16),
                        )),
                  )
                ],
              )
            ],
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color.fromARGB(183, 43, 97, 16),
              title: Text(
                "${_auth.currentUser!.displayName}",
                textAlign: TextAlign.center,
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      try {
                        await _auth.signOut();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                              fullscreenDialog: true,
                            ));
                      } catch (e) {
                        print("error");
                      }
                    },
                    icon: const Icon(Icons.logout)),
              ],
            ),
            /*drawer: Container(
            margin: const EdgeInsets.only(top: 20.0, right: 10.0),
            alignment: Alignment.topRight,
            width: 230,
            color: Colors.cyan,
            child: Drawer(
              child: Positioned(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(
                      height: 70,
                      child: DrawerHeader(
                        decoration:
                            BoxDecoration(color: Color.fromARGB(183, 43, 97, 16)),
                        child: Text(
                          'AGRIMETEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'POPPINS',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Riz',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/ana.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Ananas',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/soja.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Soja',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/ma.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Maïs',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/marai.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Maraichage',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Anacardre',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Cacao',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Coton',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Manoc',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Igname',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        title: const Text('Hévéa',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: const Icon(
                          Icons.cloudy_snowing,
                          color: Color.fromARGB(183, 43, 97, 16),
                          size: 40,
                        ),
                        title: const Text('Climat',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: const Icon(
                          Icons.add,
                          color: Color.fromARGB(183, 43, 97, 16),
                          size: 40,
                        ),
                        title: const Text('Tout Afficher',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Divider(
                      height: 3.0,
                      thickness: 3,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const VerticalDivider(
                      width: 3,
                      thickness: 3,
                    ),
                    SizedBox(
                      height: 40,
                      child: ListTile(
                        leading: const Icon(
                          Icons.message,
                          color: Color.fromARGB(183, 43, 97, 16),
                          size: 30,
                        ),
                        title: const Text('A propos',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                          _showDialog(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Color.fromARGB(183, 43, 97, 16),
                          size: 30,
                        ),
                        title: const Text('Contacts',
                            style: TextStyle(
                                color: Color.fromARGB(183, 43, 97, 16))),
                        onTap: () {
                          Navigator.pop(context);
                          _showDialog1(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: ListTile(
                        onTap: () async {
                          FirebaseAuth _auth = FirebaseAuth.instance;
  
                          await _auth.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                                fullscreenDialog: true,
                              ));
                        },
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          "Deconnexion",
                          style: TextStyle(
                            fontSize: size.width / 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          */
            body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollController,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.25,
                      width: MediaQuery.of(context).size.width,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('sending')
                            .doc(_auth.currentUser!.displayName)
                            .collection('envoyers')
                            .orderBy("codetime", descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.data != null) {
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> map =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                String? token;
                                try {} catch (e) {
                                  token =
                                      snapshot.data!.docs[index].get('token');
                                } catch (e) {}

                                return messageType(
                                    MediaQuery.of(context).size, map, context);
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ))),
      );

  Widget buildText(String txt) {
    var styleButton = const TextStyle(
        fontSize: 10,
        color: Color.fromARGB(183, 43, 97, 16),
        fontWeight: FontWeight.bold);
    return ReadMoreText(
      txt,
      trimLines: 2,
      trimMode: TrimMode.Line,
      style: const TextStyle(fontSize: 14),
      trimCollapsedText: 'Voir Plus',
      trimExpandedText: 'Voir moins',
      lessStyle: styleButton,
      moreStyle: styleButton,
    );
  }

  Widget messageType(
      Size size, Map<String, dynamic> map, BuildContext context) {
    if (map['type'] == 'text') {
      Container(
        height: size.height / 4.5,
        width: size.width,
        alignment: map['sendby'] == _auth.currentUser!.displayName
            ? Alignment.center
            : Alignment.center,
        child: Container(
          width: size.width,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: const Color.fromARGB(38, 33, 149, 243),
          ),
        ),
      );
    }
    return map['type'] == 'text'
        ? BubbleMessage(
            painter: BubblePainter(),
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(183, 43, 97, 16)),
                borderRadius: BorderRadius.circular(9),
              ),
              constraints:
                  const BoxConstraints(maxWidth: 250.0, minWidth: 50.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      map['date'],
                      style:
                          const TextStyle(fontSize: 12, fontFamily: 'POPPINS'),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  buildText(map['message']),
                  Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      map['time'],
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          )
        : (map['type'] == 'audio')
            ? BubbleMessage(
                painter: BubblePainter(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(183, 43, 97, 16)),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: 250, minWidth: 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 6.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          map['date'],
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'POPPINS'),
                        ),
                      ),
                      AudioShowing(audioUrl: map['message'], code: map['code']),
                      Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          map['time'],
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : (map['type'] == 'img')
                ? Container(
                    height: size.height / 4.5,
                    width: size.width,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0, 2, 183, 2))),
                    alignment: map['sendby'] == _auth.currentUser!.displayName
                        ? Alignment.center
                        : Alignment.center,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShowImage(
                              imageUrl: map['message'],
                            ),
                          ),
                        ),
                        child: Container(
                          height: size.height / 4.5,
                          width: size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(0, 2, 183, 2)),
                            borderRadius: BorderRadius.circular(9),
                            color: const Color.fromARGB(0, 2, 183, 2),
                          ),
                          alignment:
                              map['message'] != "" ? null : Alignment.center,
                          child: map['message'] != ""
                              ? Image.network(
                                  map['message'],
                                  fit: BoxFit.cover,
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: size.height / 4.5,
                    width: size.width,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0, 2, 183, 2))),
                    alignment: map['sendby'] == _auth.currentUser!.displayName
                        ? Alignment.center
                        : Alignment.center,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ShowVideo(vidUrl: map['message'])),
                      ),
                      child: Container(
                        height: size.height / 4.5,
                        width: size.width,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(0, 2, 183, 2)),
                          borderRadius: BorderRadius.circular(9),
                          color: const Color.fromARGB(0, 2, 183, 2),
                        ),
                        alignment:
                            map['message'] != "" ? null : Alignment.center,
                        child: map['message'] != ""
                            ? Image.asset(
                                "assets/images/preview.jpg",
                                height: 10,
                                width: 10,
                                fit: BoxFit.cover,
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                  );
  }

  Widget buildPaysage() {
    final size = MediaQuery.of(context).size;
    return Text('data');
    /*Column(
      children: [
        Container(
          height: size.height,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(_auth.currentUser!.displayName)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    //checkForInitialMessage();
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    String? token;
                    try {} catch (e) {
                      token = snapshot.data!.docs[index].get('token');
                    } catch (e) {}
                    return messageType(size, map, context);
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
 */
  }
}
