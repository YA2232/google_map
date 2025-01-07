import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_app/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:google_maps_app/constants/strings.dart';
import 'package:google_maps_app/presentation/screens/login_screen.dart';
import 'package:google_maps_app/presentation/screens/map.dart';
import 'package:google_maps_app/presentation/screens/map_screen.dart';
import 'package:google_maps_app/presentation/screens/otp_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;
  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: LoginScreen(),
                ));
      case mapScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: MapScreen(),
                ));
      case mapPage:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: MapPage(),
                ));
      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: OtpScreen(phoneNumber: phoneNumber),
                ));
      default:
        return null;
    }
  }
}
