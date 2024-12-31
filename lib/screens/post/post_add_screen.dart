import 'dart:io';

import 'package:auction/config/color.dart';
import 'package:auction/models/bid_model.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/models/user_model.dart';
import 'package:auction/providers/auth_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/route.dart';
import 'package:auction/screens/post/widgets/post_Image_item.dart';
import 'package:auction/screens/post/widgets/post_item_widget.dart';
import 'package:auction/utils/SharedPrefsUtil.dart';
import 'package:auction/utils/custom_alert_dialog.dart';
import 'package:auction/utils/string_util.dart';
import 'package:auction/widgets/default_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/post_image_provider.dart';

class PostAddScreen extends StatefulWidget {
  const PostAddScreen({super.key});

  @override
  State<PostAddScreen> createState() => _PostAddScreenState();
}

class _PostAddScreenState extends State<PostAddScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _contentController;
  DateTime? _selectedDateTime;
  bool _isPriceFocused = false;
  final _priceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _priceFocusNode.addListener(() {
      setState(() {
        _isPriceFocused = _priceFocusNode.hasFocus;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return ChangeNotifierProvider(
      create: (context) => PostImageProvider(),
      child: Scaffold(
        appBar: const DefaultAppbar(title: "물품 올리기"),
        body: Consumer<PostImageProvider>(
          builder: (context, postImageProvider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      postImageProvider.pickImage();
                                    },
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 100,
                                    child: ListView.separated(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 10),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            postImageProvider.imageList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return PostImageItem(
                                            imageUrl:
                                                postImageProvider.imageList[index],
                                            index: index,
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const SizedBox(
                                                  width: 5,
                                                )),
                                  ),
                                ),
                              ],
                            ),
                            const Text('제목',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: '제목',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: AppsColor.pastelGreen)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('초기 입찰가',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Focus(
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _isPriceFocused = hasFocus;
                                });
                              },
                              child: TextField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                focusNode: _priceFocusNode,
                                onChanged: (value){
                                  final formattedValue = formatPrice(value);
                                  _priceController.value = TextEditingValue(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: '가격을 입력해주세요.',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: Icon(
                                    Icons.attach_money,
                                    color: _isPriceFocused
                                        ? AppsColor.pastelGreen
                                        : Colors.grey,
                                  ),
                                  enabledBorder: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: AppsColor.pastelGreen,
                                  )),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('경매 종료 시간설정',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(14.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0, // 테두리 두께
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8.0), // 테두리 둥글게 만들기
                                    ),
                                    child: Text(
                                      _selectedDateTime != null
                                          ? '종료시간 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime!)}'
                                          : '종료시간을 선택해주세요.',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectDateTime(context),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(14.0),
                                    // 버튼 내부 패딩 설정
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ) // 버튼 모서리 둥글게 만들기
                                        ),
                                  ),
                                  child: const Icon(Icons.access_time),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('자세한 설명',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 5),
                            TextField(
                              maxLines: 5,
                              controller: _contentController,
                              decoration: const InputDecoration(
                                  hintText:
                                      '올릴 게시글 내용을 작성해 주세요. (판매 금지 물품은 게시가 제한될 수 있어요.)\n\n신뢰할 수 있는 거래를 위해 자세히 적어주세요.\n과학기술정보통신부, 한국 인터넷진흥원과 함께 해요.',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.0, color: AppsColor.pastelGreen),
                                  )),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: postProvider.isLoading || authProvider.isLoading
                                    ? null
                                    : () async {
                                  //빈 항목 검증
                                  if(_titleController.text.isEmpty || _selectedDateTime == null || _contentController.text.isEmpty || postImageProvider.imageList.isEmpty ){
                                    showCustomAlertDialog(context: context, title: "알림", message: "모든 항목을 입력해주세요.");
                                    return;
                                  }

                              final userData = await SharedPrefsUtil.getUserData();
                              final loginUserData = UserModel.fromMap(userData);
                              final bid = BidModel(
                                  bidUser: loginUserData,
                                  bidTime: DateTime.now(), // DateTime 객체로 직접 전달
                                  bidPrice: "${_priceController.text}원"
                              );

                                  final postModel = PostModel(//Todo price 숫자 검증
                                      postUid: '',
                                      writeUser: loginUserData,
                                      postTitle: _titleController.text,
                                      postContent: _contentController.text,
                                      createTime: DateTime.now(),
                                      endTime: _selectedDateTime ?? DateTime.now(),
                                      postImageList: postImageProvider.imageList,
                                      bidList: List<BidModel>.of([bid]),
                                  );
                                  final postResult = await postProvider.addPostItem(postModel);
                                  final addPostIntoSellListResult = await authProvider.addPostIntoSellList(loginUserData.uid,postModel.postUid);

                                  if(postResult.isSuccess && addPostIntoSellListResult.isSuccess){
                                    showCustomAlertDialog(context: context, title:  "알림", message: postResult.message ?? "게시물을 등록했습니다.", onPositiveClick: () => context.go('/main/post'));
                                  }else{
                                    showCustomAlertDialog(context: context, title: "알림", message: "게시물 등록중 오류가 발생했습니다. 오류메시지 : ${postResult.message} , ${addPostIntoSellListResult.message}");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppsColor.pastelGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0))),
                                child: postProvider.isLoading || authProvider.isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "작성 완료",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),)),
                      ),
                    ),
                  ],
                ),
                if (postProvider.isLoading || authProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    // 시간이 선택되면 시간도 선택
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selectedDateTime.isBefore(DateTime.now())) {
          // 다이얼로그를 띄움
          showCustomAlertDialog(context: context, title: "알림", message: "현재보다 이후시간을 선택해주세요.");

        } else {
          // 선택한 시간이 유효할 경우 상태를 업데이트
          setState(() {
            _selectedDateTime = selectedDateTime;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
