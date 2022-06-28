//import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ListResult> futureFiles;

  Map<int, double> downloadProgress = {};

  final GlobalKey<ScaffoldState> _sb = GlobalKey<ScaffoldState>();

  final String logo = 'assets/images/agri2.png';
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/images').list();
  }

  @override
  Widget build(BuildContext context) {
    Future downloadFile(int index, Reference ref) async {
      final url = await ref.getDownloadURL();
      final tmpDir = await getTemporaryDirectory();
      final path = '${tmpDir.path}/${ref.name}';
      await Dio().download(url, path, onReceiveProgress: (received, total) {
        double progress = received / total;
        setState(() {
          downloadProgress[index] = progress;
        });
      });
      if (url.contains('.mp3')) {
        await GallerySaver.saveVideo(path, toDcim: true);
      } else if (url.contains('jpg')) {
        await GallerySaver.saveImage(path, toDcim: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${ref.name}')),
      );
    }

    /*  Future<Uri> fetchAudio(String url, String filename) async {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final tempFile = io.File('$tempPath/$filename');

      http.Response response = await http.get(Uri.parse(url));

      await tempFile.writeAsBytes(response.bodyBytes, flush: true);

      return tempFile.uri;
    }
*/
    final Widget svgS = Image.asset(
      logo,
    );
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0xB758F10B),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 0, top: 5, left: 110),
                child: IconButton(
                  onPressed: null,
                  icon: svgS,
                  iconSize: 230,
                ),
              )
              /*  MaterialButton(
                onPressed: () {
                  _auth.signOut().whenComplete(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  });
                },
                child: const Text(
                  "Deconnexion",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            
            */
            ]),
        drawer: Container(
          width: 230,
          color: Colors.cyan,
          child: Drawer(
            child: Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const SizedBox(
                    height: 100,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(183, 94, 171, 56),
                      ),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'cambria',
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
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: const Text('Riz',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: const Text('Ananas',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: const Text('Soja',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: const Text('Maïs',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                          height: 50,
                          width: 50,
                        ),
                      ),
                      title: const Text('Maraichage',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                        color: Color.fromARGB(183, 94, 171, 56),
                        size: 40,
                      ),
                      title: const Text('Climat',
                          style: TextStyle(color: Color(0xB758F10B))),
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
                        color: Color.fromARGB(183, 94, 171, 56),
                        size: 40,
                      ),
                      title: const Text('Tout afficher',
                          style: TextStyle(color: Color(0xB758F10B))),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Divider(
                    height: 3,
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
                        Icons.favorite,
                        color: Color.fromARGB(183, 94, 171, 56),
                        size: 30,
                      ),
                      title: const Text('A propos',
                          style: TextStyle(color: Color(0xB758F10B))),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    child: ListTile(
                      leading: const Icon(
                        Icons.message,
                        color: Color.fromARGB(183, 94, 171, 56),
                        size: 30,
                      ),
                      title: const Text('Contacts',
                          style: TextStyle(color: Color(0xB758F10B))),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        size: 30,
                        color: Color.fromARGB(183, 94, 171, 56),
                      ),
                      title: const Text('Confidentialité',
                          style: TextStyle(color: Color(0xB758F10B))),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: FutureBuilder<ListResult>(
            future: futureFiles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final files = snapshot.data!.items;
                return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      double? progress = downloadProgress[index];
                      return ListTile(
                        title: Text(file.name),
                        subtitle: progress != null
                            ? LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.black26,
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.download,
                            color: Colors.red,
                          ),
                          onPressed: () => downloadFile(index, file),
                        ),
                      );
                    });
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error générée'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })

        /* stream: FirebaseFirestore.instance.collection("messages").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Erreur'),
              );
            }
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  CupertinoSliverNavigationBar(
                    largeTitle: Text("Climat"),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()!;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 6,
                                  mainAxisExtent: 3),
                          itemBuilder: (context, i) {
                            QueryDocumentSnapshot x = snapshot.data!.docs[i];
                            if (snapshot.hasData) {
                              return Card(
                                child: CupertinoListTile(
                                  title: Text(data['title']),
                                  subtitle: Text(data['contenu']),
                                  //selected: ,
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  )
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text('En cours'),
              );
            }
          },
        )*/
        /*
        StreamBuilder(
          stream: _messageStrem,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Rien ne va plus");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              primary: true,
              itemBuilder: (_, index) {
                QueryDocumentSnapshot qs = snapshot.data!.docs[index];
                Timestamp t = qs['time'];
                DateTime d = t.toDate();
                print(d.toString());
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: id == qs['identité']
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.purple,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          title: Text(
                            qs['Climat'],
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 200,
                                child: Text(
                                  qs['message'],
                                  softWrap: true,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Text(
                                d.hour.toString() + ":" + d.minute.toString(),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
*/

        );
  }

  /*Future<void> _onUploadComplete() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    ListResult listResult =
        await firebaseStorage.ref().child("upload_voice-firebase").list();
    setState(() {
      //reference = listResult.items;
    });
  }*/
}
