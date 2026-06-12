import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ai/ai_config_providers.dart';
import '../../../../core/ai/chat_message.dart';
import '../../../../core/ai/chat_session.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/chat_history_service.dart';
import '../../../../core/services/connectivity_test_service.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/storage/local_storage.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;

  static const String _systemPrompt = '''
أنت مساعد إسلامي متخصص اسمه إبراهيم. تجيب على جميع الأسئلة الدينية
والشرعية: الفقه، التفسير، الحديث، العقيدة، السيرة النبوية، الأذكار
والأدعية، الرقائق، التزكية، السيرة، التاريخ الإسلامي، علوم القرآن،
مصطلح الحديث، وأصول الفقه. تستند دائماً إلى القرآن الكريم والسنة
النبوية الصحيحة وإجماع العلماء. أسلوبك هادئ، موثوق، ومحترم.
تذكر المصادر والأدلة دائماً. لا تفتي في المسائل الخلافية الكبرى —
أحل المستخدم إلى العلماء. وفي نهاية كل رد أضف: والله أعلم.
''';

  final List<String> _suggestions = [
    'ما هي أركان الصلاة؟',
    'اشرح لي تفسير آية الكرسي',
    'ما فضل قراءة القرآن؟',
    'أدعية عند الكرب والضيق',
    'ما صحة حديث... ؟',
  ];

  ChatSession? _session;
  List<ChatSession> _sessions = [];
  String _apiInfo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  void _initSession() {
    final sessions = ref.read(chatHistoryProvider).getSessions();
    final currentId = ref.read(currentSessionIdProvider);

    ChatSession session;
    if (currentId != null) {
      try {
        session = sessions.firstWhere((s) => s.id == currentId);
      } catch (_) {
        session = ref.read(chatHistoryProvider).createSession();
      }
    } else {
      session = sessions.isNotEmpty ? sessions.first : ref.read(chatHistoryProvider).createSession();
    }

    ref.read(currentSessionIdProvider.notifier).state = session.id;
    setState(() {
      _session = session;
      _sessions = sessions;
    });
    _updateApiInfo();
    _scrollToBottom();
  }

  void _updateApiInfo() {
    final apiKey = ref.read(effectiveApiKeyProvider);
    final provider = ref.read(currentAiProvider);
    final model = ref.read(selectedAiModel).isNotEmpty
        ? ref.read(selectedAiModel)
        : provider.defaultModel;
    setState(() {
      _apiInfo = apiKey.isNotEmpty ? '$model' : '';
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _newSession() async {
    final service = ref.read(chatHistoryProvider);
    final session = service.createSession();
    ref.read(currentSessionIdProvider.notifier).state = session.id;
    await service.saveSession(session);
    setState(() {
      _session = session;
      _sessions = service.getSessions();
    });
  }

  void _switchSession(ChatSession session) {
    ref.read(currentSessionIdProvider.notifier).state = session.id;
    setState(() {
      _session = session;
    });
    _scrollToBottom();
    Navigator.pop(context); // close drawer
  }

  Future<void> _deleteSession(String id) async {
    final service = ref.read(chatHistoryProvider);
    await service.deleteSession(id);
    final sessions = service.getSessions();
    setState(() {
      _sessions = sessions;
      if (_session?.id == id) {
        if (sessions.isNotEmpty) {
          _session = sessions.first;
          ref.read(currentSessionIdProvider.notifier).state = sessions.first.id;
        } else {
          _session = service.createSession();
          ref.read(currentSessionIdProvider.notifier).state = _session!.id;
          _sessions = [_session!];
        }
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();

    final userMsg = ChatMessage(content: text, isUser: true, timestamp: DateTime.now());
    final chatService = ref.read(chatHistoryProvider);

    setState(() {
      _session!.messages.add(userMsg);
      if (_session!.title == 'محادثة جديدة') {
        _session!.title = text.length > 25 ? '${text.substring(0, 25)}...' : text;
      }
      _session!.updatedAt = DateTime.now();
      _isLoading = true;
    });
    chatService.saveSession(_session!);
    _scrollToBottom();

    try {
      final apiKey = ref.read(effectiveApiKeyProvider);

      if (apiKey.isEmpty) {
        throw Exception('المفتاح فارغ');
      }

      final providerId = ref.read(selectedAiProviderId);
      final model = ref.read(selectedAiModel);
      final resolvedModel = model.isNotEmpty ? model : ref.read(currentAiProvider).defaultModel;

      final cleanMessages = _session!.messages
          .where((m) => !m.content.startsWith('⚠️'))
          .toList();

      final reply = await ref.read(aiServiceProvider).generateResponse(
        providerId: providerId,
        model: resolvedModel,
        apiKey: apiKey,
        messages: cleanMessages,
        systemPrompt: _systemPrompt,
      );

      final footer = reply.contains('والله أعلم') || reply.contains('والله اعلم') ? '' : '\n\nوالله أعلم';
      final replyWithFooter = '$reply$footer';

      if (mounted) {
        setState(() {
          _session!.messages.add(ChatMessage(content: replyWithFooter, isUser: false, timestamp: DateTime.now()));
          _session!.updatedAt = DateTime.now();
          _isLoading = false;
        });
        chatService.saveSession(_session!);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString();
        String hint;
        if (err.contains('المفتاح فارغ') || err.contains('API key')) {
          hint = 'لم يتم إعداد مفتاح API بعد. اضغط على ⚙️ أعلاه لإضافته.';
        } else if (err.contains('401') || err.contains('403') || err.contains('API_KEY_INVALID')) {
          hint = 'المفتاح غير صالح. تحقق من الإعدادات.';
        } else if (err.contains('429')) {
          hint = 'طلبات كثيرة جداً. حاول لاحقاً.';
        } else if (err.contains('connection') || err.contains('SocketException') || err.contains('Failed host lookup')) {
          hint = 'تأكد من اتصالك بالإنترنت.';
        } else if (err.contains('timeout') || err.contains('Timeout')) {
          hint = 'انتهت مهلة الاتصال. حاول مرة أخرى.';
        } else if (err.contains('500') || err.contains('502') || err.contains('503')) {
          hint = 'الخادم غير متاح حالياً. حاول لاحقاً.';
        } else {
          hint = 'حدث خطأ: $err';
        }
        setState(() {
          _session!.messages.add(ChatMessage(content: '⚠️ $hint', isUser: false, timestamp: DateTime.now()));
          _session!.updatedAt = DateTime.now();
          _isLoading = false;
        });
        chatService.saveSession(_session!);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _testing = false;
  List<Map<String, dynamic>> _testResults = [];

  void _showApiSetup() {
    final storage = LocalStorage();
    final providerId = ref.read(selectedAiProviderId);
    final provider = ref.read(currentAiProvider);

    final apiCtrl = TextEditingController(text: ref.read(aiApiKeyProvider));
    String tempProvider = providerId;
    String tempModel = ref.read(selectedAiModel).isNotEmpty
        ? ref.read(selectedAiModel)
        : provider.defaultModel;

    _testing = false;
    _testResults = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final currentProv = ref.read(aiServiceProvider).getProvider(tempProvider);
          final models = currentProv.availableModels;

          return AlertDialog(
            backgroundColor: AppColors.navy,
            insetPadding: const EdgeInsets.all(16),
            title: const Text('إعدادات الذكاء الاصطناعي', textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مزود الخدمة', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: tempProvider,
                    dropdownColor: AppColors.navyLight,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Amiri'),
                    decoration: _fieldDeco(),
                    items: ref.read(aiServiceProvider).allProviders.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.displayName, style: const TextStyle(fontSize: 13)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          tempProvider = v;
                          tempModel = ref.read(aiServiceProvider).getProvider(v).defaultModel;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('النموذج', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: models.contains(tempModel) ? tempModel : currentProv.defaultModel,
                    dropdownColor: AppColors.navyLight,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 12),
                    decoration: _fieldDeco(),
                    items: models.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => tempModel = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (ref.read(hasRemoteKeyProvider))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('المفتاح مضبوط تلقائياً — اتركه فارغاً أو أدخل مفتاحك الخاص', 
                        style: TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 12)),
                    ),
                  Text(currentProv.apiKeyLabel, style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apiCtrl,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'الصق مفتاح API هنا',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.navyLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ========== TEST BUTTON ==========
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testing ? null : () async {
                        setDialogState(() => _testing = true);
                        final tester = ConnectivityTestService(ref.read(dioProvider));
                        final results = <Map<String, dynamic>>[];

                        final internet = await tester.testInternet();
                        results.add({'label': internet.label, 'success': internet.success, 'msg': internet.message, 'code': internet.statusCode});

                        if (apiCtrl.text.isNotEmpty) {
                          if (tempProvider == 'gemini') {
                            final r = await tester.testGemini(apiKey: apiCtrl.text);
                            results.add({'label': r.label, 'success': r.success, 'msg': r.message, 'code': r.statusCode});
                          }
                          if (tempProvider == 'openrouter') {
                            final r = await tester.testOpenRouter(apiKey: apiCtrl.text);
                            results.add({'label': r.label, 'success': r.success, 'msg': r.message, 'code': r.statusCode});
                          }
                          if (tempProvider == 'together') {
                            final r = await tester.testTogether(apiKey: apiCtrl.text);
                            results.add({'label': r.label, 'success': r.success, 'msg': r.message, 'code': r.statusCode});
                          }
                        }

                        setDialogState(() {
                          _testing = false;
                          _testResults = results;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _testing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy))
                          : const Icon(Icons.wifi_find, size: 20),
                      label: Text(_testing ? 'جاري الاختبار...' : '🔍 اختبار الاتصال'),
                    ),
                  ),

                  // ========== TEST RESULTS ==========
                  if (_testResults.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: _testResults.map((r) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: (r['success'] as bool) ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (r['success'] as bool) ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (r['success'] as bool) ? Icons.check_circle : Icons.error,
                                color: (r['success'] as bool) ? AppColors.success : AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['label'] as String,
                                      style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(r['msg'] as String,
                                      style: TextStyle(
                                        color: (r['success'] as bool) ? AppColors.success : AppColors.error,
                                        fontFamily: 'Inter', fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (r['code'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.navy,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${r['code']}',
                                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 10)),
                                ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📌 للحصول على مفتاح مجاني:',
                          style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _linkTile('Google Gemini', 'ai.google.dev'),
                        _linkTile('OpenRouter', 'openrouter.ai/keys'),
                        _linkTile('Together AI', 'together.ai'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: Colors.white70))),
              TextButton(
                onPressed: () {
                  ref.read(selectedAiProviderId.notifier).state = tempProvider;
                  ref.read(selectedAiModel.notifier).state = tempModel;
                  ref.read(aiApiKeyProvider.notifier).state = apiCtrl.text;
                  storage.saveString('ai_provider', tempProvider);
                  storage.saveString('ai_model_$tempProvider', tempModel);
                  storage.saveString('ai_key_$tempProvider', apiCtrl.text);
                  Navigator.pop(ctx);
                  _updateApiInfo();
                },
                child: const Text('حفظ', style: TextStyle(color: AppColors.gold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _linkTile(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.open_in_new, color: AppColors.goldMuted, size: 14),
          const SizedBox(width: 6),
          Text('$label — ', style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 11)),
          GestureDetector(
            onTap: () => context.push('/ai-assistant'),
            child: Text(url, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 11, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.navyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.mosque, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            const Text('إبراهيم AI'),
            if (_apiInfo.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_apiInfo, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 9)),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.navy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold),
            tooltip: 'محادثة جديدة',
            onPressed: _newSession,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.gold),
            onPressed: _showApiSetup,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(child: _session == null ? const SizedBox.shrink() : _buildMessages()),
          if (_session != null && _session!.messages.isEmpty) _buildSuggestions(),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.navy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.gold, size: 24),
                  const SizedBox(width: 10),
                  const Text('المحادثات السابقة',
                    style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (_sessions.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        final service = ref.read(chatHistoryProvider);
                        await service.clearAll();
                        setState(() {
                          _sessions = [];
                          _session = service.createSession();
                          ref.read(currentSessionIdProvider.notifier).state = _session!.id;
                          _sessions = [_session!];
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Icon(Icons.delete_sweep, color: AppColors.error, size: 20),
                    ),
                ],
              ),
            ),
            const Divider(color: AppColors.goldMuted, height: 1),
            Expanded(
              child: _sessions.isEmpty
                  ? const Center(
                      child: Text('لا توجد محادثات سابقة',
                        style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 14)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _sessions.length,
                      itemBuilder: (context, i) {
                        final s = _sessions[i];
                        final active = s.id == _session?.id;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: active ? AppColors.goldMuted : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Text(s.messages.isEmpty ? '💬' : '💭',
                              style: const TextStyle(fontSize: 20)),
                            title: Text(
                              s.title,
                              style: TextStyle(
                                color: active ? AppColors.gold : AppColors.textOnDark,
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              s.preview ?? '',
                              style: const TextStyle(
                                color: AppColors.textOnDarkMuted,
                                fontFamily: 'Inter',
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: GestureDetector(
                              onTap: () => _deleteSession(s.id),
                              child: const Icon(Icons.close, color: AppColors.textOnDarkMuted, size: 16),
                            ),
                            onTap: () => _switchSession(s),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _send(_suggestions[i]),
          child: Container(
            margin: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldMuted),
            ),
            child: Center(
              child: Text(_suggestions[i],
                style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    final msgs = _session!.messages;
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: msgs.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == msgs.length) return const _TypingIndicator();
        return _MessageBubble(message: msgs[index]);
      },
    );
  }

  Widget _buildInput() {
    final hasKey = ref.read(effectiveApiKeyProvider).isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.navyLight,
        border: Border(top: BorderSide(color: AppColors.goldMuted)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              textDirection: TextDirection.rtl,
              maxLines: null,
              style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16),
              decoration: InputDecoration(
                hintText: hasKey ? 'اسألني...' : 'اضغط ⚙️ لإعداد المفتاح أولاً',
                hintStyle: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 14),
                filled: true,
                fillColor: AppColors.navy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: hasKey ? _send : null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: hasKey ? () => _send(_inputCtrl.text) : _showApiSetup,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: hasKey ? AppColors.gold : AppColors.goldMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(hasKey ? Icons.send : Icons.settings, color: AppColors.navy, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isError = message.content.startsWith('⚠️');
    return Align(
      alignment: message.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? AppColors.error.withValues(alpha: 0.15)
              : message.isUser
                  ? AppColors.navyLight
                  : AppColors.goldMuted,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? Radius.zero : const Radius.circular(16),
            bottomRight: message.isUser ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border.all(
            color: isError
                ? AppColors.error.withValues(alpha: 0.3)
                : message.isUser
                    ? AppColors.goldMuted
                    : AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          message.content,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isError ? AppColors.error : message.isUser ? AppColors.textOnDark : AppColors.gold,
            fontFamily: 'Amiri',
            fontSize: 16,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.goldMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FadeTransition(
          opacity: _anim,
          child: const Text('...',
              style: TextStyle(color: AppColors.gold, fontSize: 20, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}
