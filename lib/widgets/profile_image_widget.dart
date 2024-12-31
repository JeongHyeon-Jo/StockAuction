import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImageSelector extends StatefulWidget {
  final Function(String) onImageSelected;
  final String initialImage;

  ProfileImageSelector({required this.onImageSelected, required this.initialImage});

  @override
  _ProfileImageSelectorState createState() => _ProfileImageSelectorState();
}

class _ProfileImageSelectorState extends State<ProfileImageSelector> {
  late String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.initialImage;
  }

  final List<String> imageOptions = [
    'default_blue.png',
    'default_green.png',
    'default_mint.png',
    'default_red.png',
    'default_yellow.png',
  ];

  Future<void> _showImageOptions() async {
    final storage = FirebaseStorage.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('프로필 이미지 선택'),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: imageOptions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: storage.ref('userProfileImages/defaultImage/${imageOptions[index]}').getDownloadURL(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = snapshot.data as String;
                          });
                          widget.onImageSelected(selectedImage);
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data as String),
                          radius: 30,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(selectedImage),
            radius: 50,
          ),
          SizedBox(height: 10),
          Text('프로필 이미지 선택'),
        ],
      ),
    );
  }
}