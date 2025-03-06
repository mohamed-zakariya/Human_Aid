const String signupParentQuery = """
  mutation signUpParent(\$parent: AddParentData!){
  signUpParent(parent: \$parent) {
    parent{
      id,
      name,
      phoneNumber,
      email,
      birthdate,
      nationality,
      gender,
    }
    accessToken,
    refreshToken
  }
}
""";

const String signupChildQuery = """
  mutation signUpChild(\$child: AddChildData!){
  signUpChild(child: \$child) {
    child{
      name,
      username,
      nationality,
      gender,
      role,
    },
    parentId
  }
}
""";


const String signupAdultQuery = """
  mutation signUpAdult(\$adult: AddAdultData){
  signUpAdult(adult: \$adult) {
    adult {
      name,
      username,
      email,
      phoneNumber,
      nationality,
      birthdate,
      gender,
      role
    },
    accessToken,
    refreshToken
  }
}
""";


