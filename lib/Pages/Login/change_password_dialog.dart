import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Enums/firebase_exception.dart';

class PasswordChangeDialog {
  static Future<void> showPasswordChangeDialogWhenNotUser() async {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final AuthController auth = Get.find<AuthController>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  validator: emaildValidator.call,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    fillColor: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: oldPasswordController,
                      validator: passwordValidator.call,
                      textInputAction: TextInputAction.next,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "Old Password",
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                        fillColor: Colors.blueGrey,
                      ),
                    )),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: newPasswordController,
                      validator: passwordValidator.call,
                      textInputAction: TextInputAction.done,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                        fillColor: Colors.blueGrey,
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          AuthStatus status =
                              await auth.changePasswordWhenNotUser(
                            oldPasswordController.text.trim(),
                            newPasswordController.text.trim(),
                            emailController.text.trim(),
                          );
                          if (status == AuthStatus.successful) {
                            successMessage(
                                "Changed Password ${auth.getCurrentUserEmail()} successfully !");
                            Get.offAllNamed("/auth");
                          } else {
                            String error =
                                AuthExceptionHandler.generateErrorMessage(
                                    status);
                            errorMessage(error);
                          }
                        }
                      },
                      child: const Text('  OK  '),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showPasswordChangeDialogWhenUser() async {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final AuthController auth = Get.find<AuthController>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  validator: emaildValidator.call,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    fillColor: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: oldPasswordController,
                      validator: passwordValidator.call,
                      textInputAction: TextInputAction.next,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "Old Password",
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                        fillColor: Colors.blueGrey,
                      ),
                    )),
                const SizedBox(height: 10),
                Obx(() => TextFormField(
                      controller: newPasswordController,
                      validator: passwordValidator.call,
                      textInputAction: TextInputAction.done,
                      obscureText: auth.obscure.value,
                      decoration: InputDecoration(
                        hintText: "New Password",
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            !auth.obscure.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: auth.togglePasswordVisibility,
                        ),
                        fillColor: Colors.blueGrey,
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          AuthStatus status = await auth.changePasswordWhenUser(
                            oldPasswordController.text.trim(),
                            newPasswordController.text.trim(),
                            emailController.text.trim(),
                          );
                          if (status == AuthStatus.successful) {
                            successMessage(
                                "Changed Password ${auth.getCurrentUserEmail()} successfully !");
                            Get.offAllNamed("/mainHome");
                          } else {
                            String error =
                                AuthExceptionHandler.generateErrorMessage(
                                    status);
                            errorMessage(error);
                          }
                        }
                      },
                      child: const Text('  OK  '),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
