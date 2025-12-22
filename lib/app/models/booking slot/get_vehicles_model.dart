class GetVehiclesModel {
  final List<VehicleItem> vehicles;

  GetVehiclesModel({required this.vehicles});

  factory GetVehiclesModel.fromJson(List<dynamic> jsonList) {
    return GetVehiclesModel(
      vehicles: jsonList.map((json) => VehicleItem.fromJson(json)).toList(),
    );
  }
}

class VehicleItem {
  final int id;
  final String customerId;
  final String customerName;
  final String vehicleNumber;
  final String make;
  final String model;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.vehicleNumber,
    required this.make,
    required this.model,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleItem.fromJson(Map<String, dynamic> json) {
    return VehicleItem(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? "",
      customerName: json['customer_name'] ?? "",
      vehicleNumber: json['vehicle_number'] ?? json['vehicleNumber'] ?? "",
      make: json['make'] ?? "",
      model: json['model'] ?? "",
      type: json['type'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt'] ?? ""),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ""),
    );
  }
}
