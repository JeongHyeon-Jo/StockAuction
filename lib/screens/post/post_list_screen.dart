import 'package:auction/config/color.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/screens/post/widgets/post_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late TextEditingController _searchController;
  List<PostModel> _filteredPosts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.getAllPostList();
    _filterPosts();
  }

  void _filterPosts() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredPosts = postProvider.postList;
      } else {
        _filteredPosts = postProvider.postList
            .where((post) =>
        post.postTitle.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            post.postContent.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _filterPosts();
                },
              )
                  : Text(''),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _filterPosts();
                      }
                    });
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: RefreshIndicator(
                onRefresh: _loadPosts,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1/2,
                  ),
                  itemCount: _filteredPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PostItemWidget(postModel: _filteredPosts[index]);
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push("/post/add");
              },
              backgroundColor: AppsColor.pastelGreen,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }
    );
  }
}