
const String checkUserUsernameExists = """
  query checkUsernameExists(\$username: String!){
  checkUserUsernameExists(username: \$username) {
    usernameExists
  }
}
""";

const String checkParentEmailExists = """
  query checkEmailExists(\$email: String!){
  checkParentEmailExists(email: \$email) {
    emailExists
  }
}
""";

const String checkUserEmailExists = """
  query checkEmailExists(\$email: String!){
  checkUserEmailExists(email: \$email) {
    emailExists
  }
}
""";