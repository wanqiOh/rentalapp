import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/model/view_model/order.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  List<Order> orders;
  NotificationPage({this.orders});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.subMargin),
            ),
            notificationIcon(widget.orders, context),
          ],
        ),
        body: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () =>
              Future.delayed(Duration(milliseconds: 200), () => true),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, AppTheme.largeMargin),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    generateTitle('Notificaton'),
                    ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.orders.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                widget.orders[index].clicked = true;
                              });

                              Navigator.pushNamed(
                                context,
                                CustomRouter.inboxRoute,
                                arguments: widget.orders[index],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: textLayoutNotificationPage(
                                            widget.orders[index].title,
                                            widget.orders[index].clicked,
                                            TextAlign.start),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: textLayoutNotificationPage(
                                            filterDateTime(widget
                                                .orders[index].receivedTime),
                                            widget.orders[index].clicked,
                                            TextAlign.end),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: AppTheme.subMargin),
                                  ),
                                  AutoSizeText(
                                    'The delivery of renting machines is scheduled on ' +
                                        DateFormat('dd/MM/yyyy').format(
                                            widget.orders[index].startDate) +
                                        ' ' +
                                        'Delivery to ' +
                                        widget.orders[index].address.address1 +
                                        ', ' +
                                        widget.orders[index].address.address2 +
                                        ', ' +
                                        widget.orders[index].address.city +
                                        ', ' +
                                        widget.orders[index].address.postcode +
                                        ', ' +
                                        widget.orders[index].address.state,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.orders[index].clicked
                                        ? AppTheme.smallText
                                        : AppTheme.boldSmallText,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider()),
                  ]),
            ),
          ),
        ));
  }

  notificationIcon(List<Order> orders, BuildContext context) {
    List<bool> item = [];
    for (var element in orders) {
      element.clicked ? null : item.add(element.clicked);
    }

    if (item.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.red,
        radius: 12,
        child: AutoSizeText(
          '${item.length}',
          style: TextStyle(color: AppTheme.white),
          minFontSize: 10,
          maxFontSize: 10,
          maxLines: 1,
        ),
      );
    } else {
      return Container();
    }
  }

  textLayoutNotificationPage(String title, bool isRead, TextAlign textAlign) {
    return Text(
      title,
      style: isRead ? AppTheme.smallText : AppTheme.boldSmallText,
      maxLines: 1,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }

  String filterDateTime(DateTime createdDate) {
    if (createdDate.day == DateTime.now().day &&
        createdDate.month == DateTime.now().month &&
        createdDate.year == DateTime.now().year) {
      if (createdDate.hour == DateTime.now().hour &&
          createdDate.minute == DateTime.now().minute) {
        return 'Now';
      } else {
        return timeago.format(createdDate);
      }
    } else {
      return DateFormat('dd').format(createdDate) +
          'th ' +
          DateFormat('MMM yyyy hh.mm a').format(createdDate);
    }
  }
}
