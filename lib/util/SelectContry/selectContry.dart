import 'dart:convert';

import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';

class SelectCountry extends StatefulWidget {
  const SelectCountry({Key? key}) : super(key: key);

  @override
  _SelectCountryState createState() => _SelectCountryState();
}

class _SelectCountryState extends State<SelectCountry> {
  List<dynamic>? donneeRecup; // data decoded from the json file
  List<dynamic>? donnee; // data to display on the screen
  var _searchController = TextEditingController();
  var searchValue = "";
  @override
  void initState() {
    _getData();
  }

  Future _getData() async {
    final String response = await rootBundle.loadString('assets/pays.json');
    donneeRecup = await json.decode(response) as List<dynamic>;
    setState(() {
      donnee = donneeRecup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text("Selectionner le pays"),
            previousPageTitle: "",
          ),
          SliverToBoxAdapter(
            child: CupertinoSearchTextField(
              onChanged: (value) {
                setState(() {
                  searchValue = value;
                });
              },
              controller: _searchController,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate((donnee != null)
                ? donnee!
                    .where((e) => e['country']
                        .toString()
                        .toLowerCase()
                        .contains(searchValue.toLowerCase()))
                    .map((e) => CupertinoListTile(
                          onTap: () {
                            print(e['country']);
                            Navigator.pop(context, {
                              "country": e['country'],
                              "continent": e['continent']
                            });
                          },
                          title: Text(e['country']),
                          trailing: Text(
                            e['continent'],
                            style: TextStyle(fontSize: 11),
                          ),
                        ))
                    .toList()
                : [Center(child: Text("Loading"))]),
          )
        ],
      ),
    );
  }
}
