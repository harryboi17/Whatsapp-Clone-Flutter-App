import 'package:flutter/material.dart';

import '../../auth/screens/login_screen.dart';
import '../../../common/utils/colors.dart';
import '../../../common/widgets/custom_button.dart';
class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    void navigateToLoginScreen(BuildContext context) {
      Navigator.pushNamed(context, LoginScreen.routeName);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height/12),
              const Text(
                'Welcome to WhatsApp',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: size.height / 9),
              Image.asset(
                'assets/bg.png',
                height: 320,
                width: 320,
                color: tabColor,
              ),
              SizedBox(height: size.height / 9),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                  style: TextStyle(color: greyColor),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: size.height/27),
              SizedBox(
                width: size.width * 0.75,
                child: CustomButton(
                  text: 'AGREE AND CONTINUE',
                  onPressed: () => navigateToLoginScreen(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
