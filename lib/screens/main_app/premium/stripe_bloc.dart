import 'dart:async';
import 'dart:convert';

import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/constants/constants.dart';
import 'package:skoller/model/my_subscriptions.dart';
import 'package:skoller/model/plans_model.dart';
import 'package:skoller/web_services/bloc_provider.dart';
import 'package:skoller/web_services/web_service_client.dart';

class StripeBloc implements BlocBase {
  var allPlansCont = BehaviorSubject<PlansModel>();

  Stream<PlansModel> get allPlans => allPlansCont.stream;

  var mySubscriptions = BehaviorSubject<MySubscriptions>();

  Stream<MySubscriptions> get mySubscription => mySubscriptions.stream;

  var planIdCont = BehaviorSubject<String>();

  Stream<String> get planId => planIdCont.stream;

  Future AlPlans() async {
    return WebServiceClient.AllPlans().then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          var decoded = json.decode(response);
          PlansModel parsedResponse = PlansModel.fromJson(decoded);
          parsedResponse.data.sort((a, b) =>
              int.parse(a.price.toString().replaceAll(".", "")).compareTo(
                  int.parse(b.price.toString().replaceAll(".", ""))));
          // PlansModel plansModel = (PlansModel.fromJson(parsedResponse));
          PlansModel model = PlansModel(data: [
            PlansModelData(
                active: false,
                amount: 8000,
                amountDecimal: '8000',
                created: 1630572175,
                currency: 'inr',
                price: '80.0',
                id: 'price_1JYF3sSGLvMTa3qVrsx7uADn',
                interval: 'lifetime',
                intervalCount: 1,
                name: '',
                product: 'prod_KRv2Bs7sRlUaRB')
          ]);

          parsedResponse.data.addAll(model.data);

          allPlansCont.sink.add(parsedResponse);
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future saveCardAndSubscription(Map<String, dynamic> params) async {
    return WebServiceClient.saveCarAndSub(params).then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          case WebError.BAD_REQUEST:
            {
              Utilities.showErrorMessage("Internal Server Error");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          var decodedRes = json.decode(response);
          Utilities.showSuccessMessage(decodedRes['message']);
          return true;
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future updateSub(Map<String, dynamic> params) async {
    return WebServiceClient.updateSub(params).then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          case WebError.BAD_REQUEST:
            {
              Utilities.showErrorMessage("Internal Server Error");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          var decodedRes = json.decode(response);
          print(decodedRes);
          return true;
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future mySubscriptionsList() async {
    return WebServiceClient.mySub().then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          var decoded = json.decode(response);
          var parsedResponse = MySubscriptions.fromJson(decoded);

          Subscriptions.mySubscriptions = parsedResponse;
          mySubscriptions.sink.add(parsedResponse);

          /// Notify subscription listeners
          DartNotificationCenter.post(
              channel: NotificationChannels.subscriptionChanged);
          return true;
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future cancelSubscriptions(Map<String, dynamic> params) async {
    return WebServiceClient.cancelSub(params).then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          return true;
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future<bool> sendInAppPurchaseToBackend(Map<String, dynamic> params) async {
    return WebServiceClient.sendInAppPurchaseToBackend(params)
        .then((response) async {
      if (response is WebError) {
        switch (response) {
          case WebError.INTERNAL_SERVER_ERROR:
            {
              Utilities.showErrorMessage(
                  "Unable to reach server. Please check connection.");
              break;
            }
          case WebError.UNAUTHORIZED:
            {
              Utilities.showErrorMessage("Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage("Phone already exist");
              break;
            }
          case WebError.BAD_REQUEST:
            {
              Utilities.showErrorMessage("Internal Server Error");
              break;
            }
          default:
            Utilities.showErrorMessage(
                "Something went unexpectedly wrong. Please try again later");
            break;
        }
        return false;
      } else {
        if (response == null) {
          Utilities.showErrorMessage(
              "Something went unexpectedly wrong. Please try again later");
          return false;
        } else {
          var decodedRes = json.decode(response);
          print(decodedRes);
          return true;
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    allPlansCont.close();
    mySubscriptions.close();
    planIdCont.close();
  }
}

StripeBloc stripeBloc = StripeBloc();
