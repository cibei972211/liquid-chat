import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../widgets/glass_container.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final ApiService _api = ApiService();

  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _systemPromptController;
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;

  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
    _systemPromptController = TextEditingController();
    _temperatureController = TextEditingController();
    _maxTokensController = TextEditingController();
    _loadConfig();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _systemPromptController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _storage.loadApiConfig();
    setState(() {
      _baseUrlController.text = config.baseUrl;
      _apiKeyController.text = config.apiKey;
      _modelController.text = config.model;
      _systemPromptController.text = config.systemPrompt;
      _temperatureController.text = config.temperature.toString();
      _maxTokensController.text = config.maxTokens.toString();
    });
  }

  Future<void> _saveConfig() async {
    final config = ApiConfig(
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _modelController.text.trim(),
      temperature: double.tryParse(_temperatureController.text) ?? 0.7,
      maxTokens: int.tryParse(_maxTokensController.text) ?? 2048,
      systemPrompt: _systemPromptController.text.trim(),
    );
    await _storage.saveApiConfig(config);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('设置已保存'),
        backgroundColor: Colors.green.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    // 先保存当前配置
    await _saveConfig();

    final success = await _api.testConnection();
    setState(() {
      _testing = false;
      _testResult = success ? '连接成功！' : '连接失败，请检查地址和密钥';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              _buildHeader(),
              // 设置内容
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('API 配置'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildLabel('Base URL'),
                          const SizedBox(height: 8),
                          GlassInput(
                            controller: _baseUrlController,
                            hintText: 'http://localhost:11434/v1',
                            prefixIcon: Icons.link,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('API 密钥'),
                          const SizedBox(height: 8),
                          GlassInput(
                            controller: _apiKeyController,
                            hintText: 'sk-... 或 ollama',
                            prefixIcon: Icons.key,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('模型名称'),
                          const SizedBox(height: 8),
                          GlassInput(
                            controller: _modelController,
                            hintText: 'deepseek-r1:9b',
                            prefixIcon: Icons.psychology,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('生成参数'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Temperature'),
                                    const SizedBox(height: 8),
                                    GlassInput(
                                      controller: _temperatureController,
                                      hintText: '0.7',
                                      prefixIcon: Icons.thermostat,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Max Tokens'),
                                    const SizedBox(height: 8),
                                    GlassInput(
                                      controller: _maxTokensController,
                                      hintText: '2048',
                                      prefixIcon: Icons.text_fields,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('系统提示词'),
                          const SizedBox(height: 8),
                          GlassInput(
                            controller: _systemPromptController,
                            hintText: '你是一个友好的AI助手...',
                            prefixIcon: Icons.edit_note,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 测试连接
                    if (_testResult != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            color: _testResult!.contains('成功') ? Colors.green : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            text: _testing ? '测试中...' : '测试连接',
                            onPressed: _testing ? () {} : _testConnection,
                            isPrimary: false,
                            icon: Icons.wifi_tethering,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton(
                            text: '保存设置',
                            onPressed: _saveConfig,
                            icon: Icons.save,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 使用说明
                    _buildSectionTitle('使用说明'),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTip('本地 Ollama 模型', 'Base URL 填 http://你电脑IP:11434/v1，密钥随便填，模型填你拉取的模型名'),
                          const SizedBox(height: 12),
                          _buildTip('在线 API', 'Base URL 填服务商地址（如 https://api.openai.com/v1），密钥填你的 API Key'),
                          const SizedBox(height: 12),
                          _buildTip('手机和电脑', '用本地模型时，手机和电脑要连同一个 WiFi，电脑 IP 在设置里看'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            iconSize: 20,
          ),
          Text(
            '设置',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTip(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
