const String googleLoginMutation = """
mutation LoginWithGoogle(\$token: String!) {
  loginWithGoogle(token: \$token) {
    accessToken
    refreshToken
    parent {
      id
      name
      email
    }
  }
}
""";