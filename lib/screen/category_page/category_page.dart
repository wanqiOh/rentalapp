import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/loading_dialog.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/category_item.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/machine_detail.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';
import 'package:rentalapp/model/view_model/price_detail.dart';

class CategoryPage extends StatefulWidget {
  String type;
  CategoryPage({this.type});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<MachineItem> filteredMachineTypeList = [];
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

  @override
  Widget build(BuildContext context) {
    // print(widget.type);
    // FirestoreService.filterMachines('type', widget.type).get().then((value) {
    //   value.docs.map((element) {
    //     print('Element: ${element.data()}');
    //   }).toList();
    // });
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          leading: backwardButton(context)),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirestoreService.filterMachines('type', widget.type).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              filteredMachineTypeList = snapshot.data.docs.map((element) {
                print(element.get('merchant'));
                return MachineItem(
                  id: element.reference.id,
                  machineName: element.get('model'),
                  machineCategory: element.get('type'),
                  quantity: element.get('quantity'),
                  image: element.get('image'),
                  machineDetail: MachineDetail.fromJson(element.get('detail')),
                  price: PriceDetail.fromJson(element.get('price')),
                  merchant: CompanyItem.fromJson(element.get('merchant')),
                  enable: element.get('enable'),
                );
              }).toList();

              return SingleChildScrollView(
                child: makeSearchComponent(context, filteredMachineTypeList),
              );
            }
          }),
    );
  }

  makeSearchComponent(
      BuildContext context, List<MachineItem> filteredMachineList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        children: List<Widget>.generate(filteredMachineList.length, (index) {
          return searchListSection(filteredMachineList[index]);
        }).toList(),
      )
    ]);
  }

  searchListSection(MachineItem machine) {
    return Stack(children: [
      GestureDetector(
        onTap: () {
          machine.enable || machine.quantity == 0
              ? Navigator.pushNamed(context, CustomRouter.machineDetailRoute,
                  arguments: machine)
              : null;
        },
        child: GridTile(
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
                          AutoSizeText(
                              machine.machineCategory.split('_').join(' '),
                              style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          AutoSizeText(
                              'owns by ${machine.merchant.companyName}',
                              style: TextStyle(fontSize: 10)),
                        ],
                      ))),
            ]),
          ),
        ),
      ),
      machine.enable || machine.quantity == 0
          ? Container()
          : Positioned(
              bottom: 0.0,
              child: Container(
                height: MediaQuery.of(context).size.height / 7,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors
                            .transparent), //color is transparent so that it does not blend with the actual color specified
                    color: Color.fromRGBO(255, 255, 255,
                        0.7) // Specifies the background color and the opacity
                    ),
                child: Center(
                  child: Text(
                    'Disable Now',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 40),
                  ),
                ),
              ),
            ),
    ]);
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
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.yellow.shade200),
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
                        Navigator.popAndPushNamed(
                            context, CustomRouter.categoryRoute,
                            arguments: categoryItemList[index].machineType);
                        break;
                    }
                  },
                  child: Text(
                      categoryItemList[index].machineType.split('_').join(' '),
                      style: TextStyle(color: Colors.grey))));
        },
      ),
    );
  }
}
