import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendNotification({required String title, required String body, required String pushToken, String screen = "/main"}) async {
  try {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('sendPushNotification');
    final result = await callable.call({
      'title': title,
      'body': body,
      'token': pushToken,
      'screen': screen
    });
    print("success : ${result.data}");
  } catch (e) {
    print('Caught generic exception: $e');
  }
}