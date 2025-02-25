import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  final String userId; // User ID of the profile being viewed

  UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late bool isFollowing;
  List<String> followingUsers = [];

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<String> followedUsers = List<String>.from(userDoc['following'] ?? []);
    setState(() {
      followingUsers = followedUsers;
      isFollowing = followedUsers.contains(widget.userId);
    });
  }

  Future<void> _followUser(String otherUserId) async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    await userRef.update({
      'following': FieldValue.arrayUnion([otherUserId]),
    });

    setState(() {
      followingUsers.add(otherUserId);
      isFollowing = true;
    });
  }

  Future<void> _unfollowUser(String otherUserId) async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    await userRef.update({
      'following': FieldValue.arrayRemove([otherUserId]),
    });

    setState(() {
      followingUsers.remove(otherUserId);
      isFollowing = false;
    });
  }

  Future<List<DocumentSnapshot>> _getUserRecipes() async {
    QuerySnapshot recipesSnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('userId', isEqualTo: widget.userId)
        .get();

    return recipesSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("User Recipes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: isFollowing ? Icon(Icons.person_remove) : Icon(Icons.person_add),
                  onPressed: () {
                    if (isFollowing) {
                      _unfollowUser(widget.userId);
                    } else {
                      _followUser(widget.userId);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _getUserRecipes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> recipes = snapshot.data!;

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    var recipe = recipes[index];
                    return Card(
                      child: ListTile(
                        title: Text(recipe['name']),
                        subtitle: Text(recipe['description']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
