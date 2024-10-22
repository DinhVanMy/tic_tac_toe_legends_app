import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/constant_data.dart';
import 'mission_model.dart'; // Đường dẫn đến model TaskModel

class TaskController extends GetxController {
  FirebaseFirestore db = FirebaseFirestore.instance;

  RxList<TaskModel> dailyTasks = <TaskModel>[].obs;
  RxList<TaskModel> weeklyTasks = <TaskModel>[].obs;
  RxList<TaskModel> monthlyTasks = <TaskModel>[].obs;

  final String userId;
  TaskController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    listenForTasks();
  }

  // Lắng nghe nhiệm vụ của người chơi
  void listenForTasks() {
    db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        TaskModel task = TaskModel.fromJson(change.doc.data()!, change.doc.id);

        if (task.type == 'daily') {
          _updateTaskList(dailyTasks, change, task);
        } else if (task.type == 'weekly') {
          _updateTaskList(weeklyTasks, change, task);
        } else if (task.type == 'monthly') {
          _updateTaskList(monthlyTasks, change, task);
        }
      }
    });
  }

  // Hàm cập nhật danh sách nhiệm vụ
  void _updateTaskList(
      RxList<TaskModel> taskList, DocumentChange change, TaskModel task) {
    if (change.type == DocumentChangeType.added) {
      taskList.add(task);
    } else if (change.type == DocumentChangeType.modified) {
      int index = taskList.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        taskList[index] = task;
      }
    } else if (change.type == DocumentChangeType.removed) {
      taskList.removeWhere((t) => t.id == task.id);
    }
  }

  // Hàm thêm nhiệm vụ mới
  Future<void> addTask(TaskModel task) async {
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(task.toJson());
  }

  // Kiểm tra và tạo nhiệm vụ Daily
  Future<void> checkAndCreateDailyTasks() async {
    var now = DateTime.now();
    var tasksSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'daily')
        .where('deadline', isGreaterThanOrEqualTo: now)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      // Tạo 5 nhiệm vụ Daily
      List<TaskModel> dailyMissions = _generateDailyMissions();
      for (var task in dailyMissions) {
        await addTask(task);
      }
    }
  }

  // Kiểm tra và tạo nhiệm vụ Weekly
  Future<void> checkAndCreateWeeklyTasks() async {
    var now = DateTime.now();
    var tasksSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'weekly')
        .where('deadline', isGreaterThanOrEqualTo: now)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      // Tạo 5 nhiệm vụ Weekly
      List<TaskModel> weeklyMissions = _generateWeeklyMissions();
      for (var task in weeklyMissions) {
        await addTask(task);
      }
    }
  }

  // Kiểm tra và tạo nhiệm vụ Monthly
  Future<void> checkAndCreateMonthlyTasks() async {
    var now = DateTime.now();
    var tasksSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'monthly')
        .where('deadline', isGreaterThanOrEqualTo: now)
        .get();

    if (tasksSnapshot.docs.isEmpty) {
      // Tạo 5 nhiệm vụ Monthly
      List<TaskModel> monthlyMissions = _generateMonthlyMissions();
      for (var task in monthlyMissions) {
        await addTask(task);
      }
    }
  }

  // Hàm reset trạng thái nhiệm vụ
  Future<void> resetTasksIfNeeded() async {
    var now = DateTime.now();

    // Reset daily tasks nếu đã qua 1 ngày
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'daily')
        .where('deadline', isLessThanOrEqualTo: now)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        db
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(doc.id)
            .delete()
            .catchError((e) => errorMessage(e.toString()));
      }
    });

    // Reset weekly tasks nếu đã qua 1 tuần
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'weekly')
        .where('deadline', isLessThanOrEqualTo: now)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        db
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(doc.id)
            .delete()
            .catchError((e) => errorMessage(e.toString()));
      }
    });

    // Reset monthly tasks nếu đã qua 1 tháng
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('type', isEqualTo: 'monthly')
        .where('deadline', isLessThanOrEqualTo: now)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        db
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(doc.id)
            .delete()
            .catchError((e) => errorMessage(e.toString()));
      }
    });
  }

  // Hàm tạo mẫu nhiệm vụ Daily
  List<TaskModel> _generateDailyMissions() {
    return dailyMissions;
  }

  // Hàm tạo mẫu nhiệm vụ Weekly
  List<TaskModel> _generateWeeklyMissions() {
    return weeklyMissions;
  }

  // Hàm tạo mẫu nhiệm vụ Monthly
  List<TaskModel> _generateMonthlyMissions() {
    return monthlyMissions;
  }

  void updateTaskByFieldId(
      {required String taskFieldId, int newProgress = 1}) async {
    final taskQuerySnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('id', isEqualTo: taskFieldId) // Lọc dựa trên trường 'id'
        .get();

    for (var taskDoc in taskQuerySnapshot.docs) {
      final taskData = taskDoc.data();
      final taskId = taskDoc.id; // Lấy taskId từ document

      if (taskData['progress'] < taskData['goal']) {
        await db
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(taskId) // Dùng taskId để cập nhật task tương ứng
            .update({
          'progress': FieldValue.increment(newProgress),
          'status': (taskData['progress'] + newProgress >= taskData['goal'])
              ? 'completed'
              : 'incomplete',
        });
      }
    }
  }

  String displayTime(DateTime dateTime) {
    // Lấy giờ theo định dạng 12 giờ
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minutes = dateTime.minute.toString().padLeft(2, '0');

    // Xác định AM hay PM
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return "$hour:$minutes $period";
  }

  String displayDate(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    return "$day/$month/$year";
  }
}

// void updateTasksByFieldIdWithBatch(
//      {required String taskFieldId, int newProgress = 1}) async {
//   final taskQuerySnapshot = await db
//       .collection('users')
//       .doc(userId)
//       .collection('tasks')
//       .where('id', isEqualTo: taskFieldId)  // Lọc dựa trên trường 'id'
//       .get();

//   WriteBatch batch = db.batch();

//   for (var taskDoc in taskQuerySnapshot.docs) {
//     final taskData = taskDoc.data();
//     final taskId = taskDoc.id;

//     if (taskData['progress'] < taskData['goal']) {
//       DocumentReference taskRef = db
//           .collection('users')
//           .doc(userId)
//           .collection('tasks')
//           .doc(taskId);

//       batch.update(taskRef, {
//         'progress': FieldValue.increment(newProgress),
//         'status': (taskData['progress'] + newProgress >= taskData['goal']) ? 'completed' : 'incomplete',
//       });
//     }
//   }

//   // Thực thi batch
//   await batch.commit();
// }
