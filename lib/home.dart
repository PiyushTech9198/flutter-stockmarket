import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/stock_data_model.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

class HomeScreenController extends GetxController {
  var selectedIndex = 0.obs;
  final marketOrderChannel = IOWebSocketChannel.connect(
      'ws://stream.bit24hr.in:8765/btc_market_history');
  RxList<StockData> data = <StockData>[].obs;

  @override
  void onInit() {
    super.onInit();
    marketOrderChannel.stream.listen((event) {
      List<StockData> jsonData =
          (json.decode(event.toString()) as List<dynamic>)
              .map((item) => StockData.fromJson(item))
              .toList();
      data.assignAll(jsonData);
      update(); // Force UI update
    }, onError: (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }, cancelOnError: true);
  }

  @override
  void onClose() {
    marketOrderChannel.sink.close();
    super.onClose();
  }
}

class HomeScreen extends StatelessWidget {
  final controller = Get.put(HomeScreenController());

  HomeScreen({Key? key}) : super(key: key);

  void setSelectedIndex(int index) {
    controller.selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff051F27),
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        bottom: PreferredSize(
          preferredSize: const Size(double.maxFinite, 30),
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 20, top: 10),
            color: const Color(0xff051F27),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "91T24HR",
                    style: TextStyle(
                      color: Color(0xffF4CD8F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(5),
                    color: const Color(0xff07303F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        title: const Text('WebSocket Example'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSelectedIndex(0),
                      child: Container(
                        color: const Color(0xff07303F),
                        child: const Center(
                          child: Text(
                            'Market Trades',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSelectedIndex(1),
                      child: Container(
                        color: const Color(0xff051F27),
                        child: const Center(
                          child: Text(
                            'Order Books',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final data = controller.data; // Access RxList directly
                return TabBarView(
                  children: [
                    _buildMarketOrderListView(data),
                    const Center(
                      child: Text("Order Book Content"),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketOrderListView(List<StockData> data) {
    return ListView.builder(
      itemCount: data.length + 1, // Add 1 for the header row
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header row
          return Container(
            decoration: const BoxDecoration(
              border:
                  Border.symmetric(horizontal: BorderSide(color: Colors.white)),
              color: Colors.black,
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    'Volume',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    'Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Data rows
          var item =
              data[index - 1]; // Subtract 1 to account for the header row
          // Check if the previous price is available
          double previousPrice = index > 1 ? data[index - 2].rate : 0.0;
          // Determine the color based on price change
          Color priceColor = item.rate < previousPrice
              ? Colors.red
              : item.rate > previousPrice
                  ? Colors.green
                  : Colors.white;
          // Determine the arrow icon
          IconData? arrowIcon = item.rate < previousPrice
              ? Icons.arrow_downward
              : item.rate > previousPrice
                  ? Icons.arrow_upward
                  : null;
          // Format the price to display with only two decimal places
          String formattedPrice = (item.rate as double).toStringAsFixed(2);
          return Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            color: priceColor.withOpacity(0.1), // Light color for the row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(arrowIcon, color: priceColor),
                      const SizedBox(width: 4.0),
                      Text(
                        formattedPrice, // Display formatted price
                        style: TextStyle(color: priceColor),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    '${item.volume}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    '${item.timestamp}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
