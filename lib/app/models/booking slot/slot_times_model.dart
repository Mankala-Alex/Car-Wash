class Slottimesmodel {
  Slottimesmodel({
    required this.success,
    required this.data,
  });

  final bool success;
  final List<TimeslotDatum> data;

  factory Slottimesmodel.fromJson(Map<String, dynamic> json) {
    return Slottimesmodel(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<TimeslotDatum>.from(
              json["data"]!.map((x) => TimeslotDatum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.map((x) => x.toJson()).toList(),
      };
}

class TimeslotDatum {
  TimeslotDatum({
    required this.id,
    required this.dateId,
    required this.time,
    required this.maxBookings,
    required this.currentBookings,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.startTime12h,
    required this.endTime12h,
  });

  final int id;
  final int dateId;
  final String time; // Example: "09:00"
  final int maxBookings;
  final int currentBookings;
  final bool isActive;
  final String startTime;
  final String endTime;
  final String startTime12h; // Example: "9:00 AM"
  final String endTime12h; // Example: "10:00 AM"

  // 🔥 ADD THESE GETTERS HERE ↓↓↓
  int get hour => int.parse(time.split(":")[0]);
  int get minute => int.parse(time.split(":")[1]);

  /// Label shown to the user — prefers the 12-hour format from the API.
  String get displayStartLabel =>
      startTime12h.isNotEmpty ? startTime12h : startTime;

  factory TimeslotDatum.fromJson(Map<String, dynamic> json) {
    return TimeslotDatum(
      id: json["id"] ?? 0,
      dateId: json["date_id"] ?? 0,
      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
      startTime12h: json["start_time_12h"] ?? "",
      endTime12h: json["end_time_12h"] ?? "",
      time: json["time"] ?? json["start_time"] ?? "",
      maxBookings: json["max_bookings"] ?? 0,
      currentBookings: json["current_bookings"] ?? 0,
      isActive: json["is_active"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "date_id": dateId,
        "time": time,
        "max_bookings": maxBookings,
        "current_bookings": currentBookings,
        "is_active": isActive,
        "start_time": startTime,
        "end_time": endTime,
        "start_time_12h": startTime12h,
        "end_time_12h": endTime12h,
      };
}
