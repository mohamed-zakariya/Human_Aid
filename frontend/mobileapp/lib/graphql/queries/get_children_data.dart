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