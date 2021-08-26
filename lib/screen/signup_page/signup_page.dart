import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rentalapp/base_helper/app_utils.dart';
import 'package:rentalapp/base_helper/auth_utils.dart';
import 'package:rentalapp/base_helper/ui/drop_down.dart';
import 'package:rentalapp/custom_router.dart';
import 'package:rentalapp/dialog/dialog.dart';
import 'package:rentalapp/global/globals.dart' as globals;
import 'package:rentalapp/model/firestore_service/firestore_service.dart';
import 'package:rentalapp/model/view_model/drop_down_item.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailContoller = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController reenterPasswordController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController dialCodeController = TextEditingController();
  List<String> usernames = [];
  List<String> emails = [];
  bool isPasswordVisible = true;
  bool isReenterPasswordVisible = true;
  bool agree = false;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode reenterPasswordFocusNode = FocusNode();
  FocusNode contactNoFocusNode = FocusNode();
  FocusNode usernameFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    emailContoller.dispose();
    passwordController.dispose();
    reenterPasswordController.dispose();
    contactController.dispose();
    contactController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reenterPasswordFocusNode.dispose();
    contactNoFocusNode.dispose();
    dialCodeController.dispose();
  }

  @override
  void initState() {
    super.initState();
    dialCodeController.text = DropDownItem.objDialCode.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          leading: backwardButton(context)),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.getUsers().snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              return CircularProgressIndicator();
            else {
              usernames.clear();
              emails.clear();
              snapshot.data.docs
                  .map((element) {
                    usernames.add(element.get('name'));
                    emails.add(element.get('email'));
                  })
                  .toSet()
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height >= 400
                          ? MediaQuery.of(context).size.height * 0.83
                          : MediaQuery.of(context).size.height * 1.8,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 1,
                              color: Colors.grey,
                              spreadRadius: 0.5,
                              offset: Offset(0, 1.0))
                        ],
                        color: Colors.grey.shade50,
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
                            Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: makeSignUpButton(context)),
                            // makeSocialMediaButton(context),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'Already have an account? |',
                            maxFontSize: 12,
                            style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.none),
                          ),
                          TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, CustomRouter.loginRoute),
                              child: Text(
                                'Login',
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
        'SIGNUP',
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
            decoration: InputDecoration(
              labelText: 'Email \*',
              hintText: "e.g abc@gmail.com",
            ),
            controller: emailContoller,
            focusNode: emailFocusNode,
            textInputAction: TextInputAction.next,
            validator: (email) {
              if (email.isEmpty)
                return 'This field cannot be empty';
              else {
                for (var i in emails)
                  if (i == email)
                    return 'This email was registered';
                  else
                    return EmailValidator.validate(email)
                        ? null
                        : "Invalid email address";
              }
            },
            onSaved: (email) => emailContoller.text = email,
            onFieldSubmitted: (_) {
              fieldFocusChange(useContext(), emailFocusNode, usernameFocusNode);
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(color: Colors.blue),
            focusNode: usernameFocusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: 'Username \*'),
            textInputAction: TextInputAction.next,
            validator: (username) {
              if (username.isEmpty)
                return 'This field cannot be empty';
              else {
                for (var i in usernames)
                  if (i == username) return 'This username was used';
              }
            },
            controller: usernameController,
            onSaved: (username) => usernameController.text = username,
            onFieldSubmitted: (_) {
              fieldFocusChange(
                  useContext(), usernameFocusNode, passwordFocusNode);
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(color: Colors.blue),
            keyboardType: TextInputType.text,
            obscureText: isPasswordVisible,
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password \* ',
              suffixIcon: IconButton(
                icon: isPasswordVisible
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (password) {
              Pattern pattern =
                  r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z]{6,}$';
              RegExp regex = new RegExp(pattern);
              if (password.isEmpty)
                return 'This field cannot be empty';
              else if (!regex.hasMatch(password))
                return 'Not match with password';
              else
                return null;
            },
            onSaved: (password) => passwordController.text = password,
            onFieldSubmitted: (_) {
              fieldFocusChange(
                  useContext(), passwordFocusNode, reenterPasswordFocusNode);
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(color: Colors.blue),
            keyboardType: TextInputType.text,
            obscureText: isReenterPasswordVisible,
            controller: reenterPasswordController,
            focusNode: reenterPasswordFocusNode,
            decoration: InputDecoration(
              labelText: 'Reenter - Password \*',
              suffixIcon: IconButton(
                icon: isReenterPasswordVisible
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
                onPressed: () => setState(
                    () => isReenterPasswordVisible = !isReenterPasswordVisible),
              ),
            ),
            textInputAction: TextInputAction.next,
            // TODO: Validate for reenter-password.
            validator: (reenterpassword) {
              if (reenterpassword.isEmpty)
                return 'This field cannot be empty';
              else if (passwordController.text.compareTo(reenterpassword) != 0)
                return 'Reenter-password is different with password';
              else
                return null;
            },
            onSaved: (reenterpassword) =>
                reenterPasswordController.text = reenterpassword,
            onFieldSubmitted: (_) {
              fieldFocusChange(useContext(), reenterPasswordFocusNode, null);
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: makeSmallDropDownBar(
                    selectedSite: DropDownItem.objDialCode,
                    list: DropDownItem.listDialCode,
                    callBack: (DropDownItem value) {
                      setState(() {
                        DropDownItem.objDialCode = value;
                        dialCodeController.text = value.name;
                      });
                    }),
              ),
              Expanded(
                flex: 3,
                child: TextFormField(
                  style: TextStyle(color: Colors.blue),
                  controller: contactController,
                  focusNode: contactNoFocusNode,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact No \*',
                    hintText: '1234XXXXX',
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                  ],
                  validator: (mobileNum) {
                    if (mobileNum.isEmpty)
                      return 'This field cannot be empty';
                    else {
                      if (checkPhoneNumberValidation(mobileNum))
                        return null;
                      else
                        return 'Invalid phone number';
                    }
                  },
                  onSaved: (contactNo) => contactController.text = contactNo,
                  onFieldSubmitted: (_) {
                    fieldFocusChange(useContext(), contactNoFocusNode, null);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Material(
                child: Checkbox(
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value;
                    });
                  },
                ),
              ),
              Text(
                'I have read and accept',
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, CustomRouter.termAndConditionRoute);
                },
                child: Text(
                  ' terms and conditions',
                  style: TextStyle(color: Colors.blue),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // makeSocialMediaButton(BuildContext context) {
  // return Column(
  //   crossAxisAlignment: CrossAxisAlignment.center,
  //   children: [
  //     AutoSizeText(
  //       'Or create account using social media',
  //       style: TextStyle(fontSize: 5),
  //     ),
  //     Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         IconButton(
  //             icon: Image.asset(icCircleFB, scale: 1),
  //             onPressed: () {
  //               Authentication.signInWithFacebook().then((result) async {
  //                 String id;
  //                 if (result != null) {
  //                   if (result.additionalUserInfo.isNewUser) {
  //                     id = await FirestoreService.getUsers().add({
  //                       'name': result.additionalUserInfo.profile['name'],
  //                       'email': result.additionalUserInfo.profile['email'],
  //                     }).then((value) {
  //                       return value.id;
  //                     }).catchError(
  //                         (error) => print("Failed to add user: $error"));
  //                     Future.delayed(
  //                         Duration(seconds: 3),
  //                         () => Navigator.pushNamedAndRemoveUntil(
  //                             context,
  //                             CustomRouter.loginRoute,
  //                             ModalRoute.withName(Navigator.defaultRouteName),
  //                             arguments: id));
  //                   } else {
  //                     Dialogs.showMessage(context,
  //                         title: 'Account Existed',
  //                         content: Text('Kindly proceed to login'));
  //                     Future.delayed(
  //                         Duration(seconds: 3),
  //                         () => Navigator.pushNamedAndRemoveUntil(
  //                             context,
  //                             CustomRouter.loginRoute,
  //                             ModalRoute.withName(Navigator.defaultRouteName),
  //                             arguments: id));
  //                   }
  //                 } else {
  //                   print('Result: ${result}');
  //                 }
  //               });
  //             }),
  //         SizedBox(height: 20),
  //         IconButton(
  //             icon: Image.asset(icCircleGoogle, scale: 1),
  //             onPressed: () {
  //               String id;
  //               Authentication.signInWithGoogle().then((result) async {
  //                 if (result != null) {
  //                   if (result.additionalUserInfo.isNewUser) {
  //                     id = await FirestoreService.getUsers().add({
  //                       'name': result.additionalUserInfo.profile['name'],
  //                       'email': result.additionalUserInfo.profile['email'],
  //                     }).then((value) {
  //                       return value.id;
  //                     }).catchError(
  //                         (error) => print("Failed to add user: $error"));
  //                     Future.delayed(
  //                         Duration(seconds: 3),
  //                         () => Navigator.pushNamedAndRemoveUntil(
  //                             context,
  //                             CustomRouter.loginRoute,
  //                             ModalRoute.withName(Navigator.defaultRouteName),
  //                             arguments: id));
  //                   } else {
  //                     Dialogs.showMessage(context,
  //                         title: 'Account Existed',
  //                         content: Text('Kindly proceed to login'));
  //                     Future.delayed(
  //                         Duration(seconds: 3),
  //                         () => Navigator.pushNamedAndRemoveUntil(
  //                             context,
  //                             CustomRouter.loginRoute,
  //                             ModalRoute.withName(Navigator.defaultRouteName),
  //                             arguments: id));
  //                   }
  //                 } else {
  //                   print('Result: ${result}');
  //                 }
  //               });
  //             }),
  //       ],
  //     ),
  //   ],
  // );
  // }

  makeSignUpButton(BuildContext context) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: ElevatedButton(
          onPressed: !agree
              ? null
              : () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    final responseMessage = await Navigator.pushNamed(
                        context, CustomRouter.otpRoute,
                        arguments:
                            dialCodeController.text + contactController.text);

                    print('Response Message: ${responseMessage}');
                    if (responseMessage) {
                      Authentication.signUpWithEmailAndPassword(context,
                              emailContoller.text, passwordController.text)
                          .then((result) async {
                        if (result != null) {
                          String id = await FirestoreService.getUsers().add({
                            'name': usernameController.text,
                            'email': result.user.email,
                            'contact': dialCodeController.text +
                                contactController.text,
                            'notifId': globals.id,
                            'createdDateTime': DateTime.now(),
                          }).then((value) {
                            return value.id;
                          }).catchError(
                              (error) => print("Failed to add user: $error"));

                          if (id != null) {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                CustomRouter.loginRoute,
                                ModalRoute.withName(Navigator.defaultRouteName),
                                arguments: id);
                          }
                        } else {
                          Dialogs.showMessage(context,
                              title: 'Account Existed',
                              content: Text('Do you active your account?'));
                        }
                      });
                    } else {
                      Dialogs.showMessage(context,
                          title: 'OTP session failed',
                          content: Text('Kindly input an valid phone number'));
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            primary: Colors.yellow,
            minimumSize: Size(MediaQuery.of(context).size.width / 2, 50.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Text(
            'SIGN UP',
            style: TextStyle(color: Colors.grey),
          )),
    );
  }
}
