import 'package:flutter/material.dart';
import 'package:rentalapp/model/view_model/drop_down_item.dart';

Widget makeFullDropDownBar(
    {DropDownItem selectedSite, List<DropDownItem> list, Function callBack}) {
  List<DropdownMenuItem<String>> obj = [];
  obj = _generateDropDownMenuItem(list);

  return SizedBox(
      height: 60,
      width: 500,
      child: DecoratedBox(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            border: Border.all(color: Colors.grey, style: BorderStyle.solid)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    isExpanded: true,
                    items: obj,
                    onChanged: (value) {
                      for (var obj in list) {
                        if (obj.id == int.parse(value)) {
                          callBack(obj);
                          break;
                        }
                      }
                    },
                    hint: obj.isNotEmpty
                        ? (selectedSite != null
                            ? Text('${selectedSite.name}')
                            : Text('Selected'))
                        : Text('No Data'),
                    onTap: () {
                      print(obj.first.child.key.toString());
                    },
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: const Icon(Icons.expand_more),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
}

Widget makeSmallDropDownBar(
    {DropDownItem selectedSite, List<DropDownItem> list, Function callBack}) {
  List<DropdownMenuItem<String>> obj = [];
  obj = _generateDropDownMenuItem(list);

  return SizedBox(
    height: 76,
    width: 60,
    child: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: DropdownButton(
        underline: Container(
          height: 1,
          color: Colors.grey,
        ),
        isExpanded: true,
        items: obj,
        onChanged: (value) {
          for (var obj in list) {
            if (obj.id == int.parse(value)) {
              callBack(obj);
              break;
            }
          }
        },
        hint: obj.isNotEmpty
            ? (selectedSite != null
                ? Text('${selectedSite.name}')
                : Text('Selected'))
            : Text('No Data'),
        onTap: () {
          print(obj.first.child.key.toString());
        },
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: const Icon(Icons.expand_more),
        ),
      ),
    ),
  );
}

List<DropdownMenuItem<String>> _generateDropDownMenuItem(
    List<DropDownItem> list) {
  if (list == null) {
    return [];
  }

  return list
      .map((data) => DropdownMenuItem(
            child: Text(data.name),
            value: '${data.id}',
          ))
      .toList();
}
