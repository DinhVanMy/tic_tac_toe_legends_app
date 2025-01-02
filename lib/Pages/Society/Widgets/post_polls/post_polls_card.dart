import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/post_polls_model.dart';

class PostPollWidget extends StatelessWidget {
  final PostPollsModel postPollsModel;
  final PostController? postController;
  final String? postId;
  final String? userId;

  const PostPollWidget({
    super.key,
    required this.postPollsModel,
    this.postController,
    this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final int days = DateTime(
      postPollsModel.endDate!.year,
      postPollsModel.endDate!.month,
      postPollsModel.endDate!.day,
    )
        .difference(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ))
        .inDays;
    final bool pollEnded = days < 0;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey, width: 3),
      ),
      child: FlutterPolls(
        pollId: postPollsModel.pollId,
        hasVoted: postPollsModel.voterList?.contains(userId) ?? false,
        userVotedOptionId: postPollsModel.options
            ?.firstWhere((opt) => opt.votedUserIds?.contains(userId) ?? false,
                orElse: () => OptionalPolls())
            .id
            ?.toString(),
        onVoted: (PollOption pollOption, int newTotalVotes) async {
          if (postId != null && userId != null && postController != null) {
            return await postController!.onVoteFunction(
              pollOption: pollOption,
              newTotalVotes: newTotalVotes,
              postPolls: postPollsModel,
              postId: postId!,
              userId: userId!,
            );
          } else {
            return false;
          }
        },
        pollEnded: pollEnded,
        loadingWidget: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
        pollTitle: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            postPollsModel.question!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        pollOptions: List<PollOption>.from(
          postPollsModel.options!.map(
            (option) => PollOption(
              id: option.id.toString(),
              title: Text(
                option.title!,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis),
              ),
              votes: option.votes!,
            ),
          ),
        ),
        votedPercentageTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        // pollOptionsFillColor:
        //     pollEnded ? Colors.grey.withOpacity(0.5) : Colors.white,
        // pollOptionsBorder:
        //     pollEnded ? null : Border.all(color: Colors.grey, width: 1),
        metaWidget: Row(
          children: [
            const SizedBox(width: 6),
            postPollsModel.voterList != null
                ? Text(postPollsModel.voterList!.length.toString())
                : const Text("0"),
            const SizedBox(width: 6),
            const Text("Voters"),
            const SizedBox(width: 6),
            const Text(
              '•',
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Text(
                _pollStatusText(days),
              ),
            ),
            GestureDetector(
              onTap: postId != null && userId != null && postController != null
                  ? () async {
                      await postController!.undoVoteFunction(
                        postPolls: postPollsModel,
                        postId: postId!,
                        userId: userId!,
                      );
                    }
                  : null,
              child: const Text(
                "Undo",
                style:
                    TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }

//   Widget _buildPollChart(){

//   return PieChart(
//     PieChartData(
//       sections: postPollsModel.options!.map((option) {
//         return PieChartSectionData(
//           value: option.votes!.toDouble(),
//           title: "${option.title!}: ${option.votes}",
//           color: Colors.blueAccent, // Tuỳ chỉnh màu theo ý muốn
//         );
//       }).toList(),
//     ),
//   );
// }

  String _pollStatusText(int days) {
    if (days < 0) {
      return "Poll ended";
    } else if (days == 0) {
      return "Ends today";
    } else {
      return "Ends in $days days";
    }
  }
}
