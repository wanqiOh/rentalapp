import 'package:flutter/material.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/base_helper/ui/drop_down.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/drop_down_item.dart';

class UploadContactPage extends StatefulWidget {
  String id;
  UploadContactPage({this.id});

  @override
  _UploadContactPageState createState() => _UploadContactPageState();
}

class _UploadContactPageState extends State<UploadContactPage> {
  TextEditingController _contactNo = TextEditingController();
  TextEditingController _dialCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dialCode.text = DropDownItem.objDialCode.name;
  }

  @override
  void dispose() {
    super.dispose();
    _dialCode.dispose();
    _contactNo.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: AlertDialog(
            title: Text('Contact Detail'),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.18,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        'Please enter your contact detail to ensure your rent experience'),
                    Form(
                      key: _formKey,
                      child: Row(children: [
                        Expanded(
                          flex: 1,
                          child: makeSmallDropDownBar(
                              selectedSite: DropDownItem.objDialCode,
                              list: DropDownItem.listDialCode,
                              callBack: (DropDownItem value) {
                                DropDownItem.objDialCode = value;
                                _dialCode.text = value.name;
                                setState(() {});
                              }),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _contactNo,
                            autofocus: true,
                            style: TextStyle(color: Colors.blue),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Contact \*',
                              hintText: "1234XXXX",
                            ),
                            validator: (mobileNum) {
                              if (checkPhoneNumberValidation(mobileNum)) {
                                return null;
                              } else {
                                return 'Invalid phone number';
                              }
                            },
                            textInputAction: TextInputAction.done,
                            onSaved: (contactNo) => _contactNo.text = contactNo,
                          ),
                        )
                      ]),
                    )
                  ]),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: Text('Ok'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    if (widget.id.isNotEmpty && _contactNo.text != '') {
                      final responseMessage = await Navigator.pushNamed(
                          context, CustomRouter.otpRoute,
                          arguments: _dialCode.text + _contactNo.text);
                      if (responseMessage) {
                        await FirestoreService.setCustomerField(widget.id)
                            .update({
                          'contact': _contactNo.text,
                        }).then((value) {
                          return value.id;
                        }).catchError(
                                (error) => print("Failed to add user: $error"));
                        Navigator.pop(context);
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
}
