import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:feels_mobile/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());