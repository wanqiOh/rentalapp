import 'package:flutter/cupertino.dart';
import 'package:rentalapp/model/view_model/customer.dart';

class CustomerState with ChangeNotifier {
  Customer currentLoginCustomer;

  CustomerState() {}

  void setCurrentLoginUser(Customer customer) {
    currentLoginCustomer = customer;
    notifyListeners();
  }
}
