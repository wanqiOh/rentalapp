library rentalapp.globals;

import 'dart:core';

import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/customer.dart';
import 'package:rentalapp/model/view_model/notification_item.dart';
import 'package:rentalapp/model/view_model/order.dart';

Customer currentLoginCustomer;

List<CompanyItem> companys;

String id;

List<NotificationsItem> notifications = [];

Order tmpOrder;

String orderId;

String deposit;

double dailyRate = 0.7;
double weeklyRate = 0.5;
double halfMonthlyRate = 0.3;
double monthlyRate = 0.1;

double tax = 0.06;
