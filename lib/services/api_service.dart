import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/message.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  // 流式聊天 - 返回一个 Stream，每个事件是一段文本
  Stream<String> streamChat(List<Message> history) async* {
    final config = await _storage.loadApiConfig();

    final messages = <Map<String, String>>[];

    // 系统提示词
    if (config.systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': config.systemPrompt});
    }

    // 历史消息
    for (final msg in history) {
      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    try {
      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        data: {
          'model': config.model,
          'messages': messages,
          'stream': true,
          'temperature': config.temperature,
          'max_tokens': config.maxTokens,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        buffer.write(text);

        // 处理 SSE 格式: data: {...}\n\n
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          if (trimmed.startsWith('data:')) {
            final data = trimmed.substring(5).trim();
            if (data == '[DONE]') continue;
            try {
              final json = jsonDecode(data);
              final delta = json['choices']?[0]?['delta']?['content'];
              if (delta != null && delta.toString().isNotEmpty) {
                yield delta.toString();
              }
            } catch (_) {
              // 忽略解析错误
            }
          }
        }
      }
    } on DioException catch (e) {
      final errorMsg = _handleError(e);
      yield '\n\n[错误] $errorMsg';
    } catch (e) {
      yield '\n\n[错误] 连接失败: $e';
    }
  }

  // 非流式聊天
  Future<String> chat(List<Message> history) async {
    final config = await _storage.loadApiConfig();

    final messages = <Map<String, String>>[];
    if (config.systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': config.systemPrompt});
    }
    for (final msg in history) {
      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    try {
      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        data: {
          'model': config.model,
          'messages': messages,
          'stream': false,
          'temperature': config.temperature,
          'max_tokens': config.maxTokens,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data['choices'][0]['message']['content'] as String? ??
          '（无响应内容）';
    } on DioException catch (e) {
      return '[错误] ${_handleError(e)}';
    } catch (e) {
      return '[错误] 连接失败: $e';
    }
  }

  // 测试连接
  Future<bool> testConnection() async {
    try {
      final config = await _storage.loadApiConfig();
      final response = await _dio.get(
        '${config.baseUrl}/models',
        options: Options(
          headers: {'Authorization': 'Bearer ${config.apiKey}'},
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查 API 地址是否正确';
      case DioExceptionType.receiveTimeout:
        return '响应超时，模型可能正在处理长文本';
      case DioExceptionType.connectionError:
        return '无法连接到服务器，请检查地址和网络';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final body = e.response?.data;
        if (status == 401) return 'API 密钥无效 (401)';
        if (status == 404) return '接口地址不存在 (404)，请检查 Base URL';
        if (status == 429) return '请求过于频繁 (429)';
        if (status == 500) return '服务器内部错误 (500)';
        return 'HTTP 错误 $status: $body';
      default:
        return e.message ?? '未知错误';
    }
  }
}
