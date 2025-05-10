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

query getLearnerDailyAttempts(\$parentId: ID!){
  getLearnerDailyAttempts(parentId: \$parentId) {
    date
    users {
      user_id
      username
      name
      correct_letters {
        correct_letter
      }
      incorrect_letters {
        spoken_letter
        correct_letter
      }
      correct_words {
        correct_word
      }
      incorrect_words {
        __typename
        correct_word
        spoken_word
      }
      correct_sentences {
        correct_sentence
      }
      incorrect_sentences {
        spoken_sentence
        incorrect_words {
          incorrect_word
          frequency
        }
      }
      game_attempts {
        game_id
        level_id
        attempts {
          score
        }
      }
    }
  }
}

""";

const String getLearnerProgress = """
query (\$parentId: ID!) {
  getLearnerOverallProgress(parentId: \$parentId) {
    id
    progress {
      user_id
      name
      username
      progress_by_exercise {
        exercise_id
        stats {
          total_correct {
            count
            items
          }
          total_incorrect {
            count
            items
          }
          total_items_attempted
          accuracy_percentage
          average_game_score
          time_spent_seconds
        }
      }
      overall_stats {
        total_time_spent
        combined_accuracy
        average_score_all
      }
    }
  }
}


""";


const String getLearnerProgress2 = """


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