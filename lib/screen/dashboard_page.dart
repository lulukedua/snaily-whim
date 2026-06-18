import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/validator/currency.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/recent_order_card.dart';
import 'package:snailywhim/core/widgets/stat_card.dart';
import 'package:snailywhim/data/models/order_model.dart';
import 'package:snailywhim/data/models/user_model.dart';
import 'package:snailywhim/data/repositories/auth_repository.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/order/order_bloc.dart';
import 'package:snailywhim/logic/bloc/order/order_event.dart';
import 'package:snailywhim/logic/bloc/order/order_state.dart';
import 'package:snailywhim/screen/order/order_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onSeeAllOrders;
  final UserModel user;

  const DashboardPage({
    super.key,
    required this.onSeeAllOrders,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String namaCabang = "...";
  int _totalOrder = 0;
  int _waitingCount = 0;
  int _processCount = 0;
  int _revenue = 0;
  bool _statsLoading = true;
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _loadNamaCabang();
    _loadStats();
    _orderBloc = OrderBloc(
      repository: OrderRepository(),
      productRepository: ProductRepository(),
    )..add(FetchOrders(page: 1));
  }

  String _formatDate(DateTime date) {
    const List<String> hariNames = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${hariNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  Future<void> _loadNamaCabang() async {
    if (widget.user.cabangId != null) {
      try {
        final repo = AuthRepository();
        final hasil = await repo.getNamaCabang(widget.user.cabangId!);
        if (mounted) setState(() => namaCabang = hasil ?? "Pusat");
      } catch (_) {
        if (mounted) setState(() => namaCabang = "Pusat");
      }
    } else {
      if (mounted) setState(() => namaCabang = "Pusat");
    }
  }

  Future<void> _loadStats() async {
    try {
      final repo = OrderRepository();
      final results = await Future.wait([
        repo.countAllOrders(),
        repo.countOrdersByStatus('waiting'),
        repo.countOrdersByStatus('process'),
        repo.getTotalRevenue(),
      ]);
      if (mounted) {
        setState(() {
          _totalOrder = results[0] as int;
          _waitingCount = results[1] as int;
          _processCount = results[2] as int;
          _revenue = results[3] as int;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
      AppSnackbar.show(
          context,
          title: 'Gagal',
          message: 'Gagal memuat data statistik',
          type: SnackType.error,
        );
    }
  }

  void _navigateToOrder(BuildContext context, String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderPage(
          userId: widget.user.id,
          isAdmin: true,
          initialFilter: filter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.primColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Cabang",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    namaCabang,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderError) {
                AppSnackbar.show(
                  context,
                  title: 'Gagal',
                  message: state.message,
                  type: SnackType.error,
                );
              }
            },
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primColor),
                );
              }

              if (state is OrderLoaded) {
                final orders = state.orderList;
                final orderImages = state.orderImages;
                final recentOrders = orders.take(3).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildStatGrid(context),
                      const SizedBox(height: 16),
                      _buildSalesChart(orders),
                      const SizedBox(height: 16),
                      _buildRecentOrders(recentOrders, orderImages),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }

              if (state is OrderError) {
                return Center(
                  child: Text("Terjadi kesalahan: ${state.message}"),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selamat datang,",
          style: TextStyle(fontSize: 12, color: AppColors.secondaryTextColor),
        ),
        const SizedBox(height: 2),
        Text(
          "${widget.user.nama}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final String formattedRevenue = CurrencyFormatter.format(_revenue);

    if (_statsLoading) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primColor,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GestureDetector(
          onTap: () => _navigateToOrder(context, 'All'),
          child: StatCard(
            title: "KESELURUHAN",
            value: _totalOrder.toString(),
            subtitle: "Semua Order",
            icon: LucideIcons.shoppingBag,
            mainColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFEF3C7),
          ),
        ),
        StatCard(
          title: "REVENUE",
          value: formattedRevenue,
          subtitle: "Total Pendapatan",
          icon: LucideIcons.coins,
          mainColor: AppColors.bgBtmColor,
          bgColor: AppColors.bgBtmColor.withOpacity(0.15),
        ),
        GestureDetector(
          onTap: () => _navigateToOrder(context, 'Waiting'),
          child: StatCard(
            title: "MENUNGGU",
            value: _waitingCount.toString(),
            subtitle: "Perlu diproses",
            icon: LucideIcons.clock,
            mainColor: const Color(0xFF854F0B),
            bgColor: const Color(0xFFFAEEDA),
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToOrder(context, 'Process'),
          child: StatCard(
            title: "PROCESS",
            value: _processCount.toString(),
            subtitle: "Sedang dikerjakan",
            icon: LucideIcons.refreshCw,
            mainColor: const Color(0xFF185FA5),
            bgColor: const Color(0xFFE6F1FB),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart(List<OrderModel> orders) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    final List<String> monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    final List<String> dayNames = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];

    String dateRangeText =
        "${monthNames[sevenDaysAgo.month - 1]} ${sevenDaysAgo.day}–${now.day}";
    if (sevenDaysAgo.month != now.month) {
      dateRangeText =
          "${monthNames[sevenDaysAgo.month - 1]} ${sevenDaysAgo.day} – ${monthNames[now.month - 1]} ${now.day}";
    }

    List<Map<String, dynamic>> chartData = [];
    double maxValue = 0;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];

      final dailyOrders = orders.where((o) {
        if (o.updated_at == null) return false;
        return o.updated_at!.year == date.year &&
            o.updated_at!.month == date.month &&
            o.updated_at!.day == date.day &&
            o.status_pembayaran.toLowerCase() == 'paid';
      });

      double dailyRevenue = dailyOrders.fold(
        0.0,
        (sum, o) => sum + o.total_harga,
      );
      if (dailyRevenue > maxValue) maxValue = dailyRevenue;

      chartData.add({'day': dayName, 'value': dailyRevenue});
    }

    if (maxValue == 0) maxValue = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Penjualan 7 hari",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primTextColor,
                ),
              ),
              Text(
                dateRangeText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 115,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                double heightRatio = data['value'] / maxValue;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: (80 * heightRatio) < 2 ? 2 : (80 * heightRatio),
                      decoration: BoxDecoration(
                        color: AppColors.primColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['day'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(
    List<OrderModel> recentOrders,
    Map<String, String> orderImages,
  ) {
    if (recentOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primColor.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            "Belum ada order masuk",
            style: TextStyle(color: AppColors.secondaryTextColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Order terbaru",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primTextColor,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAllOrders,
                child: const Text(
                  "Lihat semua",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bgBtmColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFFF0F0F0)),
            itemBuilder: (context, index) {
              final order = recentOrders[index];
              return RecentOrderCard(
                order: order,
                imageUrl: orderImages[order.id],
              );
            },
          ),
        ],
      ),
    );
  }
}
