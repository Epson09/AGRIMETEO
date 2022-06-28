import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

import 'package:tp_app/service/auth.dart';
import 'package:tp_app/util/SelectContry/selectContry.dart';

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
            return const SignScreen();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SignScreen extends StatefulWidget {
  const SignScreen({Key? key}) : super(key: key);

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  AuthService service = AuthService();
  String domain = "@agrimeteo.com";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _usernameController = TextEditingController();
  final _passwordControler = TextEditingController();
  final _confPasController = TextEditingController();
  final _nameController = TextEditingController();

  final _numController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //checkbox variable
  final auth = FirebaseAuth.instance;
  List<String> categories = [];
  List<String> langues = [];
  List<String> type = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int userSelect = 1;
  List<String> LangItems = [
    'Yoruba',
    'Baoulé',
    'Djoula',
    'Fon',
    'Adja',
    'Dendi',
    'Idatcha',
    'Nago',
    'Bété',
    'Ewé',
    'Mina',
    'Wolof',
    'Anglais',
    'Français'
  ];
  String selectedLang = 'Yoruba';
  Map<String, dynamic> data = {"country": "Bénin", "continent": "Afrique"};

  bool isloading = false;
  void _showDialog1(BuildContext context, String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enregistrement"),
            content: Text(txt),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  String state = 'user';

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Inscription"),
              backgroundColor: Colors.green,
            ),
            body: isloading
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 20,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  controller: _nameController,

                                  decoration: const InputDecoration(
                                    hintText: 'Nom Complet?',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(183, 94, 171, 56),
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
                                    labelText: 'Nom *',
                                    suffixStyle: TextStyle(
                                        color:
                                            Color.fromARGB(183, 94, 171, 56)),
                                  ),
                                  validator: (String? value) {
                                    return (value == null || value == "")
                                        ? 'Ce champ est obligatoire:'
                                        : null;
                                  },
                                  //onSaved: (val) => name = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                DropDownMultiSelect(
                                  onChanged: (List<String> x) {
                                    setState(() {
                                      type = x;
                                    });
                                  },
                                  options: const [
                                    'Producteur/Cooperative',
                                    'Institution de Recherche',
                                    'ONG/Fédération',
                                    'Agence d\'Etat'
                                  ],
                                  selectedValues: type,
                                  whenEmpty: 'Utilisateur',
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Choix du pays",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    CupertinoListTile(
                                      onTap: () async {
                                        Map<String, dynamic> dataResult =
                                            await Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        const SelectCountry()));
                                        setState(() {
                                          if (dataResult != null)
                                            data = dataResult;
                                        });
                                      },
                                      title: Text(
                                        data['country'],
                                        style: const TextStyle(
                                            color: Colors.green),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [Text(data['continent'])],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Identifiant a attribue?',
                                    labelText: 'Identifiant *',
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
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(183, 94, 171, 56),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  validator: (String? value) {
                                    return (value == null || value == "")
                                        ? 'Ce champ est obligatoire:'
                                        : null;
                                  },
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: _numController,
                                  decoration: const InputDecoration(
                                    hintText: 'numero de telephone?',
                                    labelText: 'Contact *',
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
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(183, 94, 171, 56),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  validator: (String? value) {
                                    return (value == null || value == "")
                                        ? 'Ce champ est obligatoire:'
                                        : null;
                                  },
                                  //onSaved: (val) => num = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  controller: _passwordControler,
                                  decoration: const InputDecoration(
                                      hintText: '*********',
                                      labelText: 'Code secret *',
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
                                      hintStyle: TextStyle(
                                        color: Color.fromARGB(183, 94, 171, 56),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  validator: (String? value) {
                                    return (value == null || value == "")
                                        ? 'Ce champ est obligatoire:'
                                        : null;
                                  },
                                  // onSaved: (val) => pwd = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  controller: _confPasController,
                                  decoration: const InputDecoration(
                                    hintText: 'confirmer le code?',
                                    labelText: 'Confirmation *',
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
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(183, 94, 171, 56),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'repeter le mot de passe';
                                    if (value != _passwordControler.text) {
                                      return 'ça ne correspond pas';
                                    }

                                    return null;
                                  },
                                  // onSaved: (val) => conPwd = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            183, 43, 97, 16)),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 6.0),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                width: 5,
                                                color: Colors.green))),
                                    value: selectedLang,
                                    items: LangItems.map(
                                        (e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.green),
                                            ))).toList(),
                                    onChanged: (item) => setState(() {
                                      selectedLang = item!;
                                      print(selectedLang);
                                    }),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      DropDownMultiSelect(
                                        onChanged: (List<String> x) {
                                          setState(() {
                                            categories = x;
                                          });
                                        },
                                        options: const [
                                          'Maïs',
                                          'Riz',
                                          'Soja',
                                          'Ananas',
                                          'Maraichage',
                                          'Anacarde',
                                          'Cacao',
                                          'Hévéa',
                                          'Coton',
                                          'Manioc',
                                          'Igname',
                                          'Autres'
                                        ],
                                        selectedValues: categories,
                                        whenEmpty: ' Filières*',
                                      ),
                                    ]),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      'Statut',
                                      style: TextStyle(
                                          fontFamily: 'POPPINS',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'admin',
                                              groupValue: state,
                                              onChanged: (value) {
                                                setState(() {
                                                  state = value!;
                                                });
                                              },
                                            ),
                                            const Text('Administrateur'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'éditeur',
                                              groupValue: state,
                                              onChanged: (value) {
                                                setState(() {
                                                  state = value!;
                                                });
                                              },
                                            ),
                                            const Text('Editeur'),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio<String>(
                                              value: 'user',
                                              groupValue: state,
                                              onChanged: (value) {
                                                setState(() {
                                                  state = value!;
                                                });
                                              },
                                            ),
                                            const Text('Simple Utilisateur'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (type.isNotEmpty &&
                                        categories.isNotEmpty) {
                                      setState(() {
                                        isloading = true;
                                      });
                                      if (_confPasController.text !=
                                          _passwordControler.text) {
                                        _showDialog1(
                                            context, 'Echec d\'enregistrement');
                                      } else {
                                        service.createAccount(
                                            context,
                                            _usernameController.text + domain,
                                            _passwordControler.text,
                                            _nameController.text,
                                            type,
                                            _numController.text,
                                            data['country'],
                                            state,
                                            selectedLang,
                                            categories);

                                        if (service != null) {
                                          _showDialog1(context, 'Succès');
                                          setState(() {
                                            isloading = false;
                                          });
                                          print("Reussie");
                                        } else {
                                          print("Echec");
                                        }
                                      }
                                    } else {
                                      print("Remplissez tous les champs");
                                    }
                                  },
                                  child: const Text('Valider'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,

                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    // shadowColor: Color.fromARGB(183, 35, 98, 3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  )),
      );
}
