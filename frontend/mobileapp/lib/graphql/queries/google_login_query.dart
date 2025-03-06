const String googleLoginMutation = '''
  mutation googleLogin(\$idToken: String!) {
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
