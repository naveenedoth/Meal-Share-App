import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import './confirm_slot.dart';
import './bottom_nav_bar.dart';
import './guest_appbar.dart';
import './slot_details.dart';

class OwnedMealGuest extends StatefulWidget {
  @override
  State<OwnedMealGuest> createState() => _SharedMealGuestState();
}

class _SharedMealGuestState extends State<OwnedMealGuest> { 


  
  final CollectionReference shareMealCollection =
      FirebaseFirestore.instance.collection('Share_meal_slots');

  final String formattedDate =
      "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year % 100}";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Share',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<QuerySnapshot>(
        future: shareMealCollection.where('guest_uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('Data available!');
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return MealShareHomePage(documents: documents);
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MealShareHomePage extends StatefulWidget {
  final List<QueryDocumentSnapshot> documents;
  
  MealShareHomePage({required this.documents});

  @override
  State<MealShareHomePage> createState() => _MealShareHomePageState();
}

class _MealShareHomePageState extends State<MealShareHomePage> {
  int _selectedTabIndex = 2;
  
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GuestAppBar(title: 'View Slots',),
      bottomNavigationBar: CustomBottomNavigationBar(selectedIndex: _selectedTabIndex, onTabSelected: _onTabSelected),
      backgroundColor: Color(0xFF1D1F24),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var document in widget.documents)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SlotDetails(mealId: document['meal_id'], meal: document['Meal'], mess: document['hostel'], date: document['Date'],),
                    ),
                  );
                  print('Container pressed!');
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    width: 360,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          child: Center(
                            child: Text(
                              document['Meal'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issue date : ${document['Date']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Mess: ${document['hostel']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                    document['status'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'ID: ${document['meal_id']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: double.infinity,
                          child: Image.network(
                            'https://cdn-icons-png.flaticon.com/512/3480/3480823.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
