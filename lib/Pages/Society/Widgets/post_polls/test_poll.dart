import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
// ignore: depend_on_referenced_packages
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/post_polls_model.dart';

class PollCard extends StatelessWidget {
  final String title;
  final List<PollOptionData> options;
  final bool hasVoted;
  final String? votedOptionId;
  final bool pollEnded;
  final Function(PollOptionData) onVote;

  const PollCard({
    super.key,
    required this.title,
    required this.options,
    this.hasVoted = false,
    this.votedOptionId,
    this.pollEnded = false,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final totalVotes =
        options.fold<int>(0, (sum, option) => sum + option.votes);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll title
            Text(
              title,
            ),
            const SizedBox(height: 16),

            // Poll options
            ...options.map((option) {
              final isSelected = votedOptionId == option.id;
              final votePercentage =
                  totalVotes == 0 ? 0.0 : option.votes / totalVotes;

              return GestureDetector(
                onTap: (!hasVoted && !pollEnded) ? () => onVote(option) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: hasVoted
                        ? (isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade200)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasVoted
                          ? (isSelected ? Colors.blue : Colors.grey.shade400)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background progress bar
                      if (hasVoted || pollEnded)
                        LinearPercentIndicator(
                          lineHeight: 48,
                          percent: votePercentage,
                          backgroundColor: Colors.transparent,
                          progressColor:
                              isSelected ? Colors.blue : Colors.grey.shade400,
                          barRadius: const Radius.circular(12),
                        ),

                      // Option text and vote percentage
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.title,
                              ),
                            ),
                            if (hasVoted || pollEnded)
                              Text(
                                "${(votePercentage * 100).toStringAsFixed(1)}%",
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Poll footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total votes: $totalVotes",
                ),
                if (pollEnded)
                  const Text(
                    "Poll ended",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PollOptionData {
  final String id;
  final String title;
  final int votes;

  PollOptionData({
    required this.id,
    required this.title,
    required this.votes,
  });
}

class PostPollWidget2 extends StatelessWidget {
  final PostPollsModel postPollsModel;
  final PostController? postController;
  final String? postId;
  final String? userId;

  const PostPollWidget2({
    super.key,
    required this.postPollsModel,
    this.postController,
    this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final int daysRemaining = DateTime(
      postPollsModel.endDate!.year,
      postPollsModel.endDate!.month,
      postPollsModel.endDate!.day,
    ).difference(DateTime.now()).inDays;

    final bool pollEnded = daysRemaining < 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey, width: 3),
      ),
      child: PollCard(
        title: postPollsModel.question!,
        options: postPollsModel.options!
            .map(
              (option) => PollOptionData(
                id: option.id.toString(),
                title: option.title!,
                votes: option.votes!,
              ),
            )
            .toList(),
        hasVoted: postPollsModel.voterList?.contains(userId) ?? false,
        pollEnded: pollEnded,
        onVote: (optionId) async {
          final selectedOption = postPollsModel.options!.firstWhere(
            (option) => option.id.toString() == optionId,
          );

          if (postId != null && userId != null && postController != null) {
            await postController!.onVoteFunction(
              pollOption: PollOption(
                id: optionId.id,
                title: Text(selectedOption.title!),
                votes: selectedOption.votes!,
              ),
              newTotalVotes: selectedOption.votes! + 1,
              postPolls: postPollsModel,
              postId: postId!,
              userId: userId!,
            );
          }
        },
      ),
    );
  }

  String _pollStatusText(int daysRemaining) {
    if (daysRemaining < 0) {
      return "Poll ended";
    } else if (daysRemaining == 0) {
      return "Ends today";
    } else {
      return "Ends in $daysRemaining days";
    }
  }
}
