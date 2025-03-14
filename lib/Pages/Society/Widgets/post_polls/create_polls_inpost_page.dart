import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/poll_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/text_field_custom_widget.dart';

class CreatePollsInpostPage extends StatelessWidget {
  const CreatePollsInpostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PollController pollController = Get.put(PollController());
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: false,
        title: Text(
          "Create a poll in your post",
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          Obx(() {
            return InkWell(
              onTap: pollController.isComplete.value
                  ? () =>
                      Get.back(result: pollController.createPostPollsModel())
                  : null,
              child: Ink(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  color: pollController.isComplete.value
                      ? Colors.blueAccent
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Done",
                    style: theme.textTheme.bodyLarge!.copyWith(
                        color: pollController.isComplete.value
                            ? Colors.white
                            : Colors.black45),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your question *",
                  style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(
                height: 5,
              ),
              TextFieldCustomWidget(
                fieldHeight: 120,
                maxLength: 140,
                labelText: "Add question",
                onChanged: (value) {
                  pollController.questionContent.value = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Option *", style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(
                height: 5,
              ),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Required Options",
                        style: TextStyle(color: Colors.grey),
                      ),
                      ...List.generate(2, (index) {
                        return OptionField(
                          controller: pollController.optionControllers[index],
                          hintText: "Required Option ${index + 1}",
                        );
                      }),
                      const Divider(),
                      const Text(
                        "Optional Options",
                        style: TextStyle(color: Colors.grey),
                      ),
                      ...pollController.optionControllers
                          .sublist(2)
                          .asMap()
                          .entries
                          .map((entry) => OptionField(
                                controller: entry.value,
                                hintText: "Optional Option ${entry.key + 3}",
                                onRemove: () => pollController
                                    .removeOptionField(entry.key + 2),
                              )),
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  maximumSize: const Size(150, 50),
                  foregroundColor: Colors.blueAccent,
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    // The button's outline is defined as a rounded rectangle with circular corners
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  pollController.addOptionField();
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Add option"),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Deadline of poll *",
                  style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Obx(() => Text(
                          pollController.selectedDateTime.value != null
                              ? TimeFunctions.formatDateTime(
                                  pollController.selectedDateTime.value!)
                              : 'No date/time selected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size(150, 50),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final result = await TimeFunctions.pickDateTime(context,
                          initialDateTime: DateTime.now());
                      if (result != null) {
                        pollController.selectedDateTime.value = result;
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.timer),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Deadline'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OptionField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onRemove;

  const OptionField({
    required this.controller,
    required this.hintText,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 35,
              ),
            ),
        ],
      ),
    );
  }
}
