// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Column(
      children: [
        _buildFilterBar(controller),
        Expanded(
          child: _buildAnnouncementsList(controller),
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
                value: controller.announcementTypeFilter.value,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(
                      value: 'maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'update', child: Text('Update')),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.announcementTypeFilter.value = value;
                  }
                },
              )),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showCreateAnnouncementDialog(controller),
            icon: const Icon(Icons.add),
            label: const Text('New Announcement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAnnouncementsList(AdminController controller) {
  return Obx(() {
    if (controller.isLoadingAnnouncements.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No announcements found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showCreateAnnouncementDialog(controller),
              child: const Text('Create Announcement'),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          controller.fetchAnnouncements(); // Load more when reaching the end
        }
        return true;
      },
      child: ListView.builder(
        itemCount: controller.announcements.length,
        itemBuilder: (context, index) {
          final announcement = controller.announcements[index];
          return _buildAnnouncementItem(controller, announcement);
        },
      ),
    );
  });
}

Widget _buildAnnouncementItem(
    AdminController controller, Map<String, dynamic> announcement) {
  final String id = announcement['id'] ?? '';
  final String title = announcement['title'] ?? 'No Title';
  final String message = announcement['message'] ?? 'No message';
  final String type = announcement['type'] ?? 'system';
  final String targetAudience = announcement['targetAudience'] ?? 'all';
  final bool active = announcement['active'] ?? false;

  // Parse timestamps
  DateTime? createdAt;
  if (announcement['createdAt'] != null) {
    createdAt = (announcement['createdAt'] as Timestamp).toDate();
  }

  DateTime? startDate;
  if (announcement['startDate'] != null) {
    startDate = (announcement['startDate'] as Timestamp).toDate();
  }

  DateTime? endDate;
  if (announcement['endDate'] != null) {
    endDate = (announcement['endDate'] as Timestamp).toDate();
  }

  // Determine if announcement is current, upcoming, or expired
  final now = DateTime.now();
  String status = 'current';

  if (startDate != null && startDate.isAfter(now)) {
    status = 'upcoming';
  } else if (endDate != null && endDate.isBefore(now)) {
    status = 'expired';
  }

  return Card(
    margin: const EdgeInsets.all(8.0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: _getBorderColor(status, active),
        width: 2,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAnnouncementTypeChip(type),
              const SizedBox(width: 8),
              _buildStatusChip(status, active),
              const Spacer(),
              Text(
                createdAt != null
                    ? TimeFunctions.timeAgo(now: now, createdAt: createdAt)
                    : 'Unknown time',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people, size: 16),
              const SizedBox(width: 4),
              Text(
                'Target: ${targetAudience.capitalize}',
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              if (startDate != null && endDate != null)
                Text(
                  '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                  style: const TextStyle(fontSize: 12),
                )
              else if (startDate != null)
                Text(
                  'From ${DateFormat('MMM dd').format(startDate)}',
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editAnnouncement(controller, announcement),
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
              ),
              if (active)
                IconButton(
                  onPressed: () => _deactivateAnnouncement(controller, id),
                  icon: const Icon(Icons.visibility_off),
                  tooltip: 'Deactivate',
                )
              else
                IconButton(
                  onPressed: () => _activateAnnouncement(controller, id),
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Activate',
                ),
              IconButton(
                onPressed: () =>
                    _confirmDeleteAnnouncement(controller, id, title),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildAnnouncementTypeChip(String type) {
  IconData icon;
  Color color;

  switch (type) {
    case 'system':
      icon = Icons.info;
      color = Colors.blue;
      break;
    case 'maintenance':
      icon = Icons.build;
      color = Colors.orange;
      break;
    case 'update':
      icon = Icons.system_update;
      color = Colors.green;
      break;
    case 'event':
      icon = Icons.event;
      color = Colors.purple;
      break;
    default:
      icon = Icons.announcement;
      color = Colors.grey;
  }

  return Chip(
    avatar: Icon(
      icon,
      size: 16,
      color: Colors.white,
    ),
    label: Text(
      type.capitalize!,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    backgroundColor: color,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}

Widget _buildStatusChip(String status, bool active) {
  IconData icon;
  Color color;
  String label;

  if (!active) {
    icon = Icons.visibility_off;
    color = Colors.grey;
    label = 'Inactive';
  } else {
    switch (status) {
      case 'upcoming':
        icon = Icons.access_time;
        color = Colors.amber;
        label = 'Upcoming';
        break;
      case 'expired':
        icon = Icons.timer_off;
        color = Colors.red;
        label = 'Expired';
        break;
      default:
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Active';
    }
  }

  return Chip(
    avatar: Icon(
      icon,
      size: 16,
      color: Colors.white,
    ),
    label: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    backgroundColor: color,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}

Color _getBorderColor(String status, bool active) {
  if (!active) return Colors.grey;

  switch (status) {
    case 'upcoming':
      return Colors.amber;
    case 'expired':
      return Colors.red;
    default:
      return Colors.green;
  }
}

void _showCreateAnnouncementDialog(AdminController controller) {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  String type = 'system';
  String targetAudience = 'all';
  DateTime? startDate;
  DateTime? endDate;

  Get.dialog(
    Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Announcement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: type,
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'update', child: Text('Update')),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  value: targetAudience,
                  onChanged: (value) {
                    if (value != null) {
                      targetAudience = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Admins Only')),
                    DropdownMenuItem(
                        value: 'moderator', child: Text('Moderators & Admins')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            startDate = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            startDate != null
                                ? DateFormat('MMM dd, yyyy').format(startDate)
                                : 'Select Date',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (startDate == null) {
                            Get.snackbar(
                              'Error',
                              'Please select a start date first',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate:
                                startDate!.add(const Duration(days: 1)),
                            firstDate: startDate!.add(const Duration(days: 1)),
                            lastDate: startDate!.add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            endDate = date;
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            endDate != null
                                ? DateFormat('MMM dd, yyyy').format(endDate)
                                : 'No End Date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        if (formKey.currentState!.validate()) {
                          controller
                              .createAnnouncement(
                            title: titleController.text,
                            message: messageController.text,
                            type: type,
                            targetAudience: targetAudience,
                            startDate: startDate,
                            endDate: endDate,
                          )
                              .then((success) {
                            if (success) {
                              Get.back();
                            }
                          });
                        }
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
      ),
    ),
  );
}

void _editAnnouncement(
    AdminController controller, Map<String, dynamic> announcement) {
  final formKey = GlobalKey<FormState>();
  final String id = announcement['id'] ?? '';
  final titleController =
      TextEditingController(text: announcement['title'] ?? '');
  final messageController =
      TextEditingController(text: announcement['message'] ?? '');
  String type = announcement['type'] ?? 'system';
  String targetAudience = announcement['targetAudience'] ?? 'all';

  DateTime? startDate;
  if (announcement['startDate'] != null) {
    startDate = (announcement['startDate'] as Timestamp).toDate();
  }

  DateTime? endDate;
  if (announcement['endDate'] != null) {
    endDate = (announcement['endDate'] as Timestamp).toDate();
  }

  Get.dialog(
    Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Announcement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: type,
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(
                        value: 'maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'update', child: Text('Update')),
                    DropdownMenuItem(value: 'event', child: Text('Event')),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  value: targetAudience,
                  onChanged: (value) {
                    if (value != null) {
                      targetAudience = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Admins Only')),
                    DropdownMenuItem(
                        value: 'moderator', child: Text('Moderators & Admins')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) => InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => startDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              startDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(startDate!)
                                  : 'Select Date',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) => InkWell(
                          onTap: () async {
                            if (startDate == null) {
                              Get.snackbar(
                                'Error',
                                'Please select a start date first',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ??
                                  startDate!.add(const Duration(days: 1)),
                              firstDate:
                                  startDate!.add(const Duration(days: 1)),
                              lastDate:
                                  startDate!.add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => endDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(endDate!)
                                      : 'No End Date',
                                ),
                                if (endDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      setState(() => endDate = null);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        if (formKey.currentState!.validate()) {
                          final updateData = {
                            'title': titleController.text,
                            'message': messageController.text,
                            'type': type,
                            'targetAudience': targetAudience,
                            'startDate': startDate,
                            'endDate': endDate,
                          };

                          controller
                              .updateAnnouncement(id, updateData)
                              .then((success) {
                            if (success) {
                              Get.back();
                            }
                          });
                        }
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
    ),
  );
}

void _activateAnnouncement(AdminController controller, String id) {
  controller.updateAnnouncement(id, {'active': true});
}

void _deactivateAnnouncement(AdminController controller, String id) {
  controller.updateAnnouncement(id, {'active': false});
}

void _confirmDeleteAnnouncement(
    AdminController controller, String id, String title) {
  Get.dialog(Dialog(child: Text(title)));
}
