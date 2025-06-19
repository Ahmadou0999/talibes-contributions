import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final int pharmacyId;
  final List<Map<String, dynamic>> cartItems;

  OrderScreen({required this.pharmacyId, required this.cartItems});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ApiService apiService = ApiService();
  String deliveryMethod = 'pickup';
  final _addressController = TextEditingController();
  File? prescriptionImage;
  bool isLoading = false;

  Future<void> pickPrescriptionImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        prescriptionImage = File(pickedFile.path);
      });
    }
  }

  void placeOrder() async {
    if (deliveryMethod == 'delivery' && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir une adresse de livraison')),
      );
      return;
    }

    bool requiresPrescription = widget.cartItems.any((item) => item['requires_prescription'] == true);
    if (requiresPrescription && prescriptionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez télécharger une image de l\'ordonnance')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Prepare order data
    double totalPrice = 0;
    widget.cartItems.forEach((item) {
      totalPrice += item['price'] * item['quantity'];
    });

    // Call API to place order
    bool success = await apiService.placeOrder(
      pharmacyId: widget.pharmacyId,
      items: widget.cartItems,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryMethod == 'delivery' ? _addressController.text : null,
      prescriptionImage: prescriptionImage,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commande passée avec succès')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la passation de la commande')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passer commande'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'Méthode de livraison',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text('Retrait en pharmacie'),
                    leading: Radio<String>(
                      value: 'pickup',
                      groupValue: deliveryMethod,
                      onChanged: (value) {
                        setState(() {
                          deliveryMethod = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Livraison à domicile'),
                    leading: Radio<String>(
                      value: 'delivery',
                      groupValue: deliveryMethod,
                      onChanged: (value) {
                        setState(() {
                          deliveryMethod = value!;
                        });
                      },
                    ),
                  ),
                  if (deliveryMethod == 'delivery')
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Adresse de livraison'),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Ordonnance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: pickPrescriptionImage,
                    child: Text(prescriptionImage == null ? 'Télécharger une image' : 'Changer l\'image'),
                  ),
                  if (prescriptionImage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Image.file(prescriptionImage!),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: placeOrder,
                    child: Text('Passer la commande'),
                  ),
                ],
              ),
            ),
    );
  }
}
