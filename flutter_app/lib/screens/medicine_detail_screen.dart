import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MedicineDetailScreen extends StatefulWidget {
  final int medicineId;

  MedicineDetailScreen({required this.medicineId});

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  Map<String, dynamic> medicineData = {};
  List<dynamic> pharmacies = [];

  @override
  void initState() {
    super.initState();
    fetchMedicineDetail();
  }

  void fetchMedicineDetail() async {
    setState(() {
      isLoading = true;
    });
    final response = await apiService.get('/api/medicine/\${widget.medicineId}');
    if (response.statusCode == 200) {
      final data = response.body;
      setState(() {
        medicineData = data['medicine'] ?? {};
        pharmacies = data['pharmacies'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicineData['name'] ?? 'Détail du Médicament'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    medicineData['name'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Molécule: \${medicineData['molecule'] ?? 'N/A'}'),
                  Text('Posologie: \${medicineData['posology'] ?? 'N/A'}'),
                  Text('Forme: \${medicineData['form'] ?? 'N/A'}'),
                  Text('Description: \${medicineData['description'] ?? 'N/A'}'),
                  Text('Prix: \${medicineData['price']?.toStringAsFixed(2) ?? 'N/A'} €'),
                  SizedBox(height: 20),
                  Text(
                    'Pharmacies avec disponibilité:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...pharmacies.map((pharmacy) => Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(pharmacy['name']),
                          subtitle: Text(pharmacy['address'] ?? 'Adresse non disponible'),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Stock: \${pharmacy['quantity']}'),
                              Text('Prix: \${pharmacy['price']} €'),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
