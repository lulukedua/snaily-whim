import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/validator/currency.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/data/models/order_model.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/order/order_bloc.dart';
import 'package:snailywhim/logic/bloc/order/order_event.dart';
import 'package:snailywhim/logic/bloc/order/order_state.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  final bool isAdmin;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderBloc(
        repository: OrderRepository(),
        productRepository: ProductRepository(),
      )..add(FetchOrderById(orderId)),

      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderUpdatedSuccess) {
            AppSnackbar.show(
              context,
              title: 'Berhasil',
              message: 'Status pesanan berhasil diperbarui!',
              type: SnackType.success,
            );
            context.read<OrderBloc>().add(FetchOrderById(orderId));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: AppBar(
            backgroundColor: AppColors.bgBtmColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Detail Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primColor),
                );
              }

              if (state is OrderDetailLoaded) {
                final order = state.order;
                final itemImages = state.itemImages;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              "Order ID",
                              order.id.substring(0, 12).toUpperCase(),
                              isBold: true,
                              showCopy: true,
                              context: context,
                            ),
                            const Divider(height: 24, color: Color(0xFFF0F0F0)),
                            isAdmin
                                ? _buildAdminStatusDropdown(context, order)
                                : _buildInfoRow(
                                    "Status Pesanan",
                                    order.status_order.toUpperCase(),
                                  ),

                            const SizedBox(height: 12),
                            _buildInfoRow(
                              "Status Pembayaran",
                              order.status_pembayaran.toUpperCase(),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              "Metode Pembayaran",
                              (order.payment_type ?? "N/A").toUpperCase(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Produk yang Dipesan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: (order.item ?? []).map((item) {
                            final pId = item['product_id'] ?? item['id'];
                            final imageUrl = itemImages[pId.toString()];

                            final subtotal = item['subtotal'] is String
                                ? int.tryParse(item['subtotal']) ?? 0
                                : item['subtotal'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.fastfood_rounded,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['nama_product'] ?? 'Produk',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.primTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Qty: ${item['qty']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Belanja",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(order.total_harga),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAdminStatusDropdown(BuildContext context, OrderModel order) {
    final validStatuses = ['waiting', 'process', 'selesai'];
    final currentStatus =
        validStatuses.contains(order.status_order.toLowerCase())
        ? order.status_order.toLowerCase()
        : 'waiting';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Status Pesanan",
          style: TextStyle(fontSize: 13, color: AppColors.secondaryTextColor),
        ),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primColor),
            color: AppColors.bgColor,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentStatus,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.primColor,
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primTextColor,
              ),
              items: validStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null && val != currentStatus) {
                  context.read<OrderBloc>().add(
                    UpdateOrderStatus(orderId: order.id, statusOrder: val),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primColor.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primColor.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool showCopy = false,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryTextColor,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 14 : 13,
                color: AppColors.primTextColor,
              ),
            ),
            if (showCopy && context != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  AppSnackbar.show(
                    context,
                    title: 'Berhasil',
                    message: 'Order ID disalin!',
                    type: SnackType.success,
                  );
                },
                child: const Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.primColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
