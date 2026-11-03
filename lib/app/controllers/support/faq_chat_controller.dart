import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/support/support_models.dart';
import '../../repositories/support/support_repository.dart';
import '../../routes/app_routes.dart';

/// What a chat option does when the customer taps it.
enum GuideChoiceKind { question, solved, notSolved, more, escalate, helpCenter }

/// One tappable option shown under a bot message.
class GuideChoice {
  const GuideChoice({required this.label, required this.kind, this.question});

  final String label;
  final GuideChoiceKind kind;
  final FaqQuestion? question;
}

/// One bubble in the guided help conversation.
class GuideEntry {
  GuideEntry({
    required this.fromUser,
    required this.text,
    this.steps = const [],
    this.screenRoute,
    this.choices = const [],
    this.isError = false,
  });

  final bool fromUser;
  final String text;
  final List<String> steps;
  final String? screenRoute;
  final List<GuideChoice> choices;
  final bool isError;
}

/// Guided Help Center flow.
///
/// The customer picks a topic, then the questions of that topic arrive as chat
/// options. Tapping a question shows its answer inside the conversation and the
/// next set of options follows, so the whole flow feels like chatting with a
/// help bot. At any point the customer can switch to a real agent.
///
/// All content (topics, questions, answers, steps) comes from the FAQ tables,
/// so new questions added in the admin website appear here automatically.
class FaqChatController extends GetxController {
  final SupportRepository _repository = SupportRepository();
  final ScrollController scrollController = ScrollController();

  late FaqCategory category;

  RxList<GuideEntry> entries = <GuideEntry>[].obs;
  RxBool isLoading = true.obs;
  RxBool isBotTyping = false.obs;
  RxBool isEscalating = false.obs;
  RxString errorMessage = ''.obs;

  List<FaqQuestion> _questions = <FaqQuestion>[];
  final Set<String> _asked = <String>{};
  FaqQuestion? _activeQuestion;
  String _lastAnswer = '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    category = args is FaqCategory
        ? args
        : FaqCategory(
            id: args is Map ? (args['id']?.toString() ?? '') : '',
            nameEn: args is Map ? (args['name_en']?.toString() ?? '') : '',
            nameAr: args is Map ? (args['name_ar']?.toString() ?? '') : '',
          );

