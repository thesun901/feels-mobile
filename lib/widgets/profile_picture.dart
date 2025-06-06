import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../screens/profile_screen.dart';

class ProfilePicture extends StatelessWidget {
  final String? uid;
  final String? username;
  final int size;

  const ProfilePicture({
    super.key,
    this.uid,
    this.username,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {

    void onTap() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(accountUid: uid, username: username),
        )
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: AppColors.textDim,
        radius: size.toDouble(),
        child: Icon(
          size: size.toDouble(),
          Icons.person,
          color: AppColors.cardBackground,
        ),
      ),
    );
  }
}