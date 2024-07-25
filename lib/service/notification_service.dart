import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:social4/service/shared_preference_service.dart';

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();

  final _sharedPreferencesService = SharedPreferencesService();

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal();

  init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    storeFcmToken();
    getAccessToken();
  }

  Future<void> sendFollowNotification(
      String fcmToken, Map<String, dynamic> body) async {
    // Replace with your FCM server key

    try {
      String authKey = await getAccessToken();
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/social-e88f0/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authKey',
        },
        body: jsonEncode({
          "message": {"token": fcmToken, "notification": body}
        }),
      );
      print(response.body);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<String> getAccessToken() async {
    final _clientId = ClientId(
      '912665399185-rdj0tr5fhct83oo4441mril3630nasom.apps.googleusercontent.com', // Replace with your OAuth 2.0 Client ID
    );

    const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "social-e88f0",
          "private_key_id": "e5c929a3d708f63f467f691eb63d6438d90e6a3b",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCIH+Tv8MwPR/Jr\nSMKxhp4/gja0PGJGeOzLqlxQ2AUe+kmtrsNEcBekmvdPSiTrTwDrCZHY8yFOzRTX\nr/5kWpBCwllx/gVxNZwSxozBjc3xPtTfNnAWHZrCCyOIAsyQpDpKGcHGTajxWE25\nsZtHWYYpRJdFi4+vIgE3g/xE0StcMU38XPugZvmLZM3qcw1lp3j10muYCauTMPDj\nxeksGsRmvoLmCTVx50WqyIM5dZVUpYn6wxmeAfZYGWFP5Dxo9ngzTbIDwpPf1+ZL\nC3veZGRM5wVPeixfQg//oBzOfS9J3yoDLEld2kyddu/PfGlkFb5VZ+woleHJdm53\ny7kZ6NMhAgMBAAECggEAGG0gt62N8HAIoBe+V/zACMVk65KqT9sDIsi/KAKbaKOg\n9PmXMICsvWzRU/kKBu92Sra85SE7qNhEFTAPhhJ6MICPbFUYxOfJydS3DURU4CVW\nLXenRVCqpIc7KPzXmFzf2MwmaV8mIaimyduE8Ziu6ljUjDYu4k5HyZ51diPSlAhB\n5u68my4Icfo5xhTKBDJa1PmmVFM7ACKOfR5qW6k22yQ9n00EmAAdescLgtU5A7MR\nR/0UJjRUbEseDGmHeNGRZVgifXinmJtmIe+WyUi6BovtzXaPr9jFtJcIgKmKH+U/\npwL3ioKGu92onxU1Zbl84DPHNCfJLOXCfgWknjCjwQKBgQC8Af97uyAGihE4bSRN\nXEi2uodT85vXvWUxvCp300xxKQtR1q9nSXmqqKjV2Pnbm8JkEEC7f8nAZ266Xmus\nDtxpy0MjVpvmQlU1V17ApIhTioRRA8nqvdOsApybOf8MrAh605dEiX8v7XnEVFNy\n3XB7WlHsVPM6QOsW7KYg7O6PzwKBgQC5WntgVTKrQVr9n9IOjn/eSMeJlIwk6mYS\nwO0hXfPi/mqN+pHL9XlUEQCKriNZDJB+JLYAAXl1qlH1frcsVsUyeqRVyBNpUjZw\n7DxjnBc0TTo09kKap91gkBEnM/gnSZBWc3GGGn5DYjj6ykVtDtrX14uQMr46aerK\nDTvT/+66DwKBgBBEA/yKdfza2R6OosNmpovYm3ix7Nu/cQ/afbocN9LagDY2YrqG\n6tXO/bxypztOwISzu0X9ilDxIe1R2fLq3jrw8QAPsDE9r+2Lf5EfKwQ/Sa9Qqpl6\njuOk3jO30s8f2yP1RnMRikV1QEGyIf4gFmk1qTzPJLP3hd9X3g+fMAyVAoGAMAx5\noS5U1To6+TZeALIGCbx6JXshnUw6K7BhiF3PpE9pleaXtvSqgBVsO4cK2MG+D0U6\n/ONk9hCx8F7p4w+XTQ+n3Cjih1HtlPZYbUYAael/Jk2UVH0hkS+nkq8RLDYQuahx\njF7/zj3/IVwgBTZtmrhgkH/m+kOMvtYRZVKaMxcCgYBRK26Tz1v8pyiEGxAKHImb\nGV9+TrBHt0AQ4flHUpWrmxVq/wg27kTPUMbfxSGuW1UvE7JESrVK2vGg3nDnjnYj\nhRC7EDZ5FxJaCIMHzk64JmqENO9IGSsDAZ5WQoOJ/k44jaax49m0JXot5m1TJuf2\ng4DiM6f98Rl67zNaOoU1VQ==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-hkinj@social-e88f0.iam.gserviceaccount.com",
          "client_id": "106213093281518669694",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-hkinj%40social-e88f0.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        _scopes);

    return client.credentials.accessToken.data;
  }

  Future<void> storeFcmToken() async {
    final curentUserId = _sharedPreferencesService.getString("userID");
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(curentUserId)
          .update({
        'fcmToken': token,
      });
    }
  }
}
