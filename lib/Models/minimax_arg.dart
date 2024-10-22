class MinimaxArguments {
  final List<List<String>> board;
  final String currentPlayer;
  final int depth;
  final int alpha;
  final int beta;
  final int winLength;

  MinimaxArguments({
    required this.board,
    required this.currentPlayer,
    required this.depth,
    required this.alpha,
    required this.beta,
    required this.winLength,
  });
}
