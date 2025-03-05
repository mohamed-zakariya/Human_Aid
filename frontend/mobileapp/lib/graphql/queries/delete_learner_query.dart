const String deleteLearnerQuery = """
  mutation deleteLearner(\$parentId: String!, \$passwordParent: String!, \$usernameChild: String!){
  deleteChild(parentId: \$parentId, passwordParent: \$passwordParent, usernameChild: \$usernameChild){
    success,
    message
  }
}
""";