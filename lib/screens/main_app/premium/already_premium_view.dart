import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:skoller/screens/main_app/premium/premium_packages_view.dart';
import 'package:skoller/tools.dart';

import 'stripe_bloc.dart';

class AlreadyPremiumView extends StatefulWidget {
  @override
  State createState() => _AlreadyPremiumViewState();
}

class _AlreadyPremiumViewState extends State<AlreadyPremiumView>
    with ScreenLoader<AlreadyPremiumView> {
  int _radioSelected = 1;
  late String _radioVal;

  @override
  loadingBgBlur() => 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> createAPremiumFreeUserDialog() async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: SKColors.border_gray),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Image.asset(ImageNames.sammiImages.big_smile),
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'You are a premium user!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Login on desktop at Skoller.com to manage your account settings.',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => Navigator.pop(context, true),
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: SKColors.skoller_blue1,
                        boxShadow: UIAssets.boxShadow),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cancelSub() async {
    await stripeBloc.cancelSubscriptions({
      'title': _radioVal.toLowerCase().replaceAll(" ", "_"),
      'description': _radioVal,
    }).then((value) {
      if (value) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget screen(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: SKColors.border_gray),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (_) => Navigator.pop(context),
                          child: SizedBox(
                            width: 32,
                            height: 24,
                            child: Image.asset(ImageNames.navArrowImages.down),
                          ),
                        ),
                      ],
                    ),
                    (Subscriptions.mySubscriptions?.user
                                    ?.lifetimeSubscription ??
                                true) ||
                            (Subscriptions
                                    .mySubscriptions?.user?.lifetimeTrial ??
                                true)
                        ? Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Image.asset(
                                        ImageNames.sammiImages.big_smile),
                                    Flexible(
                                      child: Text(
                                        'You have a premium account with no recurring charges.This has been setup by a Skoller administrator!',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (details) =>
                                      Navigator.pop(context, true),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 50),
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: SKColors.skoller_blue1,
                                          boxShadow: UIAssets.boxShadow),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : !(Subscriptions.mySubscriptions?.user?.trial ?? false)
                            ? Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Image.asset(
                                            ImageNames.sammiImages.big_smile),
                                        Flexible(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                              'Your free trial has expired!',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapUp: (details) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return PremiumPackagesView(true);
                                            });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 50),
                                          alignment: Alignment.center,
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: SKColors.skoller_blue1,
                                              boxShadow: UIAssets.boxShadow),
                                          child: Text(
                                            'Upgrade Subscription',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (Subscriptions.mySubscriptions?.user?.trial ??
                                    false)
                                ? Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Image.asset(ImageNames
                                                .sammiImages.big_smile),
                                            Flexible(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                  'Your free trial expires in ${(Subscriptions.mySubscriptions?.user?.trial ?? false) == false ? '' : Subscriptions.mySubscriptions?.user?.trialDaysLeft?.toStringAsFixed(0)} days',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTapUp: (details) {
                                            Navigator.pop(context);
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return PremiumPackagesView(
                                                      true);
                                                });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 12),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 50),
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 20),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: SKColors.skoller_blue1,
                                                  boxShadow:
                                                      UIAssets.boxShadow),
                                              child: Text(
                                                'Upgrade Subscription',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(
                                            left: 10.0,
                                            top: 5,
                                          ),
                                          child: Text(
                                            'Trial ends ${DateFormat('MMMM dd, yyyy').format(DateTime.now().add(Duration(days: int.parse(Subscriptions.mySubscriptions?.user?.trialDaysLeft?.toStringAsFixed(0) ?? '0'))))}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(ImageNames
                                                .sammiImages.big_smile),
                                            Flexible(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  'You are a premium user.',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Material(
                                            color: Colors.transparent,
                                            shape: RoundedRectangleBorder(),
                                            child: GestureDetector(
                                              onTap: () =>
                                                  createAPremiumFreeUserDialog(),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: SKColors.skoller_blue1,
                                                  boxShadow: UIAssets.boxShadow,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.white),
                                                ),
                                                child: Text(
                                                  'Cancel Subscription',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget whyCancel(String text, int val) {
    return Container(
      child: Row(
        children: [
          Radio(
            value: val,
            groupValue: _radioSelected,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                _radioSelected = int.parse(value.toString());
                _radioVal = text;
              });
            },
          ),
          Text(text),
        ],
      ),
    );
  }
}
