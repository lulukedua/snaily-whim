import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/category_filter.dart';
import 'package:snailywhim/core/widgets/pagination.dart';
import 'package:snailywhim/core/widgets/product_card.dart';
import 'package:snailywhim/core/widgets/search.dart';
import 'package:snailywhim/data/models/user_model.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/data/repositories/category_repository.dart';
import 'package:snailywhim/logic/bloc/product/product_bloc.dart';
import 'package:snailywhim/logic/bloc/product/product_event.dart';
import 'package:snailywhim/logic/bloc/product/product_state.dart';
import 'package:snailywhim/logic/bloc/category/category_bloc.dart';
import 'package:snailywhim/screen/category/category_page.dart';
import 'package:snailywhim/screen/product/product_detail_page.dart';
import 'package:snailywhim/screen/product/product_form_page.dart';

class ProductPage extends StatelessWidget {
  final UserModel user;
  final Function(bool visible)? onScrollDirectionChanged;

  const ProductPage({
    super.key,
    required this.user,
    this.onScrollDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductBloc(repository: ProductRepository())
            ..add(FetchProduct(page: 1)),
      child: _ProductView(
        user: user,
        onScrollDirectionChanged: onScrollDirectionChanged,
      ),
    );
  }
}

class _ProductView extends StatefulWidget {
  final UserModel user;
  final Function(bool visible)? onScrollDirectionChanged;

  const _ProductView({
    super.key,
    required this.user,
    this.onScrollDirectionChanged,
  });

  @override
  State<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<_ProductView> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 8;
  String? _activeKategoriId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.onScrollDirectionChanged?.call(false);
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.onScrollDirectionChanged?.call(true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPage(int page) {
    setState(() {
      _currentPage = page;
    });
    final bloc = context.read<ProductBloc>();
    if (_activeKategoriId != null) {
      bloc.add(FilterProductByKategori(_activeKategoriId!, page: page));
    } else if (bloc.currentKeyword.isNotEmpty) {
      bloc.add(SearchProduct(bloc.currentKeyword, page: page));
    } else {
      bloc.add(FetchProduct(page: page));
    }
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCategorySelected(String? kategoriId) {
    setState(() => _activeKategoriId = kategoriId);
 
    if (kategoriId == null) {
      context.read<ProductBloc>().add(FetchProduct(page: 1));
    } else {
      context.read<ProductBloc>().add(FilterProductByKategori(kategoriId, page: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.bgBtmColor,
        title: SizedBox(
          height: 45,
          child: SearchInput(
            hintText: "Cari produk...",
            onChanged: (value) {
              _currentPage = 1;
              setState(() => _activeKategoriId = null);
              context.read<ProductBloc>().add(SearchProduct(value, page: 1));
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          CategoryBloc(repository: CategoryRepository()),
                      child: const CategoryPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.category, color: Colors.white),
              label: const Text(
                "Kategori",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: CategoryFilterBar(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            onSelected: _onCategorySelected,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.bgBtmColor,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProductFormPage(cabangId: widget.user.cabangId!),
              ),
            );
            if (result == true) {
              _fetchPage(0);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),

      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductDeletedSuccess) {
            AppSnackbar.show(
              context,
              title: 'Berhasil',
              message: 'Produk berhasil dihapus',
              type: SnackType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primColor),
            );
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is ProductLoaded) {
            if (state.productList.isEmpty && _currentPage == 0) {
              return const Center(child: Text("Belum ada produk"));
            }

            bool isLastPage = state.productList.length < _limit;

            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.productList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: .72,
                        ),
                    itemBuilder: (_, index) {
                      final product = state.productList[index];
                      return ProductCard(
                        product: product,
                        isAdmin: widget.user.isAdmin,
                        showMenu: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(productId: product.id),
                            ),
                          );
                        },
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormPage(
                                product: product,
                                cabangId: widget.user.cabangId!,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchPage(_currentPage);
                          }
                        },
                        onDelete: () {
                          context.read<ProductBloc>().add(
                            DeleteProduct(product.id),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: PaginationControl(
                    currentPage: state.currentPage,
                    totalPage: state.totalPage,
                    onPageSelected: (page) {
                      _fetchPage(page);
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
