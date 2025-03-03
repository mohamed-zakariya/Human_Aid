const String signupParentQuery = """
  mutation createparentAccount(\$parent: AddParentData!){
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
  mutation createChildAccount(\$child: AddChildData!){
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
  mutation createAdultAccount(\$adult: AddAdultData){
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


