import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/post_polls_model.dart';
import 'package:uuid/uuid.dart';

class PollController extends GetxController {
  var uuid = const Uuid();
  RxString questionContent = "".obs;
  RxList<TextEditingController> optionControllers = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ].obs;
  Rxn<DateTime> selectedDateTime = Rxn<DateTime>();
  RxBool isComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    everAll([questionContent, optionControllers, selectedDateTime], (_) {
      isComplete.value = _checkCompletion();
    });
  }

  @override
  void onClose() {
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  bool _checkCompletion() {
    return questionContent.isNotEmpty &&
        optionControllers.length >= 2 &&
        optionControllers
            .every((controller) => controller.text.trim().isNotEmpty) &&
        selectedDateTime.value != null &&
        selectedDateTime.value!.isAfter(DateTime.now()) &&
        !_hasDuplicateOptions();
  }

  bool _hasDuplicateOptions() {
    final texts =
        optionControllers.map((c) => c.text.trim().toLowerCase()).toList();
    return texts.toSet().length != texts.length;
  }

  void addOptionField() {
    if (optionControllers.length < 10) {
      optionControllers.add(TextEditingController());
    } else {
      Get.snackbar("Limit Reached", "Maximum 10 options allowed.");
    }
  }

  void removeOptionField(int index) {
    if (optionControllers.length > 2) {
      // Đảm bảo còn ít nhất 2 options
      optionControllers.removeAt(index);
    } else {
      Get.snackbar("Minimum Required", "At least 2 options are required.");
    }
  }

  void setEndDate(DateTime? dateTime) {
    if (dateTime != null && dateTime.isAfter(DateTime.now())) {
      selectedDateTime.value = dateTime;
    } else {
      Get.snackbar("Invalid Date", "End date must be in the future.");
    }
  }

  PostPollsModel createPostPollsModel() {
    String pollId = "${uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}";
    return PostPollsModel(
      pollId: pollId,
      question: questionContent.value.trim(),
      endDate: selectedDateTime.value,
      options: optionControllers
          .asMap()
          .entries
          .map((entry) => OptionalPolls(
                id: entry.key + 1,
                title: entry.value.text.trim(),
                votes: 0,
              ))
          .toList(),
    );
  }
}
