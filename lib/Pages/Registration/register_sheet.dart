import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/firebase_exception.dart';

Future<void> registerBottomSheet(BuildContext context) async {
  await showFlexibleBottomSheet(
    minHeight: 0,
    initHeight: 0.73,
    maxHeight: 1,
    context: context,
    builder: _buildSignupBottomSheet,
    duration: const Duration(milliseconds: 1000),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      border: Border.all(color: Colors.white, width: 4),
    ),
    // anchors: [0, 0.5, 1],
    isSafeArea: true,
  );
}

final GlobalKey<FormState> formKey = GlobalKey<FormState>();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
final AuthController auth = Get.find<AuthController>();
String password = '';

Widget _buildSignupBottomSheet(
  BuildContext context,
  ScrollController scrollController,
  double bottomSheetOffset,
) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          const Icon(
            Icons.app_registration_outlined,
            color: Colors.white,
            size: 100,
          ),
          const SizedBox(height: 10),
          Text(
            "S I G N  U P",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  validator: emaildValidator.call,
                  autovalidateMode: AutovalidateMode.always,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email address",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: passwordController,
                      validator: passwordValidator.call,
                      autovalidateMode: AutovalidateMode.always,
                      textInputAction: TextInputAction.next,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                      ),
                      onChanged: (val) => password = val,
                    )),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: confirmPasswordController,
                      // validator: (value) {
                      //   if (value != passwordController.text) {
                      //     return "Passwords do not match";
                      //   }
                      //   return null;
                      // },
                      validator: (val) =>
                          MatchValidator(errorText: 'passwords do not match')
                              .validateMatch(val!, password),
                      autovalidateMode: AutovalidateMode.always,
                      textInputAction: TextInputAction.done,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      AuthStatus status = await auth.registerWithEmailPassword(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (status == AuthStatus.successful) {
                        successMessage(
                            "Welcome ${auth.getCurrentUserEmail()} !");
                        Get.offAllNamed("/updateProfile");
                      } else {
                        String error =
                            AuthExceptionHandler.generateErrorMessage(status);
                        errorMessage(error);
                      }
                    }
                  },
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    GifsPath.tictactoeGif,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
