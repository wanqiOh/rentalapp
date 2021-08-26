part of 'machine_item.dart';

MachineItem _$MachineItemFromJson(Map<String, dynamic> json) {
  return MachineItem(
      id: json['id'] as String,
      merchant: CompanyItem.fromJson(json['merchant']),
      image: json['image'] as String,
      machineName: json['machineName'] as String,
      machineCategory: json['machineCategory'] as String,
      price: PriceDetail.fromJson(json['price']),
      quantity: json['quantity'] as int,
      machineDetail: MachineDetail.fromJson(json['machineDetail']));
}

Map<String, dynamic> _$MachineItemToJson(MachineItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchant': instance.merchant.toJson(),
      'image': instance.image,
      'machineName': instance.machineName,
      'machineCategory': instance.machineCategory,
      'price': instance.price.toJson(),
      'quantity': instance.quantity,
      'machineDetail': instance.machineDetail.toJson(),
    };
