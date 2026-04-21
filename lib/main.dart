import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receipt_pro/billing/billing_service.dart';
import 'package:receipt_pro/firebase_options.dart';
import 'package:receipt_pro/home.dart';
import 'package:receipt_pro/menu.dart';
import 'package:receipt_pro/modals/forgot_password.dart';
import 'package:receipt_pro/services/storage_service.dart';
import 'router/app_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic MyUser;
bool isAppOnline = true;
bool NOW_LOGGED_IN = false;
dynamic defaultLanguage = {
  "LID": "8",
  "name1": "English",
  "name2": "LANGUAGE_GLISH",
  "value": "en",
};
dynamic selectedLanguage = defaultLanguage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});
  List<BaseDecodeStrategy> decodeStrategies = [JsonDecodeStrategy()];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            decodeStrategies: decodeStrategies,
            basePath: "assets/i18n",
            fallbackFile: "en",
            useCountryCode: false,
          ),
          missingTranslationHandler: (key, locale) {
            print(
              "--- Missing Key: $key, languageCode: ${locale?.languageCode}",
            );
          },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: const MyMain(title: 'Receipt Pro'),
    );
  }
}

class MyMain extends StatefulWidget {
  const MyMain({super.key, required this.title});
  final String title;

  @override
  State<MyMain> createState() => MyMainState();
}

class MyMainState extends State<MyMain> {
  bool isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showPassword = false;
  bool isIOS = false;
  TextEditingController forgotEmailController = TextEditingController();

  updateSelf() {
    print("MyMainState updateSelf called");
    setState(() {});
  }

  setUser() async {
    String? myUserStr = await StorageService().getData("USER");
    print("Main.setLoggedIn SETTING LOGGED IN TRUE! myUserStr = $myUserStr");
    //setState(() {
    NOW_LOGGED_IN = true;
    if (myUserStr != null) {
      MyUser = (json.decode(myUserStr)) as dynamic;
    }
    //});
  }

  removeUser() async {
    await StorageService().removeData("USER");
    //setState(() async {
    NOW_LOGGED_IN = false;
    //});
  }

  setLoggedIn() async {
    print("Main.setLoggedIn called");

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await removeUser();
    } else {
      await setUser();
    }
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          removeUser();
        });
      } else {
        print('User is signed in: ${user.email}');
        setState(() {
          setUser();
        });
      }
    });
  }

  @override
  initState() {
    print("Main/Login initState called");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb == false) {
        if (Platform.isIOS) {
          isIOS = true;
        }
        await BillingService().initializeInAppPurchase(context);
      }
      await setLoggedIn();
      String languageCode =
          (await StorageService().getData("LANGUAGE")) ?? "en";
      await FlutterI18n.refresh(context, Locale(languageCode));
      updateSelf();
    });
  }

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print("User registered: ${userCredential.user?.uid}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in!'), backgroundColor: Colors.green),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.toString();
      if (e.message ==
          "The email address is already in use by another account.") {
        message = 'User already exists.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
      print("FirebaseAuthException: ${e.code} - ${e.message}");
    } catch (e) {
      print("Unknown error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _signIn() async {
    try {
      String email = _emailController.text.trim();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in!'), backgroundColor: Colors.green),
      );
      NOW_LOGGED_IN = true;
      await StorageService().setData("IS_LOGGED_IN", "true");
      MyUser = {"Username": email.split("@")[0]};
      await StorageService().setData("USER", jsonEncode(MyUser));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException = $e");
      // ignore: unrelated_type_equality_checks
      if (e.message ==
          "The supplied auth credential is incorrect, malformed or has expired.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User does not exist. Please sign up.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> goHome() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> logout() async {
    await StorageService().setData("IS_LOGGED_IN", "false");
    await StorageService().removeData("USER");
    await FirebaseAuth.instance.signOut();
    setState(() {
      NOW_LOGGED_IN = false;
    });
  }

  void showForgotPasswordModal(BuildContext context) {
    showDialog(context: context, builder: (context) => ForgotPasswordModal());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize =
        (screenWidth * 0.022 + 4) < 16 ? 16 : (screenWidth * 0.022 + 4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(FlutterI18n.translate(context, "APP_TITLE")),
        centerTitle: true,
        actions: [
          if (NOW_LOGGED_IN == true)
            FittedBox(
              child: TextButton.icon(
                icon: Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: goHome,
                label: Text(
                  FlutterI18n.translate(context, "HOME"),
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Color.fromARGB(255, 230, 250, 230),
                ),
              ),
            ),
          Menu(context: context, page: 'main', updateParent: updateSelf),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: FlutterI18n.translate(context, "EMAIL"),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: FlutterI18n.translate(context, "PASSWORD"),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: togglePasswordVisibility,
                ),
              ),
              obscureText: !showPassword,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final email = forgotEmailController.text.trim();
                //resetPassword(context, email);
                showForgotPasswordModal(context);
              },
              child: Text(
                textAlign: TextAlign.left,
                "${FlutterI18n.translate(context, "FORGOT_PASSWORD")}?",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: Text(
                      FlutterI18n.translate(context, "SIGN_IN"),
                      style: TextStyle(fontSize: titleFontSize),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: Text(
                      FlutterI18n.translate(context, "SIGN_UP"),
                      style: TextStyle(fontSize: titleFontSize),
                    ),
                  ),
                ),
              ],
            ),
            if (NOW_LOGGED_IN == true)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 232, 184, 175),
                        ),
                        child: Text(
                          FlutterI18n.translate(context, "LOGOUT"),
                          style: TextStyle(fontSize: titleFontSize),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
