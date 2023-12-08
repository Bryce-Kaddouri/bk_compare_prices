import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compare_prices/data/model/product_model.dart';
import 'package:compare_prices/data/model/supplier_model.dart';
import 'package:compare_prices/data/repository/firestore_repo.dart';
import 'package:compare_prices/provider/product_provider.dart';
import 'package:compare_prices/view/screen/product/product_screen.dart';
import 'package:compare_prices/view/screen/supplier/supplier_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/supplier_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchController controller = SearchController();
  FirestoreRepo firestoreRepo = FirestoreRepo(FirebaseFirestore.instance);
  User? user = FirebaseAuth.instance.currentUser;

  void loadDatas() {
    /* context.read<AuthenticationProvider>().init();
    context.read<SupplierProvider>().getSuppliers(context.read<AuthenticationProvider>().user);

    context.read<ProductProvider>().getProducts(context.read<AuthenticationProvider>().user, true);*/ /*
    Get.context!.read<AuthenticationProvider>().init();
    User? user = Get.context!.read<AuthenticationProvider>().user;
    print(user);
    Get.context!.read<SupplierProvider>().getSuppliers(user);
    Get.context!.read<ProductProvider>().getProducts(user, true);*/
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().init();
      controller.addListener(() {
        print('controller.value.text');
        print(controller.value.text);
        context.read<ProductProvider>().setSearchText(controller.value.text);
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
      body: StreamBuilder(
        stream: firestoreRepo.initDatas(),
        builder: (context, initSnapshot) {
          if (initSnapshot.hasData) {
            List<SupplierModel?> suppliers = initSnapshot.data!.suppliers;
            List<ProductModel?> products = initSnapshot.data!.products;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SupplierProvider>().setSuppliers(suppliers);
              context.read<ProductProvider>().setProducts(products);
            });
            if (context.read<SupplierProvider>().suppliers.isNotEmpty && context.read<ProductProvider>().products.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      height: 60,
                      child: SearchAnchor.bar(
                        isFullScreen: true,
                        suggestionsBuilder: (context, controller) {
                          return context
                              .read<ProductProvider>()
                              .products
                              .where((element) => element.name.contains(controller.text))
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
                                      controller.text = e.name;
                                      ProductModel selectedProduct = context.read<ProductProvider>().products.firstWhere((element) => element.name == e.name);
                                      context.read<ProductProvider>().setSelectedProduct(selectedProduct);
                                    },
                                  ))
                              .toList();
                        },
                        searchController: controller,
                      ),
                    ),
                    context.watch<ProductProvider>().selectedProduct == null
                        ? Container()
                        : Column(
                            children: [
                              StreamBuilder(
                                stream: context.read<ProductProvider>().streamHistoryByProductId('VLmjBwRmjtE47FdH1uXY'),
                                builder: (context, snap) {
                                  List<PriceModelHistory> datas = [];
                                  List<Map<String, dynamic>> datasBySupplier = [];
                                  List suppliers = context.watch<SupplierProvider>().suppliers;
                                  List lst = [];
                                  double minPrice = 0;
                                  double maxPrice = 1;
                                  int interval = 1;
                                  for (SupplierModel supp in suppliers) {
                                    lst.add({'supplierModel': supp.toJson(), 'priceHistory': []});
                                  }
                                  if (snap.hasData) {
                                    print('snap.data!.docs');
                                    print(snap.data!.docs);
                                    for (var doc in snap.data!.docs) {
                                      String supplierId = doc.get('supplier_id');
                                      double price = doc.get('price');

                                      if (price > maxPrice) {
                                        maxPrice = price;
                                      }
                                      lst.firstWhere((element) => element['supplierModel']['id'] == supplierId)['priceHistory'].add(doc.data());
                                    }

                                    /* int currentYear = DateTime.now().year;*/
                                    interval = ((maxPrice - minPrice) / 10).floor();
                                    lst = lst.where((element) {
                                      /*  int year = element['priceHistory'].length > 0 ? element['priceHistory'][element['priceHistory'].length - 1]['created_at'].toDate().year : 0;
                        print('year');
                        print(year);*/
                                      return element['priceHistory'].length > 0;
                                    }).toList();

                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width > 600 ? 100 : 20),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Text('Price (€)'),
                                              ),
                                              Expanded(
                                                  child: Container(
                                                margin: EdgeInsets.only(right: MediaQuery.of(context).size.width > 600 ? 100 : 20),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Evolutions of prices by supplier',
                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width > 600 ? 100 : 20, left: MediaQuery.of(context).size.width > 600 ? 100 : 20),
                                          height: MediaQuery.of(context).size.height - 200,
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
                                                    interval: 1,
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
                                                  sideTitles: leftTitles(interval.toDouble()),
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: true,
                                                border: Border(
                                                  bottom: BorderSide(color: Colors.black, width: 2),
                                                  left: const BorderSide(color: Colors.black, width: 2),
                                                  right: const BorderSide(color: Colors.transparent),
                                                  top: const BorderSide(color: Colors.transparent),
                                                ),
                                              ),
                                              lineBarsData: List.generate(lst.length, (index) {
                                                SupplierModel supplier = context.read<SupplierProvider>().suppliers.firstWhere((element) => element.id == lst[index]['supplierModel']['id']);
                                                List<int> color = supplier.color;
                                                Color colorSupplier = Color.fromRGBO(color[0], color[1], color[2], 1);
                                                return LineChartBarData(
                                                  isCurved: true,
                                                  curveSmoothness: 0,
                                                  color: colorSupplier,
                                                  barWidth: 4,
                                                  isStrokeCapRound: true,
                                                  dotData: const FlDotData(
                                                    show: true,
                                                  ),
                                                  spots: List.generate(lst[index]['priceHistory'].length, (index2) {
                                                    int month = lst[index]['priceHistory'][index2]['created_at'].toDate().month;

                                                    return FlSpot(
                                                      (6 + index2).toDouble(),
                                                      lst[index]['priceHistory'][index2]['price'].toDouble(),
                                                    );
                                                  }),
                                                );
                                              }),
                                              minX: 1,
                                              maxX: 12,
                                              maxY: maxPrice + interval,
                                              minY: 0,
                                            ),
                                            duration: const Duration(milliseconds: 250),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.red,
                                          width: 200,
                                          height: 60,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(children: [
                                              for (var supplier in lst)
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        width: 20,
                                                        color: Color.fromRGBO(supplier['supplierModel']['color'][0], supplier['supplierModel']['color'][1], supplier['supplierModel']['color'][2], 1),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(supplier['supplierModel']['name']),
                                                    ],
                                                  ),
                                                ),
                                            ]),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              if (context.watch<ProductProvider>().products.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    var product = context.watch<ProductProvider>().products.firstWhere((element) => element.id == 'VLmjBwRmjtE47FdH1uXY');
                                    double minPrice = 0;
                                    double maxPrice = 0;
                                    for (var price in product.prices) {
                                      if (price.price > maxPrice) {
                                        maxPrice = price.price;
                                      }
                                      if (minPrice == 0) {
                                        minPrice = price.price;
                                      } else {
                                        if (price.price < minPrice) {
                                          minPrice = price.price;
                                        }
                                      }
                                    }
                                    int interval = 1;
                                    interval = ((maxPrice - minPrice) / 10).floor();

                                    return Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(top: 75, right: MediaQuery.of(context).size.width > 600 ? 100 : 50, left: MediaQuery.of(context).size.width > 600 ? 100 : 50),
                                          height: MediaQuery.of(context).size.height - 100,
                                          width: MediaQuery.of(context).size.width,
                                          child: BarChart(
                                            BarChartData(
                                                backgroundColor: Colors.white,
                                                maxY: maxPrice + interval,
                                                minY: 0,
                                                titlesData: FlTitlesData(
                                                  leftTitles: AxisTitles(
                                                    sideTitles: leftTitles(interval.toDouble()),
                                                  ),
                                                  rightTitles: const AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                  topTitles: const AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 32,
                                                      interval: 1,
                                                      getTitlesWidget: bottomTitleWidgetsBar,
                                                    ),
                                                  ),
                                                ),
                                                barGroups: List.generate(product.prices.length, (index) {
                                                  double price = product.prices[index].price;
                                                  SupplierModel supplierModel = context.read<SupplierProvider>().suppliers.firstWhere((element) => element.id == product.prices[index].supplierId);
                                                  String supplierName = supplierModel.name;
                                                  List<int> color = supplierModel.color;
                                                  Color colorSupplier = Color.fromRGBO(color[0], color[1], color[2], 1);

                                                  return BarChartGroupData(
                                                    x: index,
                                                    barRods: [
                                                      BarChartRodData(
                                                        borderRadius: const BorderRadius.all(Radius.circular(0)),
                                                        width: 20,
                                                        toY: price,
                                                        rodStackItems: [
                                                          BarChartRodStackItem(0, price, colorSupplier),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                })),
                                            swapAnimationDuration: Duration(milliseconds: 150), // Optional
                                            swapAnimationCurve: Curves.linear, // Optional
                                          ),
                                        ),
                                        Positioned(
                                          top: 25,
                                          left: MediaQuery.of(context).size.width > 600 ? 100 : 50,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              shape: BoxShape.rectangle,
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text('Price (€)'),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
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

  Widget bottomTitleWidgetsBar(double value, TitleMeta meta) {
    String supplierName = context.watch<SupplierProvider>().suppliers.firstWhere((element) => element.id == context.watch<ProductProvider>().products.firstWhere((element) => element.id == 'VLmjBwRmjtE47FdH1uXY').prices[value.toInt()].supplierId).name;

    return Text(supplierName);
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
        text = const Text('test');
        break;
    }

    return SideTitleWidget(
      space: 10,
      axisSide: AxisSide.bottom,
      child: text,
    );
  }
}
