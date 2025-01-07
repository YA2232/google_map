// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_app/app_router.dart';
import 'package:google_maps_app/constants/strings.dart';
import 'package:google_maps_app/presentation/screens/map.dart';
import 'package:google_maps_app/presentation/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatelessWidget {
  AppRouter appRouter;
  MyApp({
    Key? key,
    required this.appRouter,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: mapPage,
    );
  }
}
