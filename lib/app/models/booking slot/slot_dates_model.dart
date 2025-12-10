class Slotsdatemodel {
  Slotsdatemodel({
    required this.success,
    required this.data,
  });

  final bool success;
  final List<SlotDate> data;

  factory Slotsdatemodel.fromJson(Map<String, dynamic> json) {
    return Slotsdatemodel(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<SlotDate>.from(json["data"]!.map((x) => SlotDate.fromJson(x))),
    );
  }
}

class SlotDate {
  SlotDate({
    required this.id,
    required this.date,
  });

  final int id;
  final DateTime date;

  factory SlotDate.fromJson(Map<String, dynamic> json) {
    // Parse ISO date "2025-12-10"
    DateTime parsed = DateTime.parse(json["date"]);

    // Strip time (keep only yyyy-mm-dd)
    DateTime pure = DateTime(parsed.year, parsed.month, parsed.day);

    return SlotDate(id: json["id"], date: pure);
  }
}
