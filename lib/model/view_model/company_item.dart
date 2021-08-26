import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rentalapp/model/view_model/address.dart';
import 'package:rentalapp/model/view_model/locations.dart';

part 'company_item.g.dart';

@JsonSerializable(nullable: true)
class CompanyItem {
  String id;
  String notifId;
  String logo;
  String companyName;
  Locations location;
  Address address;
  String description;
  int orderNum;
  int index;
  String director;
  String phoneNo;
  String website;
  Position position;
  String distance;
  // List<MachineItem> machine;

  CompanyItem(
      {this.id,
      this.notifId,
      this.logo,
      this.companyName,
      this.location,
      this.description,
      this.orderNum,
      this.index,
      this.director,
      this.phoneNo,
      this.website,
      this.address,
      this.position,
      this.distance});

  CompanyItem.invoice({this.companyName, this.address, this.phoneNo});

  Map<String, dynamic> toJson() => _$CompanyItemToJson(this);
  factory CompanyItem.fromJson(Map<String, dynamic> json) =>
      _$CompanyItemFromJson(json);

  @override
  List<Object> get props => [
        id,
        notifId,
        logo,
        companyName,
        location,
        description,
        orderNum,
        index,
        director,
        phoneNo,
        website,
        address,
        position,
        distance,
      ];
}
