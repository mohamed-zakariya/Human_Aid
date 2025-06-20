import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../graphql/queries/user_forgot_password_query.dart';

class UserPasswordResetService {
  /// Sends a password reset request (OTP) to the given email for users
  static Future<String> forgotPassword(String email) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(forgotUserPasswordMutation),
        variables: {'email': email},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['forgotUserPassword']['message'];
  }

  /// Verifies the OTP sent to the email and retrieves a token for users
  static Future<String> verifyOTP(String email, String otp) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(verifyUserOTPMutation),
        variables: {'email': email, 'otp': otp},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['verifyUserOTP']['token'];
  }

  /// Resets the password using the token obtained from OTP verification for users
  static Future<String> resetPassword(String token, String newPassword) async {
    final client = await GraphQLService.getClient();
    final result = await client.mutate(
      MutationOptions(
        document: gql(resetUserPasswordMutation),
        variables: {'token': token, 'newPassword': newPassword},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['resetUserPassword']['message'];
  }
}