import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> init() async {
    // Request permissions
    await _messaging.requestPermission();

    // Get FCM token
    String? token = await _messaging.getToken();
    
    if (token != null) {
      // Get user info from SharedPreferences instead of Firebase Auth
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final String? userRole = prefs.getString('role');

      if (userId != null && userRole != null) {
        // Clean up: Remove this token from other users first
        await _cleanupTokenFromOtherUsers(token, userId);
        
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': token,
          'lastOpened': DateTime.now().toIso8601String(),
          'userRole': userRole, // Store user role for additional filtering if needed
        }, SetOptions(merge: true));
        
        print("FCM token saved for user: $userId");
      } else {
        print("No user ID found in SharedPreferences");
      }
    } else {
      print("Failed to get FCM token");
    }

    // Handle foreground messages (optional)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.title}");
      // You can show a dialog or toast here
    });
  }

  static Future<void> _cleanupTokenFromOtherUsers(String token, String currentUserId) async {
    try {
      print("🧹 Cleaning up token from other users...");
      
      // Find other users with the same token and remove it
      final querySnapshot = await _firestore
          .collection('users')
          .where('fcmToken', isEqualTo: token)
          .get();
      
      for (var doc in querySnapshot.docs) {
        if (doc.id != currentUserId) {
          await doc.reference.update({'fcmToken': FieldValue.delete()});
          print("🗑️ Removed token from previous user: ${doc.id}");
        }
      }
      
      print("✅ Token cleanup completed");
    } catch (e) {
      print("❌ Error during token cleanup: $e");
      // Continue with normal flow even if cleanup fails
    }
  }

  static Future<void> updateLastOpened() async {
    print("🔄 updateLastOpened() called");
    
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    
    print("📱 User ID from prefs: $userId");
    
    if (userId != null) {
      try {
        final newTimestamp = DateTime.now().toIso8601String();
        print("⏰ Updating timestamp to: $newTimestamp");
        
        await _firestore.collection('users').doc(userId).update({
          'lastOpened': newTimestamp,
        });
        
        print("✅ Last opened updated successfully for user: $userId");
      } catch (e) {
        print("❌ Error updating last opened: $e");
        // If document doesn't exist, create it
        await init();
      }
    } else {
      print("❌ No user ID found when updating last opened");
    }
  }

  // Call this when user logs out to clean up
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    
    if (userId != null) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        print("User data cleared from Firestore: $userId");
      } catch (e) {
        print("Error clearing user data: $e");
      }
    }
  }
}