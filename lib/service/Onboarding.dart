/*
 * Copyright 2020 Board of Trustees of the University of Illinois.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:illinois/service/FlexUI.dart';
import 'package:illinois/service/NotificationService.dart';
import 'package:illinois/service/Service.dart';
import 'package:illinois/service/Storage.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingConsentPanel.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingFinalPanel.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingHowItWorks.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingIntroPanel.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingQrCodePanel.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingResidentInfoPanel.dart';
import 'package:illinois/ui/health/onboarding/Covid19OnBoardingReviewScanPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingAuthBluetoothPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingLoginPhoneConfirmPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingGetStartedPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingAuthLocationPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingLoginNetIdPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingLoginPhonePanel.dart';
import 'package:illinois/ui/onboarding/OnboardingAuthNotificationsPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingRolesPanel.dart';
import 'package:illinois/ui/onboarding/OnboardingLoginPhoneVerifyPanel.dart';

class Onboarding extends Service implements NotificationsListener{

  static const String notifyFinished  = "edu.illinois.rokwire.onboarding.finished";

  List<dynamic> _contentCodes;

  // Singleton Factory

  Onboarding._internal();
  static final Onboarding _instance = Onboarding._internal();

  factory Onboarding() {
    return _instance;
  }

  Onboarding get instance {
    return _instance;
  }

  // Implementation

  @override
  void createService() {
    super.createService();
    NotificationService().subscribe(this,[
      FlexUI.notifyChanged,
    ]);
  }

  @override
  Future<void> initService() async{
    await super.initService();
    _loadContentCodes();
  }

  @override
  void destroyService() {
    super.destroyService();
    NotificationService().unsubscribe(this);
  }

  Set<Service> get serviceDependsOn {
    return Set<Service>.from([Storage(), FlexUI()]);
  }

  void onNotification(String name, dynamic param){
    if(name == FlexUI.notifyChanged){
      _loadContentCodes();
    }
  }

  void _loadContentCodes(){
    _contentCodes = FlexUI()['onboarding'];
  }

  Widget get startPanel {
    for (int index = 0; index < _contentCodes.length; index++) {
      OnboardingPanel nextPanel = _createPanel(name: _contentCodes[index], context: {});
      if ((nextPanel != null) && nextPanel.onboardingCanDisplay) {
        return nextPanel as Widget;
      }
    }
    return null;
  }

  Future<void> next(BuildContext context, OnboardingPanel panel, {bool replace = false}) async {
    dynamic nextPanel = await _nextPanel(panel);
    if (nextPanel is Widget) {
      if (replace) {
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => nextPanel));
      }
      else {
        Navigator.push(context, CupertinoPageRoute(builder: (context) => nextPanel));
      }
    }
    else if ((nextPanel is bool) && !nextPanel) {
      finish(context);
    }
  }

  void finish(BuildContext context) {
    NotificationService().notify(notifyFinished, context);
  }

  Future<dynamic> _nextPanel(OnboardingPanel panel) async {
    int nextPanelIndex;
    if (panel == null) {
      nextPanelIndex = 0;
    }
    else {
      String panelName = _getPanelCode(panel: panel);
      int panelIndex = _contentCodes.indexOf(panelName);
      if (0 <= panelIndex) {
        nextPanelIndex = panelIndex + 1;
      }
    }

    if (nextPanelIndex != null) {
      while (nextPanelIndex < _contentCodes.length) {
        String nextPanelName = _contentCodes[nextPanelIndex];
        OnboardingPanel nextPanel = _createPanel(name: nextPanelName, context: panel?.onboardingContext ?? {});
        if ((nextPanel != null) && nextPanel.onboardingCanDisplay && await nextPanel.onboardingCanDisplayAsync) {
          return nextPanel as Widget;
        }
        else {
          nextPanelIndex++;
        }
      }
      return false;
    }
    return null;
  }

  OnboardingPanel _createPanel({String name, Map<String, dynamic> context}) {
    switch (name) {
      case "get_started": return OnboardingGetStartedPanel(onboardingContext: context);
      case "notifications_auth": return OnboardingAuthNotificationsPanel(onboardingContext: context);
      case "location_auth": return OnboardingAuthLocationPanel(onboardingContext: context);
      case "bluetooth_auth": return OnboardingAuthBluetoothPanel(onboardingContext: context);
      case "roles": return OnboardingRolesPanel(onboardingContext: context);
      case "login_netid": return OnboardingLoginNetIdPanel(onboardingContext: context);
      case "login_phone": return OnboardingLoginPhonePanel(onboardingContext: context);
      case "verify_phone": return OnboardingLoginPhoneVerifyPanel(onboardingContext: context);
      case "confirm_phone": return OnboardingLoginPhoneConfirmPanel(onboardingContext: context);
      case "covid19_resident_info": return Covid19OnBoardingResidentInfoPanel(onboardingContext: context);
      case "covid19_review_scan": return Covid19OnBoardingReviewScanPanel(onboardingContext: context);
      case "covid19_intro": return Covid19OnBoardingIntroPanel(onboardingContext: context);
      case "covid19_how_it_works": return Covid19OnBoardingHowItWorks(onboardingContext: context);
      case "covid19_consent": return Covid19OnBoardingConsentPanel(onboardingContext: context);
      case "covid19_qrcode": return Covid19OnBoardingQrCodePanel(onboardingContext: context);
      case "covid19_final": return Covid19OnBoardingFinalPanel(onboardingContext: context);
    }
    return null;
  }

  static String _getPanelCode({OnboardingPanel panel}) {
    if (panel is OnboardingGetStartedPanel) {
      return 'get_started';
    }
    else if (panel is OnboardingAuthNotificationsPanel) {
      return 'notifications_auth';
    }
    else if (panel is OnboardingAuthLocationPanel) {
      return 'location_auth';
    }
    else if (panel is OnboardingAuthBluetoothPanel) {
      return 'bluetooth_auth';
    }
    else if (panel is OnboardingRolesPanel) {
      return 'roles';
    }
    else if (panel is OnboardingLoginNetIdPanel) {
      return 'login_netid';
    }
    else if (panel is OnboardingLoginPhonePanel) {
      return 'login_phone';
    }
    else if (panel is OnboardingLoginPhoneVerifyPanel) {
      return 'verify_phone';
    }
    else if (panel is OnboardingLoginPhoneConfirmPanel) {
      return 'confirm_phone';
    }
    else if (panel is Covid19OnBoardingResidentInfoPanel) {
      return 'covid19_resident_info';
    }
    else if (panel is Covid19OnBoardingReviewScanPanel) {
      return 'covid19_review_scan';
    }
    else if (panel is Covid19OnBoardingIntroPanel) {
      return 'covid19_intro';
    }
    else if (panel is Covid19OnBoardingHowItWorks) {
      return 'covid19_how_it_works';
    }
    else if (panel is Covid19OnBoardingConsentPanel) {
      return 'covid19_consent';
    }
    else if (panel is Covid19OnBoardingQrCodePanel) {
      return 'covid19_qrcode';
    }
    else if (panel is Covid19OnBoardingFinalPanel) {
      return 'covid19_final';
    }
    return null;
  }
}

abstract class OnboardingPanel {
  
  Map<String, dynamic> get onboardingContext {
    return null;
  }
  
  bool get onboardingCanDisplay {
    return true;
  }

  Future<bool> get onboardingCanDisplayAsync async {
    return true;
  }
}