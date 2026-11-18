import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/ai_message.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _inputController.clear();
    setState(() => _isSending = true);

    final aiRepo = ref.read(aiRepositoryProvider);
    final profile = ref.read(userProfileProvider);
    final goal = ref.read(fitnessGoalProvider);
    final prefs = ref.read(userPreferencesProvider);
    final logs = ref.read(nutritionLogsProvider);
    final water = ref.read(todayWaterProvider);

    final todayCalories = logs.fold(0.0, (sum, l) => sum + l.calories).round();

    _scrollToBottom();

    await aiRepo.sendMessage(
      text: query,
      profile: profile,
      goal: goal,
      preferences: prefs,
      todayCalories: todayCalories,
      todayWater: water,
    );

    if (mounted) {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiRepo = ref.watch(aiRepositoryProvider);
    final messages = aiRepo.getMessages();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FITORA Coach', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Personalized & Evidence-Based', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            tooltip: 'Clear Conversation',
            onPressed: () async {
              await aiRepo.clearHistory();
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safety & Medical Guidance Callout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.warningLight,
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Coach provides general training & nutritional estimates. Not medical diagnosis.',
                      style: AppTypography.labelSmall.copyWith(color: const Color(0xFF78350F), fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.role == MessageRole.user;
                  return _buildMessageBubble(msg, isUser);
                },
              ),
            ),

            // Typing Indicator
            if (_isSending) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                    ),
                    const SizedBox(width: 8),
                    Text('FITORA Coach is thinking...', style: AppTypography.labelSmall),
                  ],
                ),
              ),
            ],

            // Quick Prompt Chips
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickPill('What should I eat today?'),
                  const SizedBox(width: 6),
                  _buildQuickPill('High-protein vegetarian options'),
                  const SizedBox(width: 6),
                  _buildQuickPill('Suggest a workout for today'),
                  const SizedBox(width: 6),
                  _buildQuickPill('Why does my weight fluctuate?'),
                ],
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inputController,
                      style: AppTypography.bodyMedium,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Ask about meals, exercises, progress...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: AppSpacing.roundedFull, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: AppSpacing.roundedFull, borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: AppSpacing.roundedFull, borderSide: const BorderSide(color: AppColors.primary)),
                        fillColor: AppColors.surfaceMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                      onPressed: () => _sendMessage(_inputController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
          boxShadow: isUser ? AppColors.buttonShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              msg.content,
              style: AppTypography.bodyMedium.copyWith(
                color: isUser ? Colors.white : AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: msg.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Response copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String query) {
    return ActionChip(
      label: Text(query, style: const TextStyle(fontSize: 11)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      onPressed: () => _sendMessage(query),
    );
  }
}
