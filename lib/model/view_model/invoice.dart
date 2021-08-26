import 'package:flutter/material.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/customer.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';

class Invoice {
  final InvoiceInfo info;
  final CompanyItem supplier;
  final Customer customer;
  final List<MachineItem> items;

  const Invoice({
    @required this.info,
    @required this.supplier,
    @required this.customer,
    @required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    @required this.description,
    @required this.number,
    @required this.date,
    @required this.dueDate,
  });
}
