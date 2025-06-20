const String forgotUserPasswordMutation = """
  mutation ForgotUserPassword(\$email: String!) {
    forgotUserPassword(email: \$email) {
      message
    }
  }
""";

const String verifyUserOTPMutation = """
  mutation VerifyUserOTP(\$email: String!, \$otp: String!) {
    verifyUserOTP(email: \$email, otp: \$otp) {
      message
      token
    }
  }
""";

const String resetUserPasswordMutation = """
  mutation ResetUserPassword(\$token: String!, \$newPassword: String!) {
    resetUserPassword(token: \$token, newPassword: \$newPassword) {
      message
    }
  }
""";