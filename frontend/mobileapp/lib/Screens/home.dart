import 'package:flutter/material.dart';

import '../models/user.dart';

class Home extends StatefulWidget {
  final User user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late User user;

  @override
  void initState() {
    // TODO: implement initState
    user = widget.user;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text("Home Page", style: TextStyle(
          color: Colors.white
        ),),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(50),
            child: Text(user.name, style: const TextStyle(
              color: Colors.white,

            ),),
          ),
          ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              }
          , child: Text("Logout")
          )
        ],

      ),
    );
  }
}
