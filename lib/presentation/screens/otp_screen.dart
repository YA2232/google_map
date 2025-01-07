import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_app/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:google_maps_app/constants/my_colors.dart';
import 'package:google_maps_app/constants/strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  final phoneNumber;
  OtpScreen({required this.phoneNumber, super.key});
  late String otpCode;

  Widget _buildIntroText() {
    return Column(
      children: [
        const Text(
          "Verify your phone number",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
            text: TextSpan(
              text: 'Enter Your 6 digit code numbers sent to',
              style: TextStyle(color: Colors.black, fontSize: 18, height: 1.4),
              children: [
                TextSpan(
                  text: '$phoneNumber',
                  style: TextStyle(color: MyColors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.black),
        ),
      ),
    );
    showDialog(
        barrierColor: Colors.white.withOpacity(0),
        barrierDismissible: false,
        context: context,
        builder: (cotnext) {
          return alertDialog;
        });
  }

  Widget _buildPhoneNumbrSubmitedBlock() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, currunt) {
        return previous != currunt;
      },
      listener: (context, state) {
        if (state is Loading) {
          showProgressIndicator(context);
        }
      },
    );
  }

  Widget _buildPinCode(BuildContext context) {
    return Container(
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        autoFocus: true,
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          borderWidth: 1,
          activeColor: MyColors.blue,
          inactiveColor: MyColors.blue,
          inactiveFillColor: Colors.white,
          activeFillColor: MyColors.lightBlue,
          selectedColor: MyColors.blue,
          selectedFillColor: Colors.white,
        ),
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        onCompleted: (code) {
          otpCode = code;
          print("Completed");
        },
        onChanged: (value) {
          print(value);
        },
      ),
    );
  }

  void _login(BuildContext context) {
    BlocProvider.of<PhoneAuthCubit>(context).submitOtp(otpCode);
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _login(context);
        },
        child: Text(
          "verify",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(110, 50),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildPhoneVerificationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, currunt) {
        return previous != currunt;
      },
      listener: (context, state) {
        if (state is Loading) {
          showProgressIndicator(context);
        }
        if (state is PhoneOtpVerifyd) {
          Navigator.pop(context);
          Navigator.of(context).pushReplacementNamed(mapScreen);
        }
        if (state is Erorr) {
          Navigator.pop(context);
          String erorr = (state).erorrMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(erorr),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 32, vertical: 88),
        child: Column(
          children: [
            _buildIntroText(),
            SizedBox(
              height: 88,
            ),
            _buildPinCode(context),
            SizedBox(
              height: 60,
            ),
            _buildVerifyButton(context),
            _buildPhoneVerificationBloc(),
          ],
        ),
      ),
    );
  }
}
