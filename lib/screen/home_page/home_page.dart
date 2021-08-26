import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/loading_dialog.dart';
import 'package:rentalapp/dialog/upload_contact_dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/address.dart';
import 'package:rentalapp/model/view_model/category_item.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/customer.dart';
import 'package:rentalapp/model/view_model/directions_model.dart';
import 'package:rentalapp/model/view_model/locations.dart';
import 'package:rentalapp/model/view_model/machine_detail.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';
import 'package:rentalapp/model/view_model/order.dart';
import 'package:rentalapp/model/view_model/price_detail.dart';
import 'package:rentalapp/repository/directions_repository.dart';
import 'package:rentalapp/screen/navigation_drawer/navigation_drawer.dart';

class HomePage extends StatefulWidget {
  Customer customer;
  HomePage({this.customer});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> machineTypes = [];
  String keyword = '';
  int _current = 0;
  List<CategoryItem> categoryItemList = [
    CategoryItem(
        machineImage: checkMachineImage('scissor_lift'),
        machineType: 'scissor_lift'),
    CategoryItem(
        machineImage: checkMachineImage('aerial_lift'),
        machineType: 'aerial_lift'),
    CategoryItem(
        machineImage: checkMachineImage('spider_lift'),
        machineType: 'spider_lift'),
    CategoryItem(
        machineImage: checkMachineImage('crawler_crane'),
        machineType: 'crawler_crane'),
    CategoryItem(
        machineImage: checkMachineImage('boom_lift'), machineType: 'boom_lift'),
    CategoryItem(
        machineImage: checkMachineImage('fork_lift'), machineType: 'fork_lift'),
    CategoryItem(
        machineImage: checkMachineImage('sky_lift'),
        machineType: 'sky_lift'),
    CategoryItem(
        machineImage: checkMachineImage('beach_lift'),
        machineType: 'beach_lift'),
  ];

  List<MachineItem> filteredMachineList = [];
  List<CompanyItem> companyItemList = [];
  List<Order> orderList = [];
  Marker _origin;
  List<Marker> _destination = [];
  List<Directions> _directions = [];

  // Widget logoutIconButton(BuildContext context) {
  //   return IconButton(
  //     icon: Icon(
  //       Icons.logout,
  //       color: Colors.grey,
  //     ),
  //     onPressed: () {},
  //   );
  // }

