import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:tp_app/pages/AdminPage/adminPage.dart';
import 'package:tp_app/pages/Sign_Registed/loginPage.dart';

import 'package:tp_app/pages/Sign_Registed/signIn.dart';
import 'package:tp_app/util/Choix_Filieres/select_categ_dialog.dart';
import 'package:tp_app/pages/Sign_Registed/SignForAll.dart';
import 'package:url_launcher/url_launcher.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List groupList = [];
  List<String> useLng = [];
  String contry = "";
  bool isAdmin = false;
  String idRecup = '';
  Future<String> getUser() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['statut'] == 'admin')
                {
                  idRecup = value['identifiant'],
                  if (idRecup == _auth.currentUser!.email)
                    setState(() {
                      isAdmin = true;
                    })
                }
              else if (value['statut'] == 'éditeur')
                {contry = value['pays']}
              else
                contry = contry
            });
    return contry;
  }

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .orderBy('statut', descending: false)
      .snapshots();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUser();
    fetch();
  }

  Future openWebsite({required String url, bool inApp = false}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      // ignore: deprecated_member_use
      await launch(url,
          forceWebView: inApp, forceSafariVC: inApp, enableJavaScript: true);
    }
  }

  String chatRoomId(String user) {
    return user;
  }

  /* Future<String> getUsers() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['statut'] == 'admin')
                contry = value['pays']
              else
                contry = contry
            });
    return contry;
  }
*/
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
            tooltip: 'Enregistrer un Utilisateur',
            onPressed: () async {
              if (isAdmin == true) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignScreen(),
                      fullscreenDialog: true,
                    ));
              } else {
                final url = 'https://agrimeteo.hediong.org';
                openWebsite(url: url, inApp: true);
              }
            },
          ),
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
        title: const Text('Utilisateurs'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      alignment: Alignment.bottomLeft,
                      height: size.height,
                      width: size.width,
                      child: fetch()),
                ],
              ),
            ),
    );
  }

  Widget fetch() {
    return StreamBuilder<QuerySnapshot>(
        stream: users,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something is wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          final data = snapshot.requireData;

          return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                Map<String, dynamic> map =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                if (map['pays'] == contry) {
                  return map != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.account_box,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${map['nom']}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle:
                              Text("${map['pays']} (langue: ${map['langue']})"),
                          trailing: map['isSelect']
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setState(() {
                              map['isSelect'] = !map['isSelect'];
                              if (map['isSelect'] == true) {
                                userMap = map;
                                String roomId = chatRoomId(userMap!['nom']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                        userMap: userMap!,
                                        chatRoomId: roomId)));
                              }
                            });
                          },
                        )
                      : Container();
                } else if (isAdmin == true) {
                  return map != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.account_box,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${map['nom']} (${map['statut']})",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle:
                              Text("${map['pays']} (langue: ${map['langue']})"),
                          trailing: map['isSelect']
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setState(() {
                              map['isSelect'] = !map['isSelect'];
                              if (map['isSelect'] == true) {
                                userMap = map;
                                String roomId = chatRoomId(userMap!['nom']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                        userMap: userMap!,
                                        chatRoomId: roomId)));
                              }
                            });
                          },
                        )
                      : Container();
                } else
                  return Container();
              });
        });
  }
}
