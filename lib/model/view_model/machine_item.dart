import 'package:json_annotation/json_annotation.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/machine_detail.dart';
import 'package:rentalapp/model/view_model/price_detail.dart';

part 'machine_item.g.dart';

@JsonSerializable(nullable: true)
class MachineItem {
  String id;
  CompanyItem merchant;
  String image;
  String machineName;
  String machineCategory;
  PriceDetail price;
  int quantity;
  int index;
  MachineDetail machineDetail;
  bool enable;

  MachineItem(
      {this.id,
      this.merchant,
      this.image,
      this.machineName,
      this.machineCategory,
      this.quantity,
      this.price,
      this.machineDetail,
      this.enable});

  Map<String, dynamic> toJson() => _$MachineItemToJson(this);
  factory MachineItem.fromJson(Map<String, dynamic> json) =>
      _$MachineItemFromJson(json);

  @override
  List<Object> get props => [
        id,
        merchant,
        image,
        machineName,
        machineCategory,
        price,
        quantity,
        machineDetail,
        enable
      ];
}
