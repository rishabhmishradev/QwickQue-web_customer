class BookingModel {
  final int id;
  final int userId;
  final int salonId;
  final int staffId;
  final int serviceId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final String status;
  final String serviceName;
  final double servicePrice;
  final int serviceDuration;

  BookingModel({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.staffId,
    required this.serviceId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceDuration,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['user_id'],
      salonId: json['salon_id'],
      staffId: json['staff_id'],
      serviceId: json['service_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      serviceName: json['service_name'],
      servicePrice: double.parse(json['service_price'].toString()),
      serviceDuration: json['service_duration'],
    );
  }
}
