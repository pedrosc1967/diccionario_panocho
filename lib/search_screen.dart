import 'package:flutter/material.dart';
import 'destination.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:diccionario_panocho/globals.dart';
import 'package:easy_localization/easy_localization.dart';

String query;
String hint = 'search_voice'.tr();
String status;

stt.SpeechToText speech = stt.SpeechToText();
bool isListening = false;
String text = 'Press the button and start speaking';
double level = 0.0;
double minSoundLevel = 50000;
double maxSoundLevel = -50000;
int resultListened = 0;
String lastWords = '';
double confidence = 1.0;

// ignore: must_be_immutable
class SearchScreen extends StatefulWidget {
  final String searchTerm;
  Map<String, String> results;
  SearchScreen({this.searchTerm});

  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

filterSearchResults(query) async {
  try {
    final items = json.decode(dataFilename.toString());
    var results = items
        .where((item) =>
            item['Entry'].toString().contains(query.toString().capitalize()))
        .toList();
    // print(results);
    return results;
  } on FormatException {
    print('Unexpected character');
  }
}

class _SearchScreenState extends State<SearchScreen> {
  _SearchScreenState();

  String searchedTerm;

  void voiceSearch() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(
            () {
              query = val.recognizedWords;
              searchedTerm = query.capitalize();
              hint = query.capitalize();
              //Search is done here.
              filterSearchResults(searchedTerm);

              if (val.hasConfidenceRating && val.confidence > 0) {
                confidence = val.confidence;
              }
            },
          ),
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'back_menu'.tr(),
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (query) {
                  setState(
                    () {
                      searchedTerm = query;
                      //search is done here. Put query here
                      filterSearchResults(searchedTerm);
                    },
                  );
                },
                decoration: InputDecoration(
                  labelText: 'search'.tr(),
                  hintText: hint,
                  prefixIcon: IconButton(
                    onPressed: () {
                      voiceSearch();
                    },
                    icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  ),
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: DefaultAssetBundle.of(context).loadString(dataFilename),
                builder: (context, snapshot) {
                  var results;
                  // String query = 'Accident';
                  final items = json.decode(snapshot.data.toString());
                  try {
                    results = items
                        .where((item) => item['Entry']
                            .toString()
                            .contains(searchedTerm.capitalize()))
                        .toList();
                    print(results);
                  } on NoSuchMethodError {
                    print('Error de  tipos');
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
