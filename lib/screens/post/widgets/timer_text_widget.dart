import 'dart:async';

import 'package:auction/models/post_model.dart';
import 'package:auction/providers/auction_timer_provider.dart';
import 'package:auction/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerTextWidget extends StatelessWidget {
  final PostProvider postProvider;
  const TimerTextWidget({super.key , required this.postProvider});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionTimerProvider>(
        builder: (context, auctionTimerProvider, child) {
          if(postProvider.postModel!.auctionStatus != AuctionStatus.bidding){ //입찰중이 아니면 경매종료 표시
            return const Text("경매 종료", style: TextStyle(fontSize: 16),);
          }

          if (auctionTimerProvider.remainingTime > 10) {
            return Text(
              "남은 시간 : ${auctionTimerProvider.formattedTime}",
              style: const TextStyle(fontSize: 16),);
          } else if (auctionTimerProvider.remainingTime <= 10 &&
              auctionTimerProvider.remainingTime > 0) {
            return Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "남은 시간 : ",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text: auctionTimerProvider.formattedTime,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.red), // 빨간색
                  ),
                ],
              ),
            );
          } else {
            return const Text("경매 종료", style: TextStyle(fontSize: 16),);
          }
        }
    );
  }
}

