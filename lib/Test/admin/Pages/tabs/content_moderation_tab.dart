import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Test/admin/controllers/admin_controller.dart';

class ContentModerationTab extends StatelessWidget {
  const ContentModerationTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    
    return Column(
      children: [
        _buildFilterBar(controller),
        Expanded(
          child: _buildReportedContentList(controller),
        ),
      ],
    );
  }
  
  Widget _buildFilterBar(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Filter by: '),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
            value: controller.contentTypeFilter.value,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'post', child: Text('Posts')),
              DropdownMenuItem(value: 'comment', child: Text('Comments')),
              DropdownMenuItem(value: 'reel', child: Text('Reels')),
              DropdownMenuItem(value: 'user', child: Text('Users')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.contentTypeFilter.value = value;
              }
            },
          )),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => controller.fetchReportedContent(refresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportedContentList(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingReports.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.reportedContent.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'No reported content to review',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'All clear! Check back later for new reports.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.fetchReportedContent(); // Load more when reaching the end
          }
          return true;
        },
        child: ListView.builder(
          itemCount: controller.reportedContent.length,
          itemBuilder: (context, index) {
            final report = controller.reportedContent[index];
            return _buildReportedContentItem(controller, report);
          },
        ),
      );
    });
  }
  
  Widget _buildReportedContentItem(AdminController controller, Map<String, dynamic> report) {
    String contentType = report['contentType'] ?? '';
    String contentId = report['contentId'] ?? '';
    int reportCount = report['reportCount'] ?? 1;
    String reason = report['reason'] ?? 'Not specified';
    DateTime reportedAt = report['reportedAt'] != null 
      ? (report['reportedAt'] as Timestamp).toDate()
      : DateTime.now();
    Map<String, dynamic>? reporterData = report['reporter'];
    Map<String, dynamic>? contentData = report['contentData'];
    
    // Prepare user data
    String reporterName = reporterData?['name'] ?? 'Unknown';
    String reporterImage = reporterData?['image'] ?? '';
    
    // Prepare content preview
    String contentPreview = '';
    if (contentData != null) {
      if (contentType == 'post') {
        contentPreview = contentData['content'] ?? '';
      } else if (contentType == 'comment') {
        contentPreview = contentData['content'] ?? '';
      } else if (contentType == 'reel') {
        contentPreview = contentData['description'] ?? '';
      } else if (contentType == 'user') {
        contentPreview = 'User profile reported';
      }
    }
    
    // Create a readable content identifier
    String contentIdentifier = contentType.capitalizeFirst ?? '';
    if (contentPreview.isNotEmpty) {
      contentIdentifier += ': "${contentPreview.length > 50 ? contentPreview.substring(0, 50) + '...' : contentPreview}"';
    }
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildReportTypeChip(contentType),
                const SizedBox(width: 8),
                Chip(
                  label: Text('$reportCount reports'),
                  backgroundColor: _getReportCountColor(reportCount),
                ),
                const Spacer(),
                Text(
                  TimeFunctions.timeAgo(now: DateTime.now(), createdAt: reportedAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reporter info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reported by:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (reporterImage.isNotEmpty)
                            AvatarUserWidget(
                              radius: 20,
                              imagePath: reporterImage,
                            )
                          else
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(reporterName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(contentIdentifier),
                      const SizedBox(height: 8),
                      const Text(
                        'Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(reason),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewReportedContent(report, controller),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showModerationActionsDialog(report, controller),
                  icon: const Icon(Icons.gavel),
                  label: const Text('Moderate'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReportTypeChip(String contentType) {
    IconData icon;
    Color color;
    
    switch (contentType) {
      case 'post':
        icon = Icons.post_add;
        color = Colors.blue;
        break;
      case 'comment':
        icon = Icons.comment;
        color = Colors.green;
        break;
      case 'reel':
        icon = Icons.video_collection;
        color = Colors.purple;
        break;
      case 'user':
        icon = Icons.person;
        color = Colors.orange;
        break;
      default:
        icon = Icons.warning;
        color = Colors.red;
    }
    
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        contentType.capitalizeFirst ?? '',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
  
  Color _getReportCountColor(int count) {
    if (count >= 10) {
      return Colors.red;
    } else if (count >= 5) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }
  
  void _viewReportedContent(Map<String, dynamic> report, AdminController controller) {
    // Different actions based on content type
    String contentType = report['contentType'] ?? '';
    String contentId = report['contentId'] ?? '';
    Map<String, dynamic>? contentData = report['contentData'];
    
    if (contentData == null) {
      Get.snackbar(
        'Error',
        'Content data not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reported ${contentType.capitalizeFirst}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildContentPreview(contentType, contentData),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _showModerationActionsDialog(report, controller);
                    },
                    child: const Text('MODERATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContentPreview(String contentType, Map<String, dynamic> contentData) {
    switch (contentType) {
      case 'post':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['postUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['postUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['postUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['content'] ?? 'No content'),
            if (contentData['imageUrls'] != null && (contentData['imageUrls'] as List).isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('[Post contains images]'),
              ),
          ],
        );
        
      case 'comment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['commentUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['commentUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['commentUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['content'] ?? 'No content'),
            const SizedBox(height: 8),
            Text(
              'On post: ${contentData['postId'] ?? 'Unknown post'}',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        );
        
      case 'reel':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentData['reelUser'] != null)
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: contentData['reelUser']['image'] ?? '',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contentData['reelUser']['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(contentData['description'] ?? 'No description'),
            const SizedBox(height: 8),
            const Text('[Reel video content]'),
          ],
        );
        
      case 'user':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarUserWidget(
                  radius: 30,
                  imagePath: contentData['image'] ?? '',
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contentData['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(contentData['email'] ?? ''),
                    Text('Role: ${contentData['role'] ?? 'user'}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Bio: ${contentData['bio'] ?? 'No bio'}'),
          ],
        );
        
      default:
        return const Text('Unknown content type');
    }
  }
  
  void _showModerationActionsDialog(Map<String, dynamic> report, AdminController controller) {
    final contentType = report['contentType'] ?? '';
    final contentId = report['contentId'] ?? '';
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Moderation Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Moderation Reason',
                    hintText: 'Optional: Add a note for this action',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Action:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _actionButton(
                      icon: Icons.visibility_off,
                      label: 'Hide',
                      color: Colors.orange,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'hide',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'delete',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.warning,
                      label: 'Warn User',
                      color: Colors.amber,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'warn',
                          reasonController.text,
                        );
                      },
                    ),
                    _actionButton(
                      icon: Icons.restore,
                      label: 'Restore',
                      color: Colors.green,
                      onTap: () {
                        _performModeration(
                          controller,
                          contentType,
                          contentId,
                          'restore',
                          reasonController.text,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _performModeration(
    AdminController controller,
    String contentType,
    String contentId,
    String action,
    String reason,
  ) async {
    if (contentType.isEmpty || contentId.isEmpty) {
      Get.back();
      Get.snackbar(
        'Error',
        'Invalid content information',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.back();
    
    final success = await controller.moderateContent(
      contentType,
      contentId,
      action,
      reason: reason,
    );
    
    if (success) {
      Get.snackbar(
        'Success',
        'Content has been moderated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}