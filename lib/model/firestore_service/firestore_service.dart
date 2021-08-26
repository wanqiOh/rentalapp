import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static getDeviceId() {
    return FirebaseFirestore.instance.collection('device_ids');
  }

  static getMerchants() {
    return FirebaseFirestore.instance
        .collection('device_ids')
        .where('role', isEqualTo: 'Merchant')
        .where('firstTime', isEqualTo: false);
  }

  static getAdmins() {
    return FirebaseFirestore.instance
        .collection('device_ids')
        .where('role', isEqualTo: 'Admin');
  }

  static getUsers() {
    return FirebaseFirestore.instance.collection('customers');
  }

  static filterUsers(String focusField, String requirement) {
    return FirebaseFirestore.instance
        .collection('customers')
        .where(focusField, isEqualTo: requirement);
  }

  static setCustomerField(String id) {
    return FirebaseFirestore.instance.collection('customers').doc(id);
  }

  static filterMachines(String focusField, String requirement) {
    return FirebaseFirestore.instance
        .collection('rental_machines')
        .where(focusField, isEqualTo: requirement);
  }

  static getMachines() {
    return FirebaseFirestore.instance.collection('rental_machines');
  }

  static getOrders() {
    return FirebaseFirestore.instance.collection('orders');
  }

  static filterOrders(String field, String requirement) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where(field, isEqualTo: requirement);
  }

  static filterOrdersFor2Req(
      String field1, String requirement1, String field2, String requirement2) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where(field1, isEqualTo: requirement1)
        .where(field2, isEqualTo: requirement2);
  }

  static filterOrdersForPendingOrder(
      String field1, String requirement1, String field2, String requirement2) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where(field1, isEqualTo: requirement1)
        .where(field2, isNotEqualTo: requirement2);
  }

  static getInvoice() {
    return FirebaseFirestore.instance.collection('invoices');
  }

  static filterInvoice(String field, String requirement) {
    return FirebaseFirestore.instance
        .collection('invoices')
        .where(field, isEqualTo: requirement);
  }
}
