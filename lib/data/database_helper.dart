import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/destination_model.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../models/experience_log_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wanderlab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS destinations');
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS services');
        await db.execute('DROP TABLE IF EXISTS bookings');
        await db.execute('DROP TABLE IF EXISTS experience_logs');
        await db.execute('DROP TABLE IF EXISTS notifications');
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE destinations (
  id $idType,
  name $textType,
  description $textType,
  imageUrl $textType,
  location $textType,
  rating $doubleType,
  price $doubleType,
  latitude $doubleType,
  longitude $doubleType,
  category $textType
)
''');

    await db.execute('''
CREATE TABLE users (
  id $idType,
  fullName $textType,
  email $textType UNIQUE,
  passwordHash $textType,
  avatarUrl TEXT,
  createdAt $textType
)
''');

    await db.execute('''
CREATE TABLE services (
  id $idType,
  destinationId $intType,
  name $textType,
  description $textType,
  price $doubleType,
  category $textType,
  FOREIGN KEY (destinationId) REFERENCES destinations (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE bookings (
  id $idType,
  userId $intType,
  serviceId $intType,
  bookingDate $textType,
  bookingTime $textType,
  guestCount $intType,
  status $textType,
  totalPrice $doubleType,
  createdAt $textType,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (serviceId) REFERENCES services (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE experience_logs (
  id $idType,
  userId $intType,
  destinationId $intType,
  title $textType,
  content $textType,
  rating $doubleType,
  imageUrl TEXT,
  createdAt $textType,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (destinationId) REFERENCES destinations (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE notifications (
  id $idType,
  userId $intType,
  title $textType,
  message $textType,
  isRead $intType,
  createdAt $textType,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
)
''');

    // Insert dummy data
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // 1. Insert Destinations
    final List<Map<String, dynamic>> dummyDestinations = [
      {
        'id': 1,
        'name': 'Vịnh Hạ Long',
        'description': 'Vịnh Hạ Long là một di sản thiên nhiên thế giới được UNESCO công nhận. Nơi đây nổi tiếng với hàng ngàn hòn đảo đá vôi kỳ vĩ và những hang động tuyệt đẹp.',
        'imageUrl': 'assets/images/ha_long_bay.png',
        'location': 'Quảng Ninh, Việt Nam',
        'rating': 4.9,
        'price': 1500000.0,
        'latitude': 20.9101,
        'longitude': 107.1839,
        'category': 'Biển',
      },
      {
        'id': 2,
        'name': 'Sapa - Phan Xi Păng',
        'description': 'Sapa là một thị trấn mờ sương nổi tiếng với đỉnh Phan Xi Păng - nóc nhà Đông Dương, những thửa ruộng bậc thang tuyệt đẹp và bản sắc văn hóa độc đáo của các dân tộc thiểu số.',
        'imageUrl': 'assets/images/sapa_vietnam.png',
        'location': 'Lào Cai, Việt Nam',
        'rating': 4.8,
        'price': 1200000.0,
        'latitude': 22.3333,
        'longitude': 103.8333,
        'category': 'Núi',
      },
      {
        'id': 3,
        'name': 'Đảo Phú Quốc',
        'description': 'Phú Quốc là hòn đảo lớn nhất Việt Nam, được mệnh danh là đảo Ngọc. Nơi đây có những bãi biển cát trắng mịn, nước trong xanh và nhiều khu nghỉ dưỡng sang trọng.',
        'imageUrl': 'assets/images/phu_quoc_island.png',
        'location': 'Kiên Giang, Việt Nam',
        'rating': 4.7,
        'price': 2500000.0,
        'latitude': 10.2289,
        'longitude': 103.9572,
        'category': 'Biển',
      },
      {
        'id': 4,
        'name': 'Phố cổ Hội An',
        'description': 'Hội An là một đô thị cổ nằm ở hạ lưu sông Thu Bồn. Nơi đây lưu giữ nguyên vẹn hàng ngàn di tích kiến trúc gồm phố xá, nhà cửa, hội quán, đình, chùa, miếu...',
        'imageUrl': 'assets/images/hoi_an_ancient.png',
        'location': 'Quảng Nam, Việt Nam',
        'rating': 4.6,
        'price': 800000.0,
        'latitude': 15.8801,
        'longitude': 108.3380,
        'category': 'Văn hóa',
      },
      {
        'id': 5,
        'name': 'Cố đô Huế',
        'description': 'Cố đô Huế là di sản văn hóa thế giới với quần thể kiến trúc cung đình triều Nguyễn nguy nga, tráng lệ cùng nhã nhạc cung đình đặc sắc.',
        'imageUrl': 'assets/images/hue_imperial_city.png',
        'location': 'Thừa Thiên Huế, Việt Nam',
        'rating': 4.8,
        'price': 1000000.0,
        'latitude': 16.4637,
        'longitude': 107.5909,
        'category': 'Lịch sử',
      }
    ];

    for (var destination in dummyDestinations) {
      await db.insert('destinations', destination, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2. Insert Dummy Users (to link experience logs)
    // password hash for: 123456aA
    final List<Map<String, dynamic>> dummyUsers = [
      {
        'id': 1,
        'fullName': 'Nguyễn Văn A',
        'email': 'user@wanderlab.com',
        'passwordHash': 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',
        'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/svg?seed=A',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'fullName': 'Trần Thị B',
        'email': 'test@wanderlab.com',
        'passwordHash': 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f',
        'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/svg?seed=B',
        'createdAt': DateTime.now().toIso8601String(),
      }
    ];

    for (var user in dummyUsers) {
      await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Insert Dummy Services for each destination
    final List<Map<String, dynamic>> dummyServices = [
      // Hạ Long (id: 1)
      {
        'destinationId': 1,
        'name': 'Du thuyền Hạ Long 5 sao (2 ngày 1 đêm)',
        'description': 'Trải nghiệm ngủ đêm sang trọng trên vịnh, thưởng thức hải sản cao cấp và ngắm hoàng hôn.',
        'price': 3500000.0,
        'category': 'Tour'
      },
      {
        'destinationId': 1,
        'name': 'Chèo thuyền Kayak & Thăm hang Luồn',
        'description': 'Khám phá vẻ đẹp kỳ vĩ của hang Luồn bằng thuyền kayak tự chèo.',
        'price': 200000.0,
        'category': 'Vé tham quan'
      },
      {
        'destinationId': 1,
        'name': 'Khách sạn Hạ Long Plaza (1 đêm)',
        'description': 'Phòng Deluxe hướng biển tại trung tâm thành phố Hạ Long.',
        'price': 1200000.0,
        'category': 'Khách sạn'
      },

      // Sapa (id: 2)
      {
        'destinationId': 2,
        'name': 'Vé cáp treo Fansipan khứ hồi',
        'description': 'Vé cáp treo ngắm thung lũng Mường Hoa và lên đỉnh Fansipan.',
        'price': 800000.0,
        'category': 'Vé tham quan'
      },
      {
        'destinationId': 2,
        'name': 'Tour đi bộ Cát Cát - Tả Van (1 ngày)',
        'description': 'Tìm hiểu văn hóa dân tộc H\'mông, Mông tại bản Cát Cát và thung lũng Tả Van.',
        'price': 400000.0,
        'category': 'Tour'
      },
      {
        'destinationId': 2,
        'name': 'Sapa Jade Hill Resort Package (1 đêm)',
        'description': 'Nghỉ dưỡng biệt thự trong rừng thông ngắm thung lũng mây Sapa.',
        'price': 2200000.0,
        'category': 'Khách sạn'
      },

      // Phú Quốc (id: 3)
      {
        'destinationId': 3,
        'name': 'Tour 4 đảo cáp treo Hòn Thơm',
        'description': 'Lặn ngắm san hô tại hòn Móng Tay, Gầm Ghì, Mây Rút và cáp treo vượt biển.',
        'price': 1100000.0,
        'category': 'Tour'
      },
      {
        'destinationId': 3,
        'name': 'Vé vào cửa VinWonders Phú Quốc',
        'description': 'Công viên chủ đề hàng đầu Việt Nam với vô vàn trò chơi giải trí.',
        'price': 950000.0,
        'category': 'Vé tham quan'
      },

      // Hội An (id: 4)
      {
        'destinationId': 4,
        'name': 'Thả hoa đăng sông Hoài & Thuyền thúng Rừng dừa',
        'description': 'Trải nghiệm văn hóa Hội An đặc trưng.',
        'price': 150000.0,
        'category': 'Vé tham quan'
      },
      {
        'destinationId': 4,
        'name': 'Tour Ẩm thực đường phố Hội An (Buổi tối)',
        'description': 'Thưởng thức cao lầu, bánh mỳ Phượng, chè Hội An cùng hướng dẫn viên.',
        'price': 350000.0,
        'category': 'Tour'
      },

      // Huế (id: 5)
      {
        'destinationId': 5,
        'name': 'Vé tham quan Đại Nội & Các Lăng Tẩm',
        'description': 'Tham quan quần thể di tích cố đô Huế gồm Kinh thành, Lăng Tự Đức, Lăng Khải Định.',
        'price': 420000.0,
        'category': 'Vé tham quan'
      },
      {
        'destinationId': 5,
        'name': 'Nghe ca Huế trên Sông Hương bằng thuyền rồng',
        'description': 'Thưởng thức di sản văn hóa phi vật thể ca Huế trong hoàng hôn Sông Hương.',
        'price': 180000.0,
        'category': 'Tour'
      }
    ];

    for (var service in dummyServices) {
      await db.insert('services', service);
    }

    // 4. Insert Dummy Experience Logs
    final List<Map<String, dynamic>> dummyLogs = [
      {
        'userId': 1,
        'destinationId': 1,
        'title': 'Chuyến đi Hạ Long tuyệt vời!',
        'content': 'Mình vừa có chuyến đi 2 ngày 1 đêm trên du thuyền Hạ Long. Cảnh quan thiên nhiên kỳ vĩ, phục vụ rất chu đáo. Chèo kayak rất thú vị!',
        'rating': 5.0,
        'imageUrl': null,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'userId': 2,
        'destinationId': 2,
        'title': 'Chinh phục đỉnh Fansipan',
        'content': 'Sapa mờ sương rất đẹp. Cáp treo đi nhanh và an toàn. Trên đỉnh Fansipan gió to và lạnh nhưng cảm giác rất tuyệt vời khi chạm tay vào cột mốc.',
        'rating': 4.5,
        'imageUrl': null,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      }
    ];

    for (var log in dummyLogs) {
      await db.insert('experience_logs', log);
    }
  }

  // --- DESTINATIONS ---
  Future<List<Destination>> getDestinations() async {
    final db = await instance.database;
    final result = await db.query('destinations');
    return result.map((json) => Destination.fromMap(json)).toList();
  }

  // --- USERS ---
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // --- SERVICES ---
  Future<List<ServiceModel>> getServicesForDestination(int destinationId) async {
    final db = await instance.database;
    final maps = await db.query(
      'services',
      where: 'destinationId = ?',
      whereArgs: [destinationId],
    );
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // --- BOOKINGS ---
  Future<int> insertBooking(Booking booking) async {
    final db = await instance.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getBookingsForUser(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, s.name as serviceName, d.name as destinationName
      FROM bookings b
      JOIN services s ON b.serviceId = s.id
      JOIN destinations d ON s.destinationId = d.id
      WHERE b.userId = ?
      ORDER BY b.createdAt DESC
    ''', [userId]);

    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<int> updateBookingStatus(int bookingId, String status) async {
    final db = await instance.database;
    return await db.update(
      'bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // --- Notifications ---
  Future<int> insertNotification(Map<String, dynamic> notificationMap) async {
    final db = await instance.database;
    return await db.insert('notifications', notificationMap);
  }

  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }
  
  Future<int> markNotificationAsRead(int notificationId) async {
    final db = await instance.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // --- EXPERIENCE LOGS ---
  Future<List<ExperienceLog>> getExperienceLogs() async {
    final db = await instance.database;
    
    // Join query to get user's full name and destination name
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT el.*, u.fullName as userName, d.name as destinationName
      FROM experience_logs el
      JOIN users u ON el.userId = u.id
      JOIN destinations d ON el.destinationId = d.id
      ORDER BY el.createdAt DESC
    ''');

    return maps.map((map) => ExperienceLog.fromMap(map)).toList();
  }

  Future<int> insertExperienceLog(ExperienceLog log) async {
    final db = await instance.database;
    return await db.insert('experience_logs', log.toMap());
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
