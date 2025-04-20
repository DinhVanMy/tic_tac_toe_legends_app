import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/support_system_controller.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SupportSystemPage extends StatelessWidget {
  const SupportSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SupportSystemController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Support System'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Support Analytics',
            onPressed: () => _showSupportAnalytics(controller),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showSupportSettings(controller),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Ticket list
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSearchAndFilter(controller),
                Expanded(
                  child: _buildTicketList(controller),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Obx(() {
              if (controller.selectedTicketId.isEmpty) {
                return _buildNoTicketSelectedView();
              } else {
                return _buildTicketDetailView(controller);
              }
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateKnowledgeBaseArticleDialog(controller),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add),
        tooltip: 'Add Knowledge Base Article',
      ),
    );
  }

  Widget _buildSearchAndFilter(SupportSystemController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search tickets...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    )
                  : const SizedBox()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value.trim();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFilterChip(
                label: 'All',
                selected: controller.selectedStatusFilter.value == 'all',
                onSelected: (selected) {
                  if (selected) controller.selectedStatusFilter.value = 'all';
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Open',
                selected: controller.selectedStatusFilter.value == 'open',
                onSelected: (selected) {
                  if (selected) controller.selectedStatusFilter.value = 'open';
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Resolved',
                selected: controller.selectedStatusFilter.value == 'resolved',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedStatusFilter.value = 'resolved';
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(
                label: 'High',
                selected: controller.selectedPriorityFilter.value == 'high',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedPriorityFilter.value = 'high';
                  }
                },
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Medium',
                selected: controller.selectedPriorityFilter.value == 'medium',
                onSelected: (selected) {
                  if (selected) {
                    controller.selectedPriorityFilter.value = 'medium';
                  }
                },
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Low',
                selected: controller.selectedPriorityFilter.value == 'low',
                onSelected: (selected) {
                  if (selected) controller.selectedPriorityFilter.value = 'low';
                },
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: controller.sortCriteria.value,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'date', child: Text('Date')),
                  DropdownMenuItem(value: 'priority', child: Text('Priority')),
                  DropdownMenuItem(value: 'status', child: Text('Status')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.sortCriteria.value = value;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(SupportSystemController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredTickets = controller.getFilteredTickets();

      if (filteredTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No tickets match your search'
                    : 'No tickets found for the selected filters',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Filters'),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: filteredTickets.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = filteredTickets[index];
          return _buildTicketListItem(ticket, controller);
        },
      );
    });
  }

  Widget _buildTicketListItem(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final subject = ticket['subject'] as String;
    final userId = ticket['userId'] as String;
    final userName = ticket['userName'] as String;
    final userImage = ticket['userImage'] as String?;
    final status = ticket['status'] as String;
    final priority = ticket['priority'] as String;
    final category = ticket['category'] as String;
    final createdAt = ticket['createdAt'] as DateTime;
    final lastUpdated = ticket['lastUpdated'] as DateTime;
    final hasNewMessage = ticket['hasNewMessage'] as bool? ?? false;

    final isSelected = controller.selectedTicketId.value == ticketId;

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    Color statusColor;
    switch (status) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () => controller.selectTicket(ticketId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.1) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hasNewMessage)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.capitalize!,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.capitalize!,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(lastUpdated),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Category: $category',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: AvatarUserWidget(
                    radius: 10,
                    imagePath: userImage ?? '',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '#${ticketId.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTicketSelectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select a ticket to view details',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or search for a specific ticket using the sidebar filters',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetailView(SupportSystemController controller) {
    final ticket = controller.getSelectedTicket();

    if (ticket == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final ticketId = ticket['id'] as String;
    final subject = ticket['subject'] as String;
    final description = ticket['description'] as String;
    final userId = ticket['userId'] as String;
    final userName = ticket['userName'] as String;
    final userEmail = ticket['userEmail'] as String;
    final userImage = ticket['userImage'] as String?;
    final status = ticket['status'] as String;
    final priority = ticket['priority'] as String;
    final category = ticket['category'] as String;
    final assignedTo = ticket['assignedTo'] as String?;
    final createdAt = ticket['createdAt'] as DateTime;
    final messages = ticket['messages'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${ticketId.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTicketPropertyPill(
                          label: status.capitalize!,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 8),
                        _buildTicketPropertyPill(
                          label: priority.capitalize!,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        _buildTicketPropertyPill(
                          label: category,
                          color: Colors.deepPurpleAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildTicketActions(ticket, controller),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - User info and ticket details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(
                      userName: userName,
                      userEmail: userEmail,
                      userImage: userImage,
                      userId: userId,
                    ),
                    const SizedBox(height: 16),
                    _buildTicketInfoCard(
                      createdAt: createdAt,
                      assignedTo: assignedTo,
                      controller: controller,
                      ticket: ticket,
                    ),
                    const SizedBox(height: 16),
                    _buildRelatedArticlesCard(controller, category),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right side - Conversation thread
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First message (description)
                    _buildMessageBubble(
                      sender: userName,
                      senderImage: userImage,
                      message: description,
                      timestamp: createdAt,
                      isUser: true,
                    ),
                    const SizedBox(height: 16),
                    // Other messages
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'No replies yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    messages[index] as Map<String, dynamic>;
                                final sender = message['sender'] as String;
                                final senderImage =
                                    message['senderImage'] as String?;
                                final content = message['content'] as String;
                                final timestamp =
                                    message['timestamp'] as DateTime;
                                final isUserMessage =
                                    message['isUser'] as bool? ?? false;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildMessageBubble(
                                    sender: sender,
                                    senderImage: senderImage,
                                    message: content,
                                    timestamp: timestamp,
                                    isUser: isUserMessage,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Reply form
                    if (status != 'resolved')
                      _buildReplyForm(controller, ticketId),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPropertyPill(
      {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTicketActions(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final status = ticket['status'] as String;
    final ticketId = ticket['id'] as String;

    return Row(
      children: [
        if (status == 'open' || status == 'pending')
          OutlinedButton.icon(
            onPressed: () => _showResolveTicketDialog(ticket, controller),
            icon: const Icon(Icons.check_circle),
            label: const Text('Resolve'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _showAssignTicketDialog(ticket, controller),
          icon: const Icon(Icons.person_add),
          label: const Text('Assign'),
        ),
        const SizedBox(width: 8),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'changePriority',
              child: ListTile(
                leading: Icon(Icons.flag),
                title: Text('Change Priority'),
              ),
            ),
            const PopupMenuItem(
              value: 'changeCategory',
              child: ListTile(
                leading: Icon(Icons.category),
                title: Text('Change Category'),
              ),
            ),
            const PopupMenuItem(
              value: 'addNote',
              child: ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Add Internal Note'),
              ),
            ),
            if (status == 'resolved')
              const PopupMenuItem(
                value: 'reopen',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Reopen Ticket'),
                ),
              ),
            const PopupMenuItem(
              value: 'merge',
              child: ListTile(
                leading: Icon(Icons.merge_type),
                title: Text('Merge with Another Ticket'),
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export Ticket'),
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'changePriority':
                _showChangePriorityDialog(ticket, controller);
                break;
              case 'changeCategory':
                _showChangeCategoryDialog(ticket, controller);
                break;
              case 'addNote':
                _showAddNoteDialog(ticket, controller);
                break;
              case 'reopen':
                _showReopenTicketDialog(ticket, controller);
                break;
              case 'merge':
                _showMergeTicketDialog(ticket, controller);
                break;
              case 'export':
                _exportTicket(ticket);
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserCard({
    required String userName,
    required String userEmail,
    required String? userImage,
    required String userId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AvatarUserWidget(
                radius: 25,
                imagePath: userImage ?? '',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'User ID: ${userId.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => Get.toNamed('/admin/users/$userId'),
                icon: const Icon(Icons.person),
                label: const Text('View Profile'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Show user's previous tickets
                },
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoCard({
    required DateTime createdAt,
    required String? assignedTo,
    required SupportSystemController controller,
    required Map<String, dynamic> ticket,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Created',
            value: DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Assigned To',
            value: assignedTo ?? 'Unassigned',
            valueColor:
                assignedTo != null ? Colors.deepPurpleAccent : Colors.grey,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Device',
            value: ticket['deviceInfo'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'App Version',
            value: ticket['appVersion'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Platform',
            value: ticket['platform'] as String? ?? 'Unknown',
          ),
          const SizedBox(height: 16),
          // Tags
          const Text(
            'Tags',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...(ticket['tags'] as List<dynamic>? ?? [])
                  .map((tag) => _buildTagChip(
                        tag: tag as String,
                        onDeleted: () {
                          // Remove tag
                          controller.removeTagFromTicket(
                              ticket['id'] as String, tag);
                        },
                      )),
              ActionChip(
                label: const Text('Add Tag'),
                avatar: const Icon(Icons.add, size: 16),
                onPressed: () => _showAddTagDialog(ticket, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticlesCard(
      SupportSystemController controller, String category) {
    final articles = controller.getRelatedArticles(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Knowledge Base',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => _showKnowledgeBaseDialog(controller),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Related Articles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          articles.isEmpty
              ? Text(
                  'No related articles found',
                  style: TextStyle(color: Colors.grey[600]),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length > 3 ? 3 : articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.article),
                      title: Text(article['title'] as String),
                    );
                  },
                ),
          const SizedBox(height: 16),
          const Text(
            'Suggested Responses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.quickreply),
                title: Text(
                  index == 0
                      ? 'Thank you for reporting this issue. We\'re looking into it.'
                      : 'This is a known issue and our team is working on a fix.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    // Insert the template into the reply field
                    controller.replyController.text = index == 0
                        ? 'Thank you for reporting this issue. We\'re looking into it and will get back to you as soon as possible. In the meantime, please let us know if you have any other questions.'
                        : 'Thank you for bringing this to our attention. This is a known issue and our development team is actively working on a fix. We expect to release an update within the next few days that should resolve this problem. We appreciate your patience.';
                  },
                  child: const Text('Use'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String sender,
    required String? senderImage,
    required String message,
    required DateTime timestamp,
    required bool isUser,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          AvatarUserWidget(
            radius: 16,
            imagePath: senderImage ?? '',
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.grey[100]
                      : Colors.deepPurpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUser
                        ? Colors.grey[300]!
                        : Colors.deepPurpleAccent.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.black : Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(message),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy - HH:mm').format(timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          AvatarUserWidget(
            radius: 16,
            imagePath: senderImage ?? '',
          ),
        ],
      ],
    );
  }

  Widget _buildReplyForm(SupportSystemController controller, String ticketId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reply',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.replyController,
          decoration: const InputDecoration(
            hintText: 'Type your response here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Show template responses dialog
                _showTemplateResponsesDialog(controller);
              },
              icon: const Icon(Icons.format_quote),
              label: const Text('Templates'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Show attachment dialog
                _showAttachmentDialog(controller);
              },
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (controller.replyController.text.isEmpty) {
                  errorMessage('Please enter a response');
                  return;
                }

                controller
                    .sendReply(ticketId, controller.replyController.text)
                    .then((success) {
                  if (success) {
                    controller.replyController.clear();
                    successMessage('Reply sent successfully');
                  }
                });
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Reply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: (color ?? Colors.deepPurpleAccent).withOpacity(0.2),
      checkmarkColor: color ?? Colors.deepPurpleAccent,
      labelStyle: TextStyle(
        color: selected ? (color ?? Colors.deepPurpleAccent) : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip({
    required String tag,
    required VoidCallback onDeleted,
  }) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.cancel, size: 16),
      onDeleted: onDeleted,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showResolveTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final resolutionController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resolve Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a summary of the resolution for this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resolutionController,
                decoration: const InputDecoration(
                  labelText: 'Resolution',
                  border: OutlineInputBorder(),
                  hintText: 'Explain how the issue was resolved...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Send resolution email to user'),
                value: true,
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (resolutionController.text.isEmpty) {
                        errorMessage('Please enter a resolution summary');
                        return;
                      }

                      controller
                          .resolveTicket(
                        ticketId,
                        resolutionController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket resolved successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('RESOLVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final RxString selectedAgentId = ''.obs;

    // Mock agent data
    final List<Map<String, dynamic>> agents = [
      {
        'id': 'agent1',
        'name': 'John Smith',
        'role': 'Support Agent',
        'image': '',
        'activeTickets': 5
      },
      {
        'id': 'agent2',
        'name': 'Jane Doe',
        'role': 'Senior Support',
        'image': '',
        'activeTickets': 3
      },
      {
        'id': 'agent3',
        'name': 'Mike Johnson',
        'role': 'Support Agent',
        'image': '',
        'activeTickets': 7
      },
      {
        'id': 'agent4',
        'name': 'Sarah Wilson',
        'role': 'Technical Support',
        'image': '',
        'activeTickets': 2
      },
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select an agent to assign this ticket to:',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    final agentId = agent['id'] as String;

                    return Obx(() => RadioListTile<String>(
                          title: Text(agent['name'] as String),
                          subtitle: Row(
                            children: [
                              Text(agent['role'] as String),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${agent['activeTickets']} active tickets',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          value: agentId,
                          groupValue: selectedAgentId.value,
                          onChanged: (value) {
                            selectedAgentId.value = value!;
                          },
                        ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Unassign ticket logic
                      controller.unassignTicket(ticketId).then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket unassigned successfully');
                        }
                      });
                    },
                    child: const Text('Unassign'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                            onPressed: selectedAgentId.value.isEmpty
                                ? null
                                : () {
                                    controller
                                        .assignTicket(
                                      ticketId,
                                      selectedAgentId.value,
                                      agents.firstWhere((agent) =>
                                              agent['id'] ==
                                              selectedAgentId.value)['name']
                                          as String,
                                    )
                                        .then((success) {
                                      if (success) {
                                        Get.back();
                                        successMessage(
                                            'Ticket assigned successfully');
                                      }
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                            child: const Text('ASSIGN'),
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePriorityDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final currentPriority = ticket['priority'] as String;
    RxString selectedPriority = currentPriority.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Priority',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the new priority level for this ticket:',
              ),
              const SizedBox(height: 16),
              Obx(() => Column(
                    children: [
                      _buildPriorityOption(
                        label: 'High',
                        description: 'Critical issue affecting many users',
                        value: 'high',
                        groupValue: selectedPriority.value,
                        color: Colors.red,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildPriorityOption(
                        label: 'Medium',
                        description: 'Important issue with limited impact',
                        value: 'medium',
                        groupValue: selectedPriority.value,
                        color: Colors.orange,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildPriorityOption(
                        label: 'Low',
                        description: 'Minor issue or question',
                        value: 'low',
                        groupValue: selectedPriority.value,
                        color: Colors.blue,
                        onChanged: (value) {
                          selectedPriority.value = value!;
                        },
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedPriority.value == currentPriority
                            ? null
                            : () {
                                controller
                                    .changeTicketPriority(
                                  ticketId,
                                  selectedPriority.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Priority changed successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('SAVE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption({
    required String label,
    required String description,
    required String value,
    required String groupValue,
    required Color color,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              value == groupValue ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: value == groupValue ? color : Colors.grey.withOpacity(0.3),
            width: value == groupValue ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: value == groupValue ? color : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeCategoryDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final currentCategory = ticket['category'] as String;
    RxString selectedCategory = currentCategory.obs;

    // Mock categories
    const List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select the new category for this ticket:',
              ),
              const SizedBox(height: 16),
              Obx(() => Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory.value,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;
                          }
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedCategory.value == currentCategory
                            ? null
                            : () {
                                controller
                                    .changeTicketCategory(
                                  ticketId,
                                  selectedCategory.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Category changed successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('SAVE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final tagController = TextEditingController();
    final ticketId = ticket['id'] as String;
    final currentTags = ticket['tags'] as List<dynamic>? ?? [];

    // Mock suggested tags
    final List<String> suggestedTags = [
      'login-issue',
      'payment-error',
      'game-crash',
      'feature-request',
      'account-recovery',
      'performance',
      'ui-bug',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Tag',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a new tag...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Suggested Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedTags
                    .where((tag) => !currentTags.contains(tag))
                    .map((tag) => ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            tagController.text = tag;
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (tagController.text.isEmpty) {
                        errorMessage('Please enter a tag');
                        return;
                      }

                      if (currentTags.contains(tagController.text)) {
                        errorMessage('This tag already exists');
                        return;
                      }

                      controller
                          .addTagToTicket(
                        ticketId,
                        tagController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Tag added successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ADD'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final noteController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Internal Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This note will only be visible to support staff.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your internal note here...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (noteController.text.isEmpty) {
                        errorMessage('Please enter a note');
                        return;
                      }

                      controller
                          .addInternalNote(
                        ticketId,
                        noteController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Note added successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ADD NOTE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReopenTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final reasonController = TextEditingController();
    final ticketId = ticket['id'] as String;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reopen Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a reason for reopening this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Explain why this ticket needs to be reopened...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (reasonController.text.isEmpty) {
                        errorMessage('Please enter a reason');
                        return;
                      }
                      controller
                          .reopenTicket(
                        ticketId,
                        reasonController.text,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Ticket reopened successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('REOPEN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMergeTicketDialog(
      Map<String, dynamic> ticket, SupportSystemController controller) {
    final ticketId = ticket['id'] as String;
    final RxString selectedTicketId = ''.obs;

    // Get other open tickets
    final otherTickets = controller
        .getAllTickets()
        .where((t) => t['id'] != ticketId && t['status'] == 'open')
        .toList();

    if (otherTickets.isEmpty) {
      errorMessage('No other open tickets available to merge with');
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Merge Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select another ticket to merge this one with:',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: otherTickets.length,
                  itemBuilder: (context, index) {
                    final otherTicket = otherTickets[index];
                    final otherTicketId = otherTicket['id'] as String;

                    return Obx(() => RadioListTile<String>(
                          title: Text(otherTicket['subject'] as String),
                          subtitle: Text('From: ${otherTicket['userName']}'),
                          value: otherTicketId,
                          groupValue: selectedTicketId.value,
                          onChanged: (value) {
                            selectedTicketId.value = value!;
                          },
                        ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: selectedTicketId.value.isEmpty
                            ? null
                            : () {
                                controller
                                    .mergeTickets(
                                  ticketId,
                                  selectedTicketId.value,
                                )
                                    .then((success) {
                                  if (success) {
                                    Get.back();
                                    successMessage(
                                        'Tickets merged successfully');
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('MERGE'),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportTicket(Map<String, dynamic> ticket) {
    // This would be implemented to export ticket data to a file
    successMessage('Ticket exported successfully');
  }

  void _showTemplateResponsesDialog(SupportSystemController controller) {
    // Mock template responses
    final List<Map<String, String>> templates = [
      {
        'title': 'Thank you',
        'content':
            'Thank you for contacting us. We appreciate your patience while we work on resolving your issue.',
      },
      {
        'title': 'Additional information needed',
        'content':
            'To better assist you with this issue, could you please provide more information about the problem you\'re experiencing?',
      },
      {
        'title': 'Issue resolved',
        'content':
            'We\'re pleased to inform you that the issue you reported has been resolved. Please let us know if you encounter any further problems.',
      },
      {
        'title': 'Known issue',
        'content':
            'Thank you for your report. This is a known issue that our team is currently working on. We expect to have a fix available in our next update.',
      },
      {
        'title': 'User error',
        'content':
            'Based on our investigation, it appears this issue may be related to how the feature is being used. Here are the correct steps to follow:',
      },
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Template Responses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      title: Text(template['title']!),
                      trailing: TextButton(
                        onPressed: () {
                          controller.replyController.text =
                              template['content']!;
                          Get.back();
                        },
                        child: const Text('Use'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Show create template dialog
                      Get.back();
                      _showCreateTemplateDialog(controller);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Template'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTemplateDialog(SupportSystemController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Response Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Template Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a descriptive title...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Response Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the template content...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // This would save the template in a real app
                      Get.back();
                      successMessage('Template saved successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentDialog(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select file(s) to attach to your response:',
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // File selection would be implemented here
                        },
                        child: const Text('Click to select files'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Maximum file size: 10MB. Allowed formats: PNG, JPG, PDF, ZIP.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // This would upload the file in a real app
                      Get.back();
                      successMessage('Files would be attached here');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('ATTACH'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleDialog(Map<String, dynamic> article) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article['title'] as String,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy').format(article['updatedAt'] as DateTime)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(article['content'] as String),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Edit the article
                      Get.back();
                      _showEditArticleDialog(article);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Article'),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditArticleDialog(Map<String, dynamic> article) {
    final titleController =
        TextEditingController(text: article['title'] as String);
    final contentController =
        TextEditingController(text: article['content'] as String);
    final summaryController =
        TextEditingController(text: article['summary'] as String);
    final List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other'
    ];
    final RxString selectedCategory = (article['category'] as String).obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Knowledge Base Article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the article',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory.value,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategory.value = value;
                                }
                              },
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Article content...',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty ||
                          summaryController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // This would update the article in a real app
                      Get.back();
                      successMessage('Article updated successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateKnowledgeBaseArticleDialog(
      SupportSystemController controller) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final summaryController = TextEditingController();
    final List<String> categories = [
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other'
    ];
    final RxString selectedCategory = categories[0].obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Knowledge Base Article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter article title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the article',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory.value,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategory.value = value;
                                }
                              },
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Article content...',
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty ||
                          summaryController.text.isEmpty) {
                        errorMessage('Please fill in all fields');
                        return;
                      }

                      // Create the article
                      controller
                          .createKnowledgeBaseArticle(
                        title: titleController.text,
                        content: contentController.text,
                        summary: summaryController.text,
                        category: selectedCategory.value,
                      )
                          .then((success) {
                        if (success) {
                          Get.back();
                          successMessage('Article created successfully');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text('CREATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKnowledgeBaseDialog(SupportSystemController controller) {
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
    final RxString selectedCategory = 'All'.obs;

    final List<String> categories = [
      'All',
      'Account',
      'Billing',
      'Game Play',
      'Technical',
      'Feature Request',
      'Bug Report',
      'Other',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Knowledge Base',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search articles...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  searchQuery.value = '';
                                },
                              )
                            : const SizedBox()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery.value = value.trim();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory.value,
                            hint: const Text('Category'),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedCategory.value = value;
                              }
                            },
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final articles = controller.getFilteredKnowledgeBaseArticles(
                    searchQuery.value,
                    selectedCategory.value == 'All'
                        ? null
                        : selectedCategory.value,
                  );

                  if (articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.value.isNotEmpty ||
                                    selectedCategory.value != 'All'
                                ? 'No articles match your search'
                                : 'No articles found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: articles.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ListTile(
                        title: Text(
                          article['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () {
                                Get.back();
                                _showEditArticleDialog(article);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: 'View',
                              onPressed: () {
                                Get.back();
                                _showArticleDialog(article);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showCreateKnowledgeBaseArticleDialog(controller);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Article'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportAnalytics(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Analytics content would go here
                      Text(
                          'Support analytics and reporting would be displayed here.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportSettings(SupportSystemController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Support Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Email Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('New ticket notifications'),
                  subtitle:
                      const Text('Receive email when a new ticket is created'),
                  value: true,
                  onChanged: (_) {},
                ),
                CheckboxListTile(
                  title: const Text('Ticket assignment notifications'),
                  subtitle: const Text(
                      'Receive email when a ticket is assigned to you'),
                  value: true,
                  onChanged: (_) {},
                ),
                CheckboxListTile(
                  title: const Text('Ticket update notifications'),
                  subtitle:
                      const Text('Receive email when a ticket is updated'),
                  value: false,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                const Text(
                  'Automation Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Auto-assign tickets'),
                  subtitle: const Text(
                      'Automatically assign tickets to available agents'),
                  value: true,
                  onChanged: (_) {},
                ),
                CheckboxListTile(
                  title: const Text('Auto-tag tickets'),
                  subtitle:
                      const Text('Automatically tag tickets based on content'),
                  value: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        successMessage('Settings saved successfully');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildMessageBubble({
  required String sender,
  required String? senderImage,
  required String message,
  required DateTime timestamp,
  required bool isUser,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      if (!isUser) ...[
        AvatarUserWidget(
          radius: 16,
          imagePath: senderImage ?? '',
        ),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.grey[100]
                    : Colors.deepPurpleAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser
                      ? Colors.grey[300]!
                      : Colors.deepPurpleAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.black : Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy - HH:mm').format(timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      if (isUser) ...[
        const SizedBox(width: 8),
        AvatarUserWidget(
          radius: 16,
          imagePath: senderImage ?? '',
        ),
      ],
    ],
  );
}

Widget _buildReplyForm(SupportSystemController controller, String ticketId) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Reply',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller.replyController,
        decoration: const InputDecoration(
          hintText: 'Type your response here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // Show template responses dialog
              _showTemplateResponsesDialog(controller);
            },
            icon: const Icon(Icons.format_quote),
            label: const Text('Templates'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              // Show attachment dialog
              _showAttachmentDialog(controller);
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Add Attachment'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              if (controller.replyController.text.isEmpty) {
                errorMessage('Please enter a response');
                return;
              }

              controller
                  .sendReply(ticketId, controller.replyController.text)
                  .then((success) {
                if (success) {
                  controller.replyController.clear();
                  successMessage('Reply sent successfully');
                }
              });
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Reply'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    ],
  );
}

void _showAttachmentDialog(SupportSystemController controller) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select file(s) to attach to your response:',
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // File selection would be implemented here
                      },
                      child: const Text('Click to select files'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maximum file size: 10MB. Allowed formats: PNG, JPG, PDF, ZIP.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // This would upload the file in a real app
                    Get.back();
                    successMessage('Files would be attached here');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ATTACH'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showTemplateResponsesDialog(SupportSystemController controller) {
  // Mock template responses
  final List<Map<String, String>> templates = [
    {
      'title': 'Thank you',
      'content':
          'Thank you for contacting us. We appreciate your patience while we work on resolving your issue.',
    },
    {
      'title': 'Additional information needed',
      'content':
          'To better assist you with this issue, could you please provide more information about the problem you\'re experiencing?',
    },
    {
      'title': 'Issue resolved',
      'content':
          'We\'re pleased to inform you that the issue you reported has been resolved. Please let us know if you encounter any further problems.',
    },
    {
      'title': 'Known issue',
      'content':
          'Thank you for your report. This is a known issue that our team is currently working on. We expect to have a fix available in our next update.',
    },
    {
      'title': 'User error',
      'content':
          'Based on our investigation, it appears this issue may be related to how the feature is being used. Here are the correct steps to follow:',
    },
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Template Responses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: templates.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return ListTile(
                    title: Text(template['title']!),
                    subtitle: Text(
                      template['content']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        controller.replyController.text = template['content']!;
                        Get.back();
                      },
                      child: const Text('Use'),
                    ),
                    onTap: () {
                      controller.replyController.text = template['content']!;
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Show create template dialog
                    Get.back();
                    _showCreateTemplateDialog(controller);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Template'),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showCreateTemplateDialog(SupportSystemController controller) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Response Template',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Template Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a descriptive title...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Response Content',
                border: OutlineInputBorder(),
                hintText: 'Enter the template content...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      errorMessage('Please fill in all fields');
                      return;
                    }

                    // This would save the template in a real app
                    Get.back();
                    successMessage('Template saved successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFilterChip({
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelected,
  Color? color,
}) {
  return FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: onSelected,
    selectedColor: (color ?? Colors.deepPurpleAccent).withOpacity(0.2),
    checkmarkColor: color ?? Colors.deepPurpleAccent,
    labelStyle: TextStyle(
      color: selected ? (color ?? Colors.deepPurpleAccent) : Colors.black,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

Widget _buildInfoRow({
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[700],
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ),
    ],
  );
}

Widget _buildTagChip({
  required String tag,
  required VoidCallback onDeleted,
}) {
  return Chip(
    label: Text(tag),
    deleteIcon: const Icon(Icons.cancel, size: 16),
    onDeleted: onDeleted,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'open':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'resolved':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

Color _getPriorityColor(String priority) {
  switch (priority) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String _timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} years ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 7) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}

void _showResolveTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final resolutionController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resolve Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please provide a summary of the resolution for this ticket.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution',
                border: OutlineInputBorder(),
                hintText: 'Explain how the issue was resolved...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Send resolution email to user'),
              value: true,
              onChanged: (_) {},
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (resolutionController.text.isEmpty) {
                      errorMessage('Please enter a resolution summary');
                      return;
                    }

                    controller
                        .resolveTicket(
                      ticketId,
                      resolutionController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Ticket resolved successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('RESOLVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAssignTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final RxString selectedAgentId = ''.obs;

  // Mock agent data
  final List<Map<String, dynamic>> agents = [
    {
      'id': 'agent1',
      'name': 'John Smith',
      'role': 'Support Agent',
      'image': '',
      'activeTickets': 5
    },
    {
      'id': 'agent2',
      'name': 'Jane Doe',
      'role': 'Senior Support',
      'image': '',
      'activeTickets': 3
    },
    {
      'id': 'agent3',
      'name': 'Mike Johnson',
      'role': 'Support Agent',
      'image': '',
      'activeTickets': 7
    },
    {
      'id': 'agent4',
      'name': 'Sarah Wilson',
      'role': 'Technical Support',
      'image': '',
      'activeTickets': 2
    },
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select an agent to assign this ticket to:',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final agent = agents[index];
                  final agentId = agent['id'] as String;

                  return Obx(() => RadioListTile<String>(
                        title: Text(agent['name'] as String),
                        subtitle: Row(
                          children: [
                            Text(agent['role'] as String),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${agent['activeTickets']} active tickets',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: agentId,
                        groupValue: selectedAgentId.value,
                        onChanged: (value) {
                          selectedAgentId.value = value!;
                        },
                      ));
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Unassign ticket logic
                    controller.unassignTicket(ticketId).then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Ticket unassigned successfully');
                      }
                    });
                  },
                  child: const Text('Unassign'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => ElevatedButton(
                          onPressed: selectedAgentId.value.isEmpty
                              ? null
                              : () {
                                  controller
                                      .assignTicket(
                                    ticketId,
                                    selectedAgentId.value,
                                    agents.firstWhere((agent) =>
                                            agent['id'] ==
                                            selectedAgentId.value)['name']
                                        as String,
                                  )
                                      .then((success) {
                                    if (success) {
                                      Get.back();
                                      successMessage(
                                          'Ticket assigned successfully');
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          child: const Text('ASSIGN'),
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showChangePriorityDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final currentPriority = ticket['priority'] as String;
  RxString selectedPriority = currentPriority.obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Priority',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select the new priority level for this ticket:',
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildPriorityOption(
                      label: 'High',
                      description: 'Critical issue affecting many users',
                      value: 'high',
                      groupValue: selectedPriority.value,
                      color: Colors.red,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPriorityOption(
                      label: 'Medium',
                      description: 'Important issue with limited impact',
                      value: 'medium',
                      groupValue: selectedPriority.value,
                      color: Colors.orange,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPriorityOption(
                      label: 'Low',
                      description: 'Minor issue or question',
                      value: 'low',
                      groupValue: selectedPriority.value,
                      color: Colors.blue,
                      onChanged: (value) {
                        selectedPriority.value = value!;
                      },
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedPriority.value == currentPriority
                          ? null
                          : () {
                              controller
                                  .changeTicketPriority(
                                ticketId,
                                selectedPriority.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage(
                                      'Priority changed successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPriorityOption({
  required String label,
  required String description,
  required String value,
  required String groupValue,
  required Color color,
  required ValueChanged<String?> onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(value),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            value == groupValue ? color.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: value == groupValue ? color : Colors.grey.withOpacity(0.3),
          width: value == groupValue ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: value == groupValue ? color : Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void _showChangeCategoryDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final currentCategory = ticket['category'] as String;
  RxString selectedCategory = currentCategory.obs;

  // Mock categories
  const List<String> categories = [
    'Account',
    'Billing',
    'Game Play',
    'Technical',
    'Feature Request',
    'Bug Report',
    'Other',
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select the new category for this ticket:',
            ),
            const SizedBox(height: 16),
            Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory.value,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedCategory.value = value;
                        }
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedCategory.value == currentCategory
                          ? null
                          : () {
                              controller
                                  .changeTicketCategory(
                                ticketId,
                                selectedCategory.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage(
                                      'Category changed successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('SAVE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddTagDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final tagController = TextEditingController();
  final ticketId = ticket['id'] as String;
  final currentTags = ticket['tags'] as List<dynamic>? ?? [];

  // Mock suggested tags
  final List<String> suggestedTags = [
    'login-issue',
    'payment-error',
    'game-crash',
    'feature-request',
    'account-recovery',
    'performance',
    'ui-bug',
  ];

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Tag',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Tag',
                border: OutlineInputBorder(),
                hintText: 'Enter a new tag...',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suggested Tags:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedTags
                  .where((tag) => !currentTags.contains(tag))
                  .map((tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          tagController.text = tag;
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (tagController.text.isEmpty) {
                      errorMessage('Please enter a tag');
                      return;
                    }

                    if (currentTags.contains(tagController.text)) {
                      errorMessage('This tag already exists');
                      return;
                    }

                    controller
                        .addTagToTicket(
                      ticketId,
                      tagController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Tag added successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddNoteDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final noteController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Internal Note',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This note will only be visible to support staff.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                hintText: 'Enter your internal note here...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (noteController.text.isEmpty) {
                      errorMessage('Please enter a note');
                      return;
                    }

                    controller
                        .addInternalNote(
                      ticketId,
                      noteController.text,
                    )
                        .then((success) {
                      if (success) {
                        Get.back();
                        successMessage('Note added successfully');
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('ADD NOTE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showReopenTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final reasonController = TextEditingController();
  final ticketId = ticket['id'] as String;

  Get.dialog(Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reopen Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please provide a reason for reopening this ticket.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  hintText: 'Explain why this ticket needs to be reopened...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
              ])
            ])),
  ));
}

void _showArticleDialog(Map<String, dynamic> article) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy').format(article['updatedAt'] as DateTime)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(article['content'] as String),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit the article
                    Get.back();
                    _showEditArticleDialog(article);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Article'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEditArticleDialog(Map<String, dynamic> article) {
  final titleController =
      TextEditingController(text: article['title'] as String);
  final contentController =
      TextEditingController(text: article['content'] as String);
  final summaryController =
      TextEditingController(text: article['summary'] as String);
  final List<String> categories = [
    'Account',
    'Billing',
    'Game Play',
    'Technical',
    'Feature Request',
    'Bug Report',
    'Other'
  ];
  final RxString selectedCategory = (article['category'] as String).obs;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Knowledge Base Article',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(),
                hintText: 'Brief description of the article',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory.value,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedCategory.value = value;
                              }
                            },
                          ),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Article content...',
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty ||
                        summaryController.text.isEmpty) {
                      errorMessage('Please fill in all fields');
                      return;
                    }

                    // This would update the article in a real app
                    Get.back();
                    successMessage('Article updated successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTicketPropertyPill({required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

Widget _buildTicketActions(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final status = ticket['status'] as String;
  final ticketId = ticket['id'] as String;

  return Row(
    children: [
      if (status == 'open' || status == 'pending')
        OutlinedButton.icon(
          onPressed: () => _showResolveTicketDialog(ticket, controller),
          icon: const Icon(Icons.check_circle),
          label: const Text('Resolve'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () => _showAssignTicketDialog(ticket, controller),
        icon: const Icon(Icons.person_add),
        label: const Text('Assign'),
      ),
      const SizedBox(width: 8),
      PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'changePriority',
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Change Priority'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'changeCategory',
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text('Change Category'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'addNote',
            child: ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Add Internal Note'),
              dense: true,
            ),
          ),
          if (status == 'resolved')
            const PopupMenuItem(
              value: 'reopen',
              child: ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Reopen Ticket'),
                dense: true,
              ),
            ),
          const PopupMenuItem(
            value: 'merge',
            child: ListTile(
              leading: Icon(Icons.merge_type),
              title: Text('Merge with Another Ticket'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: ListTile(
              leading: Icon(Icons.download),
              title: Text('Export Ticket'),
              dense: true,
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'changePriority':
              _showChangePriorityDialog(ticket, controller);
              break;
            case 'changeCategory':
              _showChangeCategoryDialog(ticket, controller);
              break;
            case 'addNote':
              _showAddNoteDialog(ticket, controller);
              break;
            case 'reopen':
              _showReopenTicketDialog(ticket, controller);
              break;
            case 'merge':
              _showMergeTicketDialog(ticket, controller);
              break;
            case 'export':
              _exportTicket(ticket);
              break;
          }
        },
      ),
    ],
  );
}

void _showMergeTicketDialog(
    Map<String, dynamic> ticket, SupportSystemController controller) {
  final ticketId = ticket['id'] as String;
  final RxString selectedTicketId = ''.obs;

  // Get other open tickets
  final otherTickets = controller
      .getAllTickets()
      .where((t) => t['id'] != ticketId && t['status'] == 'open')
      .toList();

  if (otherTickets.isEmpty) {
    errorMessage('No other open tickets available to merge with');
    return;
  }

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merge Ticket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select another ticket to merge this one with:',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: otherTickets.length,
                itemBuilder: (context, index) {
                  final otherTicket = otherTickets[index];
                  final otherTicketId = otherTicket['id'] as String;

                  return Obx(() => RadioListTile<String>(
                        title: Text(otherTicket['subject'] as String),
                        subtitle: Text('From: ${otherTicket['userName']}'),
                        value: otherTicketId,
                        groupValue: selectedTicketId.value,
                        onChanged: (value) {
                          selectedTicketId.value = value!;
                        },
                      ));
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: selectedTicketId.value.isEmpty
                          ? null
                          : () {
                              controller
                                  .mergeTickets(
                                ticketId,
                                selectedTicketId.value,
                              )
                                  .then((success) {
                                if (success) {
                                  Get.back();
                                  successMessage('Tickets merged successfully');
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text('MERGE'),
                    )),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void _exportTicket(Map<String, dynamic> ticket) {
  // This would be implemented to export ticket data to a file
  successMessage('Ticket exported successfully');
}

Widget _buildUserCard({
  required String userName,
  required String userEmail,
  required String? userImage,
  required String userId,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            AvatarUserWidget(
              radius: 25,
              imagePath: userImage ?? '',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'User ID: ${userId.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/admin/users/$userId'),
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Show user's previous tickets
              },
              icon: const Icon(Icons.history),
              label: const Text('View History'),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTicketInfoCard({
  required DateTime createdAt,
  required String? assignedTo,
  required SupportSystemController controller,
  required Map<String, dynamic> ticket,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ticket Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          label: 'Created',
          value: DateFormat('MMM dd, yyyy - HH:mm').format(createdAt),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Assigned To',
          value: assignedTo ?? 'Unassigned',
          valueColor:
              assignedTo != null ? Colors.deepPurpleAccent : Colors.grey,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Device',
          value: ticket['deviceInfo'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'App Version',
          value: ticket['appVersion'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          label: 'Platform',
          value: ticket['platform'] as String? ?? 'Unknown',
        ),
        const SizedBox(height: 16),
        // Tags
        const Text(
          'Tags',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...(ticket['tags'] as List<dynamic>? ?? [])
                .map((tag) => _buildTagChip(
                      tag: tag as String,
                      onDeleted: () {
                        // Remove tag
                        controller.removeTagFromTicket(
                            ticket['id'] as String, tag);
                      },
                    )),
            ActionChip(
              label: const Text('Add Tag'),
              avatar: const Icon(Icons.add, size: 16),
              onPressed: () => _showAddTagDialog(ticket, controller),
            ),
          ],
        ),
      ],
    ),
  );
}
