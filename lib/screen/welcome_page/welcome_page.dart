import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rentalapp/app_folder/app_theme.dart';
import 'package:rentalapp/constants/image_path.dart';
import 'package:rentalapp/custom_router.dart';

class WelcomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: AppTheme.white,
          image: DecorationImage(
            image: AssetImage(bgSplash),
            fit: BoxFit.contain,
          )),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: AppTheme.white.withOpacity(0.8),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 32),
                        child: makeTitle(),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: makeIcon()),
                      Padding(
                          padding:
                              const EdgeInsets.only(top: 24.0, bottom: 24.0),
                          child: makeWelcomeText()),
                      Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: makeSignButton(context)),
                      Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: makeBottomText(context)),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget makeTitle() {
    List<String> title = ['Industries ', 'Machinery', 'Renting ', 'Apps'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 2; i++)
              AutoSizeText(
                title[i],
                style: i % 2 != 0
                    ? TextStyle(
                        color: Colors.yellow, decoration: TextDecoration.none)
                    : TextStyle(
                        color: Colors.grey, decoration: TextDecoration.none),
                maxFontSize: 25,
              )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 2; i < 4; i++)
                AutoSizeText(
                  title[i],
                  style: i % 2 == 0
                      ? TextStyle(
                          color: Colors.yellow, decoration: TextDecoration.none)
                      : TextStyle(
                          color: Colors.grey, decoration: TextDecoration.none),
                  maxFontSize: 25,
                )
            ],
          ),
        ),
      ],
    );
  }

  makeIcon() {
    return Image.asset(
      icLogo,
      scale: 1,
      fit: BoxFit.cover,
    );
  }

  makeWelcomeText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            'Welcome',
            style: TextStyle(
                color: Colors.grey.shade500, decoration: TextDecoration.none),
            maxFontSize: 35,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        AutoSizeText(
          'Please login by using given credentials and enjoy your apps.',
          style: TextStyle(
              color: Colors.grey.shade500, decoration: TextDecoration.none),
          maxFontSize: 14,
        )
      ],
    );
  }

  makeSignButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, CustomRouter.loginRoute),
        style: ElevatedButton.styleFrom(
          primary: Colors.yellow,
          minimumSize: Size(MediaQuery.of(context).size.width / 2, 50.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          'Get Started',
          style: TextStyle(color: Colors.grey),
        ));
  }

  makeBottomText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            'New Here? |',
            maxFontSize: 12,
            style:
                TextStyle(color: Colors.grey, decoration: TextDecoration.none),
          ),
          TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, CustomRouter.signupRoute),
              child: Text(
                'Create Account',
                style: TextStyle(color: Colors.yellow),
              ))
        ],
      ),
    );
  }
}
