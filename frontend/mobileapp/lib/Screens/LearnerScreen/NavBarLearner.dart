import 'package:flutter/material.dart';
import 'package:mobileapp/Services/auth_service.dart';

import '../../generated/l10n.dart';
import '../../models/learner.dart';
import '../../models/parent.dart';

class NavBarLearner extends StatelessWidget {


  const NavBarLearner({super.key , this.learner});

  final Learner? learner;

  @override
  Widget build(BuildContext context) {


    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[900],
              ),
              accountName: Text(learner!.name),
              accountEmail:  Text(learner!.username),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset('assets/images/child2.png',
                  ),
                ),
              ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(S.of(context).ParentNavBarHome),
            onTap: (){
              Navigator.pushReplacementNamed(
                  context,
                  '/learnerHome',
                  arguments: learner!
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Children"),
            onTap: (){

            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("logout"),
            onTap: (){
              AuthService.logoutParent(context);
            },
          )

        ],
      ),
    );
  }
}
