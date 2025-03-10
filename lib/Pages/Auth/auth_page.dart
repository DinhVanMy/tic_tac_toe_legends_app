import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/primary_with_icon_button.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Pages/Login/login_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Registration/Register_sheet.dart';

import '../../Controller/auth_controller.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          IconsPath.applogo,
                          width: 120,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "title_auth".tr,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      "description_auth".tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        GifsPath.chloe1,
                        width: 120,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PrimaryIconWithButton(
                                  buttonText: "Sign in",
                                  onTap: () async {
                                    await loginBottomSheet(context);
                                  },
                                  iconPath: IconsPath.applogo,
                                  isLogo: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: PrimaryIconWithButton(
                                  buttonText: "Sign up",
                                  onTap: () async {
                                    await registerBottomSheet(context);
                                  },
                                  iconPath: IconsPath.applogo,
                                  isLogo: true,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PrimaryIconWithButton(
                            color: Colors.redAccent.withOpacity(0.5),
                            width: double.infinity,
                            buttonText: "google_auth".tr,
                            onTap: () {
                              authController.loginByGoogle();
                            },
                            iconPath: IconsPath.google),
                        const SizedBox(
                          height: 10,
                        ),
                        PrimaryIconWithButton(
                          buttonText: "facebook_auth".tr,
                          width: double.infinity,
                          color: Colors.lightBlueAccent,
                          onTap: () {
                            authController.loginByGoogle();
                          },
                          iconPath: IconsPath.facebook,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PrimaryIconWithButton(
                            buttonText: "github_auth".tr,
                            width: double.infinity,
                            color: Colors.grey,
                            onTap: () {
                              authController.loginByGoogle();
                            },
                            iconPath: IconsPath.github),
                      ],
                    )
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 10,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    splashColor: Colors.blueAccent,
                    onTap: () => Get.toNamed("/settings"),
                    child: Ink(
                      width: 40,
                      height: 40,
                      child: Image.asset("assets/icons/settings.png"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
