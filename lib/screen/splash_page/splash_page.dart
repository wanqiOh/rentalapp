import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/constants/image_path.dart';
import 'package:rentalapp/custom_router.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // bool isLoggedIn = false;
  // String name, pass = '';
  // Customer customer;
  @override
  void initState() {
    super.initState();
    // init();
    // if (name != null && pass != null) {
    //   autoLogIn();
    // }

    Future.delayed(const Duration(seconds: 1), () {
      // isLoggedIn
      //     ? Navigator.pushNamedAndRemoveUntil(
      //         context,
      //         CustomRouter.dashboardRoute,
      //         ModalRoute.withName(Navigator.defaultRouteName),
      //         arguments: customer,
      //       )
      //     :
      Navigator.pushReplacementNamed(context, CustomRouter.welcomeRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: AppTheme.white,
          image: DecorationImage(
            image: AssetImage(bgSplash),
            fit: BoxFit.contain,
          )),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: AppTheme.white.withOpacity(0.7),
              child: Image.asset(
                icLogo,
                scale: 0.65,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void autoLogIn() async {
  //   Map<String, dynamic> data;
  //
  //   await FirestoreService.filterUsers('email', name).get().then((value) async {
  //     value.docs.map((element) {
  //       data = element.data();
  //       print('data: ${data}');
  //       if (!(data.containsKey('position'))) {
  //         getCurrentLocation(context, element.reference.id);
  //       } else {
  //         return;
  //       }
  //
  //       customer = Customer(
  //         id: element.reference.id,
  //         notifId: element.get('notifId'),
  //         name: element.get('name'),
  //         email: element.get('email'),
  //         phoneNo: element.get('contact'),
  //         position: Position(
  //             latitude: value.get('position')['latitude'],
  //             longitude: value.get('position')['longitude']),
  //       );
  //
  //       print('Customer: ${customer.position.latitude}');
  //     }).toList();
  //   });
  //
  //   setState(() {
  //     isLoggedIn = true;
  //   });
  // }
  //
  // void init() async {
  //   final email = await UserSecureStorage.getUsername() ?? '';
  //   final password = await UserSecureStorage.getPassword() ?? [];
  //
  //   if (email != null && password != null) {
  //     setState(() {
  //       name = email;
  //       pass = password;
  //       print('Username: ${name}');
  //       print('Password: ${pass}');
  //     });
  //   }
  // }
}
