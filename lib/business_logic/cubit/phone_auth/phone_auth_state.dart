part of 'phone_auth_cubit.dart';

@immutable
sealed class PhoneAuthState {}

final class PhoneAuthInitial extends PhoneAuthState {}

class Loading extends PhoneAuthState {}

class Erorr extends PhoneAuthState {
  final String erorrMsg;
  Erorr({required this.erorrMsg});
}

class PhoneNumberSubmited extends PhoneAuthState {}

class PhoneOtpVerifyd extends PhoneAuthState {}
