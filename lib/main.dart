// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import 'app/config/environment.dart';
// import 'app/helpers/shared_preferences.dart';
// import 'app/routes/app_pages.dart';
// import 'app/theme/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await SharedPrefsHelper.init();

//   // System UI Overlay Style for both Android and iOS
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     systemNavigationBarColor: Colors.white,
//     systemNavigationBarIconBrightness: Brightness.dark,
//     statusBarColor: Colors.white,
//     statusBarIconBrightness: Brightness.dark,
//     statusBarBrightness: Brightness.light,
//   ));

//   // iOS-specific status bar style
//   if (Platform.isIOS) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//   }

//   String languageCode = await SharedPrefsHelper.getString(
//     SharedPrefsHelper.languageCode,
//     defaultValue: 'en',
//   );
//   if (languageCode.isEmpty) languageCode = 'en';

//   String countryCode = await SharedPrefsHelper.getString(
//     SharedPrefsHelper.countryCode,
//     defaultValue: 'US',
//   );
//   if (countryCode.isEmpty) countryCode = 'US';

//   runApp(MyApp(initialLocale: Locale(languageCode, countryCode)));
// }

// class MyApp extends StatelessWidget {
//   final Locale initialLocale;

//   const MyApp({super.key, required this.initialLocale});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: Environment.appName,
//       locale: initialLocale,
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       initialRoute: AppPages.initialPage,
//       getPages: AppPages.routes,
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context)
//               .copyWith(textScaler: const TextScaler.linear(1.0)),
//           child: child!,
//         );
//       },
//     );
//   }
// }

//after adding the firebase for push notification, the main.dart file is changed to this:

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'app/config/environment.dart';
import 'app/helpers/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp();

  /// Background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SharedPrefsHelper.init();

  // System UI Overlay Style for both Android and iOS
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // iOS-specific status bar style
  if (Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  String languageCode = await SharedPrefsHelper.getString(
    SharedPrefsHelper.languageCode,
    defaultValue: 'en',
  );
  if (languageCode.isEmpty) languageCode = 'en';

  String countryCode = await SharedPrefsHelper.getString(
    SharedPrefsHelper.countryCode,
    defaultValue: 'US',
  );
  if (countryCode.isEmpty) countryCode = 'US';

  runApp(MyApp(initialLocale: Locale(languageCode, countryCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  String? fcmToken;
  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    print("Permission: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("NOTIFICATION PERMISSION GRANTED");
    } else {
      print("NOTIFICATION PERMISSION DENIED");
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// 🔥 GET TOKEN
    fcmToken = await messaging.getToken();

    print("FCM TOKEN:");
    print(fcmToken);

    /// 🔁 TOKEN REFRESH
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("NEW TOKEN: $newToken");
      fcmToken = newToken;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received");

      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          id: 0,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked!");
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("App opened from terminated notification");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Environment.appName,
      locale: widget.initialLocale,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initialPage,
      getPages: AppPages.routes,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
