import 'package:dropdown_banner/dropdown_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:pay/pay.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';
import 'package:screen_loader/screen_loader.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/model/plans_model.dart';
import 'package:skoller/requests/stripe_payments.dart';
import 'package:skoller/screens/main_app/main_view.dart';
import 'package:skoller/tools.dart';
import 'package:stripe_payment/stripe_payment.dart' as stripeCard;

import 'stripe_bloc.dart';

class PremiumPackagesView extends StatefulWidget {
  final bool? canpop;

  State createState() => _PremiumPackages();

  PremiumPackagesView(this.canpop);
}

class _PremiumPackages extends State<PremiumPackagesView>
    with ScreenLoader<PremiumPackagesView> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int selectedIndex = 0;
  String? selectPlanAmounts = '3.0';
  final _stripePayment = new StripePayments();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  loadingBgBlur() => 0.0;

  void payment(String planId) {
    if (cardNumberController.text.isEmpty) {
      alert("Enter Card Number");
      return;
    }
    if (monthController.text.isEmpty) {
      alert("Enter Card Expiry MM");
      return;
    }
    if (yearController.text.isEmpty) {
      alert("Enter Card Expiry YY");
      return;
    }
    if (cvcController.text.isEmpty) {
      alert("Enter Card CVV");
      return;
    }
    if (zipCodeController.text.isEmpty) {
      alert('Enter Zip Code');
      return;
    }
    if (planId.isEmpty) {
      alert("Please select a plan");
      return;
    }
    stripeCard.CreditCard _testCard = stripeCard.CreditCard(
        number: cardNumberController.text,
        expMonth: int.parse(monthController.text),
        expYear: int.parse(yearController.text),
        cvc: cvcController.text);
    startLoading();
    _stripePayment.addSource(_testCard, context).then((value) {
      if (value.toString().isNotEmpty) {
        Utilities.showSuccessMessage("Card added successfully");
        hitSubscriptionApi(planId, value);
      }
    }).catchError((onError) {
      startLoading();
      alert("Your card is not supported");
    });
  }

  void alert(String text) {
    return DropdownBanner.showBanner(
      text: text,
      color: SKColors.alert_orange,
      textStyle: TextStyle(color: Colors.white),
    );
  }

  hitSubscriptionApi(String _planId, String token) {
    print("plane id >>>>> $_planId");
    print("TOKEN >>>>> $token");
    Map<String, dynamic> data = {
      "payment_method": {
        "token": token.toString(),
        "plan_id": _planId.toString()
      }
    };
    stripeBloc.saveCardAndSubscription(data).then((value) {
      if (value == true) {
        stopLoading();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainView(),
            ),
            (route) => false);
      }
      stopLoading();
    });
  }

  Widget getPlans(AsyncSnapshot<PlansModel> snapshot) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SKColors.border_gray),
          borderRadius: BorderRadius.circular(10),
          boxShadow: UIAssets.boxShadow,
        ),
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  selectPlanAmounts =
                      snapshot.data!.data[index].price.toString();
                  stripeBloc.planIdCont.sink.add(snapshot.data!.data[index].id);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == index ? SKColors.menu_blue : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${double.parse(snapshot.data!.data[index].price.toString()).toStringAsFixed(0)} ${snapshot.data!.data[index].interval == 'lifetime' ? '' : 'per'} ${snapshot.data!.data[index].interval} ',
                            style: TextStyle(
                                fontSize: 14, color: SKColors.light_gray),
                          ),
                          Text(
                            'Save 20%',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: SKColors.light_gray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 0,
              );
            },
            itemCount: snapshot.data!.data.length));
  }

  Widget getCardInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SKColors.border_gray),
            borderRadius: BorderRadius.circular(10),
            boxShadow: UIAssets.boxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CupertinoTextField(
                controller: cardNumberController,
                decoration: BoxDecoration(border: null),
                placeholder: 'Number',
                style: TextStyle(fontSize: 14),
                placeholderStyle:
                    TextStyle(fontSize: 14, color: SKColors.text_light_gray),
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(16),
                  WhitelistingTextInputFormatter.digitsOnly,
                  BlacklistingTextInputFormatter.singleLineFormatter,
                ],
                keyboardType: TextInputType.phone,
                autofocus: false,
              ),
              Divider(
                height: 0,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: CupertinoTextField(
                      controller: monthController,
                      decoration: BoxDecoration(border: null),
                      placeholder: 'MM',
                      style: TextStyle(fontSize: 14),
                      placeholderStyle: TextStyle(
                          fontSize: 14, color: SKColors.text_light_gray),
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(2),
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter.singleLineFormatter,
                      ],
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                    ),
                  ),
                  Flexible(
                      child: Container(
                          child: Text(
                    "/",
                    style: TextStyle(
                        fontSize: 14, color: SKColors.text_light_gray),
                  ))),
                  Flexible(
                    flex: 1,
                    child: CupertinoTextField(
                      controller: yearController,
                      decoration: BoxDecoration(border: null),
                      placeholder: 'YY',
                      style: TextStyle(fontSize: 14),
                      placeholderStyle: TextStyle(
                          fontSize: 14, color: SKColors.text_light_gray),
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(2),
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter.singleLineFormatter,
                      ],
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: CupertinoTextField(
                      controller: cvcController,
                      decoration: BoxDecoration(border: null),
                      placeholder: 'CVC',
                      style: TextStyle(fontSize: 14),
                      placeholderStyle: TextStyle(
                          fontSize: 14, color: SKColors.text_light_gray),
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(3),
                        WhitelistingTextInputFormatter.digitsOnly,
                        BlacklistingTextInputFormatter.singleLineFormatter,
                      ],
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 0,
              ),
              CupertinoTextField(
                controller: zipCodeController,
                decoration: BoxDecoration(border: null),
                placeholder: 'Zip Code',
                style: TextStyle(fontSize: 14),
                placeholderStyle:
                    TextStyle(fontSize: 14, color: SKColors.text_light_gray),
                inputFormatters: [CreditCardNumberInputFormatter()],
                keyboardType: TextInputType.phone,
                autofocus: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SKColors.border_gray),
        borderRadius: BorderRadius.circular(10),
        boxShadow: UIAssets.boxShadow,
      ),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(
              color: SKColors.selected_gray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Payment',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Text(
                      'May 21, 2021',
                      style: TextStyle(fontSize: 16, color: SKColors.dark_gray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Payment',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Text(
                      'June 21, 2021',
                      style: TextStyle(fontSize: 16, color: SKColors.dark_gray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Row(
                      children: [
                        Text(
                          '*****7391',
                          style: TextStyle(
                              fontSize: 16, color: SKColors.dark_gray),
                        ),
                        Icon(
                          Icons.close,
                          color: SKColors.light_gray,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getBillingHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SKColors.border_gray),
        borderRadius: BorderRadius.circular(10),
        boxShadow: UIAssets.boxShadow,
      ),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(
              color: SKColors.selected_gray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Billing History',
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'May 21, 2021',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Text(
                      'VIEW PDF',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: SKColors.skoller_blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'April 21, 2021',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Text(
                      'VIEW PDF',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: SKColors.skoller_blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'March 21, 2021',
                      style:
                          TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),
                    Text(
                      'VIEW PDF',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: SKColors.skoller_blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Pay _payClient = Pay.withAssets([
    'default_payment_profile_apple_pay.json',
  ]);

  @override
  Widget screen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: SKColors.border_gray),
              ),
              child: StreamBuilder<PlansModel>(
                  stream: stripeBloc.allPlans,
                  builder: (context, AsyncSnapshot<PlansModel> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (_) {
                                  if (widget.canpop ?? false)
                                    Navigator.pop(context);
                                },
                                child: SizedBox(
                                  width: 32,
                                  height: 24,
                                  child: Image.asset(
                                      ImageNames.navArrowImages.down),
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    ImageNames.sammiImages.big_smile,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      !(Subscriptions.mySubscriptions?.user
                                                  ?.trial ??
                                              false)
                                          ? Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Flexible(
                                                child: Text(
                                                  'Your free trial has expired!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ((Subscriptions
                                                          .mySubscriptions
                                                          ?.user
                                                          ?.lifetimeSubscription ??
                                                      false) ==
                                                  false)
                                              ? Text(
                                                  'Your free trial expires in ${(Subscriptions.mySubscriptions?.user?.trial ?? false) == false ? '' : Subscriptions.mySubscriptions?.user?.trialDaysLeft!.toStringAsFixed(0)} days',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                )
                                              : ((Subscriptions
                                                              .mySubscriptions
                                                              ?.user
                                                              ?.lifetimeTrial ??
                                                          false) ==
                                                      true)
                                                  ? Text(
                                                      'You have a lifetime trial',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Your free trial expires in ${(Subscriptions.mySubscriptions?.user?.trial ?? false) == false ? '' : Subscriptions.mySubscriptions?.user?.trialDaysLeft.toString()} days',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                      Text(
                                        'Upgrade to premium.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      height: 0,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Select a Plan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: 0,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              getPlans(snapshot),
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 10.0),
                                child: FutureBuilder<bool>(
                                  future: _payClient
                                      .userCanPay(PayProvider.apple_pay),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data == true) {
                                        return RawApplePayButton(
                                          style: ApplePayButtonStyle.automatic,
                                          onPressed: () {
                                            onGooglePayPressed();
                                          },
                                        );
                                      } else {
                                        return Container();
                                        // userCanPay returned false
                                        // Consider showing an alternative payment method
                                      }
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      height: 0,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Or Pay With Card',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: 0,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),

                              getCardInput(),
                              StreamBuilder<String>(
                                  initialData:
                                      snapshot.data!.data[0].id.toString(),
                                  stream: stripeBloc.planId,
                                  builder: (context, snapshotId) {
                                    return SKButton(
                                      buttonText: 'Pay',
                                      width: MediaQuery.of(context).size.width,
                                      isDark: true,
                                      callback: (context) {
                                        payment(snapshotId.data.toString());
                                      },
                                      margin: EdgeInsets.only(top: 24),
                                    );
                                  }),
                              // Center(
                              //   child: ApplePayButton(
                              //     paymentConfigurationAsset:
                              //         'default_payment_profile_apple_pay.json',
                              //     paymentItems: [
                              //       PaymentItem(
                              //           label: 'Total',
                              //           amount: "20.00",
                              //           status: PaymentItemStatus.final_price,
                              //           type: PaymentItemType.item)
                              //     ],
                              //     onError: (error) {
                              //       print('erroe' + error.toString());
                              //     },
                              //     style: ApplePayButtonStyle.automatic,
                              //     type: ApplePayButtonType.buy,
                              //     margin: const EdgeInsets.only(top: 15.0),
                              //     onPaymentResult: onApplePayResult,
                              //     loadingIndicator: const Center(
                              //       child: CircularProgressIndicator(),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  void onGooglePayPressed() async {
    final result = await _payClient.showPaymentSelector(
      provider: PayProvider.apple_pay,
      paymentItems: [
        PaymentItem(
            label: 'Total',
            amount: selectPlanAmounts.toString(),
            status: PaymentItemStatus.final_price,
            type: PaymentItemType.item)
      ],
    );
    debugPrint(result.toString());
    String tokenToBeSentToCloud = result["token"];
    BehaviorSubject<String> planId = await stripeBloc.planIdCont;
    String planid = await planId.first;
    print(planid);
    startLoading();
    hitSubscriptionApi(planid, tokenToBeSentToCloud);

    // Send the resulting Google Pay token to your server / PSP
  }

  void setError(dynamic error) {
    setState(() {});
  }

  Future<void> onApplePayResult(paymentResult) async {
    debugPrint(paymentResult.toString());
    String tokenToBeSentToCloud = paymentResult["token"];
    BehaviorSubject<String> planId = await stripeBloc.planIdCont;
    hitSubscriptionApi(await planId.last, tokenToBeSentToCloud);
  }
}
