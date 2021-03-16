import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:diccionario_panocho/alphabetical_screen.dart';
import 'dart:io' show Platform;
import 'facebook_code.dart';
import 'listentries.dart';
import 'navigate.dart';
import 'constants.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:sentry/sentry.dart';
import 'search_screen.dart';
import 'tts_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share/share.dart';
import 'globals.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [
    Firebase.initializeApp(),
    SentryFlutter.init(
      (options) {
        options.dsn = Constants.URLSentry; // URLSentri in constants.dart
      },
    )
  ];
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('it', 'IT'),
        Locale('fr', 'FR'),
        Locale('de', 'DE')
      ],
      path: 'assets/translations', // <-- change patch to your
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: HomePage(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int selectedIndex = 0;
  FlutterTts flutterTts;
  final String myLocale =
      Platform.localeName; // Returns locale string in the form 'en_US'

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    appStoreIdentifier: '1545741185',
    minDays: 0, // Show rate popup on first day of install.
    minLaunches: 8, // Show rate popup after 8 launches
    // of app after minDays is passed.
  );

  final widgetElements = new ListEntries(); // from listentries.dart
  bool isInterstitialAdLoaded = false;

  @override
  Future<void> initState() {
    FacebookAudienceNetwork.init(
      testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
    );
    //This is for Rate My App...
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await rateMyApp.init();
        if (mounted && rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(context);
        }
      },
    );

    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    //OneSignal initialization is done here
    OneSignal.shared.init(Constants.OneSignalAppID, iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: false
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);

    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // will be called whenever the subscription changes
      //(ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges emailChanges) {
      // will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });

// For each of the above functions, you can also pass in a
// reference to a function as well:....

    loadInterstitialAd();
    loadBannerAd();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initPackageInfo();
    initTts();
    speech = stt.SpeechToText();

    //Select data file
    defaultLocale = myLocale;
    print('Locales is: ' + defaultLocale);

    switch (defaultLocale) {
      case 'en':
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;

      case 'es_ES':
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;

      case 'it_IT':
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;

      case 'de_DE':
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;

      case 'fr_FR':
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;

      default:
        {
          dataFilename = 'assets/data-pa.json';
        }
        break;
    }

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  // Release back device's orientations when the page is exited
  @override
  dispose() {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    // Stop speaking
    stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.inactive) stop();
  }

  //Initialize PackageInfo
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(
      () {
        _packageInfo = info;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'title'.tr(),
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {
              if (Platform.isAndroid) {
                Share.share(
                  'share_text_android'.tr(),
                  subject: 'share_subject'.tr(),
                );
              } else {
                Share.share(
                  'share_text_ios'.tr(),
                  subject: 'share_subject'.tr(),
                );
              }
              // do something
            },
          )
        ],
      ),
      // Hamburguer menu AKA drawer in flutter
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                'other_apps'.tr(), //Other apps
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                try {
                  launchURL(Platform.isAndroid
                      ? Constants.URLOtherAppsAndroid
                      : Constants.URLOtherAppsIOS);
                } catch (exception, stackTrace) {
                  Sentry.captureException(
                    exception,
                    stackTrace: stackTrace,
                  );
                }
              },
              trailing: Icon(Icons.apps),
            ),
            ListTile(
              title: Text(
                "about".tr(), //About
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationVersion: 'version'.tr() + _packageInfo.version,
                  applicationIcon: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: Constants.avatarRadius,
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(
                            Radius.circular(Constants.avatarRadius)),
                        child: Image.asset("assets/logoaplanetbit.png")),
                  ),
                  applicationLegalese: 'app_legalese'.tr(),
                  applicationName: 'title'.tr(),
                );
              },
              trailing: Icon(Icons.arrow_forward),
            ),
            ListTile(
              title: Text(
                'rate_us'.tr(), //Rate Us
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                rateMyApp.showRateDialog(
                  context,
                  title: 'rate_title'.tr(),
                  message: 'rate_message'.tr(),
                  rateButton: 'rate_button'.tr(),
                  noButton: 'rate_no'.tr(),
                  laterButton: 'rate_maybe'.tr(),
                );
              },
              trailing: Icon(Icons.speed),
            ),
            ListTile(
              title: Text(
                'aplanetbit_web'.tr(), //AplanetBit Web
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                try {
                  launchURL(Constants.URLAplanetBit);
                } catch (exception, stackTrace) {
                  Sentry.captureException(
                    exception,
                    stackTrace: stackTrace,
                  );
                }
              },
              trailing: Icon(Icons.cloud),
            ),
            ListTile(
              title: Text(
                'search'.tr(),
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(
                      searchTerm: ('Search your term'),
                    ),
                  ),
                );
              },
              trailing: Icon(Icons.search),
            ),
            ListTile(
              title: Text(
                'alphabetical_index'.tr(),
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlphabeticalScreen(
                      searchTerm: ('Alphabetical index'),
                    ),
                  ),
                );
              },
              trailing: Icon(Icons.sort_by_alpha),
            ),
          ],
        ),
      ),
      body: Center(
        //
        // Here comes the definition of all the buttons from listentries.dart
        //
        child: widgetElements,
      ),
      bottomNavigationBar: bannerAd,
    );
  }
}
