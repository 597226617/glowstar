import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database Service for GlowStar
/// 
/// Manages local SQLite database for offline data storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// Initialize database
  Future<void> initialize() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'glowstar.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Get database instance
  Future<Database> get database async {
    if (_database == null) {
      await initialize();
    }
    return _database!;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        displayName TEXT NOT NULL,
        avatarUrl TEXT,
        bio TEXT,
        age INTEGER,
        latitude REAL,
        longitude REAL,
        lastSeen INTEGER,
        isOnline INTEGER DEFAULT 0
      )
    ''');

    // Interests table
    await db.execute('''
      CREATE TABLE interests (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // User interests table (many-to-many)
    await db.execute('''
      CREATE TABLE user_interests (
        userId TEXT,
        interestId TEXT,
        PRIMARY KEY (userId, interestId),
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (interestId) REFERENCES interests(id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_messages_conversation ON messages(conversationId)');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(userId)');
    await db.execute('CREATE INDEX idx_users_location ON users(latitude, longitude)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }

  /// Insert user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isEmpty ? null : result.first;
  }

  /// Update user
  Future<int> updateUser(String userId, Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete user
  Future<int> deleteUser(String userId) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Insert message
  Future<int> insertMessage(Map<String, dynamic> message) async {
    Database db = await database;
    return await db.insert('messages', message);
  }

  /// Get messages for conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    Database db = await database;
    return await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
  }

  /// Insert notification
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    Database db = await database;
    return await db.insert('notifications', notification);
  }

  /// Get unread notifications
  Future<List<Map<String, dynamic>>> getUnreadNotifications(String userId) async {
    Database db = await database;
    return await db.query(
      'notifications',
      where: 'userId = ? AND isRead = 0',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  /// Mark notification as read
  Future<int> markNotificationAsRead(String notificationId) async {
    Database db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
