import 'package:flutter/material.dart';
import '../data.dart';

class CarList extends StatelessWidget {
  final Future<List<Car>> futureCars;
  final String searchQuery;

  const CarList({required this.futureCars, required this.searchQuery, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Car>>(
      future: futureCars,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No cars available.'));
        }

        final filteredCars = snapshot.data!.where((car) {
          final lowerQuery = searchQuery.toLowerCase();
          return car.brand.toLowerCase().contains(lowerQuery) ||
              car.model.toLowerCase().contains(lowerQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredCars.length,
          itemBuilder: (context, index) {
            final car = filteredCars[index];
            return Card(
              child: ListTile(
                title: Text(car.brand),
                subtitle: Text('${car.model} - \$${car.price}'),
                leading: Image.network(car.images[0]),
              ),
            );
          },
        );
      },
    );
  }
}
