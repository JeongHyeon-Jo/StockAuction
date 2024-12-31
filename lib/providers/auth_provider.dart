import 'package:auction/models/result_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auction/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _nickname = '';
  String _phoneNumber = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _passwordsMatch = true;
  bool _stayLoggedIn = false;
  bool _resetEmailSent = false;
  bool _isEmailVerified = false;
  bool _isLoading = false;
  UserModel? _currentUserModel;
  String? _userProfileImage;

  AuthProvider() {
    print("AuthProvider initialized");
    _initializeAuthState();
  }

  // Getters
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get nickname => _nickname;
  String get phoneNumber => _phoneNumber;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get passwordsMatch => _passwordsMatch;
  bool get stayLoggedIn => _stayLoggedIn;
  bool get resetEmailSent => _resetEmailSent;
  bool get isEmailVerified => _isEmailVerified;
  bool get isLoading => _isLoading;
  User? get currentUser => _auth.currentUser;
  UserModel? get currentUserModel => _currentUserModel;

  // 초기화 메서드
  Future<void> _initializeAuthState() async {
    print("Initializing auth state");
    await _loadStayLoggedIn();

    // Firestore에서 현재 사용자 정보 가져오기
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _loadUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        print("Error loading user from Firestore: $e");
      }
    } else {
      // Firestore에서 사용자가 없을 경우 로컬 스토리지에서 불러오기
      await _loadUserFromLocalStorage();
    }

    notifyListeners();
    print("Auth state initialized");
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _currentUserModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        await saveUserToLocalStorage(_currentUserModel!);  // Firestore 데이터를 로컬에 저장
        print("User loaded from Firestore and saved to local storage");
      } else {
        print("User document not found in Firestore");
      }
    } catch (e) {
      print("Error loading user from Firestore: $e");
    }
  }

  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        _currentUserModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        // 로컬에 저장
        await saveUserToLocalStorage(_currentUserModel!);
        notifyListeners();
        
        print("Updated UserModel from Firestore: ${_currentUserModel!.buyList}");
        return _currentUserModel;
      }
    }
    return null;
  }

  // Setters
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    checkPasswordsMatch();
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    checkPasswordsMatch();
    notifyListeners();
  }

  void setNickname(String value) {
    _nickname = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void checkPasswordsMatch() {
    _passwordsMatch = _password == _confirmPassword;
    notifyListeners();
  }

  void setUserProfileImage(String imageUrl) {
    _userProfileImage = imageUrl;
    notifyListeners();
  }

  Future<void> setStayLoggedIn(bool value) async {
    print("Setting stay logged in: $value");
    _stayLoggedIn = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stayLoggedIn', value);
    notifyListeners();
  }

  Future<void> _loadStayLoggedIn() async {
    print("Loading stay logged in preference");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _stayLoggedIn = prefs.getBool('stayLoggedIn') ?? false;
    print("Stay logged in loaded: $_stayLoggedIn");

    if (!_stayLoggedIn && _auth.currentUser != null) {
      print("User not set to stay logged in, but current user exists. Keeping the session.");
      // 여기서 로그아웃하지 않고, 대신 현재 사용자 정보를 로드합니다.
      await _loadUserFromLocalStorage();
    }
  }

  Future<void> _loadUserFromLocalStorage() async {
    print("Loading user from local storage");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    if (userJson != null) {
      print("User data found in local storage");
      Map<String, dynamic> userMap = json.decode(userJson);
      _currentUserModel = UserModel.fromMap(userMap);
      _email = _currentUserModel!.email;
      _nickname = _currentUserModel!.nickname;
      _phoneNumber = _currentUserModel!.phoneNumber;
      print("Loaded user: ${_currentUserModel!.nickname}");
    } else {
      print("No user data found in local storage");
    }
  }

  void setResetEmailSent(bool value) {
    _resetEmailSent = value;
    notifyListeners();
  }

  Future<bool> checkNickname() async {
    print("Checking nickname availability: $_nickname");
    var snapshot = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: _nickname)
        .get();

    return snapshot.docs.isEmpty;
  }

  Future<void> signupWithEmailVerification() async {
    print("Attempting to sign up user");
    if (_password != _confirmPassword) {
      throw Exception('비밀번호가 일치하지 않습니다.');
    }

    if (_password.length < 6) {
      throw Exception('비밀번호는 최소 6자리 이상이어야 합니다.');
    }

    bool isNicknameAvailable = await checkNickname();
    if (!isNicknameAvailable) {
      throw Exception('이미 사용 중인 닉네임입니다.');
    }

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    );

    await userCredential.user!.sendEmailVerification();
    _isEmailVerified = false;
    notifyListeners();
    print("Sign up successful, verification email sent");
  }

  Future<bool> checkEmailVerification() async {
    print("Checking email verification");
    User? user = _auth.currentUser;
    await user?.reload();
    _isEmailVerified = user?.emailVerified ?? false;
    notifyListeners();
    print("Email verified: $_isEmailVerified");
    return _isEmailVerified;
  }

  Future<void> createUserInFirestore() async {
    print("Creating user in Firestore");
    User? user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      // Get the FCM token
      String? pushToken = await FirebaseMessaging.instance.getToken();

      UserModel newUser = UserModel(
        uid: user.uid,
        email: _email,
        nickname: _nickname,
        phoneNumber: _phoneNumber,
        pushToken: pushToken,
        userProfileImage: _userProfileImage,
        birthDate: null,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      await saveUserToLocalStorage(newUser);
      await setStayLoggedIn(true);
      print("User created in Firestore with push token, saved locally, and stay logged in set to true");
    } else {
      print("Failed to create user: email not verified");
      throw Exception('이메일이 인증되지 않았습니다.');
    }
  }

  Future<void> saveUserToLocalStorage(UserModel user) async {
    print("Saving user to local storage: ${user.nickname}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = json.encode(user.toMap());
    await prefs.setString('user_data', userJson);
    _currentUserModel = user;
    notifyListeners();
  }

  Future<void> login() async {
    print("Attempting login for email: $_email");
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        // FCM 토큰 가져오기 및 업데이트
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print('로그인 시 FCM 토큰: $fcmToken');
          user = user.copyWith(pushToken: fcmToken);
          await _firestore.collection('users').doc(user.uid).update({'pushToken': fcmToken});
        }

        await saveUserToLocalStorage(user);
        await setStayLoggedIn(true);
        _currentUserModel = user;
        print("Login successful, user saved locally, FCM token updated, and stay logged in set to true");
      } else {
        print("User document not found in Firestore");
      }

      notifyListeners();
    } catch (e) {
      print("Login failed: $e");
      throw e;
    }
  }


  Future<void> logout() async {
    print("Logging out");
    await _auth.signOut();
    await clearUserFromLocalStorage();
    _currentUserModel = null;
    notifyListeners();
    print("Logout complete");
  }

  Future<void> clearUserFromLocalStorage() async {
    print("Clearing user from local storage");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    print("User cleared from local storage");
  }

  Future<void> sendPasswordResetEmail() async {
    print("Sending password reset email to: $_email");
    await _auth.sendPasswordResetEmail(email: _email);
    setResetEmailSent(true);
    print("Password reset email sent");
  }

  //판매 물품 추가시 selList에 목록 추가
  Future<Result> addPostIntoSellList(String userUid, String postUid) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'sellList': FieldValue.arrayUnion([postUid])
      });
      return Result.success("판매리스트에 등록되었습니다.");
    } catch (e) {
      return Result.failure("판매리스트에 등록 실패했습니다. 실패 코드 : $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }


  //판매 물품 삭제시 selList 에서 목록 삭제
  Future<Result> deletePostInSellList(String userUid, String postUid) async{
    _isLoading = true;
    notifyListeners();
    try {
      print("userUid : $userUid, postUid : $postUid");
      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'sellList': FieldValue.arrayRemove([postUid])
      });
      return Result.success("판매리스트에서 삭제되었습니다.");
    } catch (e) {
      return Result.failure("판매리스트에서 삭제 실패했습니다. 실패 코드 : $e");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  /////////////////////////////////////////////
  // 채팅방 관련 함수
  // 상대방 닉네임 갖고오는 함수
  Future<String> getUserNickname(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      return userSnapshot['nickname'] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  Future<String?> getUserProfileImage(String uId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uId).get();
      if (userDoc.exists) {
        return userDoc['userProfileImage'];
      }
    } catch (e) {
      print("Error fetching user profile image: $e");
    }
    return null;
  }
  
  // 채팅방 관련 함수 종료
  /////////////////////////////////////////////
  
  UserModel _convertToUserModel(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      nickname: firebaseUser.displayName ?? '',
      phoneNumber: '',
      pushToken: null,
      userProfileImage: firebaseUser.photoURL,
      birthDate: null,
    );
  }

  Future<void> updatePushToken(String token) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'pushToken': token,
        });
        if (_currentUserModel != null) {
          _currentUserModel = _currentUserModel!.copyWith(pushToken: token);
          await saveUserToLocalStorage(_currentUserModel!);
        }
        print("Push token updated successfully: $token");
      } catch (e) {
        print("Error updating push token: $e");
      }
    }
  }

}