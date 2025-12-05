class Slotdatesmodel {
  Slotdatesmodel({
    required this.success,
    required this.data,
  });

  final bool success;
  final List<Datum> data;

  factory Slotdatesmodel.fromJson(Map<String, dynamic> json) {
    return Slotdatesmodel(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.map((x) => x?.toJson()).toList(),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.date,
    required this.isActive,
  });

  final int id;
  final DateTime? date;
  final bool isActive;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"] ?? 0,
      date: DateTime.tryParse(json["date"] ?? ""),
      isActive: json["is_active"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date?.toIso8601String(),
        "is_active": isActive,
      };
}
