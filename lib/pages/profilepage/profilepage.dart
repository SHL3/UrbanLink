import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urbanlink_project/models/user.dart';
import 'package:urbanlink_project/pages/loginpage/login.dart';
import 'package:urbanlink_project/repositories/user_database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _profileHeight = 200;
  static const double _profileRound = 40;

  late MyUser myUser;

  void setUser() async {
    if (FirebaseAuth.instance.currentUser == null) {
      myUser = MyUser(
          userId: 'Unknown',
          userName: 'Unknown',
          userEmail: 'Unknown',
          userExplanation: 'Unknown');
    } else {
      myUser = await UserDatabaseService.getUserById(
          FirebaseAuth.instance.currentUser!.uid);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textProfileUserStyle =
        TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    var textProfileDescriptionStyle = const TextStyle(fontSize: 20);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                // goto Login Page
                Get.offAll(const LoginPage());
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            profileBox(textProfileUserStyle, textProfileDescriptionStyle),
            const Text('Post List', style: textProfileUserStyle),
            postListView(context),
          ],
        ));
  }

  Container profileBox(
      TextStyle textProfileUserStyle, TextStyle textProfileDescriptionStyle) {
    return Container(
        height: _profileHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_profileRound),
            topRight: Radius.circular(_profileRound),
            bottomLeft: Radius.circular(_profileRound),
            bottomRight: Radius.circular(_profileRound),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const CircleAvatar(
                  minRadius: 60.0,
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                        AssetImage('assets/images/profileImage.jpeg'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(userName, style: textProfileUserStyle),
                      Text(explanation, style: textProfileDescriptionStyle),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Expanded postListView(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _postList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: const Icon(Icons.arrow_right),
              title: Text(_postList[index].postTitle),
            );
          }),
    );
  }
}
