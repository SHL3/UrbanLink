import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urbanlink_project/database/user_database_service.dart';
import 'package:urbanlink_project/widgets/menu_drawer_widget.dart';
import 'package:urbanlink_project/models/user.dart';
import 'package:urbanlink_project/database/post_database_service.dart';
import 'package:get/get.dart';
import 'package:urbanlink_project/models/posts.dart';
import 'package:urbanlink_project/pages/postpage/postedpage.dart';
import 'package:urbanlink_project/services/auth.dart';

class MyPostList extends StatefulWidget {
  final Stream<List<Post>>? postStream;

  const MyPostList({Key? key, this.postStream}) : super(key: key);

  @override
  State<MyPostList> createState() => _MyPostListState();
}

class _MyPostListState extends State<MyPostList> {
  Widget _buildPost(Post post) {
    return Card(
      shadowColor: Colors.grey,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.fromLTRB(50, 30, 50, 30),
      child: SizedBox(
        height: 50,
        width: 30,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: Text(
              post.postTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.postContent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                '${post.postCreatedTime.month}/${post.postCreatedTime.day}/${post.postCreatedTime.year}',
                style: const TextStyle(fontWeight: FontWeight.w300,),
              ),
            ],
          ),
          onTap: () {
            Get.to(() => const PostedPage(), arguments: post);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPostsPage = Get.currentRoute == '/PostsPage';
    return Expanded(
      child: StreamBuilder<List<Post>>(
        stream: widget.postStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e(snapshot.error ?? 'Unknown error');
            return Center(
              child: Text('Error: ${snapshot.error ?? 'Unknown error'}'),
            );
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            if (posts.isEmpty && isPostsPage == true) {
              return const Center(
                child: Text('이 커뮤니티에는 포스트가 없습니다.\n글을 작성하여 이곳에 첫 포스트를 남겨보세요!'),
              );
            }
            return GridView.builder(
                scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPost(posts[index]);
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              )
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.postStream});
  final Stream<List<Post>>? postStream;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription<MyUser?>? _subscription;
  MyUser? _myUser;


  @override
  void initState() {
    super.initState();
    _subscribeToUserChanges();
  }

  @override
  void dispose() {
    _unsubscribeFromUserChanges();
    super.dispose();
  }

  void _subscribeToUserChanges() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _subscription = UserDatabaseService.getUserById(currentUser.uid)
          .asStream()
          .listen((myUser) {
        setState(() {
          _myUser = myUser;
        });
      });
    }
  }

  void _unsubscribeFromUserChanges() {
    _subscription?.cancel();
    _subscription = null;
  }

  Widget profileBox(MyUser? profileUser) {
    const double profileRound = 40;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      //height: profileHeight,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(225, 225, 225, 0.3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(profileRound),
            topRight: Radius.circular(profileRound),
            bottomLeft: Radius.circular(profileRound),
            bottomRight: Radius.circular(profileRound),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(  //사진
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                minRadius: 40.0,
                backgroundColor: Colors.grey,
                child: CircleAvatar(
                  radius: 37.0,
                  backgroundImage:
                  AssetImage('assets/images/profileImage.jpeg'),
                ),
              ),
            ),
            Padding(  //이름
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 7),
              child: Text(profileUser?.userName ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(250, 63, 186, 219),
        shadowColor: Colors.transparent,
      ),
      endDrawer: MenuDrawer(
        myUser: _myUser,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Container(
              color: const Color.fromARGB(250, 63, 186, 219),
              child: Flexible(  //프로필+티켓
                fit: FlexFit.tight,
                child: Row(
                  children: [
                    Flexible(  //프로필
                      flex: 4,
                      fit: FlexFit.tight,
                      child: SizedBox(
                        child: profileBox(_myUser),
                        height: double.infinity,
                        //color: Colors.indigoAccent,
                      ),
                    ),
                    const Flexible(  //티켓: 좋아하는 장소 등록하기
                      flex: 6,
                      fit: FlexFit.tight,
                      child: SizedBox(
                        height: double.infinity,
                        width: 50,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  MyPostList(
                    postStream: widget.postStream ?? PostDatabaseService.getPostsByUserId(
                        _myUser?.userId ?? 'Unknown'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}