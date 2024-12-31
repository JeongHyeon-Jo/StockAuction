import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultAppbar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final double fontSize;
  final bool existIcon;
  const DefaultAppbar({super.key, required this.title, this.existIcon = true, this.fontSize = 20.0, });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize),
      ),
      leading: existIcon ? IconButton(
        icon: const Icon(Icons.arrow_back), // 뒤로가기 아이콘
        onPressed: () {
          context.pop(); // 이전 페이지로 이동
        },
      ) : null,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
