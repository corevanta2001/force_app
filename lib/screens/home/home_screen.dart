import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _feature(IconData icon, String title, String sub) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.local_shipping, size: 60, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text("FORCE", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
                Text("DELIVERY & LOGISTICS", style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 3)),
                SizedBox(height: 12),
                Container(width: 60, height: 3, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                SizedBox(height: 30),
                Text("Fast, Reliable, Secure", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text("Order anything from any store in Harare.\nWe deliver to your doorstep.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(child: _feature(Icons.store, "Any Store", "Pick n Pay, TM, etc")),
                    SizedBox(width: 12),
                    Expanded(child: _feature(Icons.list_alt, "Item List", "List what you want")),
                    SizedBox(width: 12),
                    Expanded(child: _feature(Icons.security, "Secure T&C", "Irreversible acceptance")),
                  ],
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text("Login to Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text("Create New Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.phone, size: 14, color: Colors.white70),
                  SizedBox(width: 6),
                  Text("Support: +263 77 123 4567", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                SizedBox(height: 12),
                Text("v1.0.0 • Made in Zimbabwe", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
