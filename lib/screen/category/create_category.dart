import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/custom_button.dart';
import 'package:snailywhim/core/widgets/custom_text_field.dart';
import 'package:snailywhim/data/models/category_model.dart';
import 'package:snailywhim/logic/bloc/category/category_bloc.dart';
import 'package:snailywhim/logic/bloc/category/category_event.dart';
import 'package:snailywhim/logic/bloc/category/category_state.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaKategoriController;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();

    namaKategoriController = TextEditingController(
      text: widget.category?.nama_kategori ?? '',
    );
  }

  @override
  void dispose() {
    namaKategoriController.dispose();
    super.dispose();
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    if (isEdit) {
      context.read<CategoryBloc>().add(
        UpdateCategory(widget.category!.id, namaKategoriController.text.trim()),
      );
    } else {
      context.read<CategoryBloc>().add(
        CreateCategory(namaKategoriController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryCreatedSuccess) {
          AppSnackbar.show(
            context,
            title: 'Berhasil',
            message: isEdit
                ? 'Kategori berhasil diperbarui'
                : 'Kategori berhasil ditambahkan',
            type: SnackType.success,
          );

          Navigator.pop(context);
        }

        if (state is CategoryError) {
          AppSnackbar.show(
            context,
            title: 'Gagal',
            message: state.message,
            type: SnackType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CategoryLoading;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    isEdit ? "Edit Kategori" : "Tambah Kategori",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: namaKategoriController,
                    label: 'Nama Kategori',
                    icon: Icons.category,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama kategori wajib diisi';
                      }
                      final text = value.trim();
                      if (!RegExp(r'^[A-Za-z ]+$').hasMatch(text)) {
                        return 'Hanya boleh huruf dan spasi';
                      }
                      final words = text.split(' ');
                      for (final word in words) {
                        if (word.isEmpty) continue;
                        final firstChar = word[0];
                        if (firstChar != firstChar.toUpperCase()) {
                          return 'Awal setiap kata harus huruf kapital';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    text: isEdit ? 'Simpan Perubahan' : 'Tambah Kategori',
                    icon: isEdit ? Icons.edit : Icons.add,
                    isLoading: isLoading,
                    onPressed: submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
