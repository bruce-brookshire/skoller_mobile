import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoller/constants/constants.dart';

class PremiumPackagesView extends StatefulWidget {
  State createState() => _PremiumPackages();
}

class _PremiumPackages extends State<PremiumPackagesView> {
  @override
  Widget build(BuildContext context) {
    return SKNavView(
      title: '',
        rightBtn: Text(
          'Save',
          style: TextStyle(color: SKColors.skoller_blue),
        ),
       leftBtn: Image.asset(ImageNames.navArrowImages.down),
       children: [
         Expanded(
           child: ListView(
             padding: EdgeInsets.only(bottom: 16),
             children: [
               getPlans(),
               getPaymentMethods(),
               getBillingHistory(),
             ],
           ),
         ),      ],
    );
  }

  Widget getPlans(){
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
                  'Premium Plan',
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          Container(
            decoration:BoxDecoration(color: SKColors.menu_blue,  ) ,
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '\$3 per month',
                  style: TextStyle(fontSize: 16, color: SKColors.skoller_blue),
                ),

              ],
            ),
          ),
          Divider(height: 0,),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$30 per year',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Text(
                      'Save 20%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: SKColors.light_gray),
                    ),

                  ],
                ),

              ],
            ),
          ),
          Divider(height: 0,),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$80 lifetime',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Text(
                      'Save 50%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: SKColors.light_gray),
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

  Widget getPaymentMethods(){
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
             padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last Payment',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
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
          Divider(height: 0,),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Payment',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
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
          Divider(height: 0,),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Row(
                      children: [
                        Text(
                          '*****7391',
                          style: TextStyle(fontSize: 16, color: SKColors.dark_gray),
                        ),
                        Icon(Icons.close, color: SKColors.light_gray,)

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

  Widget getBillingHistory(){
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
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'May 21, 2021',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Text(
                      'VIEW PDF',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SKColors.skoller_blue),
                    ),

                  ],
                ),

              ],
            ),
          ),
          Divider(height: 0,),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'April 21, 2021',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Text(
                      'VIEW PDF',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SKColors.skoller_blue),
                    ),

                  ],
                ),

              ],
            ),
          ),
          Divider(height: 0,),
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'March 21, 2021',
                      style: TextStyle(fontSize: 16, color: SKColors.light_gray),
                    ),

                    Text(
                      'VIEW PDF',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SKColors.skoller_blue),
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


}
