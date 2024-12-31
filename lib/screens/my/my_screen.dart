import 'dart:io';
import 'package:auction/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ThemeProvider 사용을 위해 provider 패키지 임포트
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _nickname = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nickname = userData['nickname'] ?? '';
            _profileImageUrl = userData['userProfileImage'] ?? '';
          });
        }
      } catch (e) {
        print('오류 발생: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File image) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('userProfileImages/${user.uid}.jpg');

        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'userProfileImage': downloadUrl});

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 변경되었습니다.')),
        );
      } catch (e) {
        print('이미지 업로드 중 오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile == null
                    ? (_profileImageUrl.isEmpty
                        ? const AssetImage('lib/assets/image/defaultUserProfile.png')
                        : NetworkImage(_profileImageUrl))
                    : FileImage(File(_imageFile!.path)) as ImageProvider,
                child: _imageFile == null && _profileImageUrl.isEmpty
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _nickname.isNotEmpty ? _nickname : '닉네임을 불러올 수 없습니다.',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('회원 정보 수정'),
              onTap: () {
                context.push('/infoupdate');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('계정 설정'),
              onTap: () {
                context.push('/account');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('나의 판매'),
              onTap: () {
                context.push('/sold');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('나의 구매'),
              onTap: () {
                context.push('/bought');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('나의 입찰 목록'),
              onTap: () {
                context.push('/my-bids');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('다크모드'),
              trailing: Switch(
                value: themeProvider.isDarkTheme, // 수정된 부분
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
