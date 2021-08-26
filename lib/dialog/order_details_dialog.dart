import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/order.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsDialog extends StatefulWidget {
  Order order;
  OrderDetailsDialog({this.order});

  @override
  _OrderDetailsDialogState createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  List<Order> orderList = [];
  @override
  Widget build(BuildContext context) {
    print(widget.order.machineItem.price.deliveryCharge);
    return WillPopScope(
      onWillPop: () async => true,
      child: AlertDialog(
        elevation: 10,
        content: SingleChildScrollView(
          reverse: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(widget.order.merchant.companyName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              Text(formatPrice(widget.order.amountPaid),
                  style: TextStyle(fontSize: 15)),
              SizedBox(height: 20),
              Text('Order ID: ${widget.order.id}',
                  style: TextStyle(fontSize: 10)),
              Text(DateFormat('dd-MMM-yyyy').format(widget.order.createdDate),
                  style: TextStyle(fontSize: 10)),
              SizedBox(height: 30),
              Row(children: [
                Text('Renting Date',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.order.getDate(),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Days',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.order.getDifference()} days',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Machine',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.order.machineItem.machineCategory,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Machine Model',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.order.machineItem.machineName,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Quantity',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.order.orderQuantity.toString(),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Price',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getRentingPrice()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Delivery Distance',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.order.totalDistance} km',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Delivery Charge',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${formatPrice(widget.order.machineItem.price.deliveryCharge)} per km',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Delivery Charge',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getDeliveryCharge()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Renting Price',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getTotalRentingPrice()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Tax Charge',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getTaxCharge()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Renting Charge',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getTotalRentCharge()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              // if (widget.order.paymentType == 'DEPOSIT PAYMENT')
              //   Row(children: [
              //     Text('Fixed Deposit Paid',
              //         style:
              //             TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              //     Expanded(
              //       child: Align(
              //         alignment: Alignment.centerRight,
              //         child: Text(
              //           formatPrice(double.parse(globals.deposit)),
              //           style: TextStyle(
              //               fontSize: 13,
              //               color: Colors.grey,
              //               fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ),
              //   ]),
              // if (widget.order.paymentType == 'DEPOSIT PAYMENT')
              //   SizedBox(height: 10),
              // if (widget.order.paymentType == 'DEPOSIT PAYMENT')
              //   Row(children: [
              //     Text('Balance Price',
              //         style:
              //             TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              //     Expanded(
              //       child: Align(
              //         alignment: Alignment.centerRight,
              //         child: Text(
              //           formatPrice((widget.order.getTotalRentCharge() -
              //               double.parse(globals.deposit))),
              //           style: TextStyle(
              //               fontSize: 13,
              //               color: Colors.grey,
              //               fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ),
              //   ]),
              // if (widget.order.paymentType == 'FULL PAYMENT')
              Row(children: [
                Text('Amount Paid',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(widget.order.getTotalRentCharge()),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 30),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: OutlineButton(
                    onPressed: () {
                      launch('tel:+60${1160959279}');
                    },
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Colors.orange,
                      style: BorderStyle.solid,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(children: [
                      Icon(Icons.phone_outlined, size: 15),
                      Text('RENTALAPP', style: TextStyle(fontSize: 8))
                    ]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: OutlineButton(
                    onPressed: () async {
                      String phone = await FirestoreService.getOrders()
                          .doc(widget.order.id)
                          .get()
                          .then((element) {
                        return element.get('merchant.phoneNo');
                      });

                      launch('tel:${phone}');
                    },
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Colors.orange,
                      style: BorderStyle.solid,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(children: [
                      Icon(Icons.phone_outlined, size: 15),
                      Text('MERCHANT', style: TextStyle(fontSize: 8))
                    ]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: OutlineButton(
                    onPressed: () async {
                      Position merchantProsition =
                          await FirestoreService.getOrders()
                              .doc(widget.order.id)
                              .get()
                              .then((element) {
                        return Position.fromMap(
                            element.get('merchant.position'));
                      });
                      String compnayName = await FirestoreService.getOrders()
                          .doc(widget.order.id)
                          .get()
                          .then((element) {
                        return element.get('merchant.name');
                      });

                      final availableMaps = await MapLauncher.installedMaps;
                      if (await MapLauncher.isMapAvailable(MapType.google)) {
                        await MapLauncher.launchMap(
                            mapType: MapType.google,
                            coords: Coords(merchantProsition.latitude,
                                merchantProsition.longitude),
                            title: compnayName);
                      }
                    },
                    borderSide: BorderSide(
                      width: 2.0,
                      color: Colors.orange,
                      style: BorderStyle.solid,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(children: [
                      Icon(Icons.location_on_outlined, size: 15),
                      Text('MAP', style: TextStyle(fontSize: 8))
                    ]),
                  ),
                )
              ]),
              widget.order.reply != 'REJECT'
                  ? TextButton(
                      onPressed: () {
                        widget.order.reply == 'COMPLETE'
                            ? _launchURL(widget.order.fileUrl)
                            : updateOrderStatus();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.orange)),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Text(
                          widget.order.reply == 'COMPLETE'
                              ? 'VIEW INVOICE'
                              : 'COMPLETE',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  updateOrderStatus() async {
    final success = await Dialogs.showConfirmationForCompleteOrder(
        context, 'Confirmation', widget.order,
        content:
            'By clicking \'Yes\', Rentalapp Guarantee will end for this order.\n\nYou will not be able to return or refund after you confirm.\n\nPlease ensure you have received the renting machine and satisfied with their condition.',
        okText: 'Yes');

    print(success);
    if (success) {
      Navigator.pop(context);
    }
  }

  _launchURL(fileUrl) async {
    await canLaunch(fileUrl)
        ? await launch(fileUrl)
        : throw 'Could not launch ${fileUrl}';
  }
}
