import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:tp_app/pages/user_profile/profScreen.dart';
import 'package:tp_app/util/DeviceInfo/DeviceInfo.dart';

import 'package:tp_app/util/DeviceInfo/ipDeviceInfo.dart';
import 'package:tp_app/util/SelectUser/allUser.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> map = {};
  List<dynamic> list = [];

  Future<User?> createAccount(context, email, password, nom, type, number, pays,
      statut, langue, filieres) async {
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("Enregistrement reussie");
      user.user!.updateDisplayName(nom);

      await _firestore.collection('userData').doc(auth.currentUser!.uid).set({
        "identifiant": email,
        "nom": nom,
        "utilisateur": type,
        "numero": number,
        "pays": pays,
        "code": password,
        "filieres": filieres,
        "langue": langue,
        "uid": auth.currentUser!.uid,
        "statut": statut,
        "isSelect": false,
      });
      await auth.signOut;

      loginUser(context, 'hedihedi@agrimeteo.com', 'Wx14sqthé0');
    } catch (e) {
      errorBox(context, e);
      return null;
    }
  }

  Future<User?> loginUser(context, email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('Connection reussite!');
      _firestore
          .collection('userData')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) => {
                userCredential.user!.updateDisplayName(value['nom']),
                if (value['statut'] == 'admin')
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllUsers()))
                  }
                else if (value['statut'] == 'éditeur')
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllUsers()))
                  }
                else
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewMessages()))
                  }
              });
      _firestore
          .collection('userData')
          .doc(auth.currentUser!.uid)
          .update({"users": FieldValue.arrayUnion(list)});
    } catch (e) {
      errorBox(context, 'Identifiant ou Code incorrect');
    }
  }

  Future init() async {
    final ipAdress = await IpInfoApi.getIpAdress();
    final phone = await DeviceInfo.getPhone();

    map = {'IP Adress': ipAdress, 'phone': phone};
    list.add(map);
  }

  void errorBox(context, e) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Erreur"),
            content: Text(e.toString(),
                style:
                    const TextStyle(color: Color.fromARGB(183, 94, 171, 56))),
          );
        });
  }
}
