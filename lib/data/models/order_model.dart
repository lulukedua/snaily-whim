class OrderModel {
  final String id;
  final int total_harga;
  final String status_order; //enum
  final List<Map<String, dynamic>>? item; //array
  final String status_pembayaran;
  final String? snap_token;
  final String? midtrans_order_id;
  final String? payment_type;
  final String user_id;
  final DateTime? updated_at;

  OrderModel({
    required this.id,
    required this.total_harga,
    required this.status_order,
    this.item,
    required this.status_pembayaran,
    this.snap_token,
    this.midtrans_order_id,
    this.payment_type,
    required this.user_id,
    this.updated_at
  });
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      total_harga: json['total_harga'] ?? 0,
      status_order: json['status_order'] ?? 'waiting',

      item: json['item'] != null
          ? List<Map<String, dynamic>>.from(
              json['item'].map((x) => Map<String, dynamic>.from(x)),
            )
          : null,
      status_pembayaran: json['status_pembayaran'] ?? 'pending',

      snap_token: json['snap_token'],
      midtrans_order_id: json['midtrans_order_id'],
      payment_type: json['payment_type'],
      user_id: json['user_id'] ?? '',
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_harga': total_harga,
      'status_order': status_order,
      'item': item,
      'status_pembayaran': status_pembayaran,
      'snap_token': snap_token,
      'midtrans_order_id': midtrans_order_id,
      'payment_type': payment_type,
      'user_id': user_id,
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}