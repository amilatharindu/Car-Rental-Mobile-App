import 'package:flutter/material.dart';
import '../data.dart';

class DealerList extends StatelessWidget {
  final Future<List<Dealer>> futureDealers;
  final String searchQuery;

  const DealerList({required this.futureDealers, required this.searchQuery, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Dealer>>(
      future: futureDealers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No dealers available.'));
        }

        final filteredDealers = snapshot.data!.where((dealer) {
          final lowerQuery = searchQuery.toLowerCase();
          return dealer.name.toLowerCase().contains(lowerQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredDealers.length,
          itemBuilder: (context, index) {
            final dealer = filteredDealers[index];
            return ListTile(
              leading: Image.network(dealer.image),
              title: Text(dealer.name),
              subtitle: Text('Offers: ${dealer.offers}'),
            );
          },
        );
      },
    );
  }
}

