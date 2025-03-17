import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleDetailsPage extends StatefulWidget {
  final String imageUrl;
  final String brand;
  final String model;
  final double price;
  final String vin;

  const VehicleDetailsPage({
    super.key,
    required this.imageUrl,
    required this.brand,
    required this.model,
    required this.price,
    required this.vin,
  });

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late Future<Map<String, dynamic>> vehicleDetails;

  @override
  void initState() {
    super.initState();
    vehicleDetails = fetchVehicleDetails(widget.vin);
  }

  Future<Map<String, dynamic>> fetchVehicleDetails(String vin) async {
    final url =
        'https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvaluesextended/$vin?format=json&modelyear=2011';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['Results'][0] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load vehicle details');
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
      throw Exception('Error fetching vehicle details');
    }
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Confirmation'),
          content: const Text('Booked'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brand} ${widget.model} Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.brand} ${widget.model}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Price : \$${widget.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder<Map<String, dynamic>>(
                          future: vehicleDetails,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              );
                            } else if (snapshot.hasData) {
                              final data = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text('Displacement (L) : ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      Text('${data['DisplacementL'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Doors : ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      Text('${data['Doors'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Drive Type : ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      Text('${data['DriveType'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Fuel Type : ',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          '${data['FuelTypePrimary'] ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.red)),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return const Text('No data available');
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: ElevatedButton(
                            onPressed: _showBookingDialog,
                            child: const Text('Book this'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
