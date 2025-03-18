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

query getLearnerProgressbyDate(\$getLearnerDailyAttemptsParentId2: ID!){
  getLearnerDailyAttempts(parentId: \$getLearnerDailyAttemptsParentId2) {
    date
    user_id
    username
    name
    correct_words {
      spoken_word
      word_id
    }
    incorrect_words {
      __typename
      word_id
      spoken_word
    }
  
  }
}

""";