import 'package:auction/utils/SharedPrefsUtil.dart';
import 'package:auction/utils/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _login(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await authProvider.login();

        // 로그인 성공 시 바로 메인 페이지로 이동
        context.go('/main');
      } catch (e) {
        _showErrorDialog(context, '아이디 또는 비밀번호를 확인해주세요');
      }
    }
  }

  void _showLocalData(BuildContext context) async {
    Map<String, dynamic> userData = await SharedPrefsUtil.getUserData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로컬 저장소 데이터'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사용자 데이터:'),
                if (userData.isEmpty)
                  Text('저장된 사용자 데이터가 없습니다.')
                else
                  ...userData.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('삭제'),
              onPressed: () async {
                await _clearLocalData(context);
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearLocalData(BuildContext context) async {
    await SharedPrefsUtil.clearAllData();
    Navigator.of(context).pop(); // 현재 대화상자 닫기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로컬 데이터가 모두 삭제되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/image/loginimage.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 200, 20, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: TextStyle(fontSize: 50, fontWeight: FontWeight.w300, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '아이디를 입력해 주세요.',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? '아이디를 입력해주세요.' : null,
                      onSaved: (value) => authProvider.setEmail(value!),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '비밀번호를 입력해 주세요.',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요.' : null,
                      onSaved: (value) => authProvider.setPassword(value!),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/password-reset'),
                          child: Text(
                            '암호를 잊어버렸습니다.',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      child: Text(
                        '로그인',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      onPressed: () => _login(context, authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF5C4439),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => authProvider.setStayLoggedIn(!authProvider.stayLoggedIn),
                          child: Text('자동 로그인', style: TextStyle(color: Colors.white)),
                        ),
                        Checkbox(
                          value: authProvider.stayLoggedIn,
                          onChanged: (bool? value) => authProvider.setStayLoggedIn(value ?? false),
                          fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.white.withOpacity(.32);
                            }
                            return Colors.white;
                          }),
                          checkColor: Color(0XFF949119),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('계정이 없습니다.', style: TextStyle(color: Colors.white)),
                        GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: Text(
                            '회원가입',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 200),
                    GestureDetector(
                      onTap: () => _showLocalData(context),
                      child: Text(
                        '로컬데이터베이스 정보확인',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
