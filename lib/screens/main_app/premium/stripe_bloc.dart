import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:skoller/constants/BaseUtilities.dart';
import 'package:skoller/model/plans_model.dart';
import 'package:skoller/web_services/bloc_provider.dart';
import 'package:skoller/web_services/web_service_client.dart';

class StripeBloc implements BlocBase{

  var allPlansCont = BehaviorSubject<PlansModel>();
  Stream<PlansModel>  get allPlans => allPlansCont.stream;
  var planIdCont = BehaviorSubject<String>();
  Stream<String> get planId => planIdCont.stream;

  Future AlPlans()  async{
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
              Utilities.showErrorMessage(
                  "Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage(
                  "Phone already exist");
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
          var parsedResponse = PlansModel.fromJson(decoded);
          allPlansCont.sink.add(parsedResponse);
        }
      }
    }).catchError((error) {
      Utilities.showErrorMessage("Something is broken \n $error");
      print("errro $error");
      return false;
    });
  }

  Future saveCardAndSubscription(Map<String, dynamic> params)  async{
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
              Utilities.showErrorMessage(
                  "Invalid Code!");
              break;
            }
          case WebError.ALREADY_EXIST:
            {
              Utilities.showErrorMessage(
                  "Phone already exist");
              break;
            }
          case WebError.BAD_REQUEST:
            {
              Utilities.showErrorMessage(
                  "Internal Server Error");
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



  @override
  void dispose() {
    // TODO: implement dispose
  allPlansCont.close();
  planIdCont.close();
  }

}
StripeBloc stripeBloc = StripeBloc();