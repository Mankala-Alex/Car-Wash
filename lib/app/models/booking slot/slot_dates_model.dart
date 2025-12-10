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
    // Parse UTC timestamp
    DateTime utc = DateTime.parse(json["date"]);

    // Convert to LOCAL India time
    DateTime local = utc.toLocal();

    // Strip time → Use only year/month/day
    DateTime pure = DateTime(local.year, local.month, local.day);

    return SlotDate(id: json["id"], date: pure);
  }
}
