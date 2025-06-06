import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import '../models/friend_request.dart';
import '../models/post.dart';

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:8002/api'; // TODO: make dynamic for prod

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all posts from the API
  Future<List<Post>> getPosts() async {
    final response = await _client.get(Uri.parse('$baseUrl/posts/'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['posts'];
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  Future<List<FriendRequest>> getPendingFriendRequests(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/friend-requests/?type=received'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['friend_requests'];
      return data.map((e) => FriendRequest.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load friend requests: ${response.statusCode}');
    }
  }

  Future<void> sendFriendRequest({
    required String token,
    required String receiverUid,
    String? message,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/friend-requests/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'receiver_uid': receiverUid,
        if (message != null) 'message': message,
      }),
    );

    if (response.statusCode != 201) {
      final json = jsonDecode(response.body);
      throw Exception(json['error'] ?? 'Failed to send friend request');
    }
  }

  Future<List<Account>> getAccounts() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/accounts/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['accounts'];
      return data.map((e) => Account.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }
  }

  // TODO: Add auth headers when token is available
}
