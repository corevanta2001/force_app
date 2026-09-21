import 'package:flutter/material.dart';
import 'client_dashboard.dart';
import 'client_orders.dart';
import 'client_profile.dart';
import 'client_new_order.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});
  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _index = 0;
  final _pages = [ClientDashboard(), ClientOrders(), ClientProfile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Color(0xFF0F172A),
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "My Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: _index == 0 ? FloatingActionButton(
        backgroundColor: Color(0xFF0F172A),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientNewOrder())),
      ) : null,
    );
  }
}
