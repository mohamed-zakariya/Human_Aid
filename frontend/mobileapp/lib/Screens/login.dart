import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/home.dart';
import 'package:mobileapp/Services/auth_service.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/parent.dart';


import '../models/user.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async{
    print("entered");

    String email = _usernameController.text;
    String password = _passwordController.text;

    print("user loged with username: $email");
    print("user loged with password: $password");

    Parent? parent = await AuthService.loginParent(email, password);
    if(parent != null){
      print(parent.name);
      Navigator.pushReplacementNamed(
        context,
        '/parentHome',
        arguments: parent);
    }
    else{
      print("Enter the right username && password");
    }
  }

  void handleLoginUser() async{
    print("entered");

    String username = _usernameController.text;
    String password = _passwordController.text;

    print("user loged with username: $username");
    print("user loged with password: $password");

    Learner? learner = await AuthService.loginLearner(username, password);
    if(learner != null){
      print(learner.name);
      Navigator.pushReplacementNamed(
          context,
          '/learnerHome',
          arguments: learner);
    }
    else{
      print("Enter the right username && password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Login Page", style: TextStyle(
          color: Colors.white
        ),),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Container(
        padding: const EdgeInsets.all(60),
        child:  Column(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "enter you username",
                ),
              ),
            ),
            const SizedBox(height: 20,),
             SizedBox(
              width: 300,
              child: TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "enter you password",
                ),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                  // handleLogin();
                  handleLoginUser();
                },
                child: const Text("Login")),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/signup1');
                },
                child: const Text("Signup for Parent"))
            ,
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/signupAdult');
                },
                child: const Text("Signup for Adult"))
          ],
        ),
      ),
    );
  }
}