  Widget notifIconButton(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.filterOrdersFor2Req('customer.id',
                globals.currentLoginCustomer.id, 'reply', 'ACCEPT')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData)
            return CircularProgressIndicator();
          else {
            if (snapshot.data.docs.length == 0) {
              var order = snapshot.data.docs.firstWhere(
                  (element) => element.get('clicked') == false,
                  orElse: () => null);
              return IconButton(
                  icon: Icon(
                    order == null
                        ? Icons.notifications_none_outlined
                        : Icons.notifications_active_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, CustomRouter.notificationRoute,
                        arguments: orderList);
                  });
            } else {
              Map<String, dynamic> data;
              orderList.clear();
              orderList = snapshot.data.docs.map((element) {
                data = element.data();
                if (!(data.containsKey('notifCus'))) {
                  print('text');
                  for (int i = 0; i < snapshot.data.docs.length; i++) {
                    print(snapshot.data.docs[i].reference.id);
                    FirestoreService.getOrders()
                        .doc(snapshot.data.docs[i].reference.id)
                        .update({
                      'notifCus': {
                        'title': globals.notifications[i].title,
                        'content': globals.notifications[i].content,
                        'clicked': checkClickedStatus(
                            globals.notifications[i].clicked),
                        'receivedTime': DateTime.fromMillisecondsSinceEpoch(
                            (globals.notifications[i].receivedDateTime * 1000))
                      },
                    });
                  }
                }

                DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
                    ((element.get('date.startDate')).seconds * 1000));
                DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
                    ((element.get('date.endDate')).seconds * 1000));
                DateTime createdDate = DateTime.fromMillisecondsSinceEpoch(
                    ((element.get('date.createdDate')).seconds * 1000));
                return Order(
                  id: element.reference.id,
                  machineItem: MachineItem.fromJson(element.get('machine')),
                  customer: Customer.fromJson(element.get('customer')),
                  address: Address.fromJson(element.get('address')),
                  orderStatus: element.get('reply'),
                  startDate: startDate,
                  endDate: endDate,
                  createdDate: createdDate,
                  totalDistance:
                      element.get('distance').toString().split(' ')[0],
                  amountPaid: element.get('payment.paid'),
                  // balance: element.get('payment.paid.balance'),
                  // fileUrl: element.get('payment.fileUrl'),
                  title: data.containsKey('notifCus')
                      ? element.get('notifCus.title')
                      : null,
                  content: data.containsKey('notifCus')
                      ? element.get('notifCus.content')
                      : null,
                  clicked: data.containsKey('notifCus')
                      ? element.get('notifCus.clicked')
                      : null,
                  receivedTime: DateTime.fromMillisecondsSinceEpoch(
                      (data.containsKey('notifCus')
                              ? element.get('notifCus.receivedTime').seconds
                              : 0) *
                          1000),
                );
              }).toList();

              print(orderList.first.clicked);
              Order order = orderList.firstWhere(
                  (element) => element.clicked == false,
                  orElse: () => null);
              print('order: ${order}');
              return IconButton(
                  icon: Icon(
                    order == null
                        ? Icons.notifications_none_outlined
                        : Icons.notifications_active_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, CustomRouter.notificationRoute,
                        arguments: orderList);
                  });
            }
          }
        });
  }

  @override
  void initState() {
    super.initState();
    print(widget.customer.position);
    widget.customer.position = Position(
        latitude: widget.customer.position.latitude,
        longitude: widget.customer.position.longitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customer.position == null || widget.customer.phoneNo == null) {
      if (widget.customer.position == null)
        getCurrentLocation(context, widget.customer.id);
      if (widget.customer.phoneNo == null)
        return UploadContactPage(id: widget.customer.id);
    }
    globals.currentLoginCustomer = widget.customer;

    return Scaffold(
      key: _scaffoldKey,
      drawer:
          (keyword != null && keyword != '') ? Container() : NavigationDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        actions: [
          (keyword != null && keyword != '')
              ? Container()
              : notifIconButton(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          makeSearchBar(),
          (keyword != null && keyword != '')
              ? makeSearchComponent(context)
              : makeNonSearchComponent(context),
        ]),
      ),
    );
  }

  makeSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (text) {
          setState(() {
            keyword = text;
          });
        },
        keyboardType: TextInputType.text,
        cursorColor: Colors.grey,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
          hintText: 'Search ...',
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  makeNonSearchComponent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getMerchants().snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingPage(message: 'Waiting for connection...'));
          }
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else {
            companyItemList.clear();
            companyItemList = snapshot.data.docs.map((element) {
              return CompanyItem(
                id: element.get('id'),
                notifId: element.get('notifId'),
                logo: element.get('logo'),
                companyName: element.get('name'),
                location: Locations.fromJson(element.get('location')),
                address: Address.fromJson(element.get('address')),
                director: element.get('director'),
                phoneNo: element.get('phoneNo'),
                website: element.get('website'),
                position: Position(
                    latitude: element.get('position')['latitude'],
                    longitude: element.get('position')['longitude']),
                orderNum: element.get('orderNum'),
              );
            }).toList();
            globals.companys = companyItemList;
            print('Length: ${companyItemList.length}');

            _origin = Marker(
              markerId: const MarkerId('current location'),
              infoWindow: const InfoWindow(title: 'You are here'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              position: LatLng(globals.currentLoginCustomer.position.latitude,
                  globals.currentLoginCustomer.position.longitude),
            );

            _destination.clear();
            for (var element in companyItemList) {
              _destination.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  infoWindow: const InfoWindow(title: 'Destination'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  position: LatLng(
                      element.position.latitude, element.position.longitude),
                ),
              );
            }

            return FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingPage(message: 'Waiting for connection...'));
                }
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                else {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height >= 700
                        ? MediaQuery.of(context).size.height / 1.25
                        : MediaQuery.of(context).size.height / 0.39,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          generateTitle('RENTAL\nMACHINE'),
                          GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            mainAxisSpacing: 20.0,
                            crossAxisCount: 4,
                            children: List.generate(8, (index) {
                              return Center(
                                child: GestureDetector(
                                  onTap: () {
                                    print(
                                        '${categoryItemList[index].machineType} is pressed');
                                    switch (index) {
                                      case 0:
                                      case 1:
                                      case 2:
                                      case 3:
                                      case 4:
                                      case 5:
                                      case 6:
                                      case 7:
                                        Navigator.pushNamed(
                                            context, CustomRouter.categoryRoute,
                                            arguments: categoryItemList[index]
                                                .machineType);
                                        break;
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.network(
                                          categoryItemList[index].machineImage,
                                          scale: MediaQuery.of(context)
                                                      .size
                                                      .height >=
                                                  400
                                              ? 3.0
                                              : 1.5),
                                      AutoSizeText(
                                        categoryItemList[index]
                                            .machineType
                                            .split('_')
                                            .join(' '),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          ...makeRecommendSection(context),
                        ]),
                  );
                }
              },
              future: asyncInfo(),
            );
          }
        });
  }

  makeRecommendSection(BuildContext context) {
    if (companyItemList.isEmpty) {
      return [Expanded(child: Center(child: Text('No nearby merchant yet')))];
    }

    return [
      generateTitle('RECOMMEND'),
      Container(
        height: MediaQuery.of(context).size.height >= 400
            ? MediaQuery.of(context).size.height * 0.28
            : MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: companyItemList.length,
          itemBuilder: (_, int index) {
            return generateRecommendCardList(context, companyItemList[index]);
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: companyItemList.map((item) {
          int index = item.index;
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? AppTheme.primaryColor
                  : AppTheme.disabled_grey,
            ),
          );
        }).toList(),
      ),
    ];
  }

  generateRecommendCardList(BuildContext context, CompanyItem item) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            FirestoreService.filterMachines('merchant.id', item.id).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage(message: 'Waiting for connection...');
          }
          if (!snapshot.hasData)
            return CircularProgressIndicator();
          else {
            machineTypes = snapshot.data.docs
                .map((element) {
                  return element.get('type').toString().split('_').join(' ');
                })
                .toSet()
                .toList();
            String desc = machineTypes.join(', ');
            item.description = desc;
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, CustomRouter.companyDetailRoute,
                    arguments: item);
              },
              child: Container(
                height: MediaQuery.of(context).size.height >= 400
                    ? MediaQuery.of(context).size.height * 0.28
                    : MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.network(item.logo,
                                  scale:
                                      MediaQuery.of(context).size.height >= 400
                                          ? 3
                                          : 1),
                              Column(
                                children: [
                                  Text(
                                    item.companyName,
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height >=
                                                400
                                            ? 18
                                            : 30),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                      'Location: ${item.location.postcode}, ${item.location.state}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height >=
                                                  400
                                              ? 10
                                              : 20)),
                                ],
                              ),
                            ],
                          ),
                          Text('Provide ${item.description}',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height >= 400
                                          ? 15
                                          : 20)),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Complete ${item.orderNum.toString()} orders',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize:
                                      MediaQuery.of(context).size.height >= 400
                                          ? 15
                                          : 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  makeSearchComponent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getMachines()
            .where('caseSearch', arrayContains: keyword)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingPage(message: 'Waiting for connection...'));
          }
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else {
            filteredMachineList = snapshot.data.docs.map((element) {
              return MachineItem(
                machineName: element.get('model'),
                machineCategory:
                    element.get('type').toString().split('_').join(' '),
                quantity: element.get('quantity'),
                image: element.get('image'),
                merchant: CompanyItem.fromJson(element.get('merchant')),
                price: PriceDetail.fromJson(element.get('price')),
                machineDetail: MachineDetail.fromJson(element.get('detail')),
              );
            }).toList();

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  generateTitle('RENTAL\nMACHINE'),
                  makeCategorySection(context),
                  GridView.count(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    childAspectRatio: MediaQuery.of(context).size.width >= 700
                        ? MediaQuery.of(context).size.width / 125
                        : MediaQuery.of(context).size.width / 130,
                    crossAxisCount: 1,
                    children: List<Widget>.generate(filteredMachineList.length,
                        (index) {
                      return searchListSection(
                          machine: filteredMachineList[index]);
                    }).toList(),
                  )
                ]);
          }
        });
  }

  searchListSection({MachineItem machine}) {
    return GridTile(
      child: Container(
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2.0, color: Colors.grey.shade200),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 1,
              child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Image.network(machine.image,
                      scale: 3, fit: BoxFit.contain))),
          Expanded(
              flex: 2,
              child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        machine.machineName.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      AutoSizeText(machine.machineCategory,
                          style: TextStyle(fontSize: 15)),
                      SizedBox(height: 10),
                      AutoSizeText('owns by ${machine.merchant.companyName}',
                          style: TextStyle(fontSize: 8)),
                    ],
                  ))),
        ]),
      ),
    );
  }

  makeCategorySection(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: categoryItemList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow.shade200),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
              ),
              onPressed: () {
                print('${categoryItemList[index].machineType} is pressed');
                switch (index) {
                  case 0:
                  case 1:
                  case 2:
                  case 3:
                  case 4:
                  case 5:
                  case 6:
                  case 7:
                    Navigator.pushNamed(context, CustomRouter.categoryRoute,
                        arguments: categoryItemList[index].machineType);
                    break;
                }
              },
              child: Text(categoryItemList[index].machineType,
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  bool checkClickedStatus(int clicked) {
    if (clicked == 1)
      return true;
    else
      return false;
  }

  Future<List<CompanyItem>> asyncInfo() async {
    print("destination: ${_destination.length}");
    for (int i = 0; i < _destination.length; i++) {
      companyItemList[i].distance = (await DirectionsRepository().getDirections(
              origin: _origin.position, destination: _destination[i].position))
          .totalDistance
          .split(' ')[0];
    }

    companyItemList.retainWhere((element) {
      return ((double.parse(element.distance) <= 30) == true);
    });

    return companyItemList;
  }
}
