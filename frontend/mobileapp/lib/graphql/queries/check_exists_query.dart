
const String checkUserUsernameExists = """
  query checkUserUsernameExists(\$username: String!){
  checkUserUsernameExists(username: \$username) {
    usernameExists
  }
}
""";

const String checkParentEmailExists = """
  query checkParentEmailExists(\$email: String!){
  checkParentEmailExists(email: \$email) {
    emailExists
  }
}
""";

const String checkUserEmailExists = """
  query checkUserEmailExists(\$email: String!){
  checkUserEmailExists(email: \$email) {
    emailExists
  }
}
""";