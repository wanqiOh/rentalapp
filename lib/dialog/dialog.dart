import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/order.dart';

import 'order_details_dialog.dart';

class Dialogs {
  static Future<bool> showConfirmation(BuildContext context, String title,
          {String content =
              'The data will be deleted forever, Do you confirm ?',
          String okText = 'Delete'}) async =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            OutlinedButton(
              child: Text(okText),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

  static Future<bool> showConfirmationForCompleteOrder(
          BuildContext context, String title, Order order,
          {String content, String okText}) async =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            OutlinedButton(
              child: Text(okText),
              onPressed: () async {
                final successOrder = await FirestoreService.getOrders()
                    .doc(order.id)
                    .update({'reply': 'COMPLETE'}).then((value) {
                  return true;
                }).catchError((error) => print("Failed to add field: $error"));

                final successMachine = await FirestoreService.getMachines()
                    .doc(order.machineItem.id)
                    .update({
                  'quantity': (order.machineItem.quantity + order.orderQuantity)
                }).then((value) {
                  return true;
                }).catchError((error) => print("Failed to add field: $error"));

                final success = successOrder && successMachine;
                Navigator.pop(context, success);
              },
            ),
          ],
        ),
      );

  static Future<bool> showConfirmationForLogout(
          BuildContext context, String title,
          {String content, String okText}) async =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () => Navigator.pop(context, false),
            ),
            OutlinedButton(
              child: Text(okText),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

  static Future<void> showMessage(
    BuildContext context, {
    String title,
    Widget content,
  }) async =>
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: <Widget>[
            OutlineButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  static Future<void> showMessageAfterPayment(
    BuildContext context, {
    String title,
    Widget content,
  }) async =>
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: <Widget>[
            OutlineButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  CustomRouter.dashboardRoute,
                  ModalRoute.withName(Navigator.defaultRouteName),
                  arguments: globals.currentLoginCustomer),
            ),
          ],
        ),
      );

  static Future<String> resetDialog(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController _email = TextEditingController();
        final _formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text('Reset Password'),
          content: Container(
              height: MediaQuery.of(context).size.height * 0.18,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        'Please enter the email that your account was setup with'),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _email,
                        autofocus: true,
                        style: TextStyle(color: Colors.blue),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email \*',
                          hintText: "e.g abc@gmail.com",
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(color: Colors.grey)),
                        ),
                        validator: (email) => EmailValidator.validate(email)
                            ? null
                            : "Invalid email address",
                        textInputAction: TextInputAction.done,
                        onSaved: (email) => _email.text = email,
                      ),
                    )
                  ])),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            OutlinedButton(
              child: Text('Request'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.pop(context, _email.text);
                }
              },
            ),
          ],
        );
      });

  static void showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (context) => OrderDetailsDialog(order: order),
        ),
      ),
    );
  }

  // static Future<String> uploadContactDialog(
  //         BuildContext context, String id) async =>
  //     showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           TextEditingController _contactNo = TextEditingController();
  //           TextEditingController _dialCode = TextEditingController();
  //           final _formKey = GlobalKey<FormState>();
  //           return AlertDialog(
  //             title: Text('Contact Detail'),
  //             content: Container(
  //               height: MediaQuery.of(context).size.height * 0.18,
  //               child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     Text(
  //                         'Please enter your contact detail to ensure your rent experience'),
  //                     Form(
  //                       key: _formKey,
  //                       child: Row(children: [
  //                         Expanded(
  //                           flex: 1,
  //                           child: makeSmallDropDownBar(
  //                               selectedSite: DropDownItem.objDialCode,
  //                               list: DropDownItem.listDialCode,
  //                               callBack: (DropDownItem value) {
  //                                 DropDownItem.objDialCode = value;
  //                                 _dialCode.text =
  //                                     DropDownItem.objDialCode.name;
  //                               }),
  //                         ),
  //                         Expanded(
  //                           flex: 2,
  //                           child: TextFormField(
  //                             controller: _contactNo,
  //                             autofocus: true,
  //                             style: TextStyle(color: Colors.blue),
  //                             keyboardType: TextInputType.emailAddress,
  //                             decoration: InputDecoration(
  //                               labelText: 'Contact \*',
  //                               hintText: "1234XXXX",
  //                             ),
  //                             validator: (mobileNum) {
  //                               if (checkPhoneNumberValidation(mobileNum)) {
  //                                 return null;
  //                               } else {
  //                                 return 'Invalid phone number';
  //                               }
  //                             },
  //                             textInputAction: TextInputAction.done,
  //                             onSaved: (contactNo) =>
  //                                 _contactNo.text = contactNo,
  //                           ),
  //                         )
  //                       ]),
  //                     )
  //                   ]),
  //             ),
  //             actions: <Widget>[
  //               OutlinedButton(
  //                 child: Text('Ok'),
  //                 onPressed: () async {
  //                   if (_formKey.currentState.validate()) {
  //                     _formKey.currentState.save();
  //                     if (id.isNotEmpty && _contactNo.text != '') {
  //                       final responseMessage = await Navigator.pushNamed(
  //                           context, CustomRouter.otpRoute,
  //                           arguments: _dialCode.text + _contactNo.text);
  //                       if (responseMessage) {
  //                         await FirestoreService.setCustomerField(id).update({
  //                           'contact': _contactNo.text,
  //                         }).then((value) {
  //                           return value.id;
  //                         }).catchError(
  //                             (error) => print("Failed to add user: $error"));
  //                         Navigator.pop(context);
  //                       }
  //                     }
  //                   }
  //                 },
  //               ),
  //             ],
  //           );
  //         });
}
