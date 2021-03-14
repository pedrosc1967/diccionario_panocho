import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'constants.dart';

bool isInterstitialAdLoaded = false;

void loadInterstitialAd() {
  FacebookInterstitialAd.loadInterstitialAd(
    placementId: Platform.isAndroid
        ? Constants.interstitialAndroid
        : Constants.interstitialIOS,
    listener: (result, value) {
      if (result == InterstitialAdResult.LOADED) {
        isInterstitialAdLoaded = true;
        print('Result:' + result.toString());
      }
      if (result == InterstitialAdResult.DISMISSED &&
          value["invalidated"] == true) {
        isInterstitialAdLoaded = false;
        print('Result: ' + result.toString());
        loadInterstitialAd();
      }
    },
  );
}

void showInterstitialAd() {
  if (isInterstitialAdLoaded == true) {
    FacebookInterstitialAd.showInterstitialAd();
  } else {
    print("Ad not loaded yet, pito");
  }
}

Widget bannerAd = SizedBox(width: 0, height: 0);

void loadBannerAd() {
  bannerAd = FacebookBannerAd(
    placementId:
        Platform.isAndroid ? Constants.bannerAndroid : Constants.bannerIOS,
    bannerSize: BannerSize.STANDARD,
    listener: (result, value) {
      print("$result == $value");
    },
  );
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
