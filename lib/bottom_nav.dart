import 'package:flutter/material.dart';
import 'package:flutter_application_2/home.dart';
import 'package:get/get.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeScreenController()); // Initialize MyWebSocketController

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: Get.find<HomeScreenController>().selectedIndex.value,
          children: [
            HomeScreen(),
            const Center(
                child: Text('Charts', style: TextStyle(color: Colors.white))),
            const Center(
                child:
                    Text('Order Book', style: TextStyle(color: Colors.white))),
            const Center(
                child: Text('My Order', style: TextStyle(color: Colors.white))),
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff07303F),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        useLegacyColorScheme: true,
        currentIndex: Get.find<HomeScreenController>().selectedIndex.value,
        onTap: (index) {
          Get.find<HomeScreenController>().selectedIndex.value = index;
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color(0xff07303F),
            icon: Icon(Icons.local_mall),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xff07303F),
            icon: Icon(Icons.insert_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xff07303F),
            icon: Icon(Icons.library_books),
            label: 'Order Book',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.shopping_cart),
            label: 'My Order',
          ),
        ],
      ),
    );
  }
}
