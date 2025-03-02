const String loginQuery = """
  query login(\$username: String!, \$password: String!) {
  login(username: \$username, password: \$password) {
    token,
    user {
      id,
      name,
      username
    }
  }
}

""";

const String loginParentQuery = """
  mutation loginParent(\$email: String!, \$password: String!){
  loginParent(email: \$email, password: \$password) {
    parent {
      id,
      name,
      email,
      linkedChildren {
        name,
      }
    },
    accessToken,
    refreshToken
  }
}

""";

const String loginUserQuery = """
  mutation loginUser(\$username: String!, \$password: String!){
  login(username: \$username, password: \$password) {
    user {
      id,
      name,
      email,
      username,
      name,
      role,
      gender,
      nationality
    }
    accessToken,
    refreshToken
  }
}

""";