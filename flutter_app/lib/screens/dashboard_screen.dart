import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/pharmacy/dashboard'));
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PharmaLocator Dashboard'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Welcome to PharmaLocator!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Total Sales: \$\${dashboardData['total_sales'] ?? 0}'),
                  Text('Total Orders: \${dashboardData['total_orders'] ?? 0}'),
                  SizedBox(height: 20),
                  Text(
                    'Stock Alerts:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...?dashboardData['stock_alerts']?.map<Widget>((alert) => Text(
                      '\${alert['medicine_name']}: \${alert['quantity']} left')),
                  SizedBox(height: 20),
                  Text(
                    'AI Stock Prediction:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...?dashboardData['stock_prediction']?.entries.map<Widget>((entry) =>
                      Text('\${entry.key}: \${entry.value}')),
                ],
              ),
            ),
    );
  }
}
