import 'package:uuid/uuid.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/storage_service.dart';
import '../models/ai_message.dart';
import '../models/user_profile.dart';
import '../models/fitness_goal.dart';
import '../models/user_preferences.dart';

class AiRepository {
  List<AiMessage> _messages = [];

  AiRepository() {
    _loadLocalCache();
  }

  void _loadLocalCache() {
    final stored = StorageService.getJson('fitora_ai_messages');
    if (stored is List) {
      _messages = stored.map((m) => AiMessage.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      _messages = [
        AiMessage(
          id: 'ai_welcome',
          userId: 'athlete_1',
          role: MessageRole.assistant,
          content:
              'Hello! I am **FITORA Coach**, your personal fitness and sports nutrition advisor. How can I help power your goals today?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          suggestedQuestions: const [
            'What should I eat today?',
            'Suggest a high-protein vegetarian meal',
            'Suggest a workout for today',
            'Why does my weight fluctuate?',
          ],
        ),
      ];
      _persist();
    }
  }

  List<AiMessage> getMessages() => List.unmodifiable(_messages);

  Future<AiMessage> sendMessage({
    required String text,
    UserProfile? profile,
    FitnessGoal? goal,
    UserPreferences? preferences,
    int todayCalories = 0,
    int todayWater = 0,
  }) async {
    final userMsg = AiMessage(
      id: const Uuid().v4(),
      userId: profile?.id ?? 'athlete_1',
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    await _persist();

    final responseText = await AiService.generateFitnessResponse(
      prompt: text,
      profile: profile,
      goal: goal,
      preferences: preferences,
      todayCaloriesLogged: todayCalories,
      todayWaterMl: todayWater,
    );

    final assistantMsg = AiMessage(
      id: const Uuid().v4(),
      userId: profile?.id ?? 'athlete_1',
      role: MessageRole.assistant,
      content: responseText,
      timestamp: DateTime.now(),
      suggestedQuestions: const [
        'How can I hit my protein goal?',
        'Suggest workout recovery tips',
        'Can you swap one of my meals?',
      ],
    );

    _messages.add(assistantMsg);
    await _persist();
    return assistantMsg;
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _persist();
  }

  Future<void> _persist() async {
    await StorageService.setJson('fitora_ai_messages', _messages.map((m) => m.toJson()).toList());
  }
}
