import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'medicine_detail_screen.dart';

class MedicinesScreen extends StatefulWidget {
  @override
  _MedicinesScreenState createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> medicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  void fetchMedicines() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> fetchedMedicines = await apiService.fetchMedicines();
    setState(() {
      medicines = fetchedMedicines;
      isLoading = false;
    });
  }

  void navigateToDetail(int medicineId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailScreen(medicineId: medicineId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return ListTile(
                  title: Text(medicine['name']),
                  subtitle: Text(medicine['description'] ?? ''),
                  trailing: Text('\$${medicine['price']}'),
                  onTap: () {
                    navigateToDetail(medicine['id']);
                  },
                );
              },
            ),
    );
  }
}
