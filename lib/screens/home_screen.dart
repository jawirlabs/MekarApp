import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  
  // Financial metrics
  int totalSalesAmount = 0;
  int totalPurchaseAmount = 0;
  int netProfit = 0;
  
  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    try {
      final responses = await Future.wait([
        _dio.get('https://mekarjs-api.vercel.app/api/sale'),
        _dio.get('https://mekarjs-api.vercel.app/api/purchase'),
      ]);

      setState(() {
        totalSalesAmount = 0;
        totalPurchaseAmount = 0;
        
        // Calculate sales amount
        if (responses[0].data is List) {
          for (var sale in responses[0].data) {
            if (sale is Map && sale.containsKey('totalAmount')) {
              totalSalesAmount += (sale['totalAmount'] is int) 
                  ? sale['totalAmount'] as int 
                  : int.tryParse(sale['totalAmount'].toString()) ?? 0;
            }
          }
        }
        
        // Calculate purchase amount
        if (responses[1].data is List) {
          for (var purchase in responses[1].data) {
            if (purchase is Map && purchase.containsKey('totalAmount')) {
              totalPurchaseAmount += (purchase['totalAmount'] is int) 
                  ? purchase['totalAmount'] as int 
                  : int.tryParse(purchase['totalAmount'].toString()) ?? 0;
            }
          }
        }
        
        netProfit = totalSalesAmount - totalPurchaseAmount;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error loading financial data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadFinancialData();
  }

  void _onCardTap(String route) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFFFFBB00),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Net Profit Card
                    _buildNetProfitCard(currencyFormat),
                    
                    const SizedBox(height: 20),
                    
                    // Sales Card
                    _buildFinancialCard(
                      'Total Penjualan',
                      currencyFormat.format(totalSalesAmount),
                      Icons.trending_up,
                      Colors.green.shade600,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Purchase Card
                    _buildFinancialCard(
                      'Total Pembelian',
                      currencyFormat.format(totalPurchaseAmount),
                      Icons.trending_down,
                      Colors.blue.shade600,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Access Section
                    _buildQuickAccessSection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFBB00)),
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNetProfitCard(NumberFormat currencyFormat) {
    final profitMargin = totalSalesAmount > 0 ? (netProfit / totalSalesAmount) * 100 : 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: netProfit >= 0 
              ? [const Color(0xFFFFBB00), const Color(0xFFE6A600)]
              : [Colors.red.shade400, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Laba Bersih',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '${profitMargin.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            currencyFormat.format(netProfit),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Per tanggal ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String title, String amount, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -32),
          child:         GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildQuickAccessCard(
              'Produk',
              Icons.inventory_2_outlined,
              () => _onCardTap('/product'),
            ),
            _buildQuickAccessCard(
              'Inventori',
              Icons.warehouse_outlined,
              () => _onCardTap('/inventory'),
            ),
            _buildQuickAccessCard(
              'Penjualan',
              Icons.point_of_sale_outlined,
              () => _onCardTap('/sales'),
            ),
            _buildQuickAccessCard(
              'Pembelian',
              Icons.shopping_cart_outlined,
              () => _onCardTap('/purchase'),
            ),
            _buildQuickAccessCard(
              'Produksi',
              Icons.precision_manufacturing_outlined,
              () => _onCardTap('/production'),
            ),
            _buildQuickAccessCard(
              'Karyawan',
              Icons.people_outline,
              () => _onCardTap('/employee'),
            ),
          ],
        ),
      
        ),
        
      ],
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBB00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon, 
                color: const Color(0xFFFFBB00), 
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFBB00),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
