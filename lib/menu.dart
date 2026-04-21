// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:receipt_pro/billing/billing_service.dart';
import 'package:receipt_pro/languages.dart';
import 'package:provider/provider.dart';
import 'package:receipt_pro/services/helpers.dart';
import 'package:receipt_pro/services/storage_service.dart';

import 'main.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:receipt_pro/my_popup_menu_item.dart';

import 'package:http/http.dart' as http;

ProductDetails? productNoAds;

class Menu extends StatefulWidget {
  final BuildContext context;
  final String page;
  final Function updateParent;
  Menu({required this.context, required this.page, required this.updateParent});

  @override
  // ignore: library_private_types_in_public_api
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  late BuildContext mainContext;
  String helpText = "";

  @override
  void initState() {
    mainContext = widget.context;
    if (kIsWeb == false) {
      loadInAppProducts();
    }
    super.initState();
  }

  Future<void> loadInAppProducts() async {
    print("Menu.loadInAppProducts called");
    final InAppPurchase iapInstance = InAppPurchase.instance;
    final Set<String> productIds = {subscribeProductId};
    final ProductDetailsResponse response = await iapInstance
        .queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print(
        "Menu.loadInAppProducts Product IDs not found: ${response.notFoundIDs}",
      );
    } else {
      print("Menu.loadInAppProducts notFoundIDs EMPTY!");
      for (var product in response.productDetails) {
        print("Menu.loadInAppProducts Product ID: ${product.id}");
        print("Menu.loadInAppProducts Title: ${product.title}");
        print("Menu.loadInAppProducts Description: ${product.description}");
        print("Menu.loadInAppProducts Price: ${product.price}");
        print("------------------------");
      }
      ProductDetails? tempProductNoAds = response.productDetails.firstWhere(
        (product) => product.id == subscribeProductId,
      );
      // ignore: unnecessary_null_comparison
      if (tempProductNoAds != null) {
        setState(() {
          print(
            "Menu.loadInAppProducts tempProductNoAds NOT NULL! SETTING priceNoAds = $priceSubscribe, productNoAds...",
          );
          priceSubscribe = tempProductNoAds.price;
          productNoAds = tempProductNoAds;
        });
      }
    }
  }

  Future<void> showSuccessThanksBuy() async {
    print("showSuccessThanksBuy called");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                FlutterI18n.translate(context, "PROMPT_SUCCESS"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  FlutterI18n.translate(context, "THANK_YOU_NO_ADS"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              Icon(Icons.celebration, color: Colors.orange, size: 40),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () async {
                  //await Future.delayed(Duration(milliseconds: 400));
                  setState(() {
                    //isAds = false;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  FlutterI18n.translate(context, "PROMPT_LETS_GO"),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //MyMainState().setSavedLanguage(context);
    return PopupMenuButton<dynamic>(
      padding: EdgeInsets.all(0),
      color: Colors.white,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      icon: Icon(Icons.menu),
      onSelected: (value) {
        print("menu selected value = $value");
        FocusScope.of(context).unfocus();
        if (value == "BUTTON_NO_ADS") {
          print("MENU LOSING FOCUS!!!");
        }
      },
      onOpened: () {
        print("menu opened.");
        widget.updateParent();
      },
      onCanceled: () {
        widget.updateParent();
      },
      itemBuilder: (BuildContext context) {
        return [
          NonDismissingPopupMenuItem<dynamic>(
            value: 'MY POPUP',
            child: MenuList(
              context: context,
              page: widget.page,
              updateParent: widget.updateParent,
            ),
          ),
        ];
      },
    );
  }
}

class MenuList extends StatefulWidget {
  BuildContext context;
  String page;
  Function updateParent;
  MenuList({
    required this.context,
    required this.page,
    required this.updateParent,
  });

  @override
  // ignore: library_private_types_in_public_api
  MenuListState createState() => MenuListState();
}

class MenuListState extends State<MenuList> {
  bool isShowHelp = false;
  bool isRestoring = false;
  bool isFeatureRestoreButton = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    print("menu.changeLanguage called, languageCode = $languageCode");

    //FlutterI18n.refresh(widget.context, Locale(languageCode));
    await Future.delayed(Duration(milliseconds: 400));
    //setState(() {
    //Future.delayed(Duration(milliseconds: 3000), () {
    dynamic myLanguage =
        (languages.where(
          (dynamic language) => language["value"] == languageCode,
        )).toList()[0];
    await StorageService().setData("LANGUAGE", languageCode);
    //context.read<AppData>().setLanguage(myLanguage!);
    //MyMainState().changeLanguage(context, languageCode);
    //MyApp().changeLocale(languageCode);

    await FlutterI18n.refresh(
      Navigator.of(context).context,
      Locale(languageCode),
    );
    widget.updateParent();
    setState(() {});

    print("menu.changeLanguage SELECTED LANGUAGE = $myLanguage");
    //});
    //widget.updateParent();
  }

  Future<void> logout(BuildContext context) async {
    await StorageService().setData("IS_LOGGED_IN", "false");
    await StorageService().removeData("USER");
    await FirebaseAuth.instance.signOut();
    NOW_LOGGED_IN = false;
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (MyUser["Username"] == "GUEST" || MyUser["Username"] == "harryman75") {
      //"Not allowed to remove {uNM} account."
      showPopup(
        context,
        FlutterI18n.translate(
          context,
          "PROMPT_NOT_ALLOWED_DELETE_ACCOUNT",
          translationParams: {"uNM": "'${MyUser["Username"]}'"},
        ),
      );
    } else {
      //Delete Your Account?
      String title = FlutterI18n.translate(context, "DELETE_YOUR_ACCOUNT");
      //Delete {uNM} Account
      //This will remove your account and assign everything you have created to the guest account.
      //ARE YOU SURE?
      //OK, I'll Do It
      String message =
          "<center><strong>${FlutterI18n.translate(context, "PROMPT_DELETE_ACCOUNT1", translationParams: {"uNM": MyUser["Username"]})}</strong><center><br /><center>${FlutterI18n.translate(context, "PROMPT_DELETE_ACCOUNT2")}<br />${FlutterI18n.translate(context, "PROMPT_ARE_YOU_SURE")} ...</center>";
      bool isConfirm = await showConfirm(
        context,
        title,
        message,
        FlutterI18n.translate(context, "PROMPT_CANCEL"),
        FlutterI18n.translate(context, "PROMPT_OK_DO_IT"),
      );
      var url =
          "'https://www.learnfactsquick.com/lfq_app_php/delete_lfq_user.php";
      if (isConfirm == true) {
        dynamic params = {"username": MyUser["Username"]};
        showProgress(
          context,
          FlutterI18n.translate(
            context,
            "PROGRESS_DELETE_ACCOUNT",
            translationParams: {"uNM": MyUser["Username"]},
          ),
        );

        bool isRequestSuccess = true;
        http.Response response = http.Response("", 200);
        try {
          response = await http.post(Uri.parse(url), body: json.encode(params));
        } catch (e) {
          isRequestSuccess = false;
        }
        if (isRequestSuccess == false) {
          //await showPopup(context, "Error initiating app");
        } else {
          if (response.statusCode == 200) {
            // If the server returns a 200 OK response, parse the JSON data
            final Map<String, dynamic> data = json.decode(response.body);
            print("deleteAccount STATUS=200!!!");
            if (data["SUCCESS"] == true) {
              //"Successfully deleted user, {uNM}."
              await showPopup(
                context,
                FlutterI18n.translate(
                  context,
                  "PROMPT_SUCCESS_DELETE_ACCOUNT",
                  translationParams: {"uNM": MyUser["Username"]},
                ),
              );
            } else {
              print(
                "deleteAccount FAILED data['SUCCESS'] = ${data['SUCCESS']}",
              );
              await showPopup(context, data["ERROR"]);
            }
          } else {
            print('deleteAccount Failed to delete account');
            await showPopup(
              context,
              FlutterI18n.translate(context, "NETWORK_ERROR"),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //MyMainState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonFontSize =
        (screenWidth * 0.018 + 4) < 12 ? 12 : (screenWidth * 0.018 + 4);
    double promptFontSize =
        (screenWidth * 0.05 - 3) > 15 ? 15 : (screenWidth * 0.05 - 3);
    String helpText = "";

    List<DropdownMenuItem<String>> languageItems =
        languages.map<DropdownMenuItem<String>>((dynamic lang) {
          return DropdownMenuItem<String>(
            value: lang["value"],
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              child: Text(
                "${lang["name1"]}(${FlutterI18n.translate(context, lang["name2"])})",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: promptFontSize),
              ),
            ),
          );
        }).toList();
    return (widget.page == "home" ||
                widget.page == "create" ||
                widget.page == "edit" ||
                widget.page == "delete" ||
                widget.page == "update") &&
            languages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
          width: screenWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: widget.page != "table",
                  child: Container(
                    width: screenWidth,
                    height: 50,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            // Add your close logic here
                            Navigator.pop(context); // Example
                          },
                        ),
                        Expanded(
                          flex: 1, // adjust flex as needed
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Text(
                                '${FlutterI18n.translate(context, "PROMPT_LANGUAGE")}:',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: promptFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2, // adjust flex as needed
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: DropdownButton<String>(
                              alignment: Alignment.centerRight,
                              isExpanded: true,
                              value: selectedLanguage["value"],
                              onChanged: (newLanguage) {
                                changeLanguage(context, newLanguage!);
                              },
                              items: languageItems,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowHelp == false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        label: Text(
                          FlutterI18n.translate(context, "SHOW_HELP"),
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                        ),
                        onPressed: () async {
                          setState(() {
                            isShowHelp = true;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowHelp == true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        label: Text(
                          FlutterI18n.translate(context, "HIDE_HELP"),
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            isShowHelp = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowHelp == true,
                  child: GestureDetector(
                    onTap: () {
                      print("Help content tapped!");
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [Html(data: helpText)],
                        ),
                      ),
                    ),
                  ),
                ),
                if (NOW_LOGGED_IN == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 232, 184, 175),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      label: Text(
                        FlutterI18n.translate(context, "LOGOUT"),
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        logout(context);
                      },
                    ),
                  ),
                if (NOW_LOGGED_IN == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 219, 158, 148),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      label: Text(
                        FlutterI18n.translate(context, "DELETE_YOUR_ACCOUNT"),
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        deleteAccount(context);
                      },
                    ),
                  ),

                if (isFeatureRestoreButton == true &&
                    (kIsWeb == true || Platform.isIOS))
                  NonDismissingPopupMenuItem(
                    value: "RESTORE_PURCHASES",
                    onTap: () {
                      BillingService().restorePurchases();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.restore, color: Colors.blue),
                        label: Text(
                          isRestoring
                              ? FlutterI18n.translate(
                                context,
                                "PROMPT_RESTORING",
                              )
                              : FlutterI18n.translate(
                                context,
                                "PROMPT_RESTORE_PURCHASES",
                              ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Red text
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // White background
                          foregroundColor: Colors.blue, // Red text/icon color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          minimumSize: Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ), // Red border
                          ),
                          elevation: 5, // Shadow effect
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
  }
}
