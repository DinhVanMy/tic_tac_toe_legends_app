import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SupportSystemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state
  final RxBool isLoading = true.obs;

  // Form controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController replyController = TextEditingController();

  // Search and filter state
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedPriorityFilter = 'all'.obs;
  final RxString sortCriteria = 'date'.obs;

  // Selected ticket
  final RxString selectedTicketId = ''.obs;

  // Ticket data
  final RxList<Map<String, dynamic>> allTickets = <Map<String, dynamic>>[].obs;

  // Knowledge base data
  final RxList<Map<String, dynamic>> knowledgeBaseArticles =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Set up reactive search
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    replyController.dispose();
    super.onClose();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await loadData();
  }

  Future<void> loadData() async {
    try {
      await Future.wait([
        loadTickets(),
        loadKnowledgeBase(),
      ]);
    } catch (e) {
      print('Error loading support data: $e');
      errorMessage('Failed to load support data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTickets() async {
    try {
      // In a real app, this would fetch tickets from Firestore
      // For this example, we'll generate mock data

      final List<Map<String, dynamic>> tickets = [];
      final now = DateTime.now();

      // Mock ticket statuses
      final List<String> statuses = ['open', 'pending', 'resolved'];

      // Mock ticket priorities
      final List<String> priorities = ['low', 'medium', 'high'];

      // Mock ticket categories
      final List<String> categories = [
        'Account',
        'Billing',
        'Game Play',
        'Technical',
        'Feature Request',
        'Bug Report',
        'Other',
      ];

      // Generate mock tickets
      for (int i = 0; i < 20; i++) {
        final status = statuses[i % statuses.length];
        final priority = priorities[i % priorities.length];
        final category = categories[i % categories.length];
        final createdAt = now.subtract(Duration(days: i * 2));
        final lastUpdated = now.subtract(Duration(days: i));

        // Generate messages if status is not resolved
        final List<Map<String, dynamic>> messages = [];

        if (status != 'resolved') {
          // Add some mock messages
          final messageCount = 1 + (i % 3);

          for (int j = 0; j < messageCount; j++) {
            final isUserMessage = j % 2 == 0;

            messages.add({
              'sender': isUserMessage ? 'User ${i + 1}' : 'Support Agent',
              'senderImage': '',
              'content': isUserMessage
                  ? 'I\'m still experiencing the issue. Can you provide more information?'
                  : 'Thank you for the update. We\'ll look into this further.',
              'timestamp': now.subtract(Duration(days: i, hours: j * 6)),
              'isUser': isUserMessage,
            });
          }
        }

        tickets.add({
          'id': 'ticket${1000 + i}',
          'subject': getTicketSubject(category, i),
          'description': getTicketDescription(category, i),
          'userId': 'user${1000 + i}',
          'userName': 'User ${i + 1}',
          'userEmail': 'user${i + 1}@example.com',
          'userImage': '',
          'status': status,
          'priority': priority,
          'category': category,
          'assignedTo': i % 4 == 0 ? 'Agent ${i % 3 + 1}' : null,
          'createdAt': createdAt,
          'lastUpdated': lastUpdated,
          'messages': messages,
          'hasNewMessage': i % 5 == 0,
          'tags': getTags(category, i),
          'platform': i % 2 == 0 ? 'iOS' : 'Android',
          'deviceInfo': i % 2 == 0 ? 'iPhone 13' : 'Samsung Galaxy S21',
          'appVersion': '1.${5 + (i % 3)}.0',
        });
      }

      allTickets.assignAll(tickets);

      // If a ticket was selected, update it with the latest data
      if (selectedTicketId.isNotEmpty) {
        final ticketIndex = tickets
            .indexWhere((ticket) => ticket['id'] == selectedTicketId.value);
        if (ticketIndex == -1) {
          // Selected ticket no longer exists
          selectedTicketId.value = '';
        }
      }
    } catch (e) {
      print('Error loading tickets: $e');
      errorMessage('Failed to load tickets: $e');
    }
  }

  Future<void> loadKnowledgeBase() async {
    try {
      // In a real app, this would fetch articles from Firestore
      // For this example, we'll generate mock data

      final List<Map<String, dynamic>> articles = [];
      final now = DateTime.now();

      // Mock categories
      final List<String> categories = [
        'Account',
        'Billing',
        'Game Play',
        'Technical',
        'Feature Request',
        'Bug Report',
        'Other',
      ];

      // Generate mock articles
      for (int i = 0; i < 15; i++) {
        final category = categories[i % categories.length];

        articles.add({
          'id': 'article${1000 + i}',
          'title': getArticleTitle(category, i),
          'content': getArticleContent(category, i),
          'summary': getArticleSummary(category, i),
          'category': category,
          'author': 'Admin',
          'createdAt': now.subtract(Duration(days: i * 10)),
          'updatedAt': now.subtract(Duration(days: i * 5)),
          'views': 100 - (i * 5),
          'helpful': 50 - (i * 3),
        });
      }

      knowledgeBaseArticles.assignAll(articles);
    } catch (e) {
      print('Error loading knowledge base: $e');
      errorMessage('Failed to load knowledge base: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredTickets() {
    // Apply filters to the tickets
    return allTickets.where((ticket) {
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final subject = (ticket['subject'] as String).toLowerCase();
        final description = (ticket['description'] as String).toLowerCase();
        final userName = (ticket['userName'] as String).toLowerCase();
        final ticketId = (ticket['id'] as String).toLowerCase();

        if (!subject.contains(query) &&
            !description.contains(query) &&
            !userName.contains(query) &&
            !ticketId.contains(query)) {
          return false;
        }
      }

      // Apply status filter
      if (selectedStatusFilter.value != 'all' &&
          ticket['status'] != selectedStatusFilter.value) {
        return false;
      }

      // Apply priority filter
      if (selectedPriorityFilter.value != 'all' &&
          ticket['priority'] != selectedPriorityFilter.value) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Apply sorting
        switch (sortCriteria.value) {
          case 'date':
            return (b['lastUpdated'] as DateTime)
                .compareTo(a['lastUpdated'] as DateTime);
          case 'priority':
            final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
            return priorityOrder[a['priority']]!
                .compareTo(priorityOrder[b['priority']]!);
          case 'status':
            final statusOrder = {'open': 0, 'pending': 1, 'resolved': 2};
            return statusOrder[a['status']]!
                .compareTo(statusOrder[b['status']]!);
          default:
            return (b['lastUpdated'] as DateTime)
                .compareTo(a['lastUpdated'] as DateTime);
        }
      });
  }

  List<Map<String, dynamic>> getAllTickets() {
    return allTickets;
  }

  Map<String, dynamic>? getSelectedTicket() {
    if (selectedTicketId.isEmpty) return null;

    final ticketIndex = allTickets
        .indexWhere((ticket) => ticket['id'] == selectedTicketId.value);
    if (ticketIndex == -1) return null;

    return allTickets[ticketIndex];
  }

  void selectTicket(String ticketId) {
    selectedTicketId.value = ticketId;

    // Mark any new messages as read
    final ticketIndex =
        allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
    if (ticketIndex != -1) {
      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      if (ticket['hasNewMessage'] == true) {
        ticket['hasNewMessage'] = false;
        allTickets[ticketIndex] = ticket;
      }
    }
  }

  List<Map<String, dynamic>> getRelatedArticles(String category) {
    return knowledgeBaseArticles
        .where((article) => article['category'] == category)
        .toList();
  }

  List<Map<String, dynamic>> getFilteredKnowledgeBaseArticles(
      String query, String? category) {
    return knowledgeBaseArticles.where((article) {
      // Apply search filter
      if (query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        final title = (article['title'] as String).toLowerCase();
        final content = (article['content'] as String).toLowerCase();
        final summary = (article['summary'] as String).toLowerCase();

        if (!title.contains(lowercaseQuery) &&
            !content.contains(lowercaseQuery) &&
            !summary.contains(lowercaseQuery)) {
          return false;
        }
      }

      // Apply category filter
      if (category != null && article['category'] != category) {
        return false;
      }

      return true;
    }).toList();
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatusFilter.value = 'all';
    selectedPriorityFilter.value = 'all';
    sortCriteria.value = 'date';
  }

  // Ticket management methods
  Future<bool> sendReply(String ticketId, String message) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add new message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': message,
        'timestamp': DateTime.now(),
        'isUser': false,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] =
          'pending'; // Change status to pending when agent replies

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error sending reply: $e');
      errorMessage('Failed to send reply: $e');
      return false;
    }
  }

  Future<bool> resolveTicket(String ticketId, String resolution) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add resolution message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': resolution,
        'timestamp': DateTime.now(),
        'isUser': false,
        'isResolution': true,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] = 'resolved';
      ticket['resolution'] = resolution;

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error resolving ticket: $e');
      errorMessage('Failed to resolve ticket: $e');
      return false;
    }
  }

  Future<bool> reopenTicket(String ticketId, String reason) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final messages = List<Map<String, dynamic>>.from(
          ticket['messages'] as List<dynamic>? ?? []);

      // Add reopen message
      messages.add({
        'sender': 'Support Agent',
        'senderImage': '',
        'content': 'Ticket reopened: $reason',
        'timestamp': DateTime.now(),
        'isUser': false,
        'isReopen': true,
      });

      // Update ticket
      ticket['messages'] = messages;
      ticket['lastUpdated'] = DateTime.now();
      ticket['status'] = 'open';
      ticket.remove('resolution');

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error reopening ticket: $e');
      errorMessage('Failed to reopen ticket: $e');
      return false;
    }
  }

  Future<bool> assignTicket(
      String ticketId, String agentId, String agentName) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['assignedTo'] = agentName;
      ticket['assignedToId'] = agentId;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error assigning ticket: $e');
      errorMessage('Failed to assign ticket: $e');
      return false;
    }
  }

  Future<bool> unassignTicket(String ticketId) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket.remove('assignedTo');
      ticket.remove('assignedToId');
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error unassigning ticket: $e');
      errorMessage('Failed to unassign ticket: $e');
      return false;
    }
  }

  Future<bool> changeTicketPriority(String ticketId, String priority) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['priority'] = priority;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error changing ticket priority: $e');
      errorMessage('Failed to change ticket priority: $e');
      return false;
    }
  }

  Future<bool> changeTicketCategory(String ticketId, String category) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);

      // Update ticket
      ticket['category'] = category;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error changing ticket category: $e');
      errorMessage('Failed to change ticket category: $e');
      return false;
    }
  }

  Future<bool> addTagToTicket(String ticketId, String tag) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final tags = List<String>.from(ticket['tags'] as List<dynamic>? ?? []);

      // Add tag if it doesn't already exist
      if (!tags.contains(tag)) {
        tags.add(tag);
        ticket['tags'] = tags;
        ticket['lastUpdated'] = DateTime.now();

        // Update ticket in list
        allTickets[ticketIndex] = ticket;
      }

      return true;
    } catch (e) {
      print('Error adding tag to ticket: $e');
      errorMessage('Failed to add tag to ticket: $e');
      return false;
    }
  }

  Future<bool> removeTagFromTicket(String ticketId, String tag) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final tags = List<String>.from(ticket['tags'] as List<dynamic>? ?? []);

      // Remove tag if it exists
      if (tags.contains(tag)) {
        tags.remove(tag);
        ticket['tags'] = tags;
        ticket['lastUpdated'] = DateTime.now();

        // Update ticket in list
        allTickets[ticketIndex] = ticket;
      }

      return true;
    } catch (e) {
      print('Error removing tag from ticket: $e');
      errorMessage('Failed to remove tag from ticket: $e');
      return false;
    }
  }

  Future<bool> addInternalNote(String ticketId, String note) async {
    try {
      final ticketIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == ticketId);
      if (ticketIndex == -1) return false;

      final ticket = Map<String, dynamic>.from(allTickets[ticketIndex]);
      final notes = List<Map<String, dynamic>>.from(
          ticket['internalNotes'] as List<dynamic>? ?? []);

      // Add note
      notes.add({
        'note': note,
        'author': 'Support Agent',
        'timestamp': DateTime.now(),
      });

      // Update ticket
      ticket['internalNotes'] = notes;
      ticket['lastUpdated'] = DateTime.now();

      // Update ticket in list
      allTickets[ticketIndex] = ticket;

      return true;
    } catch (e) {
      print('Error adding internal note: $e');
      errorMessage('Failed to add internal note: $e');
      return false;
    }
  }

  Future<bool> mergeTickets(
      String sourceTicketId, String targetTicketId) async {
    try {
      final sourceIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == sourceTicketId);
      final targetIndex =
          allTickets.indexWhere((ticket) => ticket['id'] == targetTicketId);

      if (sourceIndex == -1 || targetIndex == -1) return false;

      final sourceTicket = allTickets[sourceIndex];
      final targetTicket = Map<String, dynamic>.from(allTickets[targetIndex]);

      // Merge messages
      final sourceMessages = List<Map<String, dynamic>>.from(
          sourceTicket['messages'] as List<dynamic>? ?? []);
      final targetMessages = List<Map<String, dynamic>>.from(
          targetTicket['messages'] as List<dynamic>? ?? []);

      // Add a merge note to the beginning of source messages
      sourceMessages.insert(0, {
        'sender': 'System',
        'content':
            'The following messages were merged from ticket #${sourceTicketId.substring(0, 8)}',
        'timestamp': DateTime.now(),
        'isUser': false,
        'isMergeNote': true,
      });

      // Combine messages (target + source)
      targetMessages.addAll(sourceMessages);
      targetTicket['messages'] = targetMessages;

      // Update target ticket
      targetTicket['lastUpdated'] = DateTime.now();

      // Add a note about the merge
      final notes = List<Map<String, dynamic>>.from(
          targetTicket['internalNotes'] as List<dynamic>? ?? []);
      notes.add({
        'note': 'Merged with ticket #${sourceTicketId.substring(0, 8)}',
        'author': 'Support Agent',
        'timestamp': DateTime.now(),
      });
      targetTicket['internalNotes'] = notes;

      // Update target ticket in list
      allTickets[targetIndex] = targetTicket;

      // Remove source ticket
      allTickets.removeAt(sourceIndex);

      // If the source ticket was selected, select the target ticket instead
      if (selectedTicketId.value == sourceTicketId) {
        selectedTicketId.value = targetTicketId;
      }

      return true;
    } catch (e) {
      print('Error merging tickets: $e');
      errorMessage('Failed to merge tickets: $e');
      return false;
    }
  }

  // Knowledge base methods
  Future<bool> createKnowledgeBaseArticle({
    required String title,
    required String content,
    required String summary,
    required String category,
  }) async {
    try {
      final now = DateTime.now();

      // Create new article
      final article = {
        'id': 'article${knowledgeBaseArticles.length + 1000}',
        'title': title,
        'content': content,
        'summary': summary,
        'category': category,
        'author': 'Admin',
        'createdAt': now,
        'updatedAt': now,
        'views': 0,
        'helpful': 0,
      };

      // Add to list
      knowledgeBaseArticles.add(article);

      return true;
    } catch (e) {
      print('Error creating knowledge base article: $e');
      errorMessage('Failed to create article: $e');
      return false;
    }
  }

  // Helper methods to generate mock data
  String getTicketSubject(String category, int index) {
    switch (category) {
      case 'Account':
        return 'Cannot log in to my account';
      case 'Billing':
        return 'Payment failed for recent purchase';
      case 'Game Play':
        return 'Game freezes during multiplayer match';
      case 'Technical':
        return 'App crashes after the latest update';
      case 'Feature Request':
        return 'Suggestion for new game mode';
      case 'Bug Report':
        return 'Found a bug in the tournament system';
      default:
        return 'Question about the game';
    }
  }

  String getTicketDescription(String category, int index) {
    switch (category) {
      case 'Account':
        return 'I\'m trying to log in to my account but it keeps saying "Invalid credentials" even though I\'m sure my password is correct. I\'ve tried resetting my password but I\'m not receiving the reset email.';
      case 'Billing':
        return 'I tried to purchase 1000 coins yesterday but the payment failed. My card was charged but I didn\'t receive the coins in my account. The transaction ID is TRX${10000 + index}.';
      case 'Game Play':
        return 'Every time I play a multiplayer match, the game freezes after about 2 minutes. I have to force close the app and restart it, which counts as a loss for me. This is really frustrating!';
      case 'Technical':
        return 'Since updating to version 1.5.0, the app crashes immediately after launching. I\'ve tried reinstalling but the problem persists. I\'m using an iPhone 13 with iOS 15.4.';
      case 'Feature Request':
        return 'I think it would be great if you could add a team mode where players can form teams and compete against other teams. This would add a new dimension to the game and encourage more social play.';
      case 'Bug Report':
        return 'I\'ve found a bug in the tournament system. When I join a tournament and then leave, I can rejoin the same tournament multiple times and get matched against myself, which shouldn\'t be possible.';
      default:
        return 'I have a question about the game that isn\'t covered in the FAQ. Can you please provide more information about how the ranking system works?';
    }
  }

  List<String> getTags(String category, int index) {
    switch (category) {
      case 'Account':
        return ['login-issue', 'account-access'];
      case 'Billing':
        return ['payment-failed', 'transaction-issue'];
      case 'Game Play':
        return ['game-freeze', 'multiplayer-issue'];
      case 'Technical':
        return ['app-crash', 'update-issue'];
      case 'Feature Request':
        return ['new-feature', 'enhancement'];
      case 'Bug Report':
        return ['bug', 'tournament-issue'];
      default:
        return ['question', 'game-mechanics'];
    }
  }

  String getArticleTitle(String category, int index) {
    switch (category) {
      case 'Account':
        return 'How to Recover Your Account';
      case 'Billing':
        return 'Troubleshooting Payment Issues';
      case 'Game Play':
        return 'Tips for Winning Multiplayer Matches';
      case 'Technical':
        return 'Fixing App Crashes After Updates';
      case 'Feature Request':
        return 'Upcoming Features in Next Release';
      case 'Bug Report':
        return 'Known Issues and Workarounds';
      default:
        return 'Frequently Asked Questions';
    }
  }

  String getArticleSummary(String category, int index) {
    switch (category) {
      case 'Account':
        return 'Learn how to recover your account if you\'ve forgotten your password or can\'t access your email.';
      case 'Billing':
        return 'Steps to resolve common payment issues and get help with failed transactions.';
      case 'Game Play':
        return 'Expert strategies and tips to improve your skills in multiplayer matches.';
      case 'Technical':
        return 'Solutions for common app crashes and performance issues after updating.';
      case 'Feature Request':
        return 'Preview of exciting new features coming in our next app update.';
      case 'Bug Report':
        return 'List of known issues in the current version and temporary solutions.';
      default:
        return 'Answers to the most common questions about gameplay, accounts, and more.';
    }
  }

  String getArticleContent(String category, int index) {
    switch (category) {
      case 'Account':
        return '''
# How to Recover Your Account

If you're having trouble accessing your account, follow these steps to recover it:

## Password Reset

1. Go to the login screen and tap "Forgot Password"
2. Enter the email address associated with your account
3. Check your email for a password reset link
4. Click the link and follow the instructions to set a new password

## Not Receiving Reset Emails

If you're not receiving password reset emails:

1. Check your spam folder
2. Make sure you're using the correct email address
3. Add our domain to your safe senders list
4. Contact support if you still don't receive the email

## Account Locked

If your account is locked due to too many failed login attempts:

1. Wait 30 minutes before trying again
2. Use the password reset function to set a new password
3. Make sure you're not using a VPN that might trigger security measures

## Still Can't Access Your Account?

If you've tried the steps above and still can't access your account, please contact our support team with the following information:

1. Username or display name
2. Email address associated with the account
3. Approximate date when you created the account
4. Any transaction IDs from purchases you've made
''';
      case 'Billing':
        return '''
# Troubleshooting Payment Issues

Common payment problems and how to solve them:

## Failed Payments

If your payment fails, check the following:

1. Verify that your card details are entered correctly
2. Ensure you have sufficient funds in your account
3. Check if your bank is blocking the transaction
4. Try a different payment method

## Charged But No Items Received

If you were charged but didn't receive your purchase:

1. Wait 15 minutes as sometimes there's a delay in processing
2. Check your in-game mail for the items
3. Restart the app to refresh your inventory
4. Contact support with your transaction ID and purchase receipt

## Subscription Issues

For problems with recurring subscriptions:

1. Check your subscription status in your account settings
2. Verify your payment method is up to date
3. Cancel and resubscribe if needed
4. Contact support for assistance with specific subscription issues

## Refunds

Our refund policy:

1. Accidental purchases may be eligible for a refund if requested within 48 hours
2. Subscription cancellations do not automatically trigger refunds for unused time
3. To request a refund, contact support with your transaction ID and reason for the refund
''';
      case 'Game Play':
        return '''
# Tips for Winning Multiplayer Matches

Improve your skills and increase your win rate with these expert tips:

## Basic Strategies

1. Focus on controlling the center of the board
2. Don't make moves reactively - plan ahead
3. Watch your opponent's patterns and adapt your strategy
4. Save power-ups for critical moments rather than using them immediately

## Advanced Techniques

1. Use the "corner trap" technique to force your opponent into making mistakes
2. Practice the "double threat" move to create two winning opportunities
3. Learn to recognize and counter common opening strategies
4. Develop a flexible playstyle that can adapt to different opponents

## Managing Your Resources

1. Use coins efficiently to upgrade your most-used items
2. Focus on upgrading a core set of items rather than spreading resources too thin
3. Save premium currency for limited-time special items
4. Complete daily missions to maximize resource acquisition

## Tournament Play

1. Rest between matches to maintain focus
2. Study the meta and popular strategies before participating
3. Practice against friends in friendly matches to prepare
4. Keep track of top players and learn from their techniques
''';
      default:
        return '''
# ${getArticleTitle(category, index)}

This is a comprehensive guide about ${category.toLowerCase()}-related issues and solutions.

## Common Problems

Users often encounter these issues:

1. Problem one description and details
2. Problem two with more specific information
3. Third common issue that users face

## Solutions

Here are the recommended solutions:

1. Step-by-step guidance for first problem
2. Detailed instructions for solving the second issue
3. Multiple approaches for addressing the third problem

## Prevention

To avoid these issues in the future:

1. Preventative measure one
2. Second tip for avoiding problems
3. Best practices for optimal experience

## Contact Support

If you're still experiencing issues after trying these solutions, please contact our support team with the following information:

1. Your device model and operating system
2. App version
3. Detailed description of the issue
4. Screenshots if applicable
''';
    }
  }
}