    start();
  }

  // ==================== State ====================

  String get languageCode => Get.locale?.languageCode ?? 'en';

  String get categoryName => category.id.isEmpty
      ? 'help_center_title'.tr
      : category.localizedName(languageCode);

  List<FaqQuestion> get _remainingQuestions =>
      _questions.where((q) => !_asked.contains(q.id)).toList();

  // ==================== Entry point ====================

  Future<void> start() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _questions = await _repository.fetchQuestions(category.id);
    } catch (e) {
      print("❌ Guided help questions failed: $e");
      errorMessage.value = SupportRepository.errorMessage(
        e,
        'unable_to_load_help_center'.tr,
      );
    } finally {
      isLoading.value = false;
    }

    if (_questions.isEmpty) {
      await _botSay(
        text: errorMessage.value.isNotEmpty
            ? errorMessage.value
            : 'guided_no_questions'.tr,
        choices: _escalateChoices(),
        isError: true,
      );
      return;
    }

    // Echo the chosen topic like a message, then offer the questions of it.
    entries.add(GuideEntry(fromUser: true, text: categoryName));
    _scrollToBottom();

    await _botSay(
      text: 'guided_pick_problem'.tr,
      choices: _questionChoices(_remainingQuestions),
    );
  }

  /// Restarts the conversation (used by the error state).
  Future<void> retry() async {
    entries.clear();
    _asked.clear();
    _activeQuestion = null;
    _lastAnswer = '';
    await start();
  }

  // ==================== Customer actions ====================

  Future<void> choose(GuideChoice choice) async {
    switch (choice.kind) {
      case GuideChoiceKind.question:
        final question = choice.question;
        if (question != null) await _openQuestion(question);
      case GuideChoiceKind.solved:
        await _markSolved();
      case GuideChoiceKind.notSolved:
        await _markNotSolved();
      case GuideChoiceKind.more:
        await _showMoreQuestions();
      case GuideChoiceKind.escalate:
        escalateToAgent();
      case GuideChoiceKind.helpCenter:
        _backToHelpCenter();
    }
  }

  Future<void> _openQuestion(FaqQuestion question) async {
    _asked.add(question.id);
    _activeQuestion = question;

    entries.add(
      GuideEntry(
        fromUser: true,
        text: question.localizedQuestion(languageCode),
      ),
    );
    _scrollToBottom();

    isBotTyping.value = true;

    FaqQuestion detail = question;
    try {
      detail = await _repository.fetchQuestion(question.id) ?? question;
    } catch (e) {
      print("❌ Guided help answer failed: $e");
    }

    isBotTyping.value = false;

    final answer = detail.localizedAnswer(languageCode);

    if (answer.trim().isEmpty) {
      await _botSay(
        text: 'guided_answer_failed'.tr,
        choices: _escalateChoices(),
        isError: true,
      );
      return;
    }

    _lastAnswer = answer;

    await _botSay(
      text: answer,
      steps: detail.localizedSteps(languageCode),
      screenRoute: detail.screenRoute,
    );

    await _botSay(
      text: 'did_this_solve'.tr,
      choices: [
        GuideChoice(label: 'solved_yes'.tr, kind: GuideChoiceKind.solved),
        GuideChoice(label: 'solved_no'.tr, kind: GuideChoiceKind.notSolved),
      ],
    );
  }

  Future<void> _markSolved() async {
    _sendFeedback(true);

    await _botSay(
      text: 'guided_solved'.tr,
      choices: [
        if (_remainingQuestions.isNotEmpty)
          GuideChoice(label: 'guided_show_more'.tr, kind: GuideChoiceKind.more),
        GuideChoice(
          label: 'guided_back_help_center'.tr,
          kind: GuideChoiceKind.helpCenter,
        ),
      ],
    );
  }

  Future<void> _markNotSolved() async {
    _sendFeedback(false);

    final remaining = _remainingQuestions;

    if (remaining.isEmpty) {
      await _botSay(
        text: 'guided_connect_agent'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(
      text: 'guided_other_questions'.tr,
      choices: [
        ..._questionChoices(remaining),
        GuideChoice(
          label: 'guided_chat_team'.tr,
          kind: GuideChoiceKind.escalate,
        ),
      ],
    );
  }

  Future<void> _showMoreQuestions() async {
    final remaining = _remainingQuestions;

    if (remaining.isEmpty) {
      await _botSay(
        text: 'guided_connect_agent'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(
      text: 'guided_pick_problem'.tr,
      choices: _questionChoices(remaining),
    );
  }

  /// Hands the conversation over to a human agent.
  ///
  /// The topic, the question the customer read and the answer they were shown
  /// are all forwarded, so the agent does not have to ask again.
  void escalateToAgent() {
    if (isEscalating.value) return;

    isEscalating.value = true;

    try {
      Get.toNamed(
        Routes.supportChat,
        arguments: {
          'category': category.id.isEmpty ? 'other_issues' : category.id,
          'source': 'faq_chat',
          'question_id': _activeQuestion?.id,
          'question_en': _activeQuestion?.questionEn,
          'question_ar': _activeQuestion?.questionAr,
          'last_attempted_solution': _lastAnswer,
        },
      );
    } finally {
      isEscalating.value = false;
    }
  }

  // ==================== Helpers ====================

  List<GuideChoice> _questionChoices(List<FaqQuestion> questions) {
    return questions
        .map(
          (question) => GuideChoice(
            label: question.localizedQuestion(languageCode),
            kind: GuideChoiceKind.question,
            question: question,
          ),
        )
        .toList();
  }

  List<GuideChoice> _escalateChoices() {
    return [
      GuideChoice(label: 'guided_chat_team'.tr, kind: GuideChoiceKind.escalate),
      GuideChoice(
        label: 'guided_back_help_center'.tr,
        kind: GuideChoiceKind.helpCenter,
      ),
    ];
  }

  Future<void> _botSay({
    required String text,
    List<String> steps = const [],
    String? screenRoute,
    List<GuideChoice> choices = const [],
    bool isError = false,
  }) async {
    if (!isBotTyping.value) {
      isBotTyping.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      isBotTyping.value = false;
    }

    entries.add(
      GuideEntry(
        fromUser: false,
        text: text,
        steps: steps,
        screenRoute: screenRoute,
        choices: choices,
        isError: isError,
      ),
    );

    _scrollToBottom();
  }

  Future<void> _sendFeedback(bool helpful) async {
    final questionId = _activeQuestion?.id;
    if (questionId == null || questionId.isEmpty) return;

    try {
      await _repository.sendFaqFeedback(questionId, helpful);
    } catch (e) {
      // Feedback is best-effort.
      print("⚠️ Guided help feedback failed: $e");
    }
  }

  void openScreenRoute(String? route) {
    if (route == null || route.isEmpty) return;

    const allowed = <String, String>{
      'bookings': Routes.dashboard,
      'booking_history': Routes.dashboard,
      'coupons': Routes.mycoupons,
      'offers': Routes.offerscreen,
      'profile': Routes.dashboard,
      'vehicles': Routes.carlist,
    };

    final target = allowed[route];
    if (target == null) {
      print("⚠️ Unsupported screen_route: $route");
      return;
    }

    Get.offNamedUntil(target, (page) => page.settings.name == Routes.splash);
  }

  void _backToHelpCenter() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offNamed(Routes.helpCenter);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
