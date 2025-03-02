import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/NavBarParent.dart';

import '../../models/parent.dart';

class Parenthome extends StatelessWidget {
  const Parenthome({super.key, this.parent});

  final Parent? parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarParent(parent: parent!,),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text("welcome ${parent!.name}"),
        centerTitle: true,
      ),
      body: const Text(""),
    );
  }
}
