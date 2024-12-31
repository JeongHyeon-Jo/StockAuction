import 'dart:async';
import 'package:auction/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/theme_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _images = [
    'lib/assets/image/pic1.png',
    'lib/assets/image/pic2.png',
    'lib/assets/image/pic3.png',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startImageTimer();
      _loadPosts();
      Provider.of<PostProvider>(context, listen: false).fetchSuccessBiddingPosts();
    });
  }

  void _startImageTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          if (_currentPage < _images.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
        });
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }




  void _loadPosts() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.getAllPostList(); // 모든 포스트 로드!
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child:
          Column(
            children: <Widget>[
              SizedBox(
                height: 350,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _images[index],
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                width: double.infinity,
                child: Text(
                  '방금 시작된 경매',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineLarge!.color,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Consumer<PostProvider>(
                  builder: (context, postProvider, child) {
                    if (postProvider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (postProvider.hasError) {
                      return Center(child: Text('포스트를 불러오는 데 오류가 발생했습니다.'));
                    }

                    // 전체 postList에서 최근 10개만 사용
                    final recentPosts = postProvider.postList.take(10).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: recentPosts.map((post) {
                          return Container(
                            width: 160,
                            child: auctionItem(theme, post),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 10, 0, 10),
                width: double.infinity,
                child: Text(
                  '낙찰된 경매',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineLarge!.color,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Consumer<PostProvider>(
                  builder: (context, postProvider, child) {
                    if (postProvider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (postProvider.hasError) {
                      return Center(child: Text('포스트를 불러오는 데 오류가 발생했습니다.'));
                    }

                    final successBiddingPosts = postProvider.successBiddingPosts.take(10).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: successBiddingPosts.map((post) {
                          return Container(
                            width: 160,
                            child: auctionItem(theme, post),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget auctionItem(ThemeData theme, PostModel post) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/post/detail', extra: post.postUid);
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        color: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: post.postImageList.isNotEmpty
                      ? post.postImageList[0]
                      : 'default_image_url',
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              post.postTitle,
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyLarge!.color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
            SizedBox(height: 3),
            // 가격 정보는 항상 보여야 함
            Text(
              post.bidList.isNotEmpty ? post.bidList.last.bidPrice : '가격 정보 없음',
              style: TextStyle(
                fontSize: 16, // 글씨 크기 조정
                fontWeight: FontWeight.bold, // 글씨 두껍게
                color: theme.textTheme.bodyMedium!.color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}