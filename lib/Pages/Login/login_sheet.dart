import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Enums/firebase_exception.dart';
import 'package:tictactoe_gameapp/Pages/Login/change_password_dialog.dart';

Future<void> loginBottomSheet(BuildContext context) async {
  await showFlexibleBottomSheet(
    minHeight: 0,
    initHeight: 0.7,
    maxHeight: 1,
    context: context,
    builder: _buildLoginBottomSheet,
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
final GlobalKey<FormState> formKeyReset = GlobalKey<FormState>();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController emailResetController = TextEditingController();
final AuthController auth = Get.find<AuthController>();

Widget _buildLoginBottomSheet(
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
            Icons.login_outlined,
            color: Colors.white,
            size: 100,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "L O G I N",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
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
                Obx(
                  () => TextFormField(
                    controller: passwordController,
                    validator: passwordValidator.call,
                    autovalidateMode: AutovalidateMode.always,
                    textInputAction: TextInputAction.done,
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
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await PasswordChangeDialog
                            .showPasswordChangeDialogWhenNotUser();
                      },
                      child: const Text(
                        "Change your password?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.defaultDialog(
                          // cancel: MaterialButton(
                          //   color: Colors.redAccent,
                          //   onPressed: () {
                          //     Get.back();
                          //   },
                          //   child: const Text("Cancel"),
                          // ),
                          // confirm: MaterialButton(
                          //   color: Colors.greenAccent,
                          //   onPressed: () {},
                          //   child: const Text("Confirm"),
                          // ),
                          content: Form(
                            key: formKeyReset,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailResetController,
                                  validator: emaildValidator.call,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  autovalidateMode: AutovalidateMode.always,
                                  decoration: InputDecoration(
                                    hintText: "email",
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade300,
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide(
                                        color: Colors.red.shade300,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide(
                                        color: Colors.red.shade500,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                MaterialButton(
                                  color: Colors.greenAccent,
                                  disabledColor: Colors.redAccent,
                                  splashColor: Colors.greenAccent,
                                  onPressed: () async {
                                    if (formKeyReset.currentState!.validate()) {
                                      AuthStatus status =
                                          await auth.resetPassword(
                                              email: emailResetController.text
                                                  .trim());
                                      if (status == AuthStatus.successful) {
                                        successMessage(
                                            "Resetting ${auth.getCurrentUserEmail()} successfully !");
                                        Get.offAllNamed("/auth");
                                      } else {
                                        String error = AuthExceptionHandler
                                            .generateErrorMessage(status);
                                        errorMessage(error);
                                      }
                                    }
                                  },
                                  child: const Text("Reset"),
                                ),
                              ],
                            ),
                          ),
                          title: "Reset Password",
                        );
                      },
                      child: const Text(
                        "Reset your password?",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      AuthStatus status = await auth.signInWithEmailPassword(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (status == AuthStatus.successful) {
                        successMessage(
                            "Welcome ${auth.getCurrentUserEmail()} !");
                      } else {
                        String error =
                            AuthExceptionHandler.generateErrorMessage(status);
                        errorMessage(error);
                      }
                    }
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
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
  );
}
