const String getChildrenDataQuery = """
  query getChildrenData(\$parentId: ID!) {
  getParentChildren(parentId: \$parentId) {
    name,
    username,
    gender,
    birthdate,
    nationality
  }
}
""";

const String deleteLearnerQuery = """
  mutation deleteLearner(\$parentId: String!, \$passwordParent: String!, \$usernameChild: String!){
  deleteChild(parentId: \$parentId, passwordParent: \$passwordParent, usernameChild: \$usernameChild){
    success,
    message
  }
}
""";

const String getLearnerProgressbyDateQuery= """

query getLearnerProgressbyDate(\$parentId: ID!){
  getLearnerDailyAttempts(parentId: \$parentId) {
    date
    users {
      username
      name
      correct_words {
        word_id
        spoken_word
      }
      incorrect_words {
        spoken_word
        word_id
      }
    }
  }
}

""";