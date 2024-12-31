import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BidItemWidget extends StatelessWidget {
  final String bidUserName;
  final String bidUserId;
  final String bidPrice;
  final DateTime bidTime;
  final VoidCallback onUserTap;

  const BidItemWidget({
    Key? key,
    required this.bidUserName,
    required this.bidUserId,
    required this.bidPrice,
    required this.bidTime,
    required this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onUserTap,  // 수정된 부분
              child: Text(
                bidUserName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text(bidPrice, style: const TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _formatDate(bidTime),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd HH:mm').format(date);
  }
}