import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/chat_session.dart';

class StorageService {
  static const String _sessionsKey = 'chat_sessions';
  static const String _apiConfigKey = 'api_config';
  static const String _activeSessionKey = 'active_session';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ========== 会话管理 ==========

  Future<List<ChatSession>> loadSessions() async {
    await init();
    final data = _prefs.getString(_sessionsKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<ChatSession> sessions) async {
    await init();
    final data = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, data);
  }

  Future<String?> getActiveSessionId() async {
    await init();
    return _prefs.getString(_activeSessionKey);
  }

  Future<void> setActiveSessionId(String? id) async {
    await init();
    if (id == null) {
      await _prefs.remove(_activeSessionKey);
    } else {
      await _prefs.setString(_activeSessionKey, id);
    }
  }

  // ========== API 配置 ==========

  Future<ApiConfig> loadApiConfig() async {
    await init();
    final data = _prefs.getString(_apiConfigKey);
    if (data == null || data.isEmpty) return ApiConfig.defaultConfig();
    try {
      return ApiConfig.fromJson(jsonDecode(data));
    } catch (_) {
      return ApiConfig.defaultConfig();
    }
  }

  Future<void> saveApiConfig(ApiConfig config) async {
    await init();
    await _prefs.setString(_apiConfigKey, jsonEncode(config.toJson()));
  }
}

class ApiConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final String systemPrompt;

  ApiConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.systemPrompt = '你是一个友好、聪明的AI助手。请用简洁、清晰的语言回答用户的问题。',
  });

  factory ApiConfig.defaultConfig() => ApiConfig(
        baseUrl: 'http://localhost:11434/v1',
        apiKey: 'ollama',
        model: 'deepseek-r1:9b',
      );

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'model': model,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'systemPrompt': systemPrompt,
      };

  factory ApiConfig.fromJson(Map<String, dynamic> json) => ApiConfig(
        baseUrl: json['baseUrl'] as String? ?? 'http://localhost:11434/v1',
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? 'deepseek-r1:9b',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: json['maxTokens'] as int? ?? 2048,
        systemPrompt: json['systemPrompt'] as String? ??
            '你是一个友好、聪明的AI助手。请用简洁、清晰的语言回答用户的问题。',
      );

  ApiConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) =>
      ApiConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        model: model ?? this.model,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        systemPrompt: systemPrompt ?? this.systemPrompt,
      );
}
