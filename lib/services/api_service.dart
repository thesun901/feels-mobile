import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend_request.dart';
import '../models/post.dart';
import '../models/chat.dart';
import '../models/message.dart';

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

  Future<List<FriendRequest>> getPendingFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

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

  Future<void> respondToFriendRequest({
    required String requestId,
    required String action, // 'accept' lub 'reject'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.put(
      Uri.parse('$baseUrl/friend-requests/$requestId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['error'] ?? 'Failed to respond to friend request');
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
      await prefs.setString('uid', data['user']['uid']);
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
      await prefs.setString('uid', data['user']['uid']);
      await prefs.setString('username', data['user']['username']);
      await prefs.setString('email', data['user']['email']);
      await prefs.setString('display_name', data['user']['display_name']);
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
        Uri.parse('$baseUrl/auth/'),
        headers: {'Authorization': 'Bearer $token'},
      );
    }

    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('display_name');
    await prefs.remove('uid');
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
        prefs.remove('auth_token'); // Remove invalid token
        return false; // Token is invalid
      }
    } catch (e) {
      return false; // Error occurred, treat as not logged in
    }
  }

  Future<void> sendFriendRequest({
    required String receiverUid,
    String? message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

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

  Future<Account> getAccount({
    required String? accountUid,
    required String? accountUsername,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    var uid = accountUid;

    if ((uid == null || uid.isEmpty) &&
        (accountUsername == null || accountUsername.isEmpty)) {
      uid = prefs.getString('uid');
      if (uid == null || uid.isEmpty) {
        throw Exception(
          'No account UID or username provided and no user is logged in',
        );
      }
    }

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    if (uid != null && uid.isNotEmpty) {
      final response = await _client.get(
        Uri.parse('$baseUrl/accounts/$uid/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Account.fromJson(json);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/accounts/?username=$accountUsername'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['accounts'];
      if (data.isEmpty) {
        throw Exception('No account found with username: $accountUsername');
      }
      return Account.fromJson(data.first);
    } else {
      throw Exception('Failed to load account: ${response.statusCode}');
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final uri = Uri.parse('$baseUrl/users/$userId/posts/');

    final resp = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body)['posts'] as List<dynamic>;
      return data.map((e) => Post.fromJson(e)).toList();
    }
    throw Exception('getUserPosts failed (${resp.statusCode})');
  }

  Future<List<Account>> getAccounts({
    bool excludeFriends = false,
    bool onlyFriends = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final queryParams = <String, String>{};
    if (excludeFriends) queryParams['exclude_friends'] = 'true';
    if (onlyFriends) queryParams['only_friends'] = 'true';

    final uri = Uri.parse(
      '$baseUrl/accounts/',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['accounts'];
      return data.map((e) => Account.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }
  }

  Future<void> unfriend(String friendUid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.delete(
      Uri.parse('$baseUrl/accounts/unfriend/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'friend_uid': friendUid}),
    );

    if (response.statusCode == 200) {
      // Sukces, znajomy usunięty
      return;
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['error'] ?? 'Failed to unfriend');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeelings() async {
    final response = await _client.get(Uri.parse('$baseUrl/feelings/'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['feelings'];
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Nie udało się pobrać uczuć: ${response.statusCode}');
    }
  }

  Future<String> createPost({required String body, String? feelingName}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final Map<String, dynamic> payload = {'body': body};
    if (feelingName != null) {
      payload['feeling_name'] = feelingName;
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/posts/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['uid'] as String;
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['error'] ?? 'Failed to create post');
    }
  }

  Future<List<Chat>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/chats/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['chats'];
      return data.map((e) => Chat.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  Future<Chat> getChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/chats/$chatId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Chat.fromJson(json);
    } else {
      throw Exception('Failed to load chat: ${response.statusCode}');
    }
  }

  Future<Chat> createChat(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/chats/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'participant_usernames': [username],
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Chat.fromJson(json);
    } else {
      throw Exception('Failed to create chat: ${response.statusCode}');
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$baseUrl/chats/$chatId/messages/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['messages'];
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  Future<Message> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/chats/$chatId/messages/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Message.fromJson(json);
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['error'] ?? 'Failed to send message');
    }
  }

  Future<Account> updateProfile({
    String? displayName,
    String? bio,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final Map<String, dynamic> payload = {};
    if (displayName != null) payload['display_name'] = displayName;
    if (bio != null) payload['bio'] = bio;
    if (email != null) payload['email'] = email;

    final response = await _client.put(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Account.fromJson(json['user']);
    } else {
      throw Exception(json['error'] ?? 'Failed to update profile');
    }
  }
}
