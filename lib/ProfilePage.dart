import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<String> userRecipes = [];
  List<String> followingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load User's Recipes & Followings
  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (userDoc.exists) {
      setState(() {
        userRecipes = List<String>.from(userDoc['recipes'] ?? []);
        followingUsers = List<String>.from(userDoc['following'] ?? []);
      });
    }
  }

  // 🔹 Follow another user
  void _followUser(String otherUserId) async {
    if (!followingUsers.contains(otherUserId)) {
      setState(() {
        followingUsers.add(otherUserId);
      });

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'following': followingUsers,
      });
    }
  }

  // 🔹 Unfollow User
  void _unfollowUser(String otherUserId) async {
    if (followingUsers.contains(otherUserId)) {
      setState(() {
        followingUsers.remove(otherUserId);
      });

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'following': followingUsers,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user?.photoURL ?? "https://via.placeholder.com/150"),
                  radius: 40,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.displayName ?? "User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // 🔹 User's Recipes
            Text("My Recipes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...userRecipes.map((recipe) => ListTile(
              title: Text(recipe),
            )),

            // 🔹 Users Followed
            Text("Following", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...followingUsers.map((userId) => ListTile(
              title: Text("User ID: $userId"),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _unfollowUser(userId),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
