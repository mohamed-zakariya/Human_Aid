import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/forgot_password_query.dart';

class PasswordResetService {
  /// Sends a password reset request (OTP) to the given email
  static Future<String> forgotPassword(String email) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(forgotPasswordMutation),
        variables: {'email': email},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['forgotParentPassword']['message'];
  }

  /// Verifies the OTP sent to the email and retrieves a token
  static Future<String> verifyOTP(String email, String otp) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(verifyOTPMutation),
        variables: {'email': email, 'otp': otp},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['verifyParentOTP']['token'];
  }

  /// Resets the password using the token obtained from OTP verification
  static Future<String> resetPassword(String token, String newPassword) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(resetPasswordMutation),
        variables: {'token': token, 'newPassword': newPassword},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['resetParentPassword']['message'];
  }
}
