import 'package:cloud_functions/cloud_functions.dart';

class FirebaseHelper {
  const FirebaseHelper._();
  static Future<bool> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendNotification');

    try {
      final response = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
        'token': token,
      });

      print('result is ${response.data ?? 'No data came back'}');

      if (response.data == null) return false;
      return true;
    } catch (e) {
      print('There was an error $e');
      return false;
    }
  }
}
