import 'package:expensetracking/screens/authentication/phone_screen.dart';
import 'package:expensetracking/providers/db_provider.dart';
import 'package:expensetracking/screens/home.dart';
import 'package:expensetracking/screens/singleProject/navigation_bar.dart';
import 'package:expensetracking/screens/singleProject/new_navigation_bar.dart';
import 'package:expensetracking/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DbProvider())
      ],
      child: MaterialApp(
      theme: ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey[900],
    hintColor: Colors.teal,),
        title: 'Expense Tracker',
        // theme: ThemeData(
        //     primarySwatch: Colors.red
        // ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? firebaseUser;
  Widget initialScreen = const SplashScreen();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2), checkAuthState);
  }

  checkAuthState() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        initialScreen = PhoneScreen();
      } else {
        await context.read<DbProvider>().getUserFromFirestore(user: user);
        initialScreen =  BottomAppbarFABScreen();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialScreen;
  }
}
