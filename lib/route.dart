import 'package:auction/screens/my/my_bid_screen.dart';
import 'package:auction/screens/post/post_modify_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auction/screens/main_screen.dart';
// import auth
import 'package:auction/screens/auth/login_screen.dart';
import 'package:auction/screens/auth/signup_screen.dart';
import 'package:auction/screens/auth/password_reser_screen.dart';
// import chat
import 'package:auction/screens/chat/chat_screen.dart';
// import post
import 'package:auction/screens/post/post_list_screen.dart';
import 'package:auction/screens/post/post_add_screen.dart';
import 'package:auction/screens/post/post_detail_screen.dart';
import 'package:auction/screens/post/bid_list_screen.dart';
// import my
import 'package:auction/screens/my/my_screen.dart';
import 'package:auction/screens/my/my_sold_screen.dart';
import 'package:auction/screens/my/my_account_screen.dart';
import 'package:auction/screens/my/my_bought_screen.dart';
import 'package:auction/screens/my/my_infoupdate_screen.dart';
// import other
import 'package:auction/screens/other/other_profile_screen.dart';
import 'package:auction/screens/other/other_selling_screen.dart';
import 'package:auction/screens/other/other_sold_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/login',
  navigatorKey: rootNavigatorKey,
  routes: [
    // Auth 관련 Route
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),
    GoRoute(
      path: '/password-reset',
      builder: (context, state) => PasswordResetScreen(),
    ),
    // Main 관련 Route
    GoRoute(
      path: '/main',
      builder: (context, state) => MainScreen(),
    ),
    GoRoute(
      path: '/main/post',
      builder: (context, state) => MainScreen(pageIndex: 1),
    ),
    GoRoute(
      path: '/main/chat',
      builder: (context, state) => MainScreen(pageIndex: 2),
    ),
    GoRoute(
      path: '/main/like',
      builder: (context, state) => MainScreen(pageIndex: 3),
    ),
    // Post 관련 Route
    GoRoute(
      path: '/post/add',
      builder: (context, state) => PostAddScreen(),
    ),
    GoRoute(
      path: '/post/modify',
      builder: (context, state) => PostModifyScreen(),
    ),
    GoRoute(
      path: '/post/detail',
      builder: (context, state) => PostDetailScreen(
        postUid: state.extra as String),
    ),
    GoRoute(
      path: '/post/detail/:postUid',
      builder: (BuildContext context, GoRouterState state) {
        final postUid = state.pathParameters['postUid']!;
        return PostDetailScreen(postUid: postUid);
      },
    ),
    GoRoute(
      path: '/post/list',
      builder: (context, state) => PostListScreen(),
    ),
    GoRoute(
      path: '/post/bidList',
      builder: (context, state) => BidListScreen(postUid: ""),
    ),
    GoRoute(
      path: '/PostListScreen',
      builder: (context, state) => PostListScreen(),
    ),
    // Chat 관련 Route
    GoRoute(
      path: '/chat/:chatId',
      builder: (BuildContext context, GoRouterState state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatScreen(chatId: chatId);
      },
    ),
    // My 관련 Route
    GoRoute(
      path: '/my',
      builder: (context, state) => MyScreen(),
    ),
    GoRoute(
      path: '/infoupdate',
      builder: (context, state) => MyInfoUpdateScreen(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => MyAccountScreen(),
    ),
    GoRoute(
      path: '/sold',
      builder: (context, state) => MySoldScreen(),
    ),
    GoRoute(
      path: '/bought',
      builder: (context, state) => MyBoughtScreen(),
    ),
    GoRoute(
      path: '/my-bids',
      builder: (context, state) => MyBidsScreen(),
    ),
    // Other 관련 Route
    GoRoute(
      path: '/other/profile/:uId',
      builder: (BuildContext context, GoRouterState state) {
        final uId = state.pathParameters['uId']!;
        return OtherProfileScreen(uId: uId);
      },
    ),
    GoRoute(
      path: '/other/selling/:uId',
      builder: (BuildContext context, GoRouterState state) {
        final uId = state.pathParameters['uId']!;
        return OtherSellingScreen(uId: uId);
      },
    ),
    GoRoute(
      path: '/other/sold/:uId',
      builder: (BuildContext context, GoRouterState state) {
        final uId = state.pathParameters['uId']!;
        return OtherSoldScreen(uId: uId);
      },
    ),
  ],
);
