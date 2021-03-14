import 'package:flutter/material.dart';
import 'package:diccionario_panocho/globals.dart';
import 'destination.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class AlphaSearchedScreen extends StatefulWidget {
  final String searchTerm;
  Map<String, String> results;
  AlphaSearchedScreen({this.searchTerm});

  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

filterSearchResults(query) async {
  try {
    final items = json.decode(dataFilename.toString());
    var results = items
        .where((item) =>
            item['Entry'].toString().startsWith(query.toString().toUpperCase()))
        .toList();
    return results;
  } on FormatException {
    print('Unexpected character');
  }
}

class _SearchScreenState extends State<AlphaSearchedScreen> {
  _SearchScreenState();

  var query;
  String searchedTerm;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'back_alpha'.tr(),
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(1.0),
            ),
            Expanded(
              child: FutureBuilder(
                future: DefaultAssetBundle.of(context).loadString(dataFilename),
                builder: (context, snapshot) {
                  var results;
                  final items = json.decode(snapshot.data.toString());
                  try {
                    results = items
                        .where((item) => item['Entry']
                            .toString()
                            .startsWith(widget.searchTerm.toUpperCase()))
                        .toList();
                  } on NoSuchMethodError {
                    print('Error de tipos');
                    results = items;
                  } catch (e) {
                    print(e);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      var entrada = results[index];

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 2.0),
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            query = entrada['Entry'];
                            searchedTerm = query;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Destination(
                                  entry: entrada['Entry'],
                                  definition: entrada['Definition'],
                                ),
                              ),
                            );
                          },
                          color: Colors.blue[900],
                          child: Text(
                            entrada['Entry'],
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: results == null ? 0 : results.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: bannerAd,
    );
  }
}
