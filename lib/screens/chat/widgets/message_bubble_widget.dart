import 'package:auction/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auction/providers/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 말풍선
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? profileImageUrl;
  final String? imageUrl;
  final String? status;
  final String? messageType;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;
  final String? postTitle;
  final String? bidPrice;
  final String? postContent;

  MessageBubble(
    this.message,
    this.isMe,
    this.profileImageUrl, {
    this.imageUrl,
    this.status,
    this.messageType,
    this.onPositivePressed,
    this.onNegativePressed,
    this.postTitle,
    this.bidPrice,
    this.postContent,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // 구매 확정 메시지 타입인 경우
    if (messageType == 'purchaseConfirmation') {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeProvider.isDarkTheme ? Colors.black : Colors.white,
          border: Border.all(color: themeProvider.isDarkTheme ? Colors.white :Colors.black, width: 2.0,),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                color: themeProvider.isDarkTheme ? Colors.black : Colors.grey[100],                     
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  status == 'canceled' || status == 'dealed' ? '거래가 종료되었습니다' : '거래가 진행 중입니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'lib/assets/images/defaultUserProfile.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (postTitle != null)
                        Text(
                          postTitle!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      if (bidPrice != null)
                        Text(
                          '낙찰가: $bidPrice',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      if (postContent != null)
                        Text(
                          postContent!.length > 50 ? '${postContent!.substring(0, 50)}...' : postContent!,
                          style: TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStep(
                  icon: Icons.check_circle,
                  label: "구매 확인",
                  isActive: status == "ready" || status == "deposit" || status == "shipping" || status == "dealed",
                ),
                _buildStatusStep(
                  icon: Icons.attach_money,
                  label: "입금 확인",
                  isActive: status == "deposit" || status == "shipping" || status == "dealed",
                ),
                _buildStatusStep(
                  icon: Icons.local_shipping,
                  label: "배송 확인",
                  isActive: status == "shipping" || status == "dealed",
                ),
                _buildStatusStep(
                  icon: Icons.home,
                  label: "거래 완료",
                  isActive: status == "dealed",
                ),
              ],
            ),
            SizedBox(height: 8),
            if (status == "ready" && isMe) ...[
              Text('상대방의 응답을 대기중입니다.'),
              ElevatedButton(
                onPressed: onNegativePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                  side: BorderSide(
                    color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                    width: 1.2,          
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('판매 취소'),
              ),
            ] else if (status == "ready" && !isMe) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: onPositivePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('예'),
                  ),
                  ElevatedButton(
                    onPressed: onNegativePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('아니오'),
                  ),
                ],
              ),
            ] else if (status == "deposit" && isMe) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: onPositivePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('입금 확인 완료'),
                  ),
                  ElevatedButton(
                    onPressed: onNegativePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('판매 취소'),
                  ),
                ],
              ),
            ] else if (status == "deposit" && !isMe) ...[
              Text('입금을 하십시오.'),
              ElevatedButton(
                onPressed: onNegativePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                  side: BorderSide(
                    color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                    width: 1.2,          
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('구매 취소'),
              ),
            ] else if (status == "shipping" && isMe) ...[
              Text('배송 해주십시오.'),
              ElevatedButton(
                onPressed: onNegativePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                  side: BorderSide(
                    color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                    width: 1.2,          
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('판매 취소'),
              ),
            ] else if (status == "shipping" && !isMe) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: onPositivePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('배송 확인 완료'),
                  ),
                  ElevatedButton(
                    onPressed: onNegativePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkTheme ? Colors.black : Colors.white,
                      side: BorderSide(
                        color: themeProvider.isDarkTheme ? Colors.white : Colors.black, 
                        width: 1.2,          
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('구매 취소'),
                  ),
                ],
              ),
            ]
          ],
        ),
      );
    }

  if (messageType != 'purchaseConfirmation') {
    
  }
    // 일반 채팅
    return Row(
      // 나는 오른쪽부터 정렬, 내가 아니면 왼쪽부터 정렬
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        // 상대방은 이미지가 뜨도록 설정
        if (!isMe && profileImageUrl != null)
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(profileImageUrl!),
            radius: 15,
          ),
        // 메시지 포함하는 말풍선
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[300] : AppsColor.pastelGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          // 이미지를 첨부할 경우 CachedNetworkImage를 보낸다
          // 이미지 아니면 Text 보냄
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  // 상태 표시 아이콘과 텍스트를 간단히 만드는 위젯
  Widget _buildStatusStep({required IconData icon, required String label, required bool isActive}) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
