import 'package:tictactoe_gameapp/Components/daily_mission/mission_model.dart';

final List<TaskModel> dailyMissions = [
  TaskModel(
    id: 'daily1',
    name: 'Complete 5 games',
    description: 'Play and complete 5 matches in any mode.',
    type: 'daily',
    reward: 50,
    status: 'incomplete',
    progress: 2, // Ví dụ: đã hoàn thành 2 trận
    goal: 5,     // Mục tiêu: hoàn thành 5 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 24)),
  ),
  TaskModel(
    id: 'daily2',
    name: 'Win 3 matches',
    description: 'Win 3 matches in ranked mode.',
    type: 'daily',
    reward: 100,
    status: 'incomplete',
    progress: 1, // Ví dụ: đã thắng 1 trận
    goal: 3,     // Mục tiêu: thắng 3 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 24)),
  ),
  TaskModel(
    id: 'daily3',
    name: 'Play for 30 minutes',
    description: 'Spend at least 30 minutes in the game today.',
    type: 'daily',
    reward: 20,
    status: 'incomplete',
    progress: 15, // Đã chơi 15 phút
    goal: 30,     // Mục tiêu: chơi 30 phút
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 24)),
  ),
  TaskModel(
    id: 'daily4',
    name: 'Score 50 points',
    description: 'Accumulate 50 points in any game mode.',
    type: 'daily',
    reward: 40,
    status: 'incomplete',
    progress: 25, // Đã tích lũy 25 điểm
    goal: 50,     // Mục tiêu: tích lũy 50 điểm
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 24)),
  ),
  TaskModel(
    id: 'daily5',
    name: 'Invite a friend',
    description: 'Invite a friend to play and complete a match together.',
    type: 'daily',
    reward: 30,
    status: 'incomplete',
    progress: 0,  // Chưa mời bạn nào
    goal: 1,      // Mục tiêu: mời 1 bạn
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(hours: 24)),
  ),
];

final List<TaskModel> weeklyMissions = [
  TaskModel(
    id: 'weekly1',
    name: 'Win 10 ranked matches',
    description: 'Win 10 matches in ranked mode this week.',
    type: 'weekly',
    reward: 500,
    status: 'incomplete',
    progress: 4,  // Đã thắng 4 trận
    goal: 10,     // Mục tiêu: thắng 10 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 7)),
  ),
  TaskModel(
    id: 'weekly2',
    name: 'Play 20 games',
    description: 'Complete 20 matches in any mode this week.',
    type: 'weekly',
    reward: 300,
    status: 'incomplete',
    progress: 10, // Đã chơi 10 trận
    goal: 20,     // Mục tiêu: chơi 20 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 7)),
  ),
  TaskModel(
    id: 'weekly3',
    name: 'Accumulate 200 points',
    description: 'Score a total of 200 points across all games this week.',
    type: 'weekly',
    reward: 250,
    status: 'incomplete',
    progress: 100, // Đã tích lũy 100 điểm
    goal: 200,     // Mục tiêu: tích lũy 200 điểm
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 7)),
  ),
  TaskModel(
    id: 'weekly4',
    name: 'Invite 3 friends',
    description: 'Invite 3 different friends to play and complete matches with them.',
    type: 'weekly',
    reward: 150,
    status: 'incomplete',
    progress: 1,   // Đã mời 1 bạn
    goal: 3,       // Mục tiêu: mời 3 bạn
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 7)),
  ),
  TaskModel(
    id: 'weekly5',
    name: 'Spend 5 hours in the game',
    description: 'Spend a total of 5 hours playing the game this week.',
    type: 'weekly',
    reward: 200,
    status: 'incomplete',
    progress: 2,   // Đã chơi 2 giờ
    goal: 5,       // Mục tiêu: chơi 5 giờ
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 7)),
  ),
];

