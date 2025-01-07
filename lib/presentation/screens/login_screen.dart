import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_app/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:google_maps_app/constants/my_colors.dart';
import 'package:google_maps_app/constants/strings.dart';
import 'package:google_maps_app/presentation/screens/otp_screen.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  late String phoneNumber;
  final GlobalKey<FormState> _phoneFormField = GlobalKey();

  Widget _buildIntroText() {
    return Column(
      children: [
        const Text(
          "What is your phone number? ",
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
          child: const Text(
            "Please enter your phone number to verify your account. ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPhonFormField() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.lightBlue),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              generateCountryFlag() + ' +20',
              style: TextStyle(fontSize: 18, letterSpacing: 2.0),
            ),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          flex: 2,
          child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.blue),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                autofocus: true,
                style: TextStyle(fontSize: 18, letterSpacing: 2.0),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number!';
                  } else if (value.length < 11) {
                    return 'Too short for a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              )),
        ),
      ],
    );
  }

  String generateCountryFlag() {
    String countryCode = 'eg';
    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }

  Future<void> _register(BuildContext context) async {
    if (!_phoneFormField.currentState!.validate()) {
      Navigator.pop(context);
      return;
    } else {
      Navigator.pop(context);
      _phoneFormField.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitedPhoneNumber(phoneNumber);
    }
  }

  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _register(context);
        },
        child: Text(
          "Next",
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
        if (state is PhoneNumberSubmited) {
          Navigator.pop(context);
          Navigator.pushNamed(context, otpScreen, arguments: phoneNumber);
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
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
              key: _phoneFormField,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroText(),
                    SizedBox(
                      height: 110,
                    ),
                    _buildPhonFormField(),
                    SizedBox(
                      height: 70,
                    ),
                    _buildNextButton(context),
                    _buildPhoneNumbrSubmitedBlock()
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
