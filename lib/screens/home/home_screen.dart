import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _feature(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.local_shipping, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text("FORCE", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4)),
                const Text("DELIVERY & LOGISTICS", style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 3)),
                const SizedBox(height: 12),
                Container(width: 60, height: 3, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 30),
                const Text("Fast, Reliable, Secure", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                const Text("Order anything from any store in Harare.\nWe deliver to your doorstep.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(child: _feature(Icons.store, "Any Store", "Pick n Pay, TM, etc")),
                    const SizedBox(width: 12),
                    Expanded(child: _feature(Icons.list_alt, "Item List", "List what you want")),
                    const SizedBox(width: 12),
                    Expanded(child: _feature(Icons.security, "Secure T&C", "Irreversible acceptance")),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Login to Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Create New Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.phone, size: 14, color: Colors.white70),
                  SizedBox(width: 6),
                  Text("Support: +263 71 850 2707", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                const Text("Secured @FORCE • Made @corevanta", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
