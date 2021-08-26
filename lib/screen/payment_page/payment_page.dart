import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/base_helper/ui/drop_down.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/drop_down_item.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController referNoController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode contactFocusNode = FocusNode();
  FocusNode titleFocusNode = FocusNode();
  FocusNode referNoFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String _fileUrl, fileName;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    titleController.dispose();
    referNoController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    contactFocusNode.dispose();
    titleFocusNode.dispose();
    referNoFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('Calculate: ${globals.tmpOrder.getPriceRate().toString()}');
    nameController.text = globals.tmpOrder.customer.name;
    emailController.text = globals.tmpOrder.customer.email;
    contactController.text = globals.tmpOrder.customer.phoneNo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: backwardButton(context),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: generateTitle('PAYMENT')),
              makeTextForm(context),
              displayOrderDetails(context),
              makePaymentForm(context),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      print('Customer: ${globals.tmpOrder.customer.toJson()}');

                      bool updateQuantity = await FirestoreService.getMachines()
                          .doc(globals.tmpOrder.machineItem.id)
                          .update({
                        'quantity': globals.tmpOrder.getUpdateQnt(),
                      }).then((value) {
                        return true;
                      }).catchError(
                              (error) => print("Failed to add field: $error"));

                      bool updateCustomer = await FirestoreService.getUsers()
                          .doc(globals.tmpOrder.customer.id)
                          .update({
                        'name': nameController.text,
                        'email': emailController.text,
                        'title': titleController.text,
                        'phoneNo': contactController.text,
                        'position': {
                          'latitude': globals.tmpOrder.pinPosition.latitude,
                          'longitude': globals.tmpOrder.pinPosition.longitude
                        }
                      }).then((value) {
                        return true;
                      }).catchError(
                              (error) => print("Failed to add field: $error"));

                      if (updateQuantity && updateCustomer) {
                        String id = await FirestoreService.getOrders().add({
                          'title': titleController.text,
                          'customer': globals.tmpOrder.customer.toJson(),
                          'merchant': globals.tmpOrder.merchant.toJson(),
                          'payment': {
                            'referNo': referNoController.text,
                            'fileUrl': _fileUrl,
                            'paid':
                                ((globals.tmpOrder.getTotalRentCharge() * 1000)
                                        .ceil()) /
                                    1000,
                          },
                          'machine': globals.tmpOrder.machineItem.toJson(),
                          'date': {
                            'startDate': globals.tmpOrder.startDate,
                            'endDate': globals.tmpOrder.endDate,
                            'createdDate': DateTime.now()
                          },
                          'address': globals.tmpOrder.address.toJson(),
                          'distance':
                              double.parse(globals.tmpOrder.totalDistance),
                          'orderQuantity': globals.tmpOrder.orderQuantity,
                          'profit': globals.tmpOrder.getProfit(),
                          'reply': 'PROGRESS'
                        }).then((value) {
                          return value.id;
                        }).catchError(
                            (error) => print("Failed to add field: $error"));

                        List adminNotifID = [];
                        await FirestoreService.getAdmins()
                            .get()
                            .then((value) {
                          value.docs.map((element) {
                            print(element.get('notifId'));
                            adminNotifID.add(element.get('notifId'));
                          }).toList();
                        });

                        if (id != null && adminNotifID != null) {
                          //TODO: Push Notification Feature
                          for(var element in adminNotifID) {
                            await OneSignal.shared.postNotification(
                              OSCreateNotification(
                                playerIds: [element],
                                content:
                                    "One payment was submtted and need to verify now!!!",
                                heading: "Payment Verification",
                              ),
                            );
                          }
                          Dialogs.showMessageAfterPayment(context,
                              title: 'Order Saved',
                              content: Text(
                                  'Once payment is verifying by admin, you will received the invoice through your email.\n\nThe details of the order can be review in History...'));
                          globals.orderId = id;

                          //   await FirestoreService.getOrders()
                          //       .get()
                          //       .then((element) {
                          //     setState(() {
                          //       invoiceNum = element.docs.length.toString();
                          //     });
                          //   });
                          //
                          //   final date = DateTime.now();
                          //   final dueDate = date.add(Duration(days: 7));
                          //
                          //   // initial invoice
                          //   final invoice = Invoice(
                          //     supplier: CompanyItem.invoice(
                          //       companyName: globals
                          //           .tmpOrder.machineItem.merchant.companyName,
                          //       address:
                          //           globals.tmpOrder.machineItem.merchant.address,
                          //       phoneNo:
                          //           globals.tmpOrder.machineItem.merchant.phoneNo,
                          //     ),
                          //     customer: Customer.invoice(
                          //       name:
                          //           '${titleController.text} ${globals.tmpOrder.customer.name}',
                          //       address: globals.tmpOrder.address,
                          //     ),
                          //     info: InvoiceInfo(
                          //       date: date,
                          //       dueDate: dueDate,
                          //       description:
                          //           'Thank you for using and supporting our service',
                          //       number:
                          //           '${DateFormat('yyyyMMdd').format(DateTime.now())}-${invoiceNum.padLeft(6, '0')}',
                          //     ),
                          //     items: [globals.tmpOrder.machineItem],
                          //   );
                          //
                          //   // Generate pdf invoice
                          //   final pdfFile =
                          //       await PdfInvoiceRepository.generate(invoice);
                          //   print(pdfFile);
                          //   String url =
                          //       await PdfRepository.uploadInvoice(pdfFile);
                          //   String invoiceId = await FirestoreService.getInvoice()
                          //       .add({
                          //     'id':
                          //         '${DateFormat('yyyyMMdd').format(DateTime.now())}-${invoiceNum.padLeft(6, '0')}',
                          //     'url': url,
                          //     'pdf': pdfFile.path.toString(),
                          //     'orderID': id,
                          //   }).then((value) {
                          //     return value.id;
                          //   }).catchError((error) =>
                          //           print("Failed to add field: $error"));
                          //
                          //   //Send email
                          //   final smtpServer = gmail(
                          //       'pinanclezenith@gmail.com', 'thisisComp_Email');
                          //
                          //   final message = Message()
                          //     ..from = Address('wanqi.oh@gmail.com', 'Rentalapp')
                          //     ..recipients.add(globals.tmpOrder.customer.email)
                          //     ..subject =
                          //         'Rentalapp Invoice - ${DateFormat('yyyyMMdd').format(DateTime.now())}-${invoiceNum.padLeft(6, '0')}'
                          //     ..html = '<img src = https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/email%2FheaderImage.PNG?alt=media&token=d5bbed07-9ff1-4530-8389-184188ab1b1b, alt = rentalapp><br><br>'
                          //         '<h1>Thank you for supporting and using our service</h1><br>'
                          //         '<p>We appreciate your continous support towards rentalapp, the cashless machinery renting experience</p><br><br>'
                          //         '<p>Your invoice is ready!</p>'
                          //         '<p>Click <a href = ${url}>here</a> to view your invoice</p><br><br>'
                          //         '<img src = https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/email%2FbottomImage.PNG?alt=media&token=f766e653-0fd4-4e6d-980f-4aeaaae75024, alt = rentalapp>';
                          //
                          //   try {
                          //     final sendReport = await send(message, smtpServer);
                          //     print('Message sent: ' + sendReport.toString());
                          //   } on MailerException catch (e) {
                          //     print('Message not sent.');
                          //     for (var p in e.problems) {
                          //       print('Problem: ${p.code}: ${p.msg}');
                          //     }
                          //   }
                          //
                          //   if (invoiceId != null) {
                          //     Dialogs.showMessageAfterPayment(context,
                          //         title: 'Order Placed',
                          //         content: Text(
                          //             'Once the merchant accept the order, you will receive the notification.\n\nThe invoice already sent to registered email.\n\nThe more details of order can be refer from history...'));
                          //   }
                          // }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow,
                    minimumSize:
                        Size(MediaQuery.of(context).size.width / 2, 50.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.grey),
                  )),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  makeTextForm(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height >= 400
          ? MediaQuery.of(context).size.height * 0.4
          : MediaQuery.of(context).size.height * 0.9,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(children: [
              Text('\*', style: TextStyle(color: Colors.red)),
              Text('Title'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 44.0),
                  child: makeFullDropDownBar(
                      selectedSite: DropDownItem.objTitle,
                      list: DropDownItem.listTitle,
                      callBack: (DropDownItem value) {
                        DropDownItem.objTitle = value;
                        titleController.text = value.name;
                        setState(() {});
                      }),
                ),
              ),
            ]),
            Row(
              children: [
                Text('\*', style: TextStyle(color: Colors.red)),
                Text('Name'),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: TextFormField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.singleLineFormatter
                        ],
                        onSaved: (name) => nameController.text =
                            name, // Only numbers can be entered
                        onFieldSubmitted: (_) {
                          fieldFocusChange(
                              context, nameFocusNode, emailFocusNode);
                        },
                      )),
                ),
              ],
            ),
            Row(
              children: [
                Text('\*', style: TextStyle(color: Colors.red)),
                Text('Email'),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        focusNode: emailFocusNode,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.singleLineFormatter
                        ],
                        validator: (email) => EmailValidator.validate(email)
                            ? null
                            : "Invalid email address",
                        onSaved: (email) => emailController.text =
                            email, // Only numbers can be entered
                        onFieldSubmitted: (_) {
                          fieldFocusChange(
                              context, emailFocusNode, contactFocusNode);
                        },
                      )),
                ),
              ],
            ),
            Row(
              children: [
                Text('\*', style: TextStyle(color: Colors.red)),
                Text('Contact Number'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: TextFormField(
                      controller: contactController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      focusNode: contactFocusNode,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.singleLineFormatter
                      ], // Only numbers can be entered
                      onSaved: (contact) => contactController.text = contact,
                      onFieldSubmitted: (_) {
                        fieldFocusChange(context, contactFocusNode, null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  displayOrderDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          generateTitle('Order Details'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(children: [
              Row(children: [
                Text('Renting Date',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      globals.tmpOrder.getDate(),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Days',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${globals.tmpOrder.getDifference()} days',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Machine',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      globals.tmpOrder.machineItem.machineCategory,
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Machine Model',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      globals.tmpOrder.machineItem.machineName,
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      globals.tmpOrder.orderQuantity.toString(),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Renting Price',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getRentingPrice()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Delivery Distance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${globals.tmpOrder.totalDistance} km',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Delivery Charge',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${formatPrice(globals.tmpOrder.machineItem.price.deliveryCharge)} per km',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Delivery Charge',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getDeliveryCharge()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Renting Price',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getTotalRentingPrice()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Tax Charge',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getTaxCharge()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Text('Total Renting Charge',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getTotalRentCharge()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
              // if (globals.tmpOrder.paymentType == 'DEPOSIT PAYMENT')
              //   Row(children: [
              //     Text('Fixed Deposit Paid',
              //         style: TextStyle(fontWeight: FontWeight.bold)),
              //     Expanded(
              //       child: Align(
              //         alignment: Alignment.centerRight,
              //         child: Text(
              //           formatPrice(double.parse(widget.deposit)),
              //           style: TextStyle(
              //               color: Colors.grey, fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ),
              //   ]),
              // if (globals.tmpOrder.paymentType == 'DEPOSIT PAYMENT')
              //   SizedBox(height: 10),
              // if (globals.tmpOrder.paymentType == 'DEPOSIT PAYMENT')
              //   Row(children: [
              //     Text('Balance Price',
              //         style: TextStyle(fontWeight: FontWeight.bold)),
              //     Expanded(
              //       child: Align(
              //         alignment: Alignment.centerRight,
              //         child: Text(
              //           formatPrice((globals.tmpOrder.getTotalRentCharge() -
              //               double.parse(widget.deposit))),
              //           style: TextStyle(
              //               color: Colors.grey, fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ),
              //   ]),
              // if (globals.tmpOrder.paymentType == 'FULL PAYMENT')
              Row(children: [
                Text('Amount Paid',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPrice(globals.tmpOrder.getTotalRentCharge()),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  makePaymentForm(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text('\*', style: TextStyle(color: Colors.red)),
                Text('Transaction Statement'),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                child: Text('Choose File'),
                onPressed: () {
                  uploadFile();
                },
              ),
              Text(
                  fileName != null && fileName != ''
                      ? fileName.split('/').last
                      : 'No file choose',
                  style: TextStyle(color: Colors.grey)),
            ]),
            Row(children: [
              Text('Allowed file type: ', style: TextStyle(color: Colors.grey)),
              Text('gif, jpg, jpeg, png, pdf, doc',
                  style: TextStyle(color: Colors.black))
            ]),
            SizedBox(height: 10),
            Row(
              children: [
                Text('\*', style: TextStyle(color: Colors.red)),
                Text('Reference Number'),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextFormField(
                controller: referNoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                focusNode: referNoFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onSaved: (referNo) => referNoController.text =
                    referNo, // Only numbers can be entered
                onFieldSubmitted: (_) {
                  fieldFocusChange(context, referNoFocusNode, null);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadFile() async {
    final _firebaseStorage = FirebaseStorage.instance;
    //Check Permissions
    await Permission.storage.request();

    var permissionStatus = await Permission.storage.status;

    if (permissionStatus.isGranted) {
      //Select Image
      FilePickerResult file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['gif', 'jpeg', 'jpg', 'png', 'pdf', 'doc'],
      );

      if (file != null) {
        setState(() {
          fileName = file.files.single.path;
        });
        //Upload to Firebase
        Reference storageReference = _firebaseStorage
            .ref()
            .child('statement/${Path.basename(fileName)}}');
        UploadTask uploadTask = storageReference.putFile(File(fileName));
        await uploadTask.whenComplete(() {
          print('File Uploaded');
        });
        storageReference.getDownloadURL().then((fileURL) {
          setState(() {
            _fileUrl = fileURL;
          });
        });
      } else {
        print('No File Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  bool checkClickedStatus(int clicked) {
    if (clicked == 1)
      return true;
    else
      return false;
  }
}
