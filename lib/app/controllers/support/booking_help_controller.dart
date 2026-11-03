import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/flutter_toast.dart';
import '../../models/support/booking_support_models.dart';
import '../../repositories/support/support_repository.dart';
import '../../routes/app_routes.dart';

/// What a chip in the booking help conversation does.
enum BookingChoiceKind {
  category,
  question,
  solved,
  notSolved,
  moreCategories,
  escalate,
  backToBooking,
}

class BookingGuideChoice {
  const BookingGuideChoice({
    required this.label,
    required this.kind,
    this.category,
    this.question,
  });

  final String label;
  final BookingChoiceKind kind;
  final BookingHelpCategory? category;
  final BookingHelpQuestion? question;
}

class BookingGuideEntry {
  BookingGuideEntry({
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
  final List<BookingGuideChoice> choices;
  final bool isError;
}

/// Guided, booking-specific help.
///
/// Flow: booking summary → issue category → the questions that apply to THIS
/// booking → an answer composed from the real booking/payment state → feedback
/// → escalation to a live support conversation that is linked to the booking.
///
/// The questions, their availability and the answers all come from the backend
/// (`/api/support/bookings/:id/help`), so the app never decides what is
/// applicable on its own.
class BookingHelpController extends GetxController {
  final SupportRepository _repository = SupportRepository();
  final ScrollController scrollController = ScrollController();

  late final String bookingId;
  late final String fallbackBookingCode;

  RxList<BookingGuideEntry> entries = <BookingGuideEntry>[].obs;
  Rxn<BookingSupportSummary> booking = Rxn<BookingSupportSummary>();
  BookingHelpPayload? _payload;

  RxBool isLoading = true.obs;
  RxBool isBotTyping = false.obs;
  RxBool isEscalating = false.obs;
  RxString errorMessage = ''.obs;

  BookingHelpCategory? _activeCategory;
  BookingHelpQuestion? _activeQuestion;
  BookingHelpAnswer? _lastAnswer;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      bookingId = args['booking_id']?.toString() ?? '';
      fallbackBookingCode = args['booking_code']?.toString() ?? '';
    } else {
      bookingId = '';
      fallbackBookingCode = '';
    }

    start();
  }

  String get languageCode => Get.locale?.languageCode ?? 'en';

  String get headerCode => booking.value?.bookingCode.isNotEmpty == true
      ? booking.value!.bookingCode
      : fallbackBookingCode;

