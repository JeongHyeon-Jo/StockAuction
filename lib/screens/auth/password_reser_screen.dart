import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/auth_provider.dart';

class PasswordResetScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    Future<void> _sendPasswordResetEmail() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          await authProvider.sendPasswordResetEmail();
          _showSuccessDialog(context, '비밀번호 재설정 email을 보냈습니다. email을 확인해주세요.');
        } catch (e) {
          _showErrorDialog(context, 'email을 확인해 주세요.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('비밀번호 재설정')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '가입한 email을 입력해주세요.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'email 주소',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
                validator: (value) => value!.isEmpty ? 'email을 입력해주세요' : null,
                onSaved: (value) => authProvider.setEmail(value!),
                enabled: !authProvider.resetEmailSent,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: authProvider.resetEmailSent ? null : _sendPasswordResetEmail,
                child: Text('비밀번호 재설정 email 보내기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFFEBCDFC),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
              if (authProvider.resetEmailSent) ...[
                SizedBox(height: 20),
                Text(
                  'email을 확인하여 비밀번호를 재설정해주세요. 재설정 후 다시 로그인하세요.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text('로그인 화면으로 돌아가기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFFEBCDFC),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
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
}
