import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<bool> authenticate(String phone, String otp) async {
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(minutes: 10),
        verificationCompleted: null,
        verificationFailed: null,
        codeSent: null,
        codeAutoRetrievalTimeout: null);
  }

  Future<bool> isAuthenticated() async {}
}
