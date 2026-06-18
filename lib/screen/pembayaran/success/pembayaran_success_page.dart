import 'package:flutter/material.dart';
import 'package:snailywhim/core/widgets/bottom_bar.dart';
import 'package:snailywhim/data/models/user_model.dart';
import 'package:snailywhim/data/repositories/cart_repository.dart';

class PembayaranSuksesPage extends StatefulWidget {
  final List<String> productIds;

  const PembayaranSuksesPage({super.key, required this.productIds});

  @override
  State<PembayaranSuksesPage> createState() => _PembayaranSuksesPageState();
}

class _PembayaranSuksesPageState extends State<PembayaranSuksesPage> {
  @override
  void initState() {
    super.initState();

    removeCheckedOutItems();

    Future.delayed(
      const Duration(seconds: 5),
      () {
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(
              initialIndex: 2,
            ),
          ),
          (route) => false,
        );
      },
    );
  }

  Future<void> removeCheckedOutItems() async {
    final repo = CartRepository();

    for (final id in widget.productIds) {
      await repo.removeItem(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/gif/success.gif", width: 250, height: 250),
                const SizedBox(height: 24),
                const Text(
                  "Pembayaran Berhasil!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Selamat, pembayaran Anda berhasil.\nPesanan sedang diproses oleh admin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 32),

                const CircularProgressIndicator(),

                const SizedBox(height: 12),

                const Text("Mengalihkan ke halaman pesanan..."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
