import 'dart:io';

import 'package:auction/providers/post_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../config/color.dart';

class PostImageItem extends StatelessWidget {
  final String imageUrl;
  final int index;

  const PostImageItem({super.key, required this.imageUrl, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostImageProvider>(
      builder: (context, postImageProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Stack(
            clipBehavior: Clip.none, //자식위젯이 경계를 넘어도 잘리지 않음
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                    width: 70,
                    height: 70,
                    child: imageUrl.startsWith("http") ?
                        Image.network(imageUrl,fit: BoxFit.cover,) :
                    Image.file(File(imageUrl), fit: BoxFit.cover,)),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: GestureDetector(
                  onTap: () {
                    // 삭제 버튼이 눌렸을 때 실행할 코드
                    postImageProvider.deleteImage(index);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: const Icon(Icons.close, size: 15),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }


}
