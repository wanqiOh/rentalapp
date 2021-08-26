part of 'company_item.dart';

CompanyItem _$CompanyItemFromJson(Map<String, dynamic> json) {
  return CompanyItem(
    id: json['id'] as String,
    notifId: json['notifId'] as String,
    logo: json['logo'] as String,
    companyName: json['name'] as String,
    location: Locations.fromJson(json['location']),
    address: Address.fromJson(json['address']),
    description: json['description'] as String,
    orderNum: json['orderNum'] as int,
    director: json['director'] as String,
    phoneNo: json['phoneNo'] as String,
    website: json['website'] as String,
    position: Position(
        latitude: json['position']['latitude'],
        longitude: json['position']['longitude']),
  );
}

Map<String, dynamic> _$CompanyItemToJson(CompanyItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notifId': instance.notifId,
      'logo': instance.logo,
      'name': instance.companyName,
      'location': instance.location.toJson(),
      'address': instance.address.toJson(),
      'description': instance.description,
      'orderNum': instance.orderNum,
      'director': instance.director,
      'phoneNo': instance.phoneNo,
      'website': instance.website,
      'position': instance.position.toJson()
    };
