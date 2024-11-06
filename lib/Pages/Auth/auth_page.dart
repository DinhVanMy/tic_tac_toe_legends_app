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
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () => Get.toNamed("/settings"),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset("assets/icons/settings.png"),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    IconsPath.applogo,
                    width: 200,
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
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  GifsPath.transformerGif,
                  width: 120,
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
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
                      width: MediaQuery.of(context).size.width / 1.5,
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
                    width: MediaQuery.of(context).size.width / 1.5,
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
                      width: MediaQuery.of(context).size.width / 1.5,
                      color: Colors.grey,
                      onTap: () {
                        authController.loginByGoogle();
                      },
                      iconPath: IconsPath.github),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
