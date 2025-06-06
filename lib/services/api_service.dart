import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<bool> register(
    String username,
    String password,
    String email,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'register',
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('username', data['user']['username']);
      await prefs.setString('email', data['user']['email']);
      await prefs.setString('display_name', data['user']['display_name']);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'login',
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      await http.delete(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('display_name');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('auth_token')) {
      return false;
    }

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      return false;
    }

    // Optionally, you can validate the token by making a request to the API
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true; // Token is valid
      } else {
        return false; // Token is invalid
      }
    } catch (e) {
      return false; // Error occurred, treat as not logged in
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
