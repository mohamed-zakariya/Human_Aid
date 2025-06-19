import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthParentService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: "945135521967-cemm5lhipph0oploa7b57u9ak7jjl6t2.apps.googleusercontent.com", // ⬅ Replace this with your actual Web Client ID
    forceCodeForRefreshToken: true,  // ⬅ Ensures a refresh token is issued
  );

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Ensure a fresh sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User canceled sign-in");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print("Google ID Token: ${googleAuth.idToken}"); // Debugging
      if (googleAuth.idToken == null) {
        throw Exception("Failed to retrieve Google ID Token.");
      }

      final response = await http.post(
        Uri.parse('https://human-aid-deployment.onrender.com/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': googleAuth.idToken, // Send valid token
        }),
      );

      print("Backend Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);   // match the key
        await prefs.setString('refreshToken', data['refreshToken']);
        return data;
      } else {
        throw Exception('Google Authentication Failed');
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
    }
  }
}
