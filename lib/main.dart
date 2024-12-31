import 'package:auction/config/theme.dart';
import 'package:auction/models/user_model.dart';
import 'package:auction/utils/notification_handler.dart';
import 'package:auction/firebase_options.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:auction/route.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/providers/theme_provider.dart';
import 'package:auction/providers/chat_provider.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/my_provider.dart';
import 'package:auction/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcmToken : $fcmToken');

  // Firebase Messaging 설정          
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final notificationHandler = NotificationHandler(router: router);
  await notificationHandler.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<NotificationHandler>.value(value: notificationHandler),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationHandler =
        Provider.of<NotificationHandler>(context, listen: false);

    UserModel? currentUser = authProvider.currentUserModel;

    if (currentUser != null) {
      print("User is logged in: ${currentUser.nickname}");
      await userProvider.fetchUser(currentUser.uid);
      final token = await notificationHandler.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await authProvider.updatePushToken(token);
        await userProvider.updatePushToken(currentUser.uid, token);
      }
    } else {
      print("No user is currently logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          darkTheme: darkThemeData(),
          themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
