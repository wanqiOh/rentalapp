import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/base_helper/ui/drop_down.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/view_model/address.dart';
import 'package:rentalapp/model/view_model/company_item.dart';
import 'package:rentalapp/model/view_model/directions_model.dart';
import 'package:rentalapp/model/view_model/drop_down_item.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';
import 'package:rentalapp/model/view_model/order.dart';
import 'package:rentalapp/repository/directions_repository.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
  MachineItem machineItem;
  OrderPage({this.machineItem});
}

class _OrderPageState extends State<OrderPage> {
  DateRangePickerController _datePickerController = DateRangePickerController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController addressController1 = TextEditingController();
  TextEditingController addressController2 = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postcodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  FocusNode quantityFocusNode = FocusNode();
  FocusNode addressFocusNode1 = FocusNode();
  FocusNode addressFocusNode2 = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode postcodeFocusNode = FocusNode();
  String startDate, endDate;
  CompanyItem merchant;
  final _formKey = GlobalKey<FormState>();

  LatLng initial;
  Set<Marker> _markers = Set<Marker>();
  // for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  // For controlling the view of the Map
  GoogleMapController mapController;
  Marker _origin, _destination;
  Directions _info;

  @override
  void dispose() {
    mapController.dispose();
    quantityController.dispose();
    addressController1.dispose();
    addressController2.dispose();
    cityController.dispose();
    postcodeController.dispose();
    stateController.dispose();
    quantityFocusNode.dispose();
    addressFocusNode1.dispose();
    addressFocusNode2.dispose();
    cityFocusNode.dispose();
    postcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initial = LatLng(globals.currentLoginCustomer.position.latitude,
        globals.currentLoginCustomer.position.longitude);

    _origin = Marker(
      markerId: const MarkerId('current location'),
      infoWindow: const InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: initial,
    );

    merchant = globals.companys.firstWhere((element) {
      print(element.id == widget.machineItem.merchant.id);
      return (element.id == widget.machineItem.merchant.id);
    }, orElse: () => null);

    print(merchant);

    _destination = Marker(
      markerId: const MarkerId('destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(merchant.position.latitude, merchant.position.longitude),
    );

    asyncInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: backwardButton(context),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin.position,
                    zoom: 15.0,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('ORIGIN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination.position,
                    zoom: 15.0,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('DEST'),
            )
        ],
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.orangeAccent,
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(16.0), child: machineInfo()),
              makeMachineDetails(context),
            ]),
          )),
    );
  }

  machineInfo() {
    return Row(children: [
      Expanded(
        flex: 2,
        child: AutoSizeText(
          widget.machineItem.machineName.toUpperCase(),
          maxLines: 2,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade400,
              fontSize: 50),
        ),
      ),
      Expanded(
        flex: 1,
        child: Image.network(widget.machineItem.image),
      ),
    ]);
  }

  makeMachineDetails(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width >= 700
          ? MediaQuery.of(context).size.height / 0.20
          : MediaQuery.of(context).size.height / 0.50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              generateTitle('RENTING\nDATE'),
              makeCalendar(context),
              generateTitle('RENTING\nQUANTITY'),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: TextFormField(
                    controller: quantityController,
                    focusNode: quantityFocusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (quantity) {
                      if ((widget.machineItem.quantity)
                              .compareTo(int.parse(quantity)) <
                          0)
                        return 'No enough machines to provide';
                      else
                        return null;
                    },
                    onSaved: (quantity) => quantityController.text =
                        quantity, // Only numbers can be entered
                    onFieldSubmitted: (_) {
                      fieldFocusChange(
                          context, quantityFocusNode, addressFocusNode1);
                    },
                  )),
              generateTitle('DELIVERY\nADDRESS'),
              makeAddressTextForm(context),
            ],
          )),
    );
  }

  makeAddressTextForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('\*', style: TextStyle(color: Colors.red)),
              Text('Address'),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      focusNode: addressFocusNode1,
                      keyboardType: TextInputType.streetAddress,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      validator: (address1) {
                        if (address1.isEmpty)
                          return 'This field cannot be empty';
                        else
                          return null;
                      },
                      onSaved: (address1) => addressController1.text =
                          address1, // Only numbers can be entered
                      onFieldSubmitted: (_) {
                        fieldFocusChange(
                            context, addressFocusNode1, addressFocusNode2);
                      },
                    )),
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 75),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              keyboardType: TextInputType.streetAddress,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.singleLineFormatter
              ],
              focusNode: addressFocusNode2,
              validator: (address2) {
                if (address2.isEmpty)
                  return 'This field cannot be empty';
                else
                  return null;
              },
              onSaved: (address2) => addressController2.text =
                  address2, // Only numbers can be entered
              onFieldSubmitted: (_) {
                fieldFocusChange(context, addressFocusNode2, cityFocusNode);
              },
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('\*', style: TextStyle(color: Colors.red)),
              Text('City'),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 45.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      keyboardType: TextInputType.streetAddress,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      focusNode: postcodeFocusNode,
                      validator: (city) {
                        if (city.isEmpty)
                          return 'This field cannot be empty';
                        else
                          return null;
                      }, // Only numbers can be entered
                      onSaved: (city) => cityController.text = city,
                      onFieldSubmitted: (_) {
                        fieldFocusChange(
                            context, cityFocusNode, postcodeFocusNode);
                      },
                    )),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('\*', style: TextStyle(color: Colors.red)),
              Text('Postcode'),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (postcode) {
                        if (postcode.isEmpty)
                          return 'This field cannot be empty';
                        else
                          return null;
                      },
                      onSaved: (postcode) => postcodeController.text =
                          postcode, // Only numbers can be entered
                      onFieldSubmitted: (_) {
                        fieldFocusChange(context, postcodeFocusNode, null);
                      },
                    )),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(children: [
            Text('\*', style: TextStyle(color: Colors.red)),
            Text('State'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 44.0),
                child: makeFullDropDownBar(
                    selectedSite: DropDownItem.objState,
                    list: DropDownItem.listState,
                    callBack: (DropDownItem value) {
                      DropDownItem.objState = value;
                      stateController.text = value.name;
                      setState(() {});
                    }),
              ),
            ),
          ]),
          SizedBox(height: 10),
          SizedBox(
            height: 400,
            width: 400,
            child: Stack(
              children: [
                GoogleMap(
                  onTap: _addMarker,
                  initialCameraPosition:
                      CameraPosition(target: initial, zoom: 15.0),
                  markers: {
                    if (_origin != null) _origin,
                    if (_destination != null) _destination
                  },
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  mapType: MapType.normal,
                  zoomControlsEnabled: true,
                  onCameraMove: ((_position) => _updatePosition(_position)),
                  onMapCreated: (controller) {
                    mapController = controller;
                    print('Map Controller: ${mapController.mapId}');
                  },
                  polylines: {
                    if (_info != null)
                      Polyline(
                        polylineId: const PolylineId('overview_polyline'),
                        color: Colors.red,
                        width: 5,
                        points: _info.polylinePoints
                            .map((e) => LatLng(e.latitude, e.longitude))
                            .toList(),
                      ),
                  },
                ),
                Positioned(
                  top: 5.0,
                  right: 5.0,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    onPressed: () => mapController.animateCamera(
                      _info != null
                          ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                          : CameraUpdate.newCameraPosition(
                              CameraPosition(target: initial, zoom: 15.0)),
                    ),
                    child: const Icon(Icons.center_focus_strong),
                  ),
                ),
                Positioned(
                  bottom: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.transparent),
                        color: Color.fromRGBO(255, 255, 255,
                            0.7) // Specifies the background color and the opacity
                        ),
                    child: Text('tap to your actual loaction'),
                  ),
                ),
                // if (_info != null)
                //   Positioned(
                //     top: 20.0,
                //     left: 10.0,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         vertical: 6.0,
                //         horizontal: 12.0,
                //       ),
                //       decoration: BoxDecoration(
                //         color: Colors.yellowAccent,
                //         borderRadius: BorderRadius.circular(20.0),
                //         boxShadow: const [
                //           BoxShadow(
                //             color: Colors.black26,
                //             offset: Offset(0, 2),
                //             blurRadius: 6.0,
                //           )
                //         ],
                //       ),
                //       child: Text(
                //         '${_info.totalDistance}, ${_info.totalDuration}',
                //         style: const TextStyle(
                //           fontSize: 18.0,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Order tmpOrder = Order(
                    customer: globals.currentLoginCustomer,
                    merchant: merchant,
                    pinPosition: Position(
                        longitude: _origin.position.longitude,
                        latitude: _origin.position.latitude),
                    address: Address(
                      address1: addressController1.text,
                      address2: addressController2.text,
                      city: cityController.text,
                      postcode: postcodeController.text,
                      state: stateController.text,
                    ),
                    startDate: DateTime.parse(startDate),
                    endDate: DateTime.parse(endDate),
                    machineItem: widget.machineItem,
                    orderQuantity: int.parse(quantityController.text),
                    totalDistance: _info.totalDistance.split(' ')[0]);
                globals.tmpOrder = tmpOrder;
                Navigator.pushNamed(context, CustomRouter.paymentRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.yellow,
              minimumSize: Size(MediaQuery.of(context).size.width / 2, 50.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: Text(
              'PAY NOW',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  makeCalendar(BuildContext context) {
    return SfDateRangePicker(
      view: DateRangePickerView.month,
      selectionMode: DateRangePickerSelectionMode.range,
      controller: _datePickerController,
      minDate: DateTime.now().add(Duration(days: 1)),
      onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
        String date = args.value.toString().substring(
            (args.value.toString().indexOf('(')) + 1,
            args.value.toString().indexOf(')'));
        List<String> dates = date.split(',');
        startDate = dates[0]
            .substring((dates[0].indexOf(':')) + 2)
            .split(' ')
            .join('T');
        if (dates[1].substring(dates[1].indexOf(':')) != null)
          endDate = dates[1]
              .substring((dates[1].indexOf(':')) + 2)
              .split(' ')
              .join('T');
        setState(() {});
      },
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    _origin = Marker(
      markerId: const MarkerId('current location'),
      infoWindow: const InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: pos,
    );
    _destination = Marker(
      markerId: const MarkerId('destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(merchant.position.latitude, merchant.position.longitude),
    );

    final directions = await DirectionsRepository().getDirections(
        origin: _origin.position, destination: _destination.position);
    setState(() => _info = directions);
  }

  void _updatePosition(CameraPosition _position) {
    print('position: ${initial}');
    if (_position.target != null) {
      initial = _position.target;
    }

    print('position: ${initial}');
    Marker marker = _markers.firstWhere(
        (p) => p.markerId == MarkerId(initial.toString()),
        orElse: () => null);

    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId(initial.toString()),
        draggable: true,
        position: LatLng(_position.target.latitude, _position.target.longitude),
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet:
              '${_position.target.latitude}, ${_position.target.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    setState(() {});
  }

  void asyncInfo() async {
    final directions = await DirectionsRepository().getDirections(
        origin: _origin.position, destination: _destination.position);
    setState(() => _info = directions);
  }
}
