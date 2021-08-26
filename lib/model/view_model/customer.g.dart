part of 'customer.dart';

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
      id: json['id'] as String,
      notifId: json['notifId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNo: json['phoneNo'] as String,
      position: Position.fromMap(json['position']));
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'notifId': instance.notifId,
      'email': instance.email,
      'name': instance.name,
      'phoneNo': instance.phoneNo,
      'position': instance.position.toJson()
    };
