import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:receipt_pro/services/helpers.dart';

class ForgotPasswordModal extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordModalState createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  String resetPasswordMethod = "BY_SMS"; // Default to SMS
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isEmailValid = true;
  bool isPhoneValid = true;
  String phone = "";
  String forgotUsername = "";

  void checkEmailFormat() {
    setState(() {
      isEmailValid = emailController.text.contains("@");
    });
  }

  Future<void> resetPassword(BuildContext context, String? email) async {
    print("resetPassword called, email = $email");
    if (email == null || email.trim() == "") {
      await showPopup(
        context,
        FlutterI18n.translate(context, "PROMPT_ENTER_EMAIL"),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent.');
      await showPopup(
        context,
        FlutterI18n.translate(context, "PASSWORD_RESET_EMAIL_SENT"),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          FlutterI18n.translate(context, "FORGOT_PASSWORD"),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: FlutterI18n.translate(context, "ENTER_EMAIL"),
              errorText:
                  isEmailValid
                      ? null
                      : FlutterI18n.translate(context, "INVALID_EMAIL"),
            ),
            onChanged: (value) => checkEmailFormat(),
          ),
          SizedBox(height: 15),

          // Reset Password Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
            onPressed: () {
              resetPassword(context, emailController.text);
            },
            child: Text(FlutterI18n.translate(context, "RESET_PASSWORD")),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(FlutterI18n.translate(context, "CLOSE")),
        ),
      ],
    );
  }
}
