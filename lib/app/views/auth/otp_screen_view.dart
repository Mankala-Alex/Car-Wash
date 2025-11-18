import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
import '../../custome_widgets/custome_form_field_gaps.dart';
import '../../theme/app_theme.dart';

class OtpScreenView extends StatefulWidget {
  const OtpScreenView({super.key});

  @override
  State<OtpScreenView> createState() => _OtpScreenViewState();
}

class _OtpScreenViewState extends State<OtpScreenView> {
  String otp = '';
  bool isOtpValid = true;
  String maskedPhone = '+91 ••••••1234'; // static example

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: customTheme.bgColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenWidth * 0.14),
                          SizedBox(height: screenWidth * 0.09),
                          Text(
                            "Account Verification",
                            style: textTheme.titleMedium?.copyWith(
                              color: customTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 45),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.10,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Enter OTP",
                                      style: TextStyle(
                                        color: customTheme.textLightGray,
                                        fontSize: textTheme.bodySmall?.fontSize,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('OTP Resent'),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Resend OTP",
                                        style: TextStyle(
                                          color: customTheme.primaryColor,
                                          fontSize:
                                              textTheme.bodySmall?.fontSize,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              customTheme.primaryColor,
                                          decorationThickness: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Pinput(
                                    length: 6,
                                    onChanged: (value) {
                                      setState(() {
                                        otp = value;
                                        isOtpValid = value.length == 6;
                                      });
                                    },
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    defaultPinTheme: PinTheme(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      width: screenWidth * 0.17,
                                      height: screenHeight * 0.055,
                                      textStyle: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isOtpValid
                                              ? customTheme.borderLightGray
                                              : customTheme.errorColor,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    focusedPinTheme: PinTheme(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      width: screenWidth * 0.17,
                                      height: screenHeight * 0.075,
                                      textStyle: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isOtpValid
                                              ? customTheme.borderLightGray
                                              : customTheme.errorColor,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ),
                                const CustomeFormVerticalGaps(),
                                Row(
                                  children: [
                                    Text(
                                      maskedPhone,
                                      style: TextStyle(
                                        color: customTheme.textLightGray,
                                        fontSize: textTheme.bodySmall?.fontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Change mobile number tapped'),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Change Mobile Number",
                                        style: TextStyle(
                                          color: customTheme.primaryColor,
                                          fontSize:
                                              textTheme.bodySmall?.fontSize,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              customTheme.textLightGray,
                                          decorationThickness: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: screenHeight * 0.03),
                                  width: double.infinity,
                                  child: ElevatedButton(onPressed: (){Get.toNamed(Routes.dashboard);}, child: const Text("Continue")),
                                  // child: ElevatedButton(
                                  //   onPressed: otp.length == 6
                                  //       ? () {
                                  //           ScaffoldMessenger.of(context)
                                  //               .showSnackBar(
                                  //             SnackBar(
                                  //               content:
                                  //                   Text('OTP Submitted: $otp'),
                                  //             ),
                                  //           );
                                  //           Get.toNamed(Routes.dashboard);
                                  //         }
                                  //       : null,
                                  //   style: ElevatedButton.styleFrom(
                                  //     backgroundColor: otp.length == 6
                                  //         ? customTheme.primaryColor
                                  //         : customTheme.borderGray,
                                  //   ),
                                  //   child: Text(
                                  //     "Continue",
                                  //     style: TextStyle(
                                  //       color: otp.length == 4
                                  //           ? Colors.white
                                  //           : Colors.black,
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
