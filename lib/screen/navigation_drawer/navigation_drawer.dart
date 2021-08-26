import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rentalapp/base_helper/auth_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;

class NavigationDrawer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CustomDrawerHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: makeDrawerItemList(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('Version 1.0'),
          )
        ],
      ),
    );
  }

  Widget makeDrawerItemList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context,
                CustomRouter.dashboardRoute,
                ModalRoute.withName(Navigator.defaultRouteName),
                arguments: globals.currentLoginCustomer);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: const Text('History'),
          onTap: () {
            Navigator.pushNamed(context, CustomRouter.historyRoute);
          },
        ),
        ListTile(
          leading: const Icon(Icons.login_outlined),
          title: const Text('Logout'),
          onTap: () async {
            final ans = await Dialogs.showConfirmationForLogout(
                context, 'Logout',
                content: 'Do you want to logout?', okText: 'Yes');
            ans ? signOut(context) : null;
          },
        ),
      ],
    );
  }

  signOut(BuildContext context) {
    Authentication.signOut();
    Navigator.pushNamedAndRemoveUntil(context, CustomRouter.splashRoute,
        ModalRoute.withName(Navigator.defaultRouteName));
  }
}

// class LoginStaffDetails extends StatelessWidget {
//   const LoginStaffDetails({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final User staff =
//         Provider.of<StaffState>(context, listen: false).currentLoginStaff;
//     final PosSettingsState posSettingsState =
//         Provider.of<PosSettingsState>(context, listen: false);
//
//     final String role =
//         staff?.role?.toString()?.split('.')?.last?.toString() ?? '';
//     final String pos = 'POS ' + posSettingsState.posSettings.posId;
//     final String merchantName = posSettingsState.posSettings.merchant.name;
//     final String name = staff?.name ?? '';
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           child: Text(name + ' (' + role + ')',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               )),
//         ),
//         Text(pos, style: const TextStyle(color: Colors.white)),
//         Text(merchantName, style: const TextStyle(color: Colors.white)),
//       ],
//     );
//   }
// }

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints.expand(
          width: double.infinity,
          height: 130.0,
        ),
        child: DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.orangeAccent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          globals.currentLoginCustomer.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Text(
                          'Customer',
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 15),
                        ),
                      ])),
              // Expanded(
              //   child: TextButton(
              //     onPressed: () {},
              //     child: Text(
              //       'See your profile',
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 8,
              //           decoration: TextDecoration.underline),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
}
