import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';

import '../../../common/utils/colors.dart';
import '../../../common/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_picker/country_picker.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (countrySelected) {
          setState(() {
            country = countrySelected;
            phoneController.text = '+${country!.phoneCode}';
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void sendPhoneNumber(){
    String phoneNumber = phoneController.text.trim();
    if(country != null && phoneNumber.isNotEmpty){
      ref.read(authControllerProvider).signInWithPhone(context, phoneNumber);
    }
    else{
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    phoneController.selection =
        TextSelection.collapsed(offset: phoneController.text.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        elevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height/20),
                const Text('WhatsApp will need to verify your phone number.'),
                SizedBox(height: size.height/40),
                TextButton(
                  onPressed: pickCountry,
                  child: const Text('Pick Country'),
                ),
                SizedBox(height: size.height/60),
                SizedBox(
                  width: size.width * 0.7,
                  child: TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: 'phone number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(height: size.height * 0.5),
                SizedBox(
                  width: 90,
                  child: CustomButton(
                    onPressed: sendPhoneNumber,
                    text: 'NEXT',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
