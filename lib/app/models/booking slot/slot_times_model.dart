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
        "data": data.map((x) => x?.toJson()).toList(),
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
  });

  final int id;
  final int dateId;
  final String time;
  final int maxBookings;
  final int currentBookings;
  final bool isActive;
  final String startTime;
  final String endTime;

  factory TimeslotDatum.fromJson(Map<String, dynamic> json) {
    return TimeslotDatum(
      id: json["id"] ?? 0,
      dateId: json["date_id"] ?? 0,
      time: json["time"] ?? "",
      maxBookings: json["max_bookings"] ?? 0,
      currentBookings: json["current_bookings"] ?? 0,
      isActive: json["is_active"] ?? false,
      startTime: json["start_time"] ?? "",
      endTime: json["end_time"] ?? "",
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
      };
}
