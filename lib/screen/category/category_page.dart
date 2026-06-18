import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/data/models/category_model.dart';
import 'package:snailywhim/logic/bloc/category/category_bloc.dart';
import 'package:snailywhim/logic/bloc/category/category_event.dart';
import 'package:snailywhim/logic/bloc/category/category_state.dart';
import 'package:snailywhim/screen/category/create_category.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();

    context.read<CategoryBloc>().add(FetchCategory());
  }

  void _showCategoryForm({CategoryModel? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: CategoryFormPage(category: category),
        );
      },
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kategori"),
        content: Text("Yakin ingin menghapus ${category.nama_kategori} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<CategoryBloc>().add(DeleteCategory(category.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori")),

      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            AppSnackbar.show(
              context,
              title: 'Gagal',
              message: state.message,
              type: SnackType.error,
            );
          }

          if (state is CategoryCreatedSuccess) {
            context.read<CategoryBloc>().add(FetchCategory());
          }
        },

        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryLoaded) {
            if (state.catList.isEmpty) {
              return const Center(child: Text("Belum ada kategori"));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CategoryBloc>().add(FetchCategory());
              },
              child: ListView.builder(
                itemCount: state.catList.length,
                itemBuilder: (context, index) {
                  final category = state.catList[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.category),

                      title: Text(category.nama_kategori),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _showCategoryForm(category: category);
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteCategory(context, category);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCategoryForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
