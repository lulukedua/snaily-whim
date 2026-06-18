class CartItemModel {
  final String productId;
  final String namaProduct;
  final int harga;
  final int qty;
  final String? imageUrl;
  final bool selected;

  const CartItemModel({
    required this.productId,
    required this.namaProduct,
    required this.harga,
    required this.qty,
    this.imageUrl,
    this.selected = true,
  });

  CartItemModel copyWith({
    String? productId,
    String? namaProduct,
    int? harga,
    int? qty,
    String? imageUrl,
    bool? selected,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      namaProduct: namaProduct ?? this.namaProduct,
      harga: harga ?? this.harga,
      qty: qty ?? this.qty,
      imageUrl: imageUrl ?? this.imageUrl,
      selected: selected ?? this.selected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'nama_product': namaProduct,
      'harga': harga,
      'qty': qty,
      'image_url': imageUrl,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'],
      namaProduct: json['nama_product'],
      harga: json['harga'],
      qty: json['qty'],
      imageUrl: json['image_url'],
    );
  }

  int get subtotal => harga * qty;
}
