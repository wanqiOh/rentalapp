import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/order.dart';

class InboxPage extends StatefulWidget {
  final Order orderDetails;
  InboxPage({this.orderDetails});

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () async {
      await FirestoreService.getOrders().doc(widget.orderDetails.id).update(
          {'notifCus.clicked': widget.orderDetails.clicked}).then((value) {
        return true;
      }).catchError((error) => print("Failed to add user: $error"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          leading: backwardButtonForInbox(context, widget.orderDetails),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: AppTheme.mediumHorizontalMargin,
              right: AppTheme.mediumHorizontalMargin,
              top: AppTheme.mediumHorizontalMargin,
              bottom: AppTheme.largeMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                widget.orderDetails.title,
                style: AppTheme.title,
                minFontSize: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.mainMargin),
                child: AutoSizeText(
                  DateFormat('dd').format(widget.orderDetails.startDate) +
                      'th ' +
                      DateFormat('MMM yyyy')
                          .format(widget.orderDetails.startDate),
                  style: AppTheme.bodyText,
                  minFontSize: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.mainMargin),
              ),
              textLayoutMessagePage('Estimated time arrival is scheduled on ' +
                  DateFormat('dd/MM/yyyy')
                      .format(widget.orderDetails.startDate)),
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.mainMargin),
              ),
              textLayoutMessagePage('The renting machines will delivery to ' +
                  widget.orderDetails.address.address1 +
                  ', ' +
                  widget.orderDetails.address.address2 +
                  ', ' +
                  widget.orderDetails.address.city +
                  ', ' +
                  widget.orderDetails.address.postcode +
                  ', ' +
                  widget.orderDetails.address.state),
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.mainMargin),
              ),
              textLayoutMessagePage(
                  'Order Status: ' + widget.orderDetails.orderStatus),
            ],
          ),
        ),
      ),
    );
  }

  textLayoutMessagePage(String text) {
    return AutoSizeText(
      text,
      style: AppTheme.bodyText,
      minFontSize: 15,
    );
  }
}