  Future<void> start() async {
    isLoading.value = true;
    errorMessage.value = '';
    entries.clear();

    if (bookingId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'booking_not_found'.tr;
      return;
    }

    try {
      final payload = await _repository.fetchBookingHelp(bookingId);
      _payload = payload;
      booking.value = payload.booking;

      if (payload.categories.isEmpty) {
        await _botSay(
          text: 'booking_help_no_questions'.tr,
          choices: _escalateChoices(),
        );
      } else {
        await _botSay(
          text: 'booking_help_intro'.tr,
          choices: _categoryChoices(),
        );
      }
    } catch (e) {
      print("❌ Booking help failed: $e");
      errorMessage.value = SupportRepository.errorMessage(
        e,
        'booking_help_unavailable'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    await start();
  }

  // ==================== Actions ====================

  Future<void> choose(BookingGuideChoice choice) async {
    switch (choice.kind) {
      case BookingChoiceKind.category:
        final category = choice.category;
        if (category != null) await _openCategory(category);
      case BookingChoiceKind.question:
        final question = choice.question;
        if (question != null) await _openQuestion(question);
      case BookingChoiceKind.solved:
        await _markSolved();
      case BookingChoiceKind.notSolved:
        await _markNotSolved();
      case BookingChoiceKind.moreCategories:
        await _showCategories();
      case BookingChoiceKind.escalate:
        await escalateToAgent();
      case BookingChoiceKind.backToBooking:
        _backToBooking();
    }
  }

  Future<void> _openCategory(BookingHelpCategory category) async {
    _activeCategory = category;

    entries.add(
      BookingGuideEntry(
        fromUser: true,
        text: category.localizedLabel(languageCode),
      ),
    );
    _scrollToBottom();

    if (category.questions.isEmpty) {
      await _botSay(
        text: 'booking_help_no_questions'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(
      text: 'booking_help_pick_question'.tr,
      choices: [
        ...category.questions.map(
          (question) => BookingGuideChoice(
            label: question.localizedQuestion(languageCode),
            kind: BookingChoiceKind.question,
            question: question,
          ),
        ),
        BookingGuideChoice(
          label: 'guided_chat_team'.tr,
          kind: BookingChoiceKind.escalate,
        ),
      ],
    );
  }

  Future<void> _openQuestion(BookingHelpQuestion question) async {
    _activeQuestion = question;

    entries.add(
      BookingGuideEntry(
        fromUser: true,
        text: question.localizedQuestion(languageCode),
      ),
    );
    _scrollToBottom();

    isBotTyping.value = true;
    BookingHelpAnswer? answer;

    try {
      answer = await _repository.fetchBookingAnswer(bookingId, question.id);
      if (answer.booking.id.isNotEmpty) {
        booking.value = answer.booking;
      }
    } catch (e) {
      print("❌ Booking answer failed: $e");
    }

    isBotTyping.value = false;

    if (answer == null) {
      await _botSay(
        text: 'booking_answer_failed'.tr,
        choices: _escalateChoices(),
        isError: true,
      );
      return;
    }

    _lastAnswer = answer;

    await _botSay(
      text: answer.localizedAnswer(languageCode),
      steps: answer.localizedSteps(languageCode),
      screenRoute: answer.screenRoute,
    );

    // Urgent money/technician problems go straight to a human agent.
    if (answer.urgent) {
      await _botSay(
        text: 'booking_help_urgent'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(
      text: 'did_this_solve'.tr,
      choices: [
        BookingGuideChoice(
          label: 'solved_yes'.tr,
          kind: BookingChoiceKind.solved,
        ),
        BookingGuideChoice(
          label: 'solved_no'.tr,
          kind: BookingChoiceKind.notSolved,
        ),
      ],
    );
  }

  Future<void> _markSolved() async {
    await _botSay(
      text: 'booking_help_solved'.tr,
      choices: [
        BookingGuideChoice(
          label: 'booking_help_more_topics'.tr,
          kind: BookingChoiceKind.moreCategories,
        ),
        BookingGuideChoice(
          label: 'booking_help_back'.tr,
          kind: BookingChoiceKind.backToBooking,
        ),
      ],
    );
  }

  Future<void> _markNotSolved() async {
    final remaining = (_activeCategory?.questions ?? <BookingHelpQuestion>[])
        .where((question) => question.id != _activeQuestion?.id)
        .toList();

    if (remaining.isEmpty) {
      await _botSay(
        text: 'booking_help_connect_agent'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(
      text: 'booking_help_other_questions'.tr,
      choices: [
        ...remaining.map(
          (question) => BookingGuideChoice(
            label: question.localizedQuestion(languageCode),
            kind: BookingChoiceKind.question,
            question: question,
          ),
        ),
        BookingGuideChoice(
          label: 'guided_chat_team'.tr,
          kind: BookingChoiceKind.escalate,
        ),
      ],
    );
  }

  Future<void> _showCategories() async {
    final categories = _payload?.categories ?? const <BookingHelpCategory>[];

    if (categories.isEmpty) {
      await _botSay(
        text: 'booking_help_no_questions'.tr,
        choices: _escalateChoices(),
      );
      return;
    }

    await _botSay(text: 'booking_help_intro'.tr, choices: _categoryChoices());
  }

  List<BookingGuideChoice> _categoryChoices() {
    return (_payload?.categories ?? const <BookingHelpCategory>[])
        .map(
          (category) => BookingGuideChoice(
            label: category.localizedLabel(languageCode),
            kind: BookingChoiceKind.category,
            category: category,
          ),
        )
        .toList();
  }

  List<BookingGuideChoice> _escalateChoices() {
    return [
      BookingGuideChoice(
        label: 'contact_support'.tr,
        kind: BookingChoiceKind.escalate,
      ),
      BookingGuideChoice(
        label: 'booking_help_back'.tr,
        kind: BookingChoiceKind.backToBooking,
      ),
    ];
  }

  /// Opens (or reuses) the support conversation linked to this booking.
  Future<void> escalateToAgent() async {
    if (isEscalating.value) return;

    isEscalating.value = true;

    try {
      final conversation = await _repository.startBookingConversation(
        bookingId,
        category: _activeCategory?.id,
        questionId: _activeQuestion?.id,
        questionEn: _activeQuestion?.questionEn,
        questionAr: _activeQuestion?.questionAr,
        lastAttemptedSolution: _lastAnswer?.answerEn,
      );

      Get.toNamed(
        Routes.supportChat,
        arguments: {
          'conversation_id': conversation.id,
          'booking_id': bookingId,
        },
      );
    } catch (e) {
      print("❌ Opening booking support chat failed: $e");
      errorToast(
        SupportRepository.errorMessage(e, 'support_chat_unavailable'.tr),
      );
    } finally {
      isEscalating.value = false;
    }
  }

  // ==================== Helpers ====================

  Future<void> _botSay({
    required String text,
    List<String> steps = const [],
    String? screenRoute,
    List<BookingGuideChoice> choices = const [],
    bool isError = false,
  }) async {
    if (!isBotTyping.value) {
      isBotTyping.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 380));
      isBotTyping.value = false;
    }

    entries.add(
      BookingGuideEntry(
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

  void openScreenRoute(String? route) {
    if (route == null || route.isEmpty) return;

    const allowed = <String, String>{
      'bookings': Routes.dashboard,
      'booking_history': Routes.dashboard,
      'coupons': Routes.mycoupons,
      'offers': Routes.offerscreen,
      'vehicles': Routes.carlist,
    };

    final target = allowed[route];
    if (target == null) {
      print("⚠️ Unsupported screen_route: $route");
      return;
    }

    Get.offNamedUntil(target, (page) => page.settings.name == Routes.splash);
  }

  void _backToBooking() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.offNamed(Routes.dashboard);
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
