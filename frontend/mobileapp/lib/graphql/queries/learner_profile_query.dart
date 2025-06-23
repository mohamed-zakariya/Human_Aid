const String getLearnerProfileQuery = '''
  query(\$userId: ID!) {
    learnerProfile(userId: \$userId) {
      name
      email
      username
      nationality
      birthdate
      gender
      parentName
      totalTimeSpent
    }
  }
''';