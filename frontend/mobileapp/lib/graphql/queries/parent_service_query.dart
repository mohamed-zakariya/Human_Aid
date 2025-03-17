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
  getLearnerProgressbyDate(parentId: \$parentId) {
    id
    
    progress {
      correct_words
      incorrect_words {
        incorrect_word
      }
      exercise_id
      exercise_time_spent {
        date
      }
      user_id
    }
  }
}

""";