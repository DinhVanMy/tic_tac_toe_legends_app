import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';

class GameManagementTab extends StatefulWidget {
  const GameManagementTab({super.key});

  @override
  State<GameManagementTab> createState() => _GameManagementTabState();
}

class _GameManagementTabState extends State<GameManagementTab>
    with SingleTickerProviderStateMixin {
  late TabController _gameTabController;

  @override
  void initState() {
    super.initState();
    _gameTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _gameTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameSelector(controller),
          const SizedBox(height: 24),
          // Game tab selector
          TabBar(
            controller: _gameTabController,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Configuration'),
              Tab(text: 'Leaderboard'),
              Tab(text: 'Statistics'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingLeaderboards.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _gameTabController,
                children: [
                  _buildGameConfigTab(controller),
                  _buildLeaderboardTab(controller),
                  _buildGameStatsTab(controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSelector(AdminController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGameButton(
                    controller,
                    'tictactoe',
                    'Tic Tac Toe',
                    Icons.grid_3x3,
                  ),
                  _buildGameButton(
                    controller,
                    'sudoku',
                    'Sudoku',
                    Icons.grid_4x4,
                  ),
                  _buildGameButton(
                    controller,
                    'minesweeper',
                    'Minesweeper',
                    Icons.flag,
                  ),
                  _buildGameButton(
                    controller,
                    'match3',
                    'Match 3',
                    Icons.view_comfy,
                  ),
                  _buildGameButton(
                    controller,
                    '2048',
                    '2048',
                    Icons.view_module,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
    AdminController controller,
    String gameId,
    String name,
    IconData icon,
  ) {
    return Obx(() {
      final isSelected = controller.selectedGame.value == gameId;

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            controller.selectedGame.value = gameId;
            controller.fetchGameLeaderboard(gameId);
            controller.fetchGameConfig(gameId);
          },
          icon: Icon(icon),
          label: Text(name),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurpleAccent : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      );
    });
  }

  Widget _buildGameConfigTab(AdminController controller) {
    return Obx(() {
      final gameId = controller.selectedGame.value;
      final gameConfig = controller.gameConfig.value;

      // Default configurations if none exists
      final defaultConfigs = _getDefaultGameConfig(gameId);

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            '${gameId.capitalize} Configuration',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _saveGameConfig(controller),
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildConfigPanel(
                        controller, gameId, gameConfig, defaultConfigs),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildEmoteConfigCard(controller, gameId),
          ],
        ),
      );
    });
  }

  Widget _buildConfigPanel(
    AdminController controller,
    String gameId,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    switch (gameId) {
      case 'tictactoe':
        return _buildTicTacToeConfig(controller, gameConfig, defaultConfigs);
      case 'sudoku':
        return _buildSudokuConfig(controller, gameConfig, defaultConfigs);
      case 'minesweeper':
        return _buildMinesweeperConfig(controller, gameConfig, defaultConfigs);
      case 'match3':
        return _buildMatch3Config(controller, gameConfig, defaultConfigs);
      case '2048':
        return _build2048Config(controller, gameConfig, defaultConfigs);
      default:
        return const Center(
            child: Text('No configuration available for this game'));
    }
  }

  Widget _buildTicTacToeConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final boardSizes = ['3x3', '4x4', '5x5'];

    // Get values with defaults
    final activeBoardSizes = List<String>.from(
        gameConfig['activeBoardSizes'] ?? defaultConfigs['activeBoardSizes']);
    final winReward = gameConfig['winReward'] ?? defaultConfigs['winReward'];
    final drawReward = gameConfig['drawReward'] ?? defaultConfigs['drawReward'];
    final timeLimit = gameConfig['timeLimit'] ?? defaultConfigs['timeLimit'];
    final aiDifficulty =
        gameConfig['aiDifficulty'] ?? defaultConfigs['aiDifficulty'];

    // Controllers for editable fields
    final winRewardController =
        TextEditingController(text: winReward.toString());
    final drawRewardController =
        TextEditingController(text: drawReward.toString());
    final timeLimitController =
        TextEditingController(text: timeLimit.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Board Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: boardSizes.map((size) {
            final isActive = activeBoardSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeBoardSizes.add(size);
                } else {
                  if (activeBoardSizes.length > 1) {
                    activeBoardSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one board size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                // Create a copy of the current config for immutability
                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeBoardSizes'] = activeBoardSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: winRewardController,
                decoration: const InputDecoration(
                  labelText: 'Win Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? winReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['winReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: drawRewardController,
                decoration: const InputDecoration(
                  labelText: 'Draw Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? drawReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['drawReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final limit = int.tryParse(value) ?? timeLimit;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['timeLimit'] = limit;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'AI Difficulty',
                  border: OutlineInputBorder(),
                ),
                value: aiDifficulty,
                onChanged: (value) {
                  if (value != null) {
                    final updatedConfig =
                        Map<String, dynamic>.from(controller.gameConfig.value);
                    updatedConfig['aiDifficulty'] = value;
                    controller.gameConfig.value = updatedConfig;
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSudokuConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final difficulties = ['easy', 'medium', 'hard', 'expert'];
    final gridSizes = ['4x4', '9x9', '16x16'];

    // Get values with defaults
    final activeDifficulties = List<String>.from(
        gameConfig['activeDifficulties'] ??
            defaultConfigs['activeDifficulties']);
    final activeGridSizes = List<String>.from(
        gameConfig['activeGridSizes'] ?? defaultConfigs['activeGridSizes']);
    final completionReward =
        gameConfig['completionReward'] ?? defaultConfigs['completionReward'];
    final enableHints =
        gameConfig['enableHints'] ?? defaultConfigs['enableHints'];
    final hintsLimit = gameConfig['hintsLimit'] ?? defaultConfigs['hintsLimit'];

    // Controllers for editable fields
    final completionRewardController =
        TextEditingController(text: completionReward.toString());
    final hintsLimitController =
        TextEditingController(text: hintsLimit.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Difficulties',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: difficulties.map((diff) {
            final isActive = activeDifficulties.contains(diff);
            return FilterChip(
              label: Text(diff.capitalize!),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeDifficulties.add(diff);
                } else {
                  if (activeDifficulties.length > 1) {
                    activeDifficulties.remove(diff);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one difficulty must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeDifficulties'] = activeDifficulties;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Active Grid Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: gridSizes.map((size) {
            final isActive = activeGridSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeGridSizes.add(size);
                } else {
                  if (activeGridSizes.length > 1) {
                    activeGridSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one grid size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeGridSizes'] = activeGridSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: completionRewardController,
                decoration: const InputDecoration(
                  labelText: 'Completion Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? completionReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['completionReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                title: const Text('Enable Hints'),
                value: enableHints,
                onChanged: (value) {
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['enableHints'] = value;
                  controller.gameConfig.value = updatedConfig;
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final isHintsEnabled =
              controller.gameConfig.value['enableHints'] ?? enableHints;
          return TextField(
            controller: hintsLimitController,
            decoration: const InputDecoration(
              labelText: 'Hints Limit per Game',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: isHintsEnabled,
            onChanged: (value) {
              final limit = int.tryParse(value) ?? hintsLimit;
              final updatedConfig =
                  Map<String, dynamic>.from(controller.gameConfig.value);
              updatedConfig['hintsLimit'] = limit;
              controller.gameConfig.value = updatedConfig;
            },
          );
        }),
      ],
    );
  }

  Widget _buildMinesweeperConfig(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    final boardSizes = ['8x8', '16x16', '32x32'];

    // Get values with defaults
    final activeBoardSizes = List<String>.from(
        gameConfig['activeBoardSizes'] ?? defaultConfigs['activeBoardSizes']);
    final completionReward =
        gameConfig['completionReward'] ?? defaultConfigs['completionReward'];
    final minesPercentage =
        gameConfig['minesPercentage'] ?? defaultConfigs['minesPercentage'];
    final enableFirstClickSafety = gameConfig['enableFirstClickSafety'] ??
        defaultConfigs['enableFirstClickSafety'];

    // Controllers for editable fields
    final completionRewardController =
        TextEditingController(text: completionReward.toString());
    final minesPercentageController =
        TextEditingController(text: minesPercentage.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Board Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: boardSizes.map((size) {
            final isActive = activeBoardSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  activeBoardSizes.add(size);
                } else {
                  if (activeBoardSizes.length > 1) {
                    activeBoardSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one board size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['activeBoardSizes'] = activeBoardSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: completionRewardController,
                decoration: const InputDecoration(
                  labelText: 'Completion Reward (Coins)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? completionReward;
                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['completionReward'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: minesPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Mines Percentage (1-40)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  var percentage = int.tryParse(value) ?? minesPercentage;
                  if (percentage < 1) percentage = 1;
                  if (percentage > 40) percentage = 40;

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  updatedConfig['minesPercentage'] = percentage;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable First Click Safety'),
          subtitle: const Text('First click will never be a mine'),
          value: enableFirstClickSafety,
          onChanged: (value) {
            final updatedConfig =
                Map<String, dynamic>.from(controller.gameConfig.value);
            updatedConfig['enableFirstClickSafety'] = value;
            controller.gameConfig.value = updatedConfig;
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildMatch3Config(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    // Get values with defaults
    final boardSizes = List<String>.from(
        gameConfig['boardSizes'] ?? defaultConfigs['boardSizes']);
    final maxMoves = gameConfig['maxMoves'] ?? defaultConfigs['maxMoves'];

    final Map<String, dynamic> defaultTargetScores = {
      'easy': 1000,
      'medium': 2000,
      'hard': 3000,
    };

    final targetScores = Map<String, int>.from(
        gameConfig['targetScores'] ?? defaultTargetScores);

    final List<int> defaultRewards = [5, 10, 15];
    final rewardsPerStar =
        List<int>.from(gameConfig['rewardsPerStar'] ?? defaultRewards);

    // Controllers for editable fields
    final maxMovesController = TextEditingController(text: maxMoves.toString());
    final easyScoreController =
        TextEditingController(text: targetScores['easy'].toString());
    final mediumScoreController =
        TextEditingController(text: targetScores['medium'].toString());
    final hardScoreController =
        TextEditingController(text: targetScores['hard'].toString());
    final star1RewardController =
        TextEditingController(text: rewardsPerStar[0].toString());
    final star2RewardController =
        TextEditingController(text: rewardsPerStar[1].toString());
    final star3RewardController =
        TextEditingController(text: rewardsPerStar[2].toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: maxMovesController,
          decoration: const InputDecoration(
            labelText: 'Max Moves per Game',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final moves = int.tryParse(value) ?? maxMoves;
            final updatedConfig =
                Map<String, dynamic>.from(controller.gameConfig.value);
            updatedConfig['maxMoves'] = moves;
            controller.gameConfig.value = updatedConfig;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Target Scores by Difficulty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: easyScoreController,
                decoration: const InputDecoration(
                  labelText: 'Easy Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['easy'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['easy'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: mediumScoreController,
                decoration: const InputDecoration(
                  labelText: 'Medium Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['medium'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['medium'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: hardScoreController,
                decoration: const InputDecoration(
                  labelText: 'Hard Score',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final score = int.tryParse(value) ?? targetScores['hard'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['targetScores'] == null) {
                    updatedConfig['targetScores'] =
                        Map<String, int>.from(targetScores);
                  }
                  (updatedConfig['targetScores']
                      as Map<String, dynamic>)['hard'] = score;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Rewards per Star (Coins)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: star1RewardController,
                decoration: const InputDecoration(
                  labelText: '1 Star',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[0];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.isNotEmpty) {
                    rewards[0] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: star2RewardController,
                decoration: const InputDecoration(
                  labelText: '2 Stars',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[1];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.length > 1) {
                    rewards[1] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: star3RewardController,
                decoration: const InputDecoration(
                  labelText: '3 Stars',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward = int.tryParse(value) ?? rewardsPerStar[2];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerStar'] == null) {
                    updatedConfig['rewardsPerStar'] =
                        List<int>.from(rewardsPerStar);
                  }

                  final rewards = updatedConfig['rewardsPerStar'] as List;
                  if (rewards.length > 2) {
                    rewards[2] = reward;
                  }
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _build2048Config(
    AdminController controller,
    Map<String, dynamic> gameConfig,
    Map<String, dynamic> defaultConfigs,
  ) {
    // Get values with defaults
    final gridSizes = List<String>.from(
        gameConfig['gridSizes'] ?? defaultConfigs['gridSizes']);
    final targetTiles = List<int>.from(
        gameConfig['targetTiles'] ?? defaultConfigs['targetTiles']);

    // Default rewards if not present
    final Map<String, int> defaultRewards = {
      '1024': 10,
      '2048': 25,
      '4096': 50,
      '8192': 100,
    };

    final rewardsPerTarget =
        Map<String, int>.from(gameConfig['rewardsPerTarget'] ?? defaultRewards);

    // Controllers for editable fields
    final r1024Controller =
        TextEditingController(text: rewardsPerTarget['1024'].toString());
    final r2048Controller =
        TextEditingController(text: rewardsPerTarget['2048'].toString());
    final r4096Controller =
        TextEditingController(text: rewardsPerTarget['4096'].toString());
    final r8192Controller =
        TextEditingController(text: rewardsPerTarget['8192'].toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Grid Sizes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['4x4', '5x5', '6x6'].map((size) {
            final isActive = gridSizes.contains(size);
            return FilterChip(
              label: Text(size),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  gridSizes.add(size);
                } else {
                  if (gridSizes.length > 1) {
                    gridSizes.remove(size);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one grid size must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['gridSizes'] = gridSizes;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Target Tiles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1024, 2048, 4096, 8192].map((tile) {
            final isActive = targetTiles.contains(tile);
            return FilterChip(
              label: Text(tile.toString()),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  targetTiles.add(tile);
                } else {
                  if (targetTiles.length > 1) {
                    targetTiles.remove(tile);
                  } else {
                    Get.snackbar(
                      'Error',
                      'At least one target tile must be active',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }

                final updatedConfig =
                    Map<String, dynamic>.from(controller.gameConfig.value);
                updatedConfig['targetTiles'] = targetTiles;
                controller.gameConfig.value = updatedConfig;
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rewards per Target (Coins)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: r1024Controller,
                decoration: const InputDecoration(
                  labelText: '1024 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['1024'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['1024'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: r2048Controller,
                decoration: const InputDecoration(
                  labelText: '2048 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['2048'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['2048'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: r4096Controller,
                decoration: const InputDecoration(
                  labelText: '4096 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['4096'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['4096'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: r8192Controller,
                decoration: const InputDecoration(
                  labelText: '8192 Tile',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final reward =
                      int.tryParse(value) ?? rewardsPerTarget['8192'];

                  final updatedConfig =
                      Map<String, dynamic>.from(controller.gameConfig.value);
                  if (updatedConfig['rewardsPerTarget'] == null) {
                    updatedConfig['rewardsPerTarget'] =
                        Map<String, int>.from(rewardsPerTarget);
                  }

                  (updatedConfig['rewardsPerTarget']
                      as Map<String, dynamic>)['8192'] = reward;
                  controller.gameConfig.value = updatedConfig;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmoteConfigCard(AdminController controller, String gameId) {
    // Mock emote data
    final emotes = [
      {'id': 'emote1', 'name': 'Thumbs Up', 'free': true, 'price': 0},
      {'id': 'emote2', 'name': 'Good Game', 'free': true, 'price': 0},
      {'id': 'emote3', 'name': 'Happy', 'free': false, 'price': 50},
      {'id': 'emote4', 'name': 'Sad', 'free': false, 'price': 50},
      {'id': 'emote5', 'name': 'Angry', 'free': false, 'price': 100},
      {'id': 'emote6', 'name': 'Surprised', 'free': false, 'price': 100},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Emotes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Configure available emotes and pricing',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emotes.length,
              itemBuilder: (context, index) {
                final emote = emotes[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((emote['name'] as String)[0]),
                  ),
                  title: Text(emote['name'] as String),
                  subtitle: Text(
                    emote['free'] as bool ? 'Free' : '${emote['price']} coins',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: true, // All emotes enabled by default
                        onChanged: (enabled) {
                          // Update emote availability
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Show edit dialog
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show add emote dialog
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Emote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(AdminController controller) {
    return Obx(() {
      final gameId = controller.selectedGame.value;
      final leaderboard = controller.gameLeaderboards[gameId] ?? [];

      if (leaderboard.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.leaderboard,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No leaderboard data available',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.fetchGameLeaderboard(gameId),
                child: const Text('Refresh Leaderboard'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchGameLeaderboard(gameId),
        child: ListView.builder(
          itemCount: leaderboard.length + 1, // +1 for the header
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 50,
                        child: Text('Rank',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 16),
                    Expanded(
                        child: Text('Player',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 80,
                        child: Text('Score',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 80,
                        child: Text('Games',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 40),
                  ],
                ),
              );
            }

            final entryIndex = index - 1;
            final entry = leaderboard[entryIndex];
            final userData = entry['user'] as Map<String, dynamic>?;

            return ListTile(
              leading: SizedBox(
                width: 50,
                child: Row(
                  children: [
                    Text(
                      '${entryIndex + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(entryIndex),
                      ),
                    ),
                    if (entryIndex < 3)
                      Icon(
                        Icons.emoji_events,
                        color: _getRankColor(entryIndex),
                        size: 16,
                      ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: userData?['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(userData?['name'] ?? 'Unknown')),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${entry['score']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text('${entry['gamesPlayed'] ?? 0}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show options menu
                      _showLeaderboardEntryOptions(entry, controller);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.black; // Regular
    }
  }

  void _showLeaderboardEntryOptions(
      Map<String, dynamic> entry, AdminController controller) {
    Get.dialog(
      SimpleDialog(
        title: Text('Manage ${entry['user']?['name'] ?? 'Player'}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _showUserDetailsDialog(entry['user'], controller);
            },
            child: const Text('View Player Details'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _confirmResetScoreDialog(entry, controller);
            },
            child: const Text('Reset Score'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Get.back();
              _confirmRemoveEntryDialog(entry, controller);
            },
            child: const Text('Remove from Leaderboard'),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(
      Map<String, dynamic>? userData, AdminController controller) {
    if (userData == null) return;

    // Here you would fetch detailed user data
    // For now, show what we have
    Get.dialog(
      AlertDialog(
        title: Text(userData['name'] ?? 'Unknown Player'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarUserWidget(
              radius: 40,
              imagePath: userData['image'] ?? '',
            ),
            const SizedBox(height: 16),
            Text('ID: ${userData['id'] ?? 'Unknown'}'),
            Text('Role: ${userData['role'] ?? 'user'}'),
            // Additional details would be fetched and shown here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _confirmResetScoreDialog(
      Map<String, dynamic> entry, AdminController controller) {
    final gameId = controller.selectedGame.value;
    final entryId = entry['id'];
    final userName = entry['user']?['name'] ?? 'this player';

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Score'),
        content:
            Text('Are you sure you want to reset the score for $userName?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Implement reset score logic
              Get.back();

              // Mock implementation
              Get.snackbar(
                'Score Reset',
                'Score for $userName has been reset',
                snackPosition: SnackPosition.BOTTOM,
              );

              // Refresh leaderboard
              controller.fetchGameLeaderboard(gameId);
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveEntryDialog(
      Map<String, dynamic> entry, AdminController controller) {
    final gameId = controller.selectedGame.value;
    final entryId = entry['id'];
    final userName = entry['user']?['name'] ?? 'this player';

    Get.dialog(
      AlertDialog(
        title: const Text('Remove from Leaderboard'),
        content: Text(
            'Are you sure you want to remove $userName from the leaderboard?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Implement remove entry logic
              Get.back();

              // Mock implementation
              Get.snackbar(
                'Entry Removed',
                '$userName has been removed from the leaderboard',
                snackPosition: SnackPosition.BOTTOM,
              );

              // Refresh leaderboard
              controller.fetchGameLeaderboard(gameId);
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsTab(AdminController controller) {
    // Mock data for game stats
    final stats = {
      'totalGamesPlayed': 12500,
      'activeUsers': 1850,
      'avgGameDuration': '4m 30s',
      'completionRate': 68.5,
    };

    // Mock data for daily game plays
    final dailyPlays = [
      {'day': 'Mon', 'plays': 1250},
      {'day': 'Tue', 'plays': 1450},
      {'day': 'Wed', 'plays': 1350},
      {'day': 'Thu', 'plays': 1650},
      {'day': 'Fri', 'plays': 1850},
      {'day': 'Sat', 'plays': 2250},
      {'day': 'Sun', 'plays': 1950},
    ];

    return Obx(() {
      final gameId = controller.selectedGame.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${gameId.capitalize} Statistics',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatsOverviewCard(stats),
            const SizedBox(height: 24),
            _buildDailyPlaysChart(dailyPlays),
            const SizedBox(height: 24),
            _buildDeviceStats(),
            const SizedBox(height: 24),
            _buildDifficultyStats(),
          ],
        ),
      );
    });
  }

  Widget _buildStatsOverviewCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Games',
                  stats['totalGamesPlayed'].toString(),
                  Icons.sports_esports,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active Users',
                  stats['activeUsers'].toString(),
                  Icons.people,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Avg. Duration',
                  stats['avgGameDuration'],
                  Icons.timer,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Completion Rate',
                  '${stats['completionRate']}%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDailyPlaysChart(List<Map<String, dynamic>> dailyPlays) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Game Plays',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Placeholder(
                color: Colors.deepPurpleAccent.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'Daily Plays Chart\n(Bar Chart from fl_chart would be here)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStats() {
    // Mock device stats
    final deviceStats = [
      {'device': 'Android', 'percentage': 65},
      {'device': 'iOS', 'percentage': 35},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 180,
                    child: Placeholder(
                      color: Colors.deepPurpleAccent.withOpacity(0.5),
                      child: const Center(
                        child: Text(
                          'Device Distribution Chart\n(Pie Chart would be here)',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: deviceStats.map((stat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: stat['device'] == 'Android'
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(stat['device'] as String),
                            const Spacer(),
                            Text('${stat['percentage']}%'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyStats() {
    // Mock difficulty stats
    final difficultyStats = [
      {'difficulty': 'Easy', 'percentage': 45},
      {'difficulty': 'Medium', 'percentage': 35},
      {'difficulty': 'Hard', 'percentage': 20},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: difficultyStats.map((stat) {
                final difficulty = stat['difficulty'] as String;
                final percentage = stat['percentage'] as int;

                Color color;
                switch (difficulty) {
                  case 'Easy':
                    color = Colors.green;
                    break;
                  case 'Medium':
                    color = Colors.orange;
                    break;
                  case 'Hard':
                    color = Colors.red;
                    break;
                  default:
                    color = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(difficulty),
                          const Spacer(),
                          Text('$percentage%'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDefaultGameConfig(String gameId) {
    switch (gameId) {
      case 'tictactoe':
        return {
          'activeBoardSizes': ['3x3', '4x4', '5x5'],
          'winReward': 10,
          'drawReward': 5,
          'timeLimit': 30,
          'aiDifficulty': 'medium',
        };
      case 'sudoku':
        return {
          'activeDifficulties': ['easy', 'medium', 'hard'],
          'activeGridSizes': ['9x9'],
          'completionReward': 20,
          'enableHints': true,
          'hintsLimit': 3,
        };
      case 'minesweeper':
        return {
          'activeBoardSizes': ['8x8', '16x16'],
          'completionReward': 15,
          'minesPercentage': 15,
          'enableFirstClickSafety': true,
        };
      case 'match3':
        return {
          'boardSizes': ['8x8'],
          'maxMoves': 30,
          'targetScores': {
            'easy': 1000,
            'medium': 2000,
            'hard': 3000,
          },
          'rewardsPerStar': [5, 10, 15],
        };
      case '2048':
        return {
          'gridSizes': ['4x4'],
          'targetTiles': [2048],
          'rewardsPerTarget': {
            '1024': 10,
            '2048': 25,
            '4096': 50,
            '8192': 100,
          },
        };
      default:
        return {};
    }
  }

  void _saveGameConfig(AdminController controller) {
    final gameId = controller.selectedGame.value;
    final config = controller.gameConfig.value;

    controller.updateGameConfig(gameId, config).then((success) {
      if (success) {
        Get.snackbar(
          'Success',
          'Game configuration saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save game configuration',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });
  }
}
