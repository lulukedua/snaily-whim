class ProductModel {
  final String id;
  final String nama_product;
  final String deskripsi;
  final int harga;
  final int stok;
  final String? image_url;
  final String cabang_id;
  final String kategori_id;

  ProductModel({
    required this.id,
    required this.nama_product,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    this.image_url,
    required this.cabang_id,
    required this.kategori_id,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nama_product: json['nama_product'],
      deskripsi: json['deskripsi'],
      harga: (json['harga'] ?? 0) as int,
      stok: (json['stok'] ?? 0) as int,
      image_url: json['image_url'],
      cabang_id: json['cabang_id'],
      kategori_id: json['kategori_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nama_product': nama_product,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'image_url': image_url,
      'cabang_id': cabang_id,
      'kategori_id': kategori_id,
    };
  }
}

class ProductResponse {
  final List<ProductModel> productList;
  final int currentPage;
  final int totalPage;

  ProductResponse({
    required this.productList,
    required this.currentPage,
    required this.totalPage,
  });
}