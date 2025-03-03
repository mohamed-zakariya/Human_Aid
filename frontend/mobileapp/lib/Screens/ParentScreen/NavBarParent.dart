import 'package:flutter/material.dart';

import '../../Services/auth_service.dart';
import '../../generated/l10n.dart';
import '../../models/parent.dart';

class NavBarParent extends StatelessWidget {


  const NavBarParent({super.key , this.parent});

  final Parent? parent;

  @override
  Widget build(BuildContext context) {


    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(parent!.name),
              accountEmail:  Text(parent!.email),
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
                  '/parentHome',
                  arguments: parent!
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
