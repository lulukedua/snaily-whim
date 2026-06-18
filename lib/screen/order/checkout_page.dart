import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/custom_button.dart';
import 'package:snailywhim/data/models/cart_model.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/logic/bloc/order/order_bloc.dart';
import 'package:snailywhim/logic/bloc/order/order_event.dart';
import 'package:snailywhim/logic/bloc/order/order_state.dart';
import 'package:snailywhim/screen/pembayaran/pembayaran_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> selectedItems;
  final int totalHarga;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.totalHarga,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Map<String, dynamic>? profile;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final repo = OrderRepository();

      final result = await repo.getProfile();

      setState(() {
        profile = result;
        isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreatedSuccess) {
          if (state is OrderCreatedSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PembayaranPage(
                  orderId: state.orderId,
                  snapToken: state.snapToken,
                  productIds: widget.selectedItems
                      .map((e) => e.productId)
                      .toList(),
                ),
              ),
            );
          }

          debugPrint("SNAP TOKEN = ${state.snapToken}");
        }

        if (state is OrderError) {
          AppSnackbar.show(
            context,
            title: 'Gagal',
            message: state.message,
            type: SnackType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF8F4EF),
        appBar: AppBar(title: const Text("Checkout")),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: "Bayar Sekarang",
            onPressed: () {
              final items = widget.selectedItems.map((e) {
                return {
                  "product_id": e.productId,
                  "nama_product": e.namaProduct,
                  "qty": e.qty,
                  "harga": e.harga,
                  "subtotal": e.subtotal,
                  "image_url": e.imageUrl,
                };
              }).toList();

              context.read<OrderBloc>().add(
                CreateOrder(
                  items: items,
                  totalHarga: widget.totalHarga,
                  userId: Supabase.instance.client.auth.currentUser!.id,
                ),
              );
            },
          ),
        ),
        body: isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile?["nama"] ?? profile?["name"] ?? "Pelanggan",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: widget.selectedItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("${item.qty}x ${item.namaProduct}"),
                              ),
                              Text(formatter.format(item.subtotal)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          formatter.format(widget.totalHarga),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
