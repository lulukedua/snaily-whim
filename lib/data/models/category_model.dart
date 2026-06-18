class CategoryModel {
  final String id;
  final String nama_kategori;

  CategoryModel({
    required this.id,
    required this.nama_kategori
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nama_kategori: json['nama_kategori'],
    );
  }
}