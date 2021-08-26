import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/dialog/loading_dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/address.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/customer.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';
import 'package:rentalapp/model/view_model/order.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  List<Order> orderPendingList = [];
  List<Order> orderCompleteList = [];
  static const List<String> _TabBarItem = [
    'PENDING',
    'COMPLETE',
  ];
  TabController tabController;
  String invoiceUrl;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: _TabBarItem.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(globals.currentLoginCustomer.id);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          leading: backwardButton(context)),
      body: Material(
        elevation: 4.0,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 65.0,
                color: Colors.grey.shade50,
                child: TabBar(
                  controller: tabController,
                  tabs: _TabBarItem.map((item) => Tab(text: item)).toList(),
                  labelColor: Colors.grey.shade800,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService.filterOrdersForPendingOrder(
                                'customer.id',
                                globals.currentLoginCustomer.id,
                                'reply',
                                'COMPLETE')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: LoadingPage(
                                    message: 'Waiting for connection...'));
                          }
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());
                          else {
                            if (snapshot.data.docs.length == 0) {
                              return Center(
                                child: Text('No any order yet'),
                              );
                            } else {
                              Map<String, dynamic> data;
                              orderPendingList.clear();
                              orderPendingList =
                                  snapshot.data.docs.map((element) {
                                data = element.data();
                                DateTime startDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.startDate'))
                                                .seconds *
                                            1000));
                                DateTime endDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.endDate')).seconds *
                                            1000));
                                DateTime createdDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.createdDate'))
                                                .seconds *
                                            1000));
                                print(
                                    'Validate: ${DateTime.now().isBefore(endDate.add(Duration(days: 3)))}');
                                checkValidation(element, endDate);

                                getInvoiceUrl(element.reference.id);
                                return Order(
                                  id: element.reference.id,
                                  machineItem: MachineItem.fromJson(
                                      element.get('machine')),
                                  customer: Customer.fromJson(
                                      element.get('customer')),
                                  address:
                                      Address.fromJson(element.get('address')),
                                  merchant: CompanyItem.fromJson(
                                      element.get('merchant')),
                                  orderStatus: element.get('reply'),
                                  startDate: startDate,
                                  endDate: endDate,
                                  fileUrl: invoiceUrl,
                                  createdDate: createdDate,
                                  reply: element.get('reply'),
                                  totalDistance: element
                                      .get('distance')
                                      .toString()
                                      .split(' ')[0],
                                  orderQuantity: element.get('orderQuantity'),
                                  amountPaid:
                                      ((element.get('payment.paid') as num) ??
                                              0)
                                          .toDouble(),
                                  title: data.containsKey('notifCus')
                                      ? element.get('notifCus.title')
                                      : null,
                                  content: data.containsKey('notifCus')
                                      ? element.get('notifCus.content')
                                      : null,
                                  clicked: data.containsKey('notifCus')
                                      ? element.get('notifCus.clicked')
                                      : null,
                                  receivedTime:
                                      DateTime.fromMillisecondsSinceEpoch((data
                                                  .containsKey('notifCus')
                                              ? element
                                                  .get('notifCus.receivedTime')
                                                  .seconds
                                              : 0) *
                                          1000),
                                );
                              }).toList();

                              return SingleChildScrollView(
                                child: makeSearchComponent(
                                    context, orderPendingList),
                              );
                            }
                          }
                        }),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirestoreService.filterOrdersFor2Req(
                                'customer.id',
                                globals.currentLoginCustomer.id,
                                'reply',
                                'COMPLETE')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingPage(
                                message: 'Waiting for connection...');
                          }
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          else {
                            if (snapshot.data.docs.length == 0) {
                              return Expanded(
                                child: Center(
                                  child: Text('No any order yet'),
                                ),
                              );
                            } else {
                              Map<String, dynamic> data;
                              orderCompleteList.clear();
                              int orderNum = snapshot.data.docs.length;
                              orderCompleteList =
                                  snapshot.data.docs.map((element) {
                                data = element.data();
                                DateTime startDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.startDate'))
                                                .seconds *
                                            1000));
                                DateTime endDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.endDate')).seconds *
                                            1000));
                                DateTime createdDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        ((element.get('date.createdDate'))
                                                .seconds *
                                            1000));

                                FirestoreService.getDeviceId()
                                    .doc(element.get('merchant.id'))
                                    .update({'orderNum': orderNum}).then(
                                        (value) {
                                  return true;
                                }).catchError((error) =>
                                        print("Failed to add field: $error"));

                                getInvoiceUrl(element.reference.id);

                                return Order(
                                  id: element.reference.id,
                                  machineItem: MachineItem.fromJson(
                                      element.get('machine')),
                                  customer: Customer.fromJson(
                                      element.get('customer')),
                                  address:
                                      Address.fromJson(element.get('address')),
                                  merchant: CompanyItem.fromJson(
                                      element.get('merchant')),
                                  // paymentType: element.get('payment.payType'),
                                  orderStatus: element.get('reply'),
                                  startDate: startDate,
                                  endDate: endDate,
                                  fileUrl: invoiceUrl,
                                  reply: element.get('reply'),
                                  orderQuantity: element.get('orderQuantity'),
                                  totalDistance: element
                                      .get('distance')
                                      .toString()
                                      .split(' ')[0],
                                  createdDate: createdDate,
                                  amountPaid:
                                      (element.get('payment.paid') as num) ??
                                          0.toDouble(),
                                  title: data.containsKey('notifCus')
                                      ? element.get('notifCus.title')
                                      : null,
                                  content: data.containsKey('notifCus')
                                      ? element.get('notifCus.content')
                                      : null,
                                  clicked: data.containsKey('notifCus')
                                      ? element.get('notifCus.clicked')
                                      : null,
                                  receivedTime:
                                      DateTime.fromMillisecondsSinceEpoch((data
                                                  .containsKey('notifCus')
                                              ? element
                                                  .get('notifCus.receivedTime')
                                                  .seconds
                                              : 0) *
                                          1000),
                                );
                              }).toList();

                              return SingleChildScrollView(
                                child: makeSearchComponent(
                                    context, orderCompleteList),
                              );
                            }
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  makeSearchComponent(BuildContext context, List<Order> orderList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      generateTitle('HISTORY'),
      GridView.count(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        childAspectRatio: MediaQuery.of(context).size.width / 70,
        crossAxisCount: 1,
        children: List<Widget>.generate(orderList.length, (index) {
          print(orderList[index].amountPaid);
          return searchListSection(orderList[index]);
        }).toList(),
      )
    ]);
  }

  searchListSection(Order order) {
    print(order.amountPaid);
    return GestureDetector(
      onTap: () {
        Dialogs.showOrderDetailsDialog(context, order);
      },
      child: GridTile(
          child: Container(
        margin: const EdgeInsets.only(top: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2.0, color: Colors.grey.shade200),
          ),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 2,
              child: Text(order.merchant.companyName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(DateFormat('dd/MM/yy').format(order.createdDate),
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                order.orderStatus + ' . ' + formatPrice(order.amountPaid),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]),
      )),
    );
  }

  void checkValidation(
      QueryDocumentSnapshot<Object> element, DateTime endDate) {
    if (DateTime.now().isBefore(endDate.add(Duration(days: 3)))) {
      print('Not Expired');
      print(element.get('reply'));
    } else {
      print('Expired');
      print(element.get('reply'));
      FirestoreService.getOrders()
          .doc(element.reference.id)
          .update({'reply': 'COMPLETE'});

      FirestoreService.getMachines().doc(element.get('machine.id')).update({
        'quantity':
            (element.get('machine.quantity') + element.get('orderQuantity'))
      });
    }
  }

  Future<void> getInvoiceUrl(String requirement) async {
    await FirestoreService.filterInvoice('orderID', requirement)
        .get()
        .then((value) {
      value.docs.map((element) {
        invoiceUrl = element.get('url');
      }).toList();
    });
  }
}
