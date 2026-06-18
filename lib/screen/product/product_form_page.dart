import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snailywhim/core/helper/image_picker_helper.dart';
import 'package:snailywhim/core/validator/product_validator.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/custom_button.dart';
import 'package:snailywhim/core/widgets/custom_dropdown.dart';
import 'package:snailywhim/core/widgets/custom_text_field.dart';
import 'package:snailywhim/core/widgets/image_picker.dart';
import 'package:snailywhim/data/models/category_model.dart';
import 'package:snailywhim/data/models/product_model.dart';
import 'package:snailywhim/data/repositories/category_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;
  final String cabangId;

  const ProductFormPage({super.key, this.product, required this.cabangId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  final ProductRepository productRepository = ProductRepository();
  final CategoryRepository categoryRepository = CategoryRepository();

  List<CategoryModel> kategoriList = [];

  String? selectedKategoriId;
  File? selectedImage;

  bool isLoading = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    loadKategori();

    if (isEdit) {
      _namaController.text = widget.product!.nama_product;
      _deskripsiController.text = widget.product!.deskripsi;
      _hargaController.text = widget.product!.harga.toString();
      _stokController.text = widget.product!.stok.toString();
      selectedKategoriId = widget.product!.kategori_id;
    }
  }

  Future<void> loadKategori() async {
    try {
      final result = await categoryRepository.getAllKategori();

      if (!mounted) return;

      setState(() {
        kategoriList = result;
      });
    } catch (_) {}
  }

  Future<void> pickImage() async {
    try {
      final image = await ImagePickerHelper.pickImage(context);

      if (image == null) return;

      setState(() {
        selectedImage = image;
      });
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.show(
        context,
        title: 'Gagal',
        message: e.toString().replaceAll('Exception: ', ''),
        type: SnackType.error,
      );
    }
  }

  Future<void> submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    if (selectedKategoriId == null) {
      AppSnackbar.show(
        context,
        title: 'Perhatian',
        message: 'Kategori wajib dipilih',
        type: SnackType.warning,
      );
      return;
    }
    if (!isEdit && selectedImage == null && widget.product?.image_url == null) {
      AppSnackbar.show(
        context,
        title: 'Perhatian',
        message: 'Gambar produk wajib diisi',
        type: SnackType.warning,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? imageUrl = widget.product?.image_url;
      if (selectedImage != null) {
        imageUrl = await productRepository.uploadProductImage(selectedImage!);
      }
      final product = ProductModel(
        id: isEdit ? widget.product!.id : '',
        nama_product: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        harga: int.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
        image_url: imageUrl,
        kategori_id: selectedKategoriId!,
        cabang_id: widget.cabangId,
      );
      if (isEdit) {
        await productRepository.updateProduct(product);
      } else {
        await productRepository.createProduct(product);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        title: 'Gagal',
        message: e.toString().replaceAll('Exception: ', ''),
        type: SnackType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomImagePicker(
              imageFile: selectedImage,
              imageUrl: widget.product?.image_url,
              onTap: pickImage,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _namaController,
              label: 'Nama Produk',
              icon: Icons.local_florist,
              validator: ProductValidator.validateNama,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _deskripsiController,
              label: 'Deskripsi',
              icon: Icons.description,
              validator: ProductValidator.validateDeskripsi,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _hargaController,
              label: 'Harga',
              icon: Icons.payments,
              keyboardType: TextInputType.number,
              validator: ProductValidator.validateHarga,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _stokController,
              label: 'Stok',
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
              validator: ProductValidator.validateStok,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'Kategori',
              icon: Icons.category,
              value: selectedKategoriId,
              items: kategoriList
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.nama_kategori),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedKategoriId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Kategori wajib dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: isEdit ? 'Update Produk' : 'Tambah Produk',
              isLoading: isLoading,
              onPressed: submit,
            ),
          ],
        ),
      ),
    );
  }
}
