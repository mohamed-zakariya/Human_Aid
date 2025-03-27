const String getChildrenDataQuery = """
  query getChildrenData(\$parentId: ID!) {
  getParentChildren(parentId: \$parentId) {
    id
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
        correct_word
      }
      incorrect_words {
        spoken_word
        correct_word
        word_id
      }
    }
  }
}

""";

const String getLearnerProgress = """
query getLearnerOverallProgress(\$getLearnerOverallProgressParentId2: ID!){
  getLearnerOverallProgress(parentId: \$getLearnerOverallProgressParentId2) {
    id
    progress {
      average_accuracy
      user_id
      total_correct_words {
        words
      }
      total_incorrect_words {
        words
      } 
    }
  } 
}


""";
