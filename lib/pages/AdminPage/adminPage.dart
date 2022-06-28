import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';

import 'package:tp_app/util/SelectUser/allUser.dart';
import 'package:tp_app/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:tp_app/util/affichage_Methode/TextPlug/textCustom.dart';

import 'package:tp_app/util/affichage_Methode/audioPlayer.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tp_app/util/affichage_Methode/showImage.dart';
import 'package:tp_app/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:tp_app/util/filieres/selectCategorie.dart';

import 'package:tp_app/util/pushNotification/notification_page.dart';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    Key? key,
    required this.userMap,
    required this.chatRoomId,
    //required this.categChoice,
  }) : super(key: key);
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  //final dynamic categChoice;
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  late String downloadUrl;

  late DateFormat dateFormat;
  late DateFormat timeFormat;

  var time = DateTime.now();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _message = TextEditingController();
  File? imageFile, otherFile;
  String? token;

  final List<String> _audioExtensions = [
    'mp3',
    'm4a',
    'wav',
    'ogg',
    'aac',
  ];

  final List<String> _videoExtensions = [
    'mp4',
    'avi',
    '3gp',
    'm4a',
  ];
  final List<String> _imgExtensions = [
    'png',
    'jpeg',
    'jpg',
    'git',
  ];
  Map<String, dynamic> data = {"cat": ""};
  //methodes
  String generateRandomString(int len) {
    var r = Random();
    String randomString =
        String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
    return randomString;
  }

  /* storeNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc()
        .set({'token': token}, SetOptions(merge: true));
  }
*/
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

//recuperer l'image
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);

        uploadImage();
      }
    });
  }

//stocker l'image dans le firebase
  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
    Map<String, dynamic> dataResult = await Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const SelectCategorie()));
    setState(() {
      if (dataResult != null) data = dataResult;
    });

    await _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "date": dateFormat.format(time),
      "time": timeFormat.format(time),
      "code": FieldValue.increment(1),
      "codetime": FieldValue.serverTimestamp(),
      "categorie": data['cat']
    });

    var ref =
        FirebaseStorage.instance.ref().child('files').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .update({"message": imageUrl});
    }
  }

//recuperer et stocker autres fichiers
  Future uploadFile() async {
    String fileName = const Uuid().v1();
    int status = 1;

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    Map<String, dynamic> dataResult = await Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const SelectCategorie()));

    final path = result.files.first.path;

    setState(() {
      if (dataResult != null) data = dataResult;
      otherFile = File(path!);
    });

    await _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "",
      "date": dateFormat.format(time),
      "time": timeFormat.format(time),
      "code": FieldValue.increment(1),
      "codetime": FieldValue.serverTimestamp(),
      "categorie": data['cat']
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('files')
        .child("$fileName.${result.files.first.extension}");

    var uploadTask = await ref.putFile(otherFile!).catchError((error) async {
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String fileUrl = await uploadTask.ref.getDownloadURL();
      result.files.forEach((element) async {
        print('Name: ${element.path}');
        print('Extension: ${element.extension}');

        if (_audioExtensions.contains(element.extension)) {
          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update({"message": fileUrl, "type": 'audio'});
        }
        if (_videoExtensions.contains(element.extension)) {
          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update({"message": fileUrl, "type": 'video'});
        }
        if (_imgExtensions.contains(element.extension)) {
          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update({"message": fileUrl, "type": 'img'});
        }
      });

      print(fileUrl);
    }
  }

//Envoie du text
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> dataResult = await Navigator.push(context,
          CupertinoPageRoute(builder: (context) => const SelectCategorie()));
      setState(() {
        if (dataResult != null) data = dataResult;
      });
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "date": dateFormat.format(time),
        "time": timeFormat.format(time),
        "code": FieldValue.increment(1),
        "codetime": FieldValue.serverTimestamp(),
        "categorie": data['cat']
      };

      _message.clear();
      // sendNotification('AGRIMETEO', token!);
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .add(messages);
    } else {
      print("Entrer un Texte");
    }
  }

  Widget buildText(String txt) {
    var styleButton = const TextStyle(
        fontSize: 20,
        color: Color.fromARGB(183, 43, 97, 16),
        fontWeight: FontWeight.bold);
    return ReadMoreText(
      txt,
      trimLines: 2,
      trimMode: TrimMode.Line,
      style: const TextStyle(fontSize: 10),
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

  void openFile(PlatformFile file) {
    OpenFile.open(file.path!);
  }

  Future<File> saveFilePermanment(PlatformFile file) async {
    final appStrorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStrorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('fr');
    timeFormat = DateFormat.Hms('fr');
    // storeNotification();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen(
      (event) {
        LocalNotification.display(event);
      },
    );
  }

  Widget sending() {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height / 10,
      width: size.width,
      alignment: Alignment.center,
      child: Container(
        height: size.height / 12,
        width: size.width / 1.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height / 10,
              width: size.width / 1.3,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: null,
                expands: true,
                controller: _message,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    filled: true,
                    suffixIcon: IconButton(
                      onPressed: () {
                        getImage();
                        //sendNotification('AGRIMETEO', token!);
                      },
                      icon: const Icon(Icons.photo,
                          color: Color.fromARGB(183, 43, 97, 16)),
                    ),
                    prefixIcon: IconButton(
                      onPressed: () {
                        uploadFile();
                        //sendNotification('AGRIMETEO', token!);
                      },
                      icon: const Icon(
                        Icons.link,
                        size: 25,
                        color: Color.fromARGB(183, 43, 97, 16),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(width: 2.0))),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color.fromARGB(183, 43, 97, 16),
              ),
              onPressed: onSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPortrail() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height / 1.25,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(widget.chatRoomId)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    /* try {} catch (e) {
                      token = snapshot.data!.docs[index].get('token');
                    } catch (e) {}*/
                    return messageType(size, map, context);
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        sending()
      ],
    );
  }

  Widget buildPaysage() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(widget.chatRoomId)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
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
        sending()
      ],
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return orientation == Orientation.portrait
                    ? buildPortrail()
                    : buildPaysage();
              },
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 100,
            leading: SizedBox(
              width: 20,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AllUsers())),
                icon: const Icon(Icons.arrow_left_sharp),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                    elevation: 0, primary: Colors.transparent),
              ),
            ),
            backgroundColor: Colors.green,
            title:
                Center(child: Text(' ADMIN ${_auth.currentUser!.displayName}')),
          ),
        ),
      );
}
