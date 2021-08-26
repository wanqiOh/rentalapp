import 'dart:math' as math;
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/order.dart';

extension HexString on String {
  Color toHexColor() {
    final buffer = StringBuffer();
    if (this.length == 6 || this.length == 7) buffer.write('ff');
    buffer.write(this.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension IntStr on num {
  String valueToStr() {
    var formatter = NumberFormat('###,###,###,###,###,###,000.00');
    return 'RM ' + formatter.format(this);
  }
}

bool checkPhoneNumberValidation(String mobileNum) {
  if ((mobileNum.isNotEmpty && mobileNum.length >= 9)) {
    return true;
  } else {
    return false;
  }
}

Future<void> getUrl() async {
  final imageUrl = await FirebaseStorage.instance
      .ref()
      .child("images/30T.png")
      .getDownloadURL();
  print('test : $imageUrl');
}

void hideKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus.unfocus();
  }
}

generateTitle(String title) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: AutoSizeText(
      title,
      style: TextStyle(color: Colors.grey, fontSize: 25),
    ),
  );
}

backwardButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}

backwardButtonForInbox(BuildContext context, Order orderDetails) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.white,
          ),
          onPressed: () async {
            final success = await FirestoreService.getOrders()
                .doc(orderDetails.id)
                .update({'notifCus.clicked': orderDetails.clicked}).then(
                    (value) {
              return true;
            }).catchError((error) => print("Failed to add user: $error"));
            if (success) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    ),
  );
}

getCurrentLocation(BuildContext context, String id) async {
  Position _currentPosition;
  // if (!(await Geolocator.isLocationServiceEnabled())) {
  //   Navigator.pushNamed(context, CustomRouter.gpsRoute, arguments: id);
  // }

  _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best)
      .then((Position position) async {
    return position;
  }).catchError((e) {
    print(e);
    Navigator.pushNamed(context, CustomRouter.gpsRoute, arguments: id);
  });

  if (id != null && _currentPosition != null) {
    print(_currentPosition.latitude);
    await FirestoreService.setCustomerField(id).update({
      'position': {
        'longitude': _currentPosition.longitude,
        'latitude': _currentPosition.latitude
      },
    }).catchError((error) => print("Failed to add field: $error"));
  }
}

getAddressFromLatLng(BuildContext context, Position _currentPosition) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude);

    Placemark place = placemarks[0];
    return place;
  } catch (e) {
    print(e);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

checkMachineImage(String id) {
  switch (id) {
    case 'scissor_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fscissor_lift.png?alt=media&token=eea35166-3d4a-4dc4-968a-222bcd8b1ad2';
      break;
    case 'spider_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fspider_lift.png?alt=media&token=3dd4fe4a-d887-4ce1-a35e-110c288e0a33';
      break;
    case 'aerial_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Faerial_lift.png?alt=media&token=89b3fa9d-b76d-4081-8595-723cbed446cd';
      break;
    case 'crawler_crane':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fcrawler_crane.png?alt=media&token=0d0956c8-c3b4-4ebe-8d1f-7f09ad986ba2';
      break;
    case 'boom_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fboom_lift.png?alt=media&token=5edec986-32c4-429b-9949-49786a45be64';
      break;
    case 'fork_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Ffork_lift.png?alt=media&token=a7c6f209-91ce-44d4-96c3-60dec7829d4d';
      break;
    case 'sky_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Ftower_lift.png?alt=media&token=7430c832-0ed8-477f-9918-2a6afc1ebbd0';
      break;
    case 'beach_lift':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fbeach_lift.png?alt=media&token=1c60c625-2e1d-496a-890e-af2cb1c5c75a';
      break;
    case 'add_machine':
      return 'https://firebasestorage.googleapis.com/v0/b/rentalapp-fa5bd.appspot.com/o/images%2Fadd_icon.png?alt=media&token=63e43566-4b0e-4723-81ec-8d5a030b38b0';
      break;
  }
}

snackBar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}

formatPrice(double price) => '\RM ${price.toStringAsFixed(2)}';
formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

void fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