final List<TaskModel> monthlyMissions = [
  TaskModel(
    id: 'monthly1',
    name: 'Win 50 ranked matches',
    description: 'Win 50 matches in ranked mode this month.',
    type: 'monthly',
    reward: 1000,
    status: 'incomplete',
    progress: 20, // Đã thắng 20 trận
    goal: 50,     // Mục tiêu: thắng 50 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 30)),
  ),
  TaskModel(
    id: 'monthly2',
    name: 'Play 100 games',
    description: 'Complete 100 matches in any mode this month.',
    type: 'monthly',
    reward: 800,
    status: 'incomplete',
    progress: 45, // Đã chơi 45 trận
    goal: 100,    // Mục tiêu: chơi 100 trận
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 30)),
  ),
  TaskModel(
    id: 'monthly3',
    name: 'Accumulate 1000 points',
    description: 'Score a total of 1000 points across all games this month.',
    type: 'monthly',
    reward: 750,
    status: 'incomplete',
    progress: 500, // Đã tích lũy 500 điểm
    goal: 1000,    // Mục tiêu: tích lũy 1000 điểm
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 30)),
  ),
  TaskModel(
    id: 'monthly4',
    name: 'Invite 10 friends',
    description: 'Invite 10 friends to play and complete matches with them this month.',
    type: 'monthly',
    reward: 500,
    status: 'incomplete',
    progress: 4,  // Đã mời 4 bạn
    goal: 10,     // Mục tiêu: mời 10 bạn
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 30)),
  ),
  TaskModel(
    id: 'monthly5',
    name: 'Spend 20 hours in the game',
    description: 'Spend a total of 20 hours playing the game this month.',
    type: 'monthly',
    reward: 600,
    status: 'incomplete',
    progress: 8,  // Đã chơi 8 giờ
    goal: 20,     // Mục tiêu: chơi 20 giờ
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deadline: DateTime.now().add(const Duration(days: 30)),
  ),
];


// final List<TaskModel> dailyMissions = [
//   TaskModel(
//     id: 'daily1',
//     name: 'Complete 5 games',
//     description: 'Play and complete 5 matches in any mode.',
//     type: 'daily',
//     reward: 50,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(hours: 24)),
//   ),
//   TaskModel(
//     id: 'daily2',
//     name: 'Win 3 matches',
//     description: 'Win 3 matches in ranked mode.',
//     type: 'daily',
//     reward: 100,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(hours: 24)),
//   ),
//   TaskModel(
//     id: 'daily3',
//     name: 'Play for 30 minutes',
//     description: 'Spend at least 30 minutes in the game today.',
//     type: 'daily',
//     reward: 20,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(hours: 24)),
//   ),
//   TaskModel(
//     id: 'daily4',
//     name: 'Score 50 points',
//     description: 'Accumulate 50 points in any game mode.',
//     type: 'daily',
//     reward: 40,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(hours: 24)),
//   ),
//   TaskModel(
//     id: 'daily5',
//     name: 'Invite a friend',
//     description: 'Invite a friend to play and complete a match together.',
//     type: 'daily',
//     reward: 30,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(hours: 24)),
//   ),
// ];

// final List<TaskModel> weeklyMissions = [
//   TaskModel(
//     id: 'weekly1',
//     name: 'Win 10 ranked matches',
//     description: 'Win 10 matches in ranked mode this week.',
//     type: 'weekly',
//     reward: 500,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 7)),
//   ),
//   TaskModel(
//     id: 'weekly2',
//     name: 'Play 20 games',
//     description: 'Complete 20 matches in any mode this week.',
//     type: 'weekly',
//     reward: 300,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 7)),
//   ),
//   TaskModel(
//     id: 'weekly3',
//     name: 'Accumulate 200 points',
//     description: 'Score a total of 200 points across all games this week.',
//     type: 'weekly',
//     reward: 250,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 7)),
//   ),
//   TaskModel(
//     id: 'weekly4',
//     name: 'Invite 3 friends',
//     description:
//         'Invite 3 different friends to play and complete matches with them.',
//     type: 'weekly',
//     reward: 150,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 7)),
//   ),
//   TaskModel(
//     id: 'weekly5',
//     name: 'Spend 5 hours in the game',
//     description: 'Spend a total of 5 hours playing the game this week.',
//     type: 'weekly',
//     reward: 200,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 7)),
//   ),
// ];

// final List<TaskModel> monthlyMissions = [
//   TaskModel(
//     id: 'monthly1',
//     name: 'Win 50 ranked matches',
//     description: 'Win 50 matches in ranked mode this month.',
//     type: 'monthly',
//     reward: 1000,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 30)),
//   ),
//   TaskModel(
//     id: 'monthly2',
//     name: 'Play 100 games',
//     description: 'Complete 100 matches in any mode this month.',
//     type: 'monthly',
//     reward: 800,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 30)),
//   ),
//   TaskModel(
//     id: 'monthly3',
//     name: 'Accumulate 1000 points',
//     description: 'Score a total of 1000 points across all games this month.',
//     type: 'monthly',
//     reward: 750,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 30)),
//   ),
//   TaskModel(
//     id: 'monthly4',
//     name: 'Invite 10 friends',
//     description:
//         'Invite 10 friends to play and complete matches with them this month.',
//     type: 'monthly',
//     reward: 500,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 30)),
//   ),
//   TaskModel(
//     id: 'monthly5',
//     name: 'Spend 20 hours in the game',
//     description: 'Spend a total of 20 hours playing the game this month.',
//     type: 'monthly',
//     reward: 600,
//     status: 'incomplete',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     deadline: DateTime.now().add(const Duration(days: 30)),
//   ),
// ];
