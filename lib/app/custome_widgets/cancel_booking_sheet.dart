import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet shown when the customer taps "Cancel" on a booking.
///
/// It renders, in one place:
///  * the cancellation policy (editable in the admin portal -> LEGAL)
///  * whether THIS booking can be cancelled and whether it is refundable
///  * the cancellation reasons + optional remarks
///  * an "I agree to the cancellation policy" confirmation
///
/// Submitting only creates a cancellation REQUEST — an admin approves it in the
/// portal and only then does the refund happen.
class CancelBookingSheet extends StatefulWidget {
  const CancelBookingSheet({
    super.key,
    required this.data,
    required this.onSubmit,
    required this.isArabic,
  });

  /// Full response of GET /api/bookings/:id/cancellation-policy.
  final Map<String, dynamic> data;

  /// Called with the chosen reason code and the optional remarks.
  /// Returns true when the request was accepted.
  final Future<bool> Function(String reasonCode, String? notes) onSubmit;

  final bool isArabic;

  @override
  State<CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends State<CancelBookingSheet> {
  final TextEditingController _notesController = TextEditingController();

  String? _selectedReason;
  bool _agreed = false;
  bool _submitting = false;

  Map<String, dynamic> get _eligibility =>
      Map<String, dynamic>.from(widget.data["eligibility"] ?? const {});

  Map<String, dynamic> get _policy =>
      Map<String, dynamic>.from(widget.data["policy"] ?? const {});

  List<Map<String, dynamic>> get _reasons =>
      ((widget.data["reasons"] as List?) ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  bool get _canRequest => _eligibility["can_request"] == true;

  String get _policyTitle => widget.isArabic
      ? (_policy["title_ar"] ?? _policy["title_en"] ?? "cancellation_policy".tr)
      : (_policy["title_en"] ?? "cancellation_policy".tr);

  String get _policyContent => widget.isArabic
      ? (_policy["content_ar"] ?? _policy["content_en"] ?? "")
      : (_policy["content_en"] ?? "");

  String _reasonLabel(Map<String, dynamic> reason) => widget.isArabic
      ? (reason["label_ar"] ?? reason["label_en"] ?? "")
      : (reason["label_en"] ?? "");

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      Get.snackbar("", "please_select_cancellation_reason".tr);
      return;
    }
    if (!_agreed) {
      Get.snackbar("", "please_accept_cancellation_policy".tr);
      return;
    }

    setState(() => _submitting = true);
    final ok = await widget.onSubmit(_selectedReason!, _notesController.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- drag handle ----------
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "cancel_booking".tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _canRequest ? _buildForm() : _buildBlocked(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- not allowed ----------
  Widget _buildBlocked() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFC0392B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _eligibility["message"]?.toString() ??
                      "cancellation_not_allowed".tr,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _policySection(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("close".tr),
          ),
        ),
      ],
    );
  }

  // ---------- cancellation form ----------
  Widget _buildForm() {
    final amount = widget.data["booking"]?["amount"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // eligibility banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF1E8449)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _eligibility["refund_eligible"] == true
                          ? "full_refund_available".tr
                          : "cancellation_request_reviewed".tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_eligibility["refund_eligible"] == true &&
                        amount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "${"refund_amount".tr}: ${amount.toString()}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Text(
          "reason_for_cancellation".tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ..._reasons.map(
          (reason) => RadioListTile<String>(
            value: reason["code"]?.toString() ?? "",
            groupValue: _selectedReason,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF1E88E5),
            title: Text(
              _reasonLabel(reason),
              style: const TextStyle(fontSize: 14),
            ),
            onChanged: (value) => setState(() => _selectedReason = value),
          ),
        ),

        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: "additional_notes_optional".tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 4),
        _policySection(),

        const SizedBox(height: 8),
        CheckboxListTile(
          value: _agreed,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF1E88E5),
          title: Text(
            "i_agree_to_cancellation_policy".tr,
            style: const TextStyle(fontSize: 13),
          ),
          onChanged: (value) => setState(() => _agreed = value ?? false),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "submit_cancellation_request".tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _policySection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          _policyTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        children: [
          Text(
            _policyContent,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
