import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _benefitNotification = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 로그아웃 메소드
  void _logout() async {
    await _auth.signOut();
    GoRouter.of(context).go('/login');
  }

  void _confirmMembershipTermination() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('회원을 탈퇴하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showPasswordDialog(); // 비밀번호 입력 다이얼로그 띄우기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog() {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('비밀번호 입력'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                User? user = _auth.currentUser;
                if (user == null) return; // 사용자 확인

                try {
                  // 이메일 주소 가져오기
                  String email = user.email!;

                  // 비밀번호 재인증
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: email,
                    password: passwordController.text,
                  );

                  // 재인증 시도
                  await user.reauthenticateWithCredential(credential);

                  // 비밀번호가 일치할 경우 사용자 문서 삭제
                  await _firestore.collection('users').doc(user.uid).delete();
                  await user.delete(); // Firebase에서 사용자 삭제

                  // 로그인 화면으로 이동
                  GoRouter.of(context).go('/login'); // 고라우트를 사용하여 이동
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 설정'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/my');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이용정보 알림
            const Text(
              '이용정보 알림',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // 혜택 알림 (스위치)
            ListTile(
              title: const Text('혜택 알림'),
              trailing: Switch(
                value: _benefitNotification,
                onChanged: (bool value) {
                  setState(() {
                    _benefitNotification = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // 최신버전
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '최신버전',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '5.4.8',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 캐시 삭제
            GestureDetector(
              onTap: () {
                // 캐시 삭제 버튼 클릭
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('캐시가 삭제되었습니다.')),
                );
              },
              child: const Text(
                '캐시 삭제',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            // 로그아웃
            ElevatedButton(
              onPressed: _logout,
              child: const Text('로그아웃'),
            ),
            const SizedBox(height: 10),
            // 회원 탈퇴
            ElevatedButton(
              onPressed: _confirmMembershipTermination,
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}
