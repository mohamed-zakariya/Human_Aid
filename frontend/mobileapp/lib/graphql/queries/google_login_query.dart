const String googleLoginMutation = '''
  mutation GoogleLogin(\$idToken: String!) {
    googleLogin(idToken: \$idToken) {
      user {
        id
        email
        name
      }
      accessToken
      refreshToken
    }
  }
''';
