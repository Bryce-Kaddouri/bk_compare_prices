import 'dart:math';

import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/data/model/supplier_model.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/view/screen/product/product_screen.dart';
import 'package:compare_prices/view/screen/supplier/supplier_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/supplier_provider.dart';
import '../../base/charts/line-chart/line_chart_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchController controller = SearchController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().init();
      context.read<SupplierProvider>().getSuppliers(context.read<AuthenticationProvider>().user!);
      context.read<ProductProvider>().getProducts(context.read<AuthenticationProvider>().user!).whenComplete(() {
        String productName = context.read<ProductProvider>().products.first.name;
        print("productName");
        print(productName);
        controller.text = productName;
        String productId = context.read<ProductProvider>().products.first.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Suppliers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupplierScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Products'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthenticationProvider>().signOut();
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        child: context.watch<AuthenticationProvider>().user == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 60,
                    child: SearchAnchor.bar(
                      isFullScreen: true,
                      suggestionsBuilder: (context, query) {
                        return context
                            .read<ProductProvider>()
                            .products
                            .where((element) => element.name.contains(query.text))
                            .map((e) => ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  title: Text(e.name),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      e.photoUrl,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  onTap: () {
                                    // close the search bar
                                    controller.closeView(e.name);
                                  },
                                ))
                            .toList();
                      },
                      searchController: controller,
                    ),
                  ),
                  StreamBuilder(
                    stream: context.read<ProductProvider>().streamHistoryByProductId('VLmjBwRmjtE47FdH1uXY', context.read<AuthenticationProvider>().user),
                    builder: (context, snap) {
                      List<PriceModelHistory> datas = [];
                      List<Map<String, dynamic>> datasBySupplier = [];
                      List suppliers = context.watch<SupplierProvider>().suppliers;
                      List lst = [];
                      double minPrice = 0;
                      double maxPrice = 0;
                      for (SupplierModel supp in suppliers) {
                        lst.add({'supplierModel': supp.toJson(), 'priceHistory': []});
                      }
                      if (snap.hasData) {
                        for (var test in lst) {
                          print('-' * 30);
                          print(test);
                        }
                        int nb = 0;
                        for (var doc in snap.data!.docs) {
                          String supplierId = doc.get('supplier_id');
                          double price = doc.get('price');
                          print(supplierId);
                          print(price);
                          if (price > maxPrice) {
                            maxPrice = price;
                          }
                          if (nb == 0) {
                            minPrice = price;
                          } else {
                            if (price < minPrice) {
                              minPrice = price;
                            }
                          }
                          nb++;
                          lst.firstWhere((element) => element['supplierModel']['id'] == supplierId)['priceHistory'].add(doc.data());
                          print(supplierId);
                        }
                      }
                      print('*' * 30);

                      print(lst);
                      print('*' * 30);
                      print(minPrice);
                      print(maxPrice);

                      return Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                ),
                                gridData: FlGridData(
                                  show: false,
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      interval: 500,
                                      getTitlesWidget: bottomTitleWidgets,
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: leftTitles(1),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 4),
                                    left: const BorderSide(color: Colors.transparent),
                                    right: const BorderSide(color: Colors.transparent),
                                    top: const BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                lineBarsData: List.generate(
                                  lst.length,
                                  (index) => LineChartBarData(
                                    isCurved: true,
                                    color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                                    barWidth: 8,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                    spots:
                                        /*List.generate(lst[index]['priceHistory'].length, (index2) {
                                      print(lst[index]['priceHistory'][index2]['created_at'].toDate().month.toDouble() + 1);
                                      return FlSpot(
                                        Random().nextInt(3).toDouble(),
                                        lst[index]['priceHistory'][index2]['price'].toDouble(),
                                      );
                                    }),*/
                                        const [
                                      FlSpot(1, 1),
                                      FlSpot(3, 1.5),
                                      FlSpot(5, 1.4),
                                      FlSpot(7, 3.4),
                                      FlSpot(10, 2),
                                      FlSpot(12, 2.2),
                                      FlSpot(13, 1.8),
                                    ],
                                  ),
                                ),
                                /*[
                                  // data for the suppliers
                                  LineChartBarData(
                                    isCurved: true,
                                    color: AppColors.contentColorGreen,
                                    barWidth: 8,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                    spots: const [
                                      FlSpot(1, 1),
                                      FlSpot(3, 1.5),
                                      FlSpot(5, 1.4),
                                      FlSpot(7, 3.4),
                                      FlSpot(10, 2),
                                      FlSpot(12, 2.2),
                                      FlSpot(13, 1.8),
                                    ],
                                  ),
                                  LineChartBarData(
                                    isCurved: true,
                                    color: AppColors.contentColorPink,
                                    barWidth: 8,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: false,
                                      color: AppColors.contentColorPink.withOpacity(0),
                                    ),
                                    spots: const [
                                      FlSpot(1, 1),
                                      FlSpot(3, 2.8),
                                      FlSpot(7, 1.2),
                                      FlSpot(10, 2.8),
                                      FlSpot(12, 2.6),
                                      FlSpot(13, 3.9),
                                    ],
                                  ),
                                  LineChartBarData(
                                    isCurved: true,
                                    color: AppColors.contentColorCyan,
                                    barWidth: 8,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                    spots: const [
                                      FlSpot(1, 2.8),
                                      FlSpot(3, 1.9),
                                      FlSpot(6, 3),
                                      FlSpot(10, 1.3),
                                      FlSpot(13, 2.5),
                                    ],
                                  ),
                                ],*/
                                minX: 0,
                                maxX: 14,
                                maxY: 4,
                                /*maxPrice + 1,*/
                                minY: 0,
                                /*minPrice - 1,*/
                              ),
                              duration: const Duration(milliseconds: 250),
                            ),
                          ),
                          Container(
                            height: 80,
                            color: Colors.red,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: lst.length,
                              itemBuilder: (context, index) {
                                return Text(lst[index]['supplierModel']['name']);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  SideTitles leftTitles(double interval) => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: interval,
        reservedSize: 40,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Text(value.toString(), style: style, textAlign: TextAlign.center);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    bool isMobilePhone = MediaQuery.of(context).size.width < 600;

    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text(isMobilePhone ? 'J' : 'JAN', style: style);
        break;
      case 2:
        text = Text(isMobilePhone ? 'F' : 'FEV', style: style);
        break;
      case 3:
        text = Text(isMobilePhone ? 'M' : 'MAR', style: style);
        break;
      case 4:
        text = Text(isMobilePhone ? 'A' : 'APR', style: style);
        break;
      case 5:
        text = Text(isMobilePhone ? 'M' : 'MAY', style: style);
        break;
      case 6:
        text = Text(isMobilePhone ? 'J' : 'JUN', style: style);
        break;
      case 7:
        text = Text(isMobilePhone ? 'J' : 'JUL', style: style);
        break;
      case 8:
        text = Text(isMobilePhone ? 'A' : 'AUG', style: style);
        break;
      case 9:
        text = Text(isMobilePhone ? 'S' : 'SEP', style: style);
        break;
      case 10:
        text = Text(isMobilePhone ? 'O' : 'OCT', style: style);
        break;
      case 11:
        text = Text(isMobilePhone ? 'N' : 'NOV', style: style);
        break;
      case 12:
        text = Text(isMobilePhone ? 'D' : 'DEC', style: style);
        break;

      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
