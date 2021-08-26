import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/base_helper/auth_utils.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/dialog/loading_dialog.dart';
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/customer.dart';

class LoginPage extends StatefulWidget {
  String docId;
  LoginPage({this.docId});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Customer customer;
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = true;

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: backwardButton(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.getUsers().snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Center(child: Text('Something went wrong')),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingPage(message: 'Waiting for connection...'),
              );
            }
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            else {
              if (widget.docId != null) {
                var currentUser = snapshot.data.docs.firstWhere((element) {
                  return widget.docId == element.reference.id;
                });

                customer = Customer(
                  id: currentUser.reference.id,
                  notifId: currentUser.get('notifId'),
                  name: currentUser.get('name'),
                  email: currentUser.get('email'),
                  phoneNo: currentUser.get('contact'),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height >= 400
                          ? MediaQuery.of(context).size.height * 0.83
                          : MediaQuery.of(context).size.height * 1.8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 1,
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              offset: Offset(0, 1.0))
                        ],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                      ),
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            makeTitle(),
                            makeBodyText(),
                            makeInputField(),
                            SizedBox(height: 50),
                            // makeSocialMediaButton(context),
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: makeSignInButton(context)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'New Here? |',
                            maxFontSize: 12,
                            style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.none),
                          ),
                          TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, CustomRouter.signupRoute),
                              child: Text(
                                'Create Account',
                                style: TextStyle(color: Colors.yellow),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  makeTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AutoSizeText(
        'SIGNIN',
        style: TextStyle(color: Colors.yellow, fontSize: 30),
      ),
    );
  }

  makeBodyText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AutoSizeText(
        'To continue your account!',
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }

  makeInputField() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextFormField(
            style: TextStyle(color: Colors.blue),
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email \*',
              hintText: "e.g abc@gmail.com",
            ),
            textInputAction: TextInputAction.next,
            validator: (email) {
              if (email.isEmpty)
                return 'This field cannot be empty';
              else
                return EmailValidator.validate(email)
                    ? null
                    : "Invalid email address";
            },
            onSaved: (email) => emailController.text = email,
            onFieldSubmitted: (_) {
              fieldFocusChange(context, _emailFocusNode, _passwordFocusNode);
            },
          ),
          SizedBox(height: 30),
          TextFormField(
            style: TextStyle(color: Colors.blue),
            keyboardType: TextInputType.text,
            obscureText: isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password \*',
              suffixIcon: IconButton(
                icon: isPasswordVisible
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),
            textInputAction: TextInputAction.done,
            validator: (password) {
              Pattern pattern =
                  r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$';
              RegExp regex = new RegExp(pattern);
              if (password.isEmpty)
                return 'This field cannot be empty';
              else if (!regex.hasMatch(password))
                return 'Invalid password';
              else
                return null;
            },
            controller: passwordController,
            onSaved: (password) => passwordController.text = password,
            onFieldSubmitted: (_) {
              fieldFocusChange(context, _passwordFocusNode, null);
            },
          ),
        ],
      ),
    );
  }

  // makeSocialMediaButton(BuildContext context) {
  // return Column(
  //   crossAxisAlignment: CrossAxisAlignment.stretch,
  //   children: [
  //     AutoSizeText(
  //       'Login with social media?',
  //       style: TextStyle(fontSize: 5),
  //     ),
  //     SizedBox(height: 30),
  //     ElevatedButton(
  //         child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Image.asset(icFBLogo, scale: 45, fit: BoxFit.fitHeight),
  //                 Text(
  //                   'LOGIN WITH FACEBOOK',
  //                   style: TextStyle(color: Colors.yellow),
  //                 ),
  //               ],
  //             )),
  //         onPressed: () {
  //           Authentication.signInWithFacebook().then((result) async {
  //             if (result != null) {
  //               if (result.additionalUserInfo.isNewUser) {
  //                 String id = await FirestoreService.getUsers().add({
  //                   'name': result.additionalUserInfo.profile['name'],
  //                   'email': result.additionalUserInfo.profile['email'],
  //                 }).then((value) {
  //                   return value.id;
  //                 }).catchError(
  //                     (error) => print("Failed to add user: $error"));
  //
  //                 if (id != null) {
  //                   Customer customer = Customer(id: id);
  //                   Navigator.pushNamedAndRemoveUntil(
  //                       context,
  //                       CustomRouter.dashboardRoute,
  //                       ModalRoute.withName(Navigator.defaultRouteName),
  //                       arguments: customer);
  //                 }
  //               } else {
  //                 Customer customer;
  //                 await FirestoreService.filterUsers(
  //                         'email', result.additionalUserInfo.profile['email'])
  //                     .get()
  //                     .then((value) {
  //                   value.docs.map((element) {
  //                     customer = Customer(
  //                         id: element.reference.id,
  //                         email: element.get('email'),
  //                         position: Position(
  //                             longitude: double.parse(
  //                                 element.get('position')['longitude']),
  //                             latitude: double.parse(
  //                                 element.get('position')['latitude'])),
  //                         phoneNo: element.get('contact'));
  //                   }).toList();
  //                 });
  //
  //                 if (customer != null)
  //                   Navigator.pushNamedAndRemoveUntil(
  //                       context,
  //                       CustomRouter.dashboardRoute,
  //                       ModalRoute.withName(Navigator.defaultRouteName),
  //                       arguments: customer);
  //               }
  //             } else {
  //               print('Result: ${result}');
  //             }
  //           });
  //         },
  //         style: ButtonStyle(
  //             backgroundColor:
  //                 MaterialStateProperty.all<Color>(Colors.grey.shade50),
  //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //                 RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(30.0),
  //                     side: BorderSide(
  //                         color: Colors.yellow,
  //                         width: 4,
  //                         style: BorderStyle.solid))))),
  //     SizedBox(height: 20),
  //     ElevatedButton(
  //         child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Image.asset(icGoogleLogo, scale: 50, fit: BoxFit.fitHeight),
  //                 Text('LOGIN WITH GOOGLE',
  //                     style: TextStyle(color: Colors.grey)),
  //               ],
  //             )),
  //         onPressed: () {
  //           Authentication.signInWithGoogle().then((result) async {
  //             if (result != null) {
  //               if (result.additionalUserInfo.isNewUser) {
  //                 String id = await FirestoreService.getUsers().add({
  //                   'name': result.additionalUserInfo.profile['name'],
  //                   'email': result.additionalUserInfo.profile['email'],
  //                 }).then((value) {
  //                   return value.id;
  //                 }).catchError(
  //                     (error) => print("Failed to add user: $error"));
  //
  //                 if (id != null) {
  //                   Customer customer = await FirestoreService.getUsers()
  //                       .doc(id)
  //                       .get()
  //                       .then((value) {
  //                     return Customer(
  //                       id: id,
  //                       name: value.get('name'),
  //                       email: value.get('email'),
  //                     );
  //                   });
  //
  //                   Navigator.pushNamedAndRemoveUntil(
  //                       context,
  //                       CustomRouter.dashboardRoute,
  //                       ModalRoute.withName(Navigator.defaultRouteName),
  //                       arguments: customer);
  //                 }
  //               } else {
  //                 Customer customer;
  //                 await FirestoreService.filterUsers(
  //                         'email', result.additionalUserInfo.profile['email'])
  //                     .get()
  //                     .then((value) {
  //                   value.docs.map((element) {
  //                     customer = Customer(
  //                         id: element.reference.id,
  //                         email: element.get('email'),
  //                         name: element.get('name'),
  //                         position: Position(
  //                             longitude: double.parse(
  //                                 element.get('position')['longitude']),
  //                             latitude: double.parse(
  //                                 element.get('position')['latitude'])),
  //                         phoneNo: element.get('contact'));
  //                   }).toList();
  //                 });
  //
  //                 if (customer != null)
  //                   Navigator.pushNamedAndRemoveUntil(
  //                       context,
  //                       CustomRouter.dashboardRoute,
  //                       ModalRoute.withName(Navigator.defaultRouteName),
  //                       arguments: customer);
  //               }
  //             } else {
  //               print('Result: ${result}');
  //             }
  //           });
  //         },
  //         style: ButtonStyle(
  //             backgroundColor:
  //                 MaterialStateProperty.all<Color>(Colors.grey.shade50),
  //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //                 RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(30.0),
  //                     side: BorderSide(
  //                         color: Colors.grey,
  //                         width: 4,
  //                         style: BorderStyle.solid))))),
  //   ],
  // );
  // }

  makeSignInButton(BuildContext context) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Column(
        children: [
          SizedBox(height: 30),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Authentication.signInWithEmailAndPassword(context,
                          emailController.text, passwordController.text)
                      .then((result) async {
                    // print(result.additionalUserInfo.isNewUser);
                    Customer customer;
                    if (result != null && result.user.emailVerified) {
                      await FirestoreService.filterUsers(
                              'email', result.user.email)
                          .get()
                          .then((value) {
                        value.docs.map((element) {
                          print('Email: ${element.get('email')}');
                          customer = Customer(
                            id: element.reference.id,
                            notifId: element.get('notifId'),
                            name: element.get('name'),
                            email: element.get('email'),
                            phoneNo: element.get('contact'),
                          );
                        }).toList();
                      });
                      getCurrentLocation(context, customer.id);
                      Future.delayed(Duration(seconds: 1), () async {
                        await FirestoreService.getUsers()
                            .doc(customer.id)
                            .get()
                            .then((value) {
                          customer.position = Position(
                              latitude: value.get('position')['latitude'],
                              longitude: value.get('position')['longitude']);
                        });

                        if (customer.position != null) {
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              CustomRouter.dashboardRoute,
                              ModalRoute.withName(Navigator.defaultRouteName),
                              arguments: customer);
                        }
                      });
                    } else if (result != null && !(result.user.emailVerified)) {
                      print(result.additionalUserInfo.isNewUser);
                      Dialogs.showMessage(context,
                          title: 'Active an Account',
                          content: Text(
                              'Kindly proceed to your email to active your account'));
                    } else {
                      print('Result: ${result.credential}');
                      snackBar(context, 'No Created Account');
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
                minimumSize: Size(MediaQuery.of(context).size.width / 2, 50.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              child: Text(
                'SIGN IN',
                style: TextStyle(color: Colors.grey),
              )),
          SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final email = await Dialogs.resetDialog(context);
              print('Email: ${email}');
              if (email != '' && email != null) {
                Authentication.resetPassword(email);
              }
            },
            child: AutoSizeText(
              'Forget password?',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
