import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/services/supabase_services.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/cart_badge_button.dart';
import 'package:snailywhim/core/widgets/category_filter.dart';
import 'package:snailywhim/core/widgets/custom_carousel.dart';
import 'package:snailywhim/core/widgets/pagination.dart';
import 'package:snailywhim/core/widgets/product_card.dart';
import 'package:snailywhim/core/widgets/search.dart';
import 'package:snailywhim/data/models/cart_model.dart';
import 'package:snailywhim/data/repositories/cart_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/cart/cart_bloc.dart';
import 'package:snailywhim/logic/bloc/cart/cart_event.dart';
import 'package:snailywhim/logic/bloc/product/product_bloc.dart';
import 'package:snailywhim/logic/bloc/product/product_event.dart';
import 'package:snailywhim/logic/bloc/product/product_state.dart';
import 'package:snailywhim/screen/product/product_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ProductBloc(repository: ProductRepository())..add(FetchProduct()),
        ),
        BlocProvider(
          create: (_) =>
              CartBloc(repository: CartRepository())..add(LoadCart()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCabangId;
  String? _activeKategoriId;
  List<Map<String, dynamic>> _cabangList = [];

  @override
  void initState() {
    super.initState();
    _fetchCabang();
  }

  void _fetchPage(int page) {
    final bloc = context.read<ProductBloc>();
    if (_activeKategoriId != null) {
      bloc.add(FilterProductByKategori(_activeKategoriId!, page: page));
    } else if (bloc.currentKeyword.isNotEmpty) {
      bloc.add(SearchProduct(bloc.currentKeyword, page: page));
    } else {
      bloc.add(FetchProduct(page: page));
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onCategorySelected(String? kategoriId) {
    setState(() => _activeKategoriId = kategoriId);
    if (kategoriId == null) {
      context.read<ProductBloc>().add(FetchProduct(page: 1));
    } else {
      context.read<ProductBloc>().add(
        FilterProductByKategori(kategoriId, page: 1),
      );
    }
  }

  Future<void> _fetchCabang() async {
    try {
      final response = await SupabaseServices.client
          .from('cabang')
          .select('id, nama_cabang')
          .order('nama_cabang');

      if (mounted) {
        setState(() {
          _cabangList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data cabang: $e");
      if (mounted) {
        AppSnackbar.show(
          context,
          title: 'Gagal',
          message: 'Gagal memuat data cabang',
          type: SnackType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildCustomHeader(context),
          CategoryFilterBar(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            onSelected: _onCategorySelected,
          ),
          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state is ProductError) {
                  AppSnackbar.show(
                    context,
                    title: 'Gagal',
                    message: state.message,
                    type: SnackType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError) {
                  return Center(child: Text(state.message));
                }

                if (state is ProductLoaded) {
                  if (state.productList.isEmpty) {
                    return const Center(child: Text("Belum ada produk"));
                  }

                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverToBoxAdapter(child: HomeBannerCarousel()),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = state.productList[index];

                            return ProductCard(
                              product: product,
                              showMenu: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<CartBloc>(),
                                      child: ProductDetailPage(
                                        productId: product.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onAddToCart: () {
                                context.read<CartBloc>().add(
                                  AddToCart(
                                    CartItemModel(
                                      productId: product.id,
                                      namaProduct: product.nama_product,
                                      harga: product.harga,
                                      qty: 1,
                                      imageUrl: product.image_url,
                                    ),
                                  ),
                                );
                                AppSnackbar.show(
                                  context,
                                  title: 'Berhasil',
                                  message: '${product.nama_product} masuk ke keranjang',
                                  type: SnackType.success,
                                );
                              },
                            );
                          }, childCount: state.productList.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: PaginationControl(
                          currentPage: state.currentPage,
                          totalPage: state.totalPage,
                          onPageSelected: _fetchPage,
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.primColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCabangId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    dropdownColor: AppColors.primColor,
                    hint: const Text(
                      "Semua Cabang",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("Semua Cabang"),
                      ),
                      ..._cabangList.map((cabang) {
                        return DropdownMenuItem<String>(
                          value: cabang['id'].toString(),
                          child: Text(cabang['nama_cabang'].toString()),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCabangId = value;
                      });
                      if (value == null) {
                        context.read<ProductBloc>().add(FetchProduct());
                      } else {
                        context.read<ProductBloc>().add(
                          FilterProductByCabang(value),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: SearchInput(
                    hintText: "Cari produk...",
                    onChanged: (value) {
                      context.read<ProductBloc>().add(
                        SearchProduct(value, page: 1),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const CartBadgeButton(iconColor: Colors.white, iconSize: 32),
            ],
          ),
        ],
      ),
    );
  }
}
