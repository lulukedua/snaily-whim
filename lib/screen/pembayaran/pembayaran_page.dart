import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/data/models/user_model.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/screen/pembayaran/success/pembayaran_success_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PembayaranPage extends StatefulWidget {
  final String orderId;
  final String snapToken;
  final List<String> productIds;

  const PembayaranPage({
    super.key,
    required this.orderId,
    required this.snapToken,
    required this.productIds,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  late final WebViewController controller;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    startCheckPayment();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}",
        ),
      );
  }

  Future<void> startCheckPayment() async {
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final result = await Supabase.instance.client
            .from('order')
            .select('status_pembayaran')
            .eq('id', widget.orderId)
            .single();

        debugPrint("STATUS DB = ${result['status_pembayaran']}");

        if (result['status_pembayaran'] == 'paid') {
          final orderItems = await OrderRepository().getOrderItems(widget.orderId);
          debugPrint("ORDER ITEMS = $orderItems");
          final productRepo = ProductRepository();

          for (final item in orderItems) {
            await productRepo.reduceStock(
              productId: item['product_id'],
              qty: item['qty'],
            );
          }
          timer?.cancel();

          if (!mounted) return;
          AppSnackbar.show(
            context,
            title: 'Berhasil',
            message: 'Pembayaran berhasil dikonfirmasi!',
            type: SnackType.success,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PembayaranSuksesPage(productIds: widget.productIds),
            ),
          );
        }
      } catch (e) {
        debugPrint("ERROR CHECK PAYMENT = $e");
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: WebViewWidget(controller: controller),
    );
  }
}
