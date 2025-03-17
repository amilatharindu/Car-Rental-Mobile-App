import 'favourite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data.dart';
import 'vehicle.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Car>> futureCars;
  late Future<List<Dealer>> futureDealers;
  String searchQuery = '';
  int selectedIndex = -1;
  int currentIndex = 0;
  List<Car> favoriteCars = [];
  List<Car> filteredCars = [];

  @override
  void initState() {
    super.initState();
    futureCars = fetchCars();
    futureDealers = fetchDealers();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteCarsJson = prefs.getStringList('favoriteCars') ?? [];
    setState(() {
      favoriteCars = favoriteCarsJson
          .map((carJson) => Car.fromJson(jsonDecode(carJson)))
          .toList();
    });
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteCarsJson =
        favoriteCars.map((car) => jsonEncode(car.toJson())).toList();
    await prefs.setStringList('favoriteCars', favoriteCarsJson);
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void toggleFavorite(int index) async {
    final cars = await futureCars;
    final car = cars[index];
    setState(() {
      if (favoriteCars.any((c) => c.id == car.id)) {
        favoriteCars.removeWhere((c) => c.id == car.id);
      } else {
        favoriteCars.add(car);
      }
      _saveFavorites();
    });
  }

  void onTabTapped(int index) async {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoriteCarsPage(favoriteCars: favoriteCars),
        ),
      );
    } else if (index == 1 || index == 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(index == 1 ? 'Notifications' : 'Profile'),
          content: Text(index == 1
              ? 'No new notifications.'
              : 'Profile details will be shown here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  void filterCarsByDealer(String dealerBrand) async {
    final cars = await futureCars;
    setState(() {
      filteredCars = cars.where((car) => car.brand == dealerBrand).toList();
    });
  }

  void resetFilter() {
    setState(() {
      filteredCars = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Top Rated Models for Rent',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search for cars or dealers...',
                hintStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: FutureBuilder<List<Car>>(
                future: futureCars,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No cars available.'));
                  }

                  List<Car> cars = filteredCars.isNotEmpty
                      ? filteredCars
                      : snapshot.data!
                          .where((car) =>
                              car.brand
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ||
                              car.model
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                          .toList();

                  return Column(
                    children: [
                      if (filteredCars.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: resetFilter,
                            child: const Text('View All'),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            final car = cars[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleDetailsPage(
                                      imageUrl: car.images[0],
                                      brand: car.brand,
                                      model: car.model,
                                      price: car.price,
                                      vin: '5UXWX7C5*BA',
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              car.images[0],
                                              height: 153,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.favorite,
                                            color: favoriteCars
                                                    .any((c) => c.id == car.id)
                                                ? Colors.purple
                                                : Colors.grey,
                                          ),
                                          onPressed: () =>
                                              toggleFavorite(index),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                car.brand,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                car.model,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Condition: ${car.condition}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Text(
                                                'Price: \$${car.price}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 1.0),
            Text(
              'Dealers',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder<List<Dealer>>(
                future: futureDealers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No dealers available.'));
                  }

                  List<Dealer> dealers = snapshot.data!
                      .where((dealer) => dealer.name
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dealers.length,
                    itemBuilder: (context, index) {
                      final dealer = dealers[index];
                      return GestureDetector(
                        onTap: () {
                          filterCarsByDealer(dealer.name);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            height: 10,
                            width: 185,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        dealer.image,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      dealer.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Offers: ${dealer.offers}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
