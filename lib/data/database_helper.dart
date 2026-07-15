import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/destination_model.dart';
import '../models/user_model.dart';

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
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS destinations');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

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

    // Insert dummy data
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    final List<Map<String, dynamic>> dummyDestinations = [
      {
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
      await db.insert('destinations', destination);
    }
  }

  Future<List<Destination>> getDestinations() async {
    final db = await instance.database;
    final result = await db.query('destinations');
    return result.map((json) => Destination.fromMap(json)).toList();
  }

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

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
