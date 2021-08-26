import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/loading_dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/machine_detail.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';
import 'package:rentalapp/model/view_model/price_detail.dart';

class CompanyDetailPage extends StatefulWidget {
  CompanyItem recommendCompany;
  CompanyDetailPage({this.recommendCompany});

  @override
  _CompanyDetailPageState createState() => _CompanyDetailPageState();
}

class _CompanyDetailPageState extends State<CompanyDetailPage> {
  List<MachineItem> machineList = [];
  PriceDetail price;
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: backwardButton(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.filterMachines(
                  'merchant.id', widget.recommendCompany.id)
              .snapshots(),
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
              machineList = snapshot.data.docs.map((element) {
                return MachineItem(
                  machineName: element.get('model'),
                  machineCategory:
                      element.get('type').toString().split('_').join(' '),
                  quantity: element.get('quantity'),
                  image: element.get('image'),
                  merchant: CompanyItem.fromJson(element.get('merchant')),
                  price: PriceDetail.fromJson(element.get('price')),
                  machineDetail: MachineDetail.fromJson(element.get('detail')),
                  enable: element.get('enable'),
                );
              }).toList();

              return SingleChildScrollView(
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 0.0, 16.0),
                      child: makeCompanyTitle()),
                  makeRentalEquiment(),
                ]),
              );
            }
          }),
    );
  }

  makeCompanyTitle() {
    return Row(children: [
      Expanded(
          child: AutoSizeText(
        widget.recommendCompany.companyName,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        maxLines: 2,
      )),
      Expanded(
          child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.grey,
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade50,
          backgroundImage: NetworkImage(widget.recommendCompany.logo),
        ),
      )),
    ]);
  }

  makeRentalEquiment() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...makeRentalEquimentSection(context),
      makeContact(),
    ]);
  }

  makeRentalEquimentSection(BuildContext context) {
    if (machineList.isEmpty) {
      return [Container()];
    }

    return [
      generateTitle('RENTAL\nEQUIPMENT'),
      Container(
          height: MediaQuery.of(context).size.height >= 400
              ? MediaQuery.of(context).size.height * 0.24
              : MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: machineList.length,
            itemBuilder: (_, int index) {
              return generateRentalEquipmentList(context, machineList[index]);
            },
          )),
    ];
  }

  generateRentalEquipmentList(BuildContext context, MachineItem machine) {
    print("${globals.dailyRate}");
    return Stack(children: [
      GestureDetector(
        onTap: () {
          machine.enable || machine.quantity == 0
              ? null
              : Navigator.pushNamed(context, CustomRouter.machineDetailRoute,
                  arguments: machine);
        },
        child: Container(
          height: MediaQuery.of(context).size.height >= 400
              ? MediaQuery.of(context).size.height * 0.24
              : MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Image.network(
                              machine.image,
                              fit: BoxFit.contain,
                            )),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  machine.machineName.toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        formatPrice((machine.price.dailyRate *
                            (globals.dailyRate + 1))),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
      machine.enable || machine.quantity == 0
          ? Container()
          : Positioned(
              bottom: 0.0,
              child: Container(
                height: MediaQuery.of(context).size.height >= 400
                    ? MediaQuery.of(context).size.height * 0.24
                    : MediaQuery.of(context).size.height * 0.7,
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

  makeContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        generateTitle('CONTACT'),
        makeContactList(),
      ],
    );
  }

  makeContactList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.person),
            AutoSizeText(
              widget.recommendCompany.director,
              style: TextStyle(fontSize: 20),
            )
          ]),
          SizedBox(height: 20),
          Row(children: [
            Icon(Icons.phone),
            AutoSizeText(
              widget.recommendCompany.phoneNo,
              style: TextStyle(fontSize: 20),
            )
          ]),
          SizedBox(height: 20),
          Row(children: [
            Icon(Icons.location_on),
            Expanded(
                flex: 3,
                child: AutoSizeText(
                  '${widget.recommendCompany.address.address1}, ${widget.recommendCompany.address.address2}, ${widget.recommendCompany.address.postcode} ${widget.recommendCompany.address.city}, ${widget.recommendCompany.address.state}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20),
                ))
          ]),
          SizedBox(height: 20),
          Row(children: [
            Icon(Icons.web),
            AutoSizeText(
              widget.recommendCompany.website,
              style: TextStyle(fontSize: 20),
            )
          ]),
        ],
      ),
    );
  }
}
