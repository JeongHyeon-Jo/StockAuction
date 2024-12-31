import 'package:auction/config/color.dart';
import 'package:auction/models/post_model.dart';
import 'package:auction/providers/post_image_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:auction/route.dart';
import 'package:auction/screens/post/widgets/post_Image_item.dart';
import 'package:auction/utils/custom_alert_dialog.dart';
import 'package:auction/widgets/default_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostModifyScreen extends StatefulWidget {
  const PostModifyScreen({super.key});

  @override
  State<PostModifyScreen> createState() => _PostModifyScreenState();
}

class _PostModifyScreenState extends State<PostModifyScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    _titleController =
        TextEditingController(text: postProvider.postModel?.postTitle);
    _contentController =
        TextEditingController(text: postProvider.postModel?.postContent);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return ChangeNotifierProvider(
      create: (context) =>
          PostImageProvider(List<String>.from(postProvider.postModel?.postImageList ?? [])),
      //이미지 넣기
      child: Scaffold(
        appBar: const DefaultAppbar(title: "물품 수정"),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 10),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            postImageProvider.imageList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return PostImageItem(
                                            imageUrl: postImageProvider
                                                .imageList[index],
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
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1,
                                        color: AppsColor.pastelGreen)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('초기 입찰가',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            TextField(
                              decoration: InputDecoration(
                                hintText: postProvider
                                        .postModel?.bidList[0].bidPrice ??
                                    "초기 입찰가는 변경할 수 없습니다.",
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  color: Colors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(),
                                disabledBorder: OutlineInputBorder(),
                                enabled: false,
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
                                      borderRadius: BorderRadius.circular(
                                          8.0), // 테두리 둥글게 만들기
                                    ),
                                    child: Text(
                                      _selectedDateTime != null
                                          ? '종료시간 : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime!)}'
                                          : postProvider.postModel!.endTime
                                              .toString(),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () => _selectDateTime(context),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(14.0),
                                    // 버튼 내부 패딩 설정
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                              controller: _contentController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1.0,
                                        color: AppsColor.pastelGreen),
                                  )),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: postProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_titleController.text.isEmpty ||
                                            _contentController.text.isEmpty ||
                                            postImageProvider
                                                .imageList.isEmpty) {
                                          showCustomAlertDialog(
                                              context: context,
                                              title: "알림",
                                              message: "모든 항목을 입력해주세요.");
                                          return;
                                        }
                                        final modifiedPostModel = PostModel(
                                            postUid:
                                                postProvider.postModel!.postUid,
                                            writeUser: postProvider
                                                .postModel!.writeUser,
                                            postTitle: _titleController.text,
                                            postContent:
                                                _contentController.text,
                                            createTime: postProvider
                                                .postModel!.createTime,
                                            endTime: _selectedDateTime ??
                                                DateTime.now(),
                                            postImageList:
                                                postImageProvider.imageList);

                                        final result = await postProvider
                                            .modifyPostItem(modifiedPostModel);

                                        if (result.isSuccess) {
                                          showCustomAlertDialog(context: context, title:  "알림", message: result.message ?? "게시물을 수정했습니다.", onPositiveClick: (){
                                            context.pop();
                                            context.pop();
                                          });
                                        } else {
                                          showCustomAlertDialog(context: context, title:  "알림", message: result.message ?? "게시물 수정에 실패했습니다.");
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppsColor.pastelGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                child: postProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "수정 완료",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ))),
                      ),
                    )
                  ],
                ),
                if (postProvider.isLoading)
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
          showCustomAlertDialog(
              context: context, title: "알림", message: "현재보다 이후시간을 선택해주세요.");
        } else {
          // 선택한 시간이 유효할 경우 상태를 업데이트
          setState(() {
            _selectedDateTime = selectedDateTime;
          });
        }
      }
    }
  }
}
