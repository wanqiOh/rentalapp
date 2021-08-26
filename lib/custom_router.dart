import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/screen/category_page/category_page.dart';
import 'package:rentalapp/screen/company_detail_page/company_detail_page.dart';
import 'package:rentalapp/screen/gps_page/gps_page.dart';
import 'package:rentalapp/screen/home_page/home_page.dart';
import 'package:rentalapp/screen/login_page/login_page.dart';
import 'package:rentalapp/screen/machine_detail_page/machine_detail_page.dart';
import 'package:rentalapp/screen/notification_page/inbox_page.dart';
import 'package:rentalapp/screen/notification_page/notification_page.dart';
import 'package:rentalapp/screen/order_page/history_page.dart';
import 'package:rentalapp/screen/order_page/order_page.dart';
import 'package:rentalapp/screen/otp_page/otp_page.dart';
import 'package:rentalapp/screen/payment_page/payment_page.dart';
import 'package:rentalapp/screen/signup_page/signup_page.dart';
import 'package:rentalapp/screen/splash_page/splash_page.dart';
import 'package:rentalapp/screen/term_and_condition_page/term_and_condition_page.dart';

import 'screen/welcome_page/welcome_page.dart';

class CustomRouter {
  static const String splashRoute = '/splashScreen';
  static const String welcomeRoute = '/welcome';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String gpsRoute = '/gps';
  static const String dashboardRoute = '/dashboard';
  static const String notificationRoute = '/notification';
  static const String inboxRoute = '/inbox';
  static const String companyDetailRoute = '/companyDetail';
  static const String machineDetailRoute = '/machineDetail';
  static const String orderRoute = '/order';
  static const String paymentSelectionRoute = '/paymentSelection';
  static const String paymentRoute = '/payment';
  static const String categoryRoute = '/category';
  static const String otpRoute = '/otp';
  static const String termAndConditionRoute = '/termAndCondition';
  static const String historyRoute = '/history';

  static void backToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      CustomRouter.dashboardRoute,
      (_) => false,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case welcomeRoute:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case loginRoute:
        return MaterialPageRoute(
            builder: (_) => LoginPage(
                  docId: settings.arguments,
                ));
      case signupRoute:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case gpsRoute:
        return MaterialPageRoute(builder: (_) => GPSPage());
      case dashboardRoute:
        return MaterialPageRoute(
            builder: (_) => HomePage(customer: settings.arguments));
      case notificationRoute:
        return MaterialPageRoute(
            builder: (_) => NotificationPage(orders: settings.arguments));
      case categoryRoute:
        return MaterialPageRoute(
            builder: (_) => CategoryPage(type: settings.arguments));
      case inboxRoute:
        return MaterialPageRoute(
            builder: (_) => InboxPage(orderDetails: settings.arguments));
      case companyDetailRoute:
        return MaterialPageRoute(
            builder: (_) =>
                CompanyDetailPage(recommendCompany: settings.arguments));
      case machineDetailRoute:
        return MaterialPageRoute(
            builder: (_) => MachineDetailPage(machine: settings.arguments));
      case orderRoute:
        return MaterialPageRoute(
            builder: (_) => OrderPage(
                  machineItem: settings.arguments,
                ));
      case paymentRoute:
        return MaterialPageRoute(builder: (_) => PaymentPage());
      case otpRoute:
        return MaterialPageRoute(
            builder: (_) => OTPPage(
                  phoneNo: settings.arguments,
                ));
      case termAndConditionRoute:
        return MaterialPageRoute(builder: (_) => TermAndConditionPage());
      case historyRoute:
        return MaterialPageRoute(builder: (_) => HistoryPage());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
