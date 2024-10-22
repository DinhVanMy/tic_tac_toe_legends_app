import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/champion_model.dart';

const String url1 = "https://github.com/DinhVanMy?tab=repositories";
const String url2 = "https://poki.com/";
const String apiGemini = "AIzaSyBhZLp795GpY6xGzOd1wnH_7zYVJahHSk4";

//----------------------------------------------------------------
final roomCodeValidator = MultiValidator([
  RequiredValidator(errorText: 'Room code is required'),
]);

final nameProfile = MultiValidator([
  RequiredValidator(errorText: 'Name is required'),
  MinLengthValidator(2, errorText: 'Name must be at least 2 characters long'),
  MaxLengthValidator(30, errorText: 'Name must be at most 30 characters long'),
  PatternValidator(r'^[a-zA-Z\s]*$',
      errorText: 'Name can only contain alphabetic characters'),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";
//----------------------------------------------------------------

const String contentAlertChatBot = """
Alert Message:

"Thank you for your questions! It seems like you have a lot of inquiries. To provide the best assistance, could we please address them one at a time? This way, we can ensure each question gets the attention it deserves. Feel free to let us know which one you'd like to start with!"

""";

class Cards {
  final String title;
  final String image;

  Cards({required this.title, required this.image});
}

final List<Cards> images = [
  Cards(image: Jajas.card0, title: "SPRING"),
  Cards(image: Jajas.card1, title: "SUMMER"),
  Cards(image: Jajas.card2, title: "FALLEN"),
  Cards(image: Jajas.card3, title: "WINTER"),
  Cards(image: Jajas.card4, title: "ETERNAL ERA"),
  Cards(image: Jajas.card5, title: "CHAOS ERA"),
];

List<List<Color>> gradientColors = [
  [Colors.red, Colors.orange], // Gradient đỏ - cam
  [Colors.pink, Colors.purple], // Gradient hồng - tím
  [Colors.blue, Colors.lightBlueAccent], // Gradient xanh dương - xanh nhạt
  [Colors.green, Colors.teal], // Gradient xanh lá - xanh ngọc
  [Colors.yellow, Colors.orange], // Gradient vàng - cam
  [Colors.indigo, Colors.blue], // Gradient chàm - xanh dương
  [Colors.purple, Colors.blueAccent], // Gradient tím - xanh dương nhạt
  [Colors.deepOrange, Colors.orange], // Gradient cam đậm - cam
  [Colors.cyan, Colors.lightGreen], // Gradient xanh lam - xanh lá nhạt
  [Colors.brown, Colors.orangeAccent], // Gradient nâu - cam nhạt
  [Colors.deepPurple, Colors.purpleAccent], // Gradient tím đậm - tím nhạt
  [Colors.teal, Colors.cyanAccent], // Gradient xanh ngọc - xanh nhạt
  [Colors.lime, Colors.yellow], // Gradient chanh - vàng
  [Colors.amber, Colors.redAccent], // Gradient vàng hổ phách - đỏ nhạt
  [Colors.blueGrey, Colors.grey], // Gradient xanh xám - xám
  [Colors.lightBlue, Colors.tealAccent], // Gradient xanh nhạt - xanh ngọc nhạt
  [Colors.pinkAccent, Colors.deepPurpleAccent], // Gradient hồng nhạt - tím đậm
  [
    Colors.greenAccent,
    Colors.limeAccent
  ], // Gradient xanh nhạt - xanh chanh nhạt
  [Colors.yellowAccent, Colors.orangeAccent], // Gradient vàng nhạt - cam nhạt
  [
    Colors.lightGreenAccent,
    Colors.cyanAccent
  ], // Gradient xanh lá nhạt - xanh lam nhạt
];

final List<String> quickChatMessages = [
  "Let's set up an ambush.",
  "Clear the minion wave!",
  "Let me get the buff.",
  "Rally for a team fight!",
  "Hold them off. I'll take the towers!",
  "Attack the Abyssal Dragon!",
  "Hang on, I'm on my way!",
  "Everyone push mid!",
  "Watch the jungle!",
  "Don't overextend! Get back to farming.",
];

const List<String> listChamA = [
  ChampionsPathA.aatrox,
  ChampionsPathA.ahri,
  ChampionsPathA.akali,
  ChampionsPathA.alistar,
  ChampionsPathA.annie,
  ChampionsPathA.anivia,
  ChampionsPathA.aphelios,
  ChampionsPathA.ashe,
  ChampionsPathA.aurelionSol,
  ChampionsPathA.aurora,
  ChampionsPathA.belveth,
  ChampionsPathA.brand,
  ChampionsPathA.caitlyn,
  ChampionsPathA.camille,
  ChampionsPathA.darius,
  ChampionsPathA.diana,
  ChampionsPathA.evelynn,
  ChampionsPathA.ezreal,
  ChampionsPathA.fiora,
  ChampionsPathA.gwen,
  ChampionsPathA.jinx,
  ChampionsPathA.kalista,
  ChampionsPathA.karma,
  ChampionsPathA.katarina,
  ChampionsPathA.kayle,
  ChampionsPathA.kayn,
  ChampionsPathA.leblanc,
];

const List<String> listChamB = [
  ChampionsPathB.lillia,
  ChampionsPathB.lux,
  ChampionsPathB.masterYi,
  ChampionsPathB.missfortune,
  ChampionsPathB.nasus,
  ChampionsPathB.nautilus,
  ChampionsPathB.nunu,
  ChampionsPathB.qi,
  ChampionsPathB.quinn,
  ChampionsPathB.rengar,
  ChampionsPathB.riven,
  ChampionsPathB.seraphine,
  ChampionsPathB.sivir,
  ChampionsPathB.sona,
  ChampionsPathB.sylas,
  ChampionsPathB.talon,
  ChampionsPathB.teemo,
  ChampionsPathB.tryndamere,
  ChampionsPathB.twistedFate,
  ChampionsPathB.varus,
  ChampionsPathB.viego,
  ChampionsPathB.volibear,
  ChampionsPathB.yasuo,
  ChampionsPathB.yone,
  ChampionsPathB.zed,
  ChampionsPathB.zoe,
];

const List<String> listChampions = [
  ChampionsPathA.aatrox,
  ChampionsPathA.ahri,
  ChampionsPathA.akali,
  ChampionsPathA.alistar,
  ChampionsPathA.annie,
  ChampionsPathA.anivia,
  ChampionsPathA.aphelios,
  ChampionsPathA.ashe,
  ChampionsPathA.aurelionSol,
  ChampionsPathA.aurora,
  ChampionsPathA.belveth,
  ChampionsPathA.brand,
  ChampionsPathA.caitlyn,
  ChampionsPathA.camille,
  ChampionsPathA.darius,
  ChampionsPathA.diana,
  ChampionsPathA.evelynn,
  ChampionsPathA.ezreal,
  ChampionsPathA.fiora,
  ChampionsPathA.gwen,
  ChampionsPathA.jinx,
  ChampionsPathA.kalista,
  ChampionsPathA.karma,
  ChampionsPathA.katarina,
  ChampionsPathA.kayle,
  ChampionsPathA.kayn,
  ChampionsPathA.leblanc,
  ChampionsPathB.lillia,
  ChampionsPathB.lux,
  ChampionsPathB.masterYi,
  ChampionsPathB.missfortune,
  ChampionsPathB.nasus,
  ChampionsPathB.nautilus,
  ChampionsPathB.nunu,
  ChampionsPathB.qi,
  ChampionsPathB.quinn,
  ChampionsPathB.rengar,
  ChampionsPathB.riven,
  ChampionsPathB.seraphine,
  ChampionsPathB.sivir,
  ChampionsPathB.sona,
  ChampionsPathB.sylas,
  ChampionsPathB.talon,
  ChampionsPathB.teemo,
  ChampionsPathB.tryndamere,
  ChampionsPathB.twistedFate,
  ChampionsPathB.varus,
  ChampionsPathB.viego,
  ChampionsPathB.volibear,
  ChampionsPathB.yasuo,
  ChampionsPathB.yone,
  ChampionsPathB.zed,
  ChampionsPathB.zoe,
];

final List<ChampionModel> listChampionModels = [
  ChampionModel(image: ChampionsPathA.aatrox, name: 'Aatrox'),
  ChampionModel(image: ChampionsPathA.ahri, name: 'Ahri'),
  ChampionModel(image: ChampionsPathA.akali, name: 'Aatrox'),
  ChampionModel(image: ChampionsPathA.alistar, name: 'Aatrox'),
];

const List<String> listChampName = [
  "aatrox",
  "aatrox",
  "ahri",
  "akali",
  "alistar",
  "annie",
  "anivia",
  "aphelios",
  "ashe",
  "aurelionSol",
  "aurora",
  "belveth",
  "brand",
  "caitlyn",
  "camille",
  "darius",
  "diana",
  "evelynn",
  "ezreal",
  "fiora",
  "gwen",
  "jinx",
  "kalista",
  "karma",
  "katarina",
  "kayle",
  "kayn",
  "leblanc",
  "lillia",
  "lux",
  "masterYi",
  "missfortune",
  "nasus",
  "nautilus",
  "nunu",
  "qi",
  "quinn",
  "rengar",
  "riven",
  "seraphine",
  "sivir",
  "sona",
  "sylas",
  "talon",
  "teemo",
  "tryndamere",
  "twistedFate",
  "varus",
  "viego",
  "volibear",
  "yasuo",
  "yone",
  "zed",
  "zoe",
];

const List<String> listChamNameA = [
  "aatrox",
  "ahri",
  "akali",
  "alistar",
  "annie",
  "anivia",
  "aphelios",
  "ashe",
  "aurelionSol",
  "aurora",
  "belveth",
  "brand",
  "caitlyn",
  "camille",
  "darius",
  "diana",
  "evelynn",
  "ezreal",
  "fiora",
  "gwen",
  "jinx",
  "kalista",
  "karma",
  "katarina",
  "kayle",
  "kayn",
  "leblanc",
];
const List<String> listChamNameB = [
  "lillia",
  "lux",
  "masterYi",
  "missfortune",
  "nasus",
  "nautilus",
  "nunu",
  "qi",
  "quinn",
  "rengar",
  "riven",
  "seraphine",
  "sivir",
  "sona",
  "sylas",
  "talon",
  "teemo",
  "tryndamere",
  "twistedFate",
  "varus",
  "viego",
  "volibear",
  "yasuo",
  "yone",
  "zed",
  "zoe",
];

const List<String> imagePaths = [
  ImagePath.map1,
  ImagePath.map2,
  ImagePath.map4,
  ImagePath.map5,
  ImagePath.map6,
  ImagePath.map7,
  ImagePath.map8,
  ImagePath.map9,
  ImagePath.map10,
];

const List<String> emotes = [
  Emotes.angryKittenEmote,
  Emotes.beeHappyEmote,
  Emotes.beeMadEmote,
  Emotes.beeSadEmote,
  Emotes.cupEmote,
  Emotes.despairEmote,
  Emotes.dressedToKillEmote,
  Emotes.goodAsGoldEmote,
  Emotes.howDareEmote,
  Emotes.happyToSeeUEmote,
  Emotes.lookingForEmote,
  Emotes.penguEmote,
  Emotes.sadKittenEmote,
  Emotes.seeEmote,
  Emotes.starRikuEmote,
  Emotes.starSakiEmote,
  Emotes.starTowaEmote,
  Emotes.thumbsUpEmote,
];
