import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/constants/image_path.dart';

class GPSPage extends HookWidget {
  String id;
  GPSPage({this.id});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  makeTitle(),
                  makeBodyText(),
                  makeIconSection(),
                  makeAllowButton(useContext()),
                ],
              )),
        ),
      ),
    );
  }

  makeTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: AutoSizeText(
        'Location Access Is Important',
        style: TextStyle(color: Colors.grey, fontSize: 35),
      ),
    );
  }

  makeBodyText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: AutoSizeText(
        'Ride pick-off and other services will be faster and more accurate. We can also better ensure your rent experience.',
        style: TextStyle(color: Colors.grey, fontSize: 20),
      ),
    );
  }

  makeIconSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
          alignment: FractionalOffset.center,
          child: Image.asset(
            bgGPS,
            scale: 0.5,
          )),
    );
  }

  makeAllowButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: ElevatedButton(
            onPressed: () async {
              getCurrentLocation(context, id);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade50),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.grey, width: 2)))),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Allow Location Address',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ))),
      ),
    );
  }
}
