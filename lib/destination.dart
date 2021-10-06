import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:diccionario_panocho/tts_helper.dart';
import 'facebook_code.dart';
import 'package:share/share.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable...
class Destination extends StatefulWidget {
  final String entry;
  final String definition;

  Destination({this.entry, this.definition});

  @override
  DestinationState createState() => DestinationState();
}

class DestinationState extends State<Destination> {
  bool isInterstitialAdLoaded = false;

  @override
  void initState() {
    FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
    );
    loadInterstitialAd(); //This was called in main
    loadBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry,
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {
              Share.share(widget.entry + '\n \n' + widget.definition);
            },
          )
        ],
        backgroundColor: Colors.black,
      ),
      body: Center(
        //mainAxisSize: MainAxisSize.min,
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: 30.0, right: 30.0, top: 30.0, bottom: 30.0),
              child: Text(
                widget.definition,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2.0),
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
                  onPrimary: Colors.white,
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: Size(double.infinity, 40), // full width
                ),
                onPressed: () {
                  speak(widget.entry + '\n ' + widget.definition);
                },
                child: Text(
                  'say_button'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2.0),
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
                  onPrimary: Colors.white,
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: Size(double.infinity, 40), // full width
                ),
                onPressed: () {
                  stop();
                },
                child: Text(
                  'stop_button'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2.0),
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900],
                  onPrimary: Colors.white,
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: Size(double.infinity, 40), // full width
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'back_button'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bannerAd,
    );
  }
}
