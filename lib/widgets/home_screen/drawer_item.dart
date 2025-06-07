import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class DrawerItem extends StatelessWidget{
  final String title;
  final IconData icon;
  final void Function() onTap;

  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textLight),
      title: Text(
        title,
        style: TextStyle(color: AppColors.textLight),
      ),
      onTap: onTap
    );
  }
}