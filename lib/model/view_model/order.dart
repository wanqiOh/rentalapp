import 'package:easy_localization/easy_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/view_model/address.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/customer.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';

class Order {
  String id;
  Customer customer;
  Position pinPosition;
  Address address;
  CompanyItem merchant;
  String paymentType;
  DateTime startDate;
  DateTime endDate;
  DateTime createdDate;
  MachineItem machineItem;
  String totalDistance;
  int orderQuantity;
  String orderStatus;
  String title;
  String content;
  bool clicked;
  DateTime receivedTime;
  double amountPaid;
  // double balance;
  String fileUrl;
  String reply;

  Order(
      {this.id,
      this.customer,
      this.pinPosition,
      this.address,
      this.merchant,
      this.paymentType,
      this.startDate,
      this.endDate,
      this.createdDate,
      this.machineItem,
      this.orderQuantity,
      this.totalDistance,
      this.orderStatus,
      this.title,
      this.content,
      this.clicked,
      this.receivedTime,
      this.amountPaid,
      // this.balance,
      this.fileUrl,
      this.reply});

  getDifference() {
    return (endDate.difference(startDate).inDays) + 1;
  }

  getPriceRate() {
    int days = getDifference();
    if (days < 7)
      return globals.dailyRate;
    else if (days >= 7 && days < 15)
      return globals.weeklyRate;
    else if (days >= 15 && days < 25)
      return globals.halfMonthlyRate;
    else
      return globals.monthlyRate;
  }

  getProfit() {
    double rateCharge = getPriceRate();
    return rateCharge * machineItem.price.dailyRate;
  }

  getRentingPrice() {
    double rateCharge = getPriceRate();
    return (rateCharge + 1) * machineItem.price.dailyRate;
  }

  getDeliveryCharge() {
    return double.parse(totalDistance) * machineItem.price.deliveryCharge;
  }

  getTotalRentingPrice() {
    double rentingPrice = getRentingPrice() * orderQuantity;
    double deliveryCharge = getDeliveryCharge();

    return rentingPrice + deliveryCharge;
  }

  getDate() {
    return '${DateFormat('dd/MM/yy').format(startDate)}-${DateFormat('dd/MM/yy').format(endDate)}';
  }

  getTaxCharge() {
    return globals.tax * getTotalRentingPrice();
  }

  getTotalRentCharge() {
    return getTotalRentingPrice() + getTaxCharge();
  }

  getMinDeposit() {
    return getTotalRentCharge() * 0.5;
  }

  getUpdateQnt() {
    return machineItem.quantity - orderQuantity;
  }
}
