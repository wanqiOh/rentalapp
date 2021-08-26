import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/model/view_model/machine_item.dart';

class MachineDetailPage extends HookWidget {
  MachineItem machine;
  MachineDetailPage({this.machine});
  List<String> title = [
    'Model',
    'Width',
    'Length',
    'Height',
    'Weight',
    'Working Height, Max',
    'Platform Capacity, Max',
    'Engine',
    'Quantity',
    'Remark'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: backwardButton(useContext()),
      ),
      body: Container(
          height: MediaQuery.of(useContext()).size.height,
          width: MediaQuery.of(useContext()).size.width,
          color: Colors.orangeAccent,
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(16.0), child: machineInfo()),
              makeMachineDetails(useContext()),
            ]),
          )),
    );
  }

  machineInfo() {
    return Row(children: [
      Expanded(
        flex: 2,
        child: AutoSizeText(
          machine.machineName.toUpperCase(),
          maxLines: 2,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade400,
              fontSize: 50),
        ),
      ),
      Expanded(
        flex: 1,
        child: Image.network(machine.image),
      ),
    ]);
  }

  makeMachineDetails(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width >= 700
          ? MediaQuery.of(context).size.height / 0.5
          : MediaQuery.of(context).size.height / 0.9,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          generateTitle('DETAILS'),
          GridView.count(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width >= 700
                  ? MediaQuery.of(context).size.width / 130
                  : MediaQuery.of(context).size.width / 288,
              children: List<Widget>.generate(10, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title[index],
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    contextOfDetails(index),
                  ],
                );
              }).toList()),
          Align(
            alignment: Alignment.center,
            child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 16.0),
                  child: Text('RENT NOW', style: TextStyle(color: Colors.grey)),
                ),
                onPressed: () {
                  print('Rent Now Button is pressed');
                  Navigator.pushNamed(context, CustomRouter.orderRoute,
                      arguments: machine);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade50),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                                color: Colors.grey,
                                width: 4,
                                style: BorderStyle.solid))))),
          )
        ],
      ),
    );
  }

  contextOfDetails(int index) {
    switch (index) {
      case 0:
        return Text(
          machine.machineName,
          style: TextStyle(fontSize: 20),
        );
        break;
      case 1:
        return Text(
          '${machine.machineDetail.width.toStringAsFixed(2)} m',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 2:
        return Text(
          '${machine.machineDetail.length.toStringAsFixed(2)} m',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 3:
        return Text(
          '${machine.machineDetail.height.toStringAsFixed(2)} m',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 4:
        return Text(
          '${machine.machineDetail.weight.toString()} kg',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 5:
        return Text(
          '${machine.machineDetail.workingHeight.toStringAsFixed(2)} m',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 6:
        return Text(
          '${machine.machineDetail.capacity.toString()} kg',
          style: TextStyle(fontSize: 20),
        );
        break;
      case 7:
        return Text(
          machine.machineDetail.engine,
          style: TextStyle(fontSize: 20),
        );
        break;
      case 8:
        return Text(
          machine.quantity.toString(),
          style: TextStyle(fontSize: 20),
        );
        break;
      case 9:
        return AutoSizeText(
          machine.machineDetail.remark,
          overflowReplacement: Text(machine.machineDetail.remark),
          style: TextStyle(fontSize: 16),
        );
        break;
    }
  }
}
