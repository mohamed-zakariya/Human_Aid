const String forgotPasswordMutation = """
  mutation ForgotPassword(\$email: String!) {
    forgotParentPassword(email: \$email) {
      message
    }
  }
""";

const String verifyOTPMutation = """
  mutation VerifyOTP(\$email: String!, \$otp: String!) {
    verifyParentOTP(email: \$email, otp: \$otp) {
      message
      token
    }
  }
""";

const String resetPasswordMutation = """
  mutation ResetPassword(\$token: String!, \$newPassword: String!) {
    resetParentPassword(token: \$token, newPassword: \$newPassword) {
      message
    }
  }
""";
