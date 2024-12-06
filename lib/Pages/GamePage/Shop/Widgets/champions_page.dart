import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';
import 'package:tictactoe_gameapp/Models/champion_model.dart';

class ChampionsPage extends StatelessWidget {
  const ChampionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 10.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: GradientGeneratorFunctions.getDynamicRandomGradientColors(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 40,
            crossAxisSpacing: 20,
            childAspectRatio: 0.6,
          ),
          itemCount: listChampions.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 5,
                      ),
                    ),
                    child: Image.asset(
                      listChampions[index],
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  ChampionModel.capitalize(listChampName[index + 1]),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 40,
                  width: 120,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "999 Coins",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 14,
                        ),
                      ),
                      SvgPicture.asset(IconsPath.coinIcon),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
