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

query getLearnerDailyAttempts(\$parentId: ID!) {
  getLearnerDailyAttempts(parentId: \$parentId) {
    date
    users {
      user_id
      name
      username
      correct_words {
        word_id
        correct_word
        spoken_word
      }
      incorrect_words {
        word_id
        correct_word
        spoken_word
      }
      correct_letters {
        letter_id
        correct_letter
        spoken_letter
      }
      incorrect_letters {
        letter_id
        correct_letter
        spoken_letter
      }
      correct_sentences {
        sentence_id
        correct_sentence
        spoken_sentence
      }
      incorrect_sentences {
        sentence_id
        correct_sentence
        spoken_sentence
      }
      game_attempts {
        game_id
        level_id
        game_name
        game_arabic_name
        level_arabic_name
        level_name
        attempts {
          score
          timestamp
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

const String getParentProfileQuery = """

  query parentProfile(\$parentId: ID!) {
    parentProfile(parentId: \$parentId) {
      id
      name
      email
      phoneNumber
      nationality
      birthdate
      gender
    }
  }

""";