import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/tinder_cards/example_model_card.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/tinder_cards/tinder_cards_controller.dart';

class MapFriendTinderWidget extends StatelessWidget {
  final List<UserModel> users;
  final int initialIndex;
  const MapFriendTinderWidget({
    super.key,
    required this.users,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final TinderCardController controller =
        Get.put(TinderCardController(colorsLength: users.length));

    return Column(
      children: [
        Flexible(
          child: CardSwiper(
            controller: controller.cardController,
            initialIndex: initialIndex,
            cardsCount: users.length,
            onSwipe: controller.onSwipe,
            onUndo: controller.onUndo,
            numberOfCardsDisplayed: users.length < 3 ? users.length : 3,
            backCardOffset: const Offset(40, 40),
            padding: const EdgeInsets.all(0.0),
            cardBuilder: (context, index, horizontalThresholdPercentage,
                    verticalThresholdPercentage) =>
                CardTinderWidget(
              user: users[index],
              colors: controller.newGradients[index],
              index: initialIndex,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        _interactCardFAB(controller),
      ],
    );
  }

  Widget _interactCardFAB(TinderCardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FloatingActionButton(
          heroTag: "1",
          elevation: 5.0,
          onPressed: controller.undo,
          child: const Icon(
            Icons.rotate_90_degrees_ccw_rounded,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
        FloatingActionButton(
          heroTag: "2",
          onPressed: () => controller.swipe(CardSwiperDirection.left),
          child: const Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
        FloatingActionButton(
          heroTag: "3",
          onPressed: () => controller.swipe(CardSwiperDirection.right),
          child: const Icon(
            Icons.keyboard_arrow_right,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
        FloatingActionButton(
          heroTag: "4",
          onPressed: () => controller.swipe(CardSwiperDirection.top),
          child: const Icon(
            Icons.keyboard_arrow_up,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
        FloatingActionButton(
          heroTag: "5",
          onPressed: () => controller.swipe(CardSwiperDirection.bottom),
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
