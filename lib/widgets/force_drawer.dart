import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_vans.dart';
import '../screens/admin/admin_income.dart';
import '../screens/client/history_screen.dart';
class ForceDrawer extends StatelessWidget {
  final bool isAdmin; const ForceDrawer({required this.isAdmin});
  @override Widget build(BuildContext context){
    return Drawer(child:ListView(children:[
      DrawerHeader(decoration:BoxDecoration(color:Color(0xFF0F172A)), child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.local_shipping,color:Colors.white,size:40),Text("FORCE DELIVERY",style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),Text(isAdmin?"Admin - Pure Mundezha":"Client",style:TextStyle(color:Colors.white70))])),
      if(isAdmin)...[
        ListTile(leading:Icon(Icons.dashboard),title:Text("Dashboard"),onTap:()=>Navigator.pop(context)),
        ListTile(leading:Icon(Icons.local_shipping),title:Text("Vans & Expenses"),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminVans()))),
        ListTile(leading:Icon(Icons.bar_chart),title:Text("Daily Income"),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AdminIncome()))),
        Divider(), ListTile(title:Text("EcoCash: 0771234567
Bank: CBZ 123456789 - FORCE"),subtitle:Text("Company Payments")),
      ] else...[
        ListTile(leading:Icon(Icons.history),title:Text("My History"),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>HistoryScreen()))),
      ],
      ListTile(leading:Icon(Icons.logout),title:Text("Logout"),onTap:()async{ await AuthService().logout(); Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>LoginScreen())); })
    ]));
  }
}