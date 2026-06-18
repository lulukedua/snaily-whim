import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/cart_badge_button.dart';
import 'package:snailywhim/core/widgets/custom_banner.dart';
import 'package:snailywhim/core/widgets/custom_button.dart';
import 'package:snailywhim/core/widgets/info_card.dart';
import 'package:snailywhim/core/widgets/product_detail_card.dart';
import 'package:snailywhim/data/models/category_model.dart';
import 'package:snailywhim/data/repositories/category_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/auth/auth_bloc.dart';
import 'package:snailywhim/logic/bloc/auth/auth_state.dart';
import 'package:snailywhim/logic/bloc/cart/cart_bloc.dart';
import 'package:snailywhim/logic/bloc/product/product_bloc.dart';
import 'package:snailywhim/logic/bloc/product/product_event.dart';
import 'package:snailywhim/logic/bloc/product/product_state.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductBloc(repository: ProductRepository())
            ..add(FetchProductById(productId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  bool showTitle = false;

  Future<CategoryModel?> getKategori(String kategoriId) async {
    try {
      final kategori = await CategoryRepository().getAllKategori();

      return kategori.firstWhere((e) => e.id == kategoriId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    final isAdmin = authState is Authenticated && authState.user.isAdmin;
    print(context.read<CartBloc>());
    return Scaffold(
      backgroundColor: AppColors.bgColor,

      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductDetailLoaded) {
            final product = state.product;
            final rawData = state.rawData;
            final namaCabang = rawData['cabang']?['nama_cabang'] ?? '-';

            return FutureBuilder<CategoryModel?>(
              future: getKategori(product.kategori_id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final kategoriNama = snapshot.data?.nama_kategori ?? "-";
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    final visible = notification.metrics.pixels > 260;
                    if (visible != showTitle) {
                      setState(() {
                        showTitle = visible;
                      });
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 340,
                        pinned: true,
                        elevation: 0,

                        backgroundColor: AppColors.bgColor,
                        surfaceTintColor: AppColors.bgColor,

                        title: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: showTitle ? 1 : 0,
                          child: const Text(
                            "Detail",
                            style: TextStyle(
                              color: AppColors.primTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primTextColor,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          if (!isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: CartBadgeButton(
                                iconColor: AppColors.primTextColor,
                                iconSize: 22,
                              ),
                            ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: CustomNetworkBanner(
                            imageUrl: product.image_url,
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Transform.translate(
                          offset: const Offset(0, -40),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.bgColor,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                DetailInfoCard(
                                  namaProduk: product.nama_product,
                                  harga: product.harga,
                                ),

                                const SizedBox(height: 24),

                                InfoCard(
                                  items: [
                                    InfoCardItem(
                                      icon: Icons.description_outlined,
                                      label: "Deskripsi",
                                      value: product.deskripsi,
                                    ),
                                    InfoCardItem(
                                      icon: Icons.store_outlined,
                                      label: "Cabang",
                                      value: namaCabang,
                                    ),
                                    InfoCardItem(
                                      icon: Icons.category_outlined,
                                      label: "Kategori",
                                      value: kategoriNama,
                                    ),
                                    InfoCardItem(
                                      icon: Icons.inventory_2_outlined,
                                      label: "Stok",
                                      value: "${product.stok} Produk",
                                    ),
                                  ],
                                ),

                                if (!isAdmin) ...[
                                  const SizedBox(height: 24),

                                  CustomButton(
                                    text: "Pesan Sekarang",
                                    icon: Icons.shopping_bag_outlined,
                                    onPressed: () {},
                                  ),
                                ],

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
