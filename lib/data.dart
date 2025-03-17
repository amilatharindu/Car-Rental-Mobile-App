import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Brands and Models',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class NavigationItem {
  IconData iconData;
  bool isSelected;

  NavigationItem(this.iconData, {this.isSelected = false});
}

List<NavigationItem> getNavigationItemList() {
  return <NavigationItem>[
    NavigationItem(Icons.home),
    NavigationItem(Icons.notifications),
    NavigationItem(Icons.person),
  ];
}

class Car {
  String id; // Unique identifier for each car
  String brand;
  String model;
  double price;
  String condition;
  List<String> images;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.price,
    required this.condition,
    required this.images,
  });

  // Convert a Car object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'price': price,
      'condition': condition,
      'images': images,
    };
  }

  // Create a Car object from a JSON map
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      price: json['price'],
      condition: json['condition'],
      images: List<String>.from(json['images']),
    );
  }

  // Override toString for easier debugging
  @override
  String toString() {
    return 'Car(id: $id, brand: $brand, model: $model, price: $price, condition: $condition, images: $images)';
  }
}

class Dealer {
  String name;
  int offers;
  String image;

  Dealer(this.name, this.offers, this.image);
}

final urls = {
  'Audi': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/582?format=json',
    'modelId': 3148,
    'modelImageUrl':
        'https://crdms.images.consumerreports.org/c_lfill,w_470,q_auto,f_auto/prod/cars/chrome/white/2018AUC020001_1280_01',
  },
  'BMW': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/452?format=json',
    'modelId': 1707,
    'modelImageUrl':
        'https://cdn.myshoptet.com/usr/www.autoibuy.com/user/documents/upload/Roman%202024/BMW/M4/M4%20performance/1.png',
  },
  'Honda': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/474?format=json',
    'modelId': 1863,
    'modelImageUrl':
        'https://media.licdn.com/dms/image/v2/D4D12AQHEEGDWGLmt-A/article-cover_image-shrink_720_1280/article-cover_image-shrink_720_1280/0/1711553347188?e=2147483647&v=beta&t=QZGtPghekGqGntPwg4ELRl2KjXoFLLbinKBijgEHj3Q',
  },
  'Toyota': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/448?format=json',
    'modelId': 3647,
    'modelImageUrl':
        'https://media.vov.vn/sites/default/files/styles/large/public/2022-04/2023-toyota-supra_3.jpg',
  },
  'Nissan': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/478?format=json',
    'modelId': 1890,
    'modelImageUrl':
        'https://imgd.aeplcdn.com/1920x1080/cw/ec/20361/Nissan-GTR-Right-Front-Three-Quarter-84904.jpg?v=201711021421&q=80&q=80',
  },
  'Dodge': {
    'url':
        'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/476?format=json',
    'modelId': 1893,
    'modelImageUrl':
        'https://di-uploads-pod12.dealerinspire.com/friendlycdjr/uploads/2020/06/2020-Dodge-Challenger-SRT-Hellcat-Redeye-50th-Anniversary.jpg',
  },
};

final dealerUrls = {
  'Honda':
      'https://cdn.pixabay.com/photo/2016/08/15/18/18/honda-1596081_150.png',
  'Nissan':
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvewSrFPCk7tmV4wu5Wue3ZLO8y5LsU2R1aw&s',
  'Toyota':
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdgeUI4uPpTnu5OJ_OEMNc9bPfyUE9IYU8mg&s',
  'Audi': 'https://upload.wikimedia.org/wikipedia/commons/a/ae/Logo_audi.jpg',
};

Future<List<Car>> fetchCars() async {
  List<Car> carList = [];

  for (var entry in urls.entries) {
    final make = entry.key;
    final apiUrl = entry.value['url'] as String;
    final modelId = entry.value['modelId'];
    final modelImageUrl = entry.value['modelImageUrl'] as String;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['Results'] as List;

        for (var model in models) {
          final modelName = model['Model_Name'];
          final modelIdFromApi = model['Model_ID'];

          if (modelIdFromApi != null && modelIdFromApi == modelId) {
            double price = (make == 'Audi')
                ? 35000
                : (make == 'BMW')
                    ? 45000
                    : (make == 'Honda')
                        ? 25000
                        : (make == 'Toyota')
                            ? 28000
                            : (make == 'Nissan')
                                ? 27000
                                : 32000;

            carList.add(Car(
              id: modelIdFromApi
                  .toString(), // Use model ID as unique identifier
              brand: make,
              model: modelName,
              price: price,
              condition: 'Weekly',
              images: [modelImageUrl],
            ));
          }
        }
      } else {
        print('Failed to fetch data for $make: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data for $make: $e');
    }
  }

  return carList;
}

Future<List<Dealer>> fetchDealers() async {
  List<Dealer> dealerList = [];

  for (var dealerName in dealerUrls.keys) {
    final dealerImageUrl = dealerUrls[dealerName] as String;

    dealerList.add(Dealer(
      dealerName,
      10,
      dealerImageUrl,
    ));
  }

  return dealerList;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Car>> futureCars;
  late Future<List<Dealer>> futureDealers;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureCars = fetchCars();
    futureDealers = fetchDealers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Brands and Models'),
        toolbarHeight: 100,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Car>>(
              future: futureCars,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available.'));
                }

                List<Car> cars = snapshot.data!;

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(car.images[0],
                              height: 200, fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              car.brand,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              car.model,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Condition: ${car.condition} \nPrice: \$${car.price}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Dealers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.orange,
              ),
            ),
          ),
          SizedBox(
            height: 180,
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

                List<Dealer> dealers = snapshot.data!;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dealers.length,
                  itemBuilder: (context, index) {
                    final dealer = dealers[index];
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.network(
                            dealer.image,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            dealer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Offers: ${dealer.offers}',
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
