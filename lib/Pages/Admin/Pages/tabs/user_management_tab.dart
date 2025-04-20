import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Pages/Admin/controllers/admin_controller.dart';
import 'package:tictactoe_gameapp/Pages/Admin/models/user_model.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final RxString searchQuery = ''.obs;
  final expandedIndex = (-1).obs;
  final TextEditingController searchEditingController = TextEditingController();

  @override
  void dispose() {
    searchQuery.close();
    expandedIndex.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Column(
      children: [
        _buildSearchBar(controller),
        _buildBatchOperationsBar(controller),
        Expanded(
          child: _buildUserList(controller),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchEditingController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchEditingController.clear();
                          FocusNode().unfocus();
                          searchQuery.value = '';
                          controller.userSearchQuery.value = '';
                        },
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                searchQuery.value = value.trim();
                controller.userSearchQuery.value = value.trim();
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => DropdownButton<String>(
                value: controller.selectedRoleFilter.value,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'moderator', child: Text('Moderator')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedRoleFilter.value = value;
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildBatchOperationsBar(AdminController controller) {
    return Obx(() {
      if (controller.selectedUserIds.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Row(
          children: [
            Text(
              '${controller.selectedUserIds.length} users selected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  controller.clearUserSelection();
                } else {
                  _confirmBatchOperation(
                    controller,
                    value,
                    controller.selectedUserIds.length,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'verify',
                  child: Text('Verify Selected'),
                ),
                const PopupMenuItem(
                  value: 'suspend',
                  child: Text('Suspend Selected'),
                ),
                const PopupMenuItem(
                  value: 'activate',
                  child: Text('Activate Selected'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Selected'),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear Selection'),
                ),
              ],
              child: Chip(
                label: const Text('Actions'),
                avatar: const Icon(Icons.more_vert),
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUserList(AdminController controller) {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                GifsPath.transitionGif,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      }

      if (controller.users.isEmpty) {
        return const Center(
          child: Text('No users found'),
        );
      }

      // Lọc danh sách người dùng theo từ khóa tìm kiếm
      var filteredUsers = controller.users.where((user) {
        if (searchQuery.value.isEmpty) {
          return true;
        }

        final query = searchQuery.value.toLowerCase();
        final name = user.name?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        final id = user.id?.toLowerCase() ?? '';

        return name.contains(query) ||
            email.contains(query) ||
            id.contains(query);
      }).toList();

      // Áp dụng bộ lọc theo vai trò nếu được chọn
      if (controller.selectedRoleFilter.value != 'all') {
        filteredUsers = filteredUsers
            .where((user) => user.role == controller.selectedRoleFilter.value)
            .toList();
      }

      if (filteredUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No users found matching "${searchQuery.value}"',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  searchEditingController.clear();
                  FocusNode().unfocus();
                  searchQuery.value = '';
                  controller.userSearchQuery.value = '';
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ),
        );
      }

      // Sắp xếp người dùng theo coins giảm dần
      filteredUsers.sort((a, b) {
        int totalCoinsA = int.tryParse(a.totalCoins ?? '0') ?? 0;
        int totalCoinsB = int.tryParse(b.totalCoins ?? '0') ?? 0;
        return totalCoinsB.compareTo(totalCoinsA);
      });

      return Scrollbar(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserRankingItem(
                controller, filteredUsers[index], index);
          },
        ),
      );
    });
  }

  Widget _buildUserRankingItem(
      AdminController controller, UserModel user, int position) {
    final isSelected = controller.selectedUserIds.contains(user.id);

    return Obx(() => Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 2.0,
                    spreadRadius: 2.0,
                    color: Colors.white,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                onExpansionChanged: (bool expanded) {
                  if (expanded) {
                    expandedIndex.value = position;
                  } else if (expandedIndex.value == position) {
                    expandedIndex.value = -1;
                  }
                },
                iconColor: Colors.white,
                collapsedIconColor: Colors.pink,
                collapsedBackgroundColor: isSelected
                    ? Colors.purpleAccent.withOpacity(0.5)
                    : Colors.lightBlueAccent,
                backgroundColor: isSelected
                    ? Colors.purpleAccent.withOpacity(0.5)
                    : Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Badge(
                  label: Text("${position + 1}"),
                  textColor: position == 0
                      ? Colors.red
                      : position == 1
                          ? Colors.yellow
                          : position == 2
                              ? Colors.greenAccent
                              : Colors.white,
                  backgroundColor: Colors.black,
                  child: Column(
                    children: [
                      Image.asset(
                        position == 0
                            ? TrimRanking.challTrim
                            : position == 1
                                ? TrimRanking.masterTrim
                                : position == 2
                                    ? TrimRanking.diamondTrim
                                    : TrimRanking.goldTrim,
                        width: 45,
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  children: [
                    user.status == "online"
                        ? const Text(
                            "Online",
                            style: TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 15,
                            ),
                          )
                        : const Text(
                            "Offline",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                          ),
                    Icon(
                      expandedIndex.value == position
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showUserDetailsDialog(user);
                      },
                      onLongPress: () {
                        if (user.id != null) {
                          controller.toggleUserSelection(user.id!);
                        }
                      },
                      child: Stack(
                        children: [
                          user.image != null && user.image!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.image!),
                                  radius: 25,
                                )
                              : const CircleAvatar(
                                  radius: 25,
                                  child: Icon(Icons.person_2_outlined),
                                ),
                          if (isSelected)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sử dụng Expanded cho phần thông tin user
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: user.suspended == true
                                  ? Colors.grey
                                  : Colors.deepPurple,
                              fontSize: 15,
                              decoration: user.suspended == true
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Row(
                            children: [
                              Text(
                                user.totalCoins ?? "0",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 5),
                              SvgPicture.asset(
                                IconsPath.coinIcon,
                                width: 20,
                                color: Colors.yellowAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Phần này sẽ luôn hiển thị
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(user.role ?? 'user'),
                          backgroundColor: _getRoleColor(user.role),
                          labelStyle: const TextStyle(
                              fontSize: 10, color: Colors.white),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        if (user.verified == true)
                          const Icon(Icons.verified,
                              size: 16, color: Colors.blue),
                        if (user.suspended == true)
                          const Icon(Icons.block, size: 16, color: Colors.red),
                      ],
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email: ${user.email ?? "${user.name}@gmail.com"}",
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Bio: ${user.bio}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Role'),
                                onPressed: () {
                                  _showEditRoleDialog(user, controller);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon: Icon(user.suspended == true
                                    ? Icons.check_circle
                                    : Icons.block),
                                label: Text(user.suspended == true
                                    ? 'Activate'
                                    : 'Suspend'),
                                onPressed: () {
                                  if (user.suspended == true) {
                                    _confirmActivateUser(user, controller);
                                  } else {
                                    _confirmSuspendUser(user, controller);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: user.suspended == true
                                      ? Colors.green
                                      : Colors.red,
                                  side: BorderSide(
                                      color: user.suspended == true
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Delete'),
                                onPressed: () {
                                  _confirmDeleteUser(user, controller);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.green;
      case 'user':
      default:
        return Colors.blue;
    }
  }

  void _showUserDetailsDialog(UserModel user) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AvatarUserWidget(
                      radius: 50,
                      imagePath: user.image ?? '',
                      gradientColors: user.avatarFrame,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: user.status == "online"
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(user.role ?? 'user'),
                      backgroundColor: _getRoleColor(user.role),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    if (user.verified == true)
                      const Chip(
                        label: Text('Verified'),
                        avatar:
                            Icon(Icons.verified, color: Colors.blue, size: 18),
                        backgroundColor: Color(0xFFE3F2FD),
                      ),
                    if (user.suspended == true)
                      const Chip(
                        label: Text('Suspended'),
                        avatar: Icon(Icons.block, color: Colors.red, size: 18),
                        backgroundColor: Color(0xFFFFEBEE),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _userStatItem(
                      'Coins', user.totalCoins ?? '0', Icons.monetization_on),
                  _userStatItem(
                      'Wins', user.totalWins ?? '0', Icons.emoji_events),
                  _userStatItem('Friends', '${user.friendsList?.length ?? 0}',
                      Icons.people),
                ],
              ),
              const SizedBox(height: 16),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.bio!),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const SizedBox(height: 8),
              _detailRow('User ID', user.id ?? ''),
              _detailRow('Status', user.status ?? 'Offline'),
              _detailRow(
                  'Joined',
                  user.createdAt?.toDate().toString().split(' ')[0] ??
                      'Unknown'),
              _detailRow('Last Active',
                  user.lastActive?.toDate().toString() ?? 'Unknown'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(UserModel user, AdminController controller) {
    final currentRole = user.role ?? 'user';
    var selectedRole = currentRole;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarUserWidget(
                    radius: 25,
                    imagePath: user.image ?? '',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Edit User Role',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('User: ${user.name ?? "Unknown"}'),
                        Text('Current Role: $currentRole',
                            style:
                                TextStyle(color: _getRoleColor(currentRole))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('User'),
                        value: 'user',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      RadioListTile<String>(
                        title: const Text('Moderator'),
                        value: 'moderator',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      RadioListTile<String>(
                        title: const Text('Admin'),
                        value: 'admin',
                        groupValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  );
                },
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
                      if (selectedRole != currentRole && user.id != null) {
                        controller
                            .updateUserRole(user.id!, selectedRole)
                            .then((success) {
                          if (success) {
                            Get.back();
                            successMessage('User role updated successfully!');
                          }
                        });
                      } else {
                        Get.back();
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
    );
  }

  void _confirmSuspendUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Suspend User'),
        content: Text(
            'Are you sure you want to suspend ${user.name}? This will prevent them from accessing the app.'),
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
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('suspend').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User suspended successfully!');
                }
              });
            },
            child: const Text('SUSPEND'),
          ),
        ],
      ),
    );
  }

  void _confirmActivateUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Activate User'),
        content: Text(
            'Are you sure you want to activate ${user.name}? This will restore their access to the app.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('activate').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User activated successfully!');
                }
              });
            },
            child: const Text('ACTIVATE'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(UserModel user, AdminController controller) {
    if (user.id == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to permanently delete ${user.name}? This action cannot be undone.'),
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
              // Add the user ID to selected list
              controller.selectedUserIds.clear();
              controller.selectedUserIds.add(user.id!);

              controller.performBatchOperation('delete').then((success) {
                if (success) {
                  Get.back();
                  successMessage('User deleted successfully!');
                }
              });
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _confirmBatchOperation(
      AdminController controller, String operation, int count) {
    String title;
    String content;
    String action;
    Color actionColor = Colors.blue;

    switch (operation) {
      case 'verify':
        title = 'Verify Users';
        content = 'Are you sure you want to verify $count users?';
        action = 'VERIFY';
        break;
      case 'suspend':
        title = 'Suspend Users';
        content =
            'Are you sure you want to suspend $count users? This will prevent them from accessing the app.';
        action = 'SUSPEND';
        actionColor = Colors.red;
        break;
      case 'activate':
        title = 'Activate Users';
        content =
            'Are you sure you want to activate $count users? This will restore their access to the app.';
        action = 'ACTIVATE';
        break;
      case 'delete':
        title = 'Delete Users';
        content =
            'Are you sure you want to permanently delete $count users? This action cannot be undone.';
        action = 'DELETE';
        actionColor = Colors.red;
        break;
      default:
        return;
    }

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
            ),
            onPressed: () {
              controller.performBatchOperation(operation).then((success) {
                if (success) {
                  Get.back();
                  successMessage('Operation completed successfully!');
                }
              });
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
