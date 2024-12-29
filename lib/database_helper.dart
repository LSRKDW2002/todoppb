import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist_app/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'todolist.db');
    var localDb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return localDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<List<Todo>> getAllTodos() async {
    final dbClient = await db;
    final todos = await dbClient!.query('todos');
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<List<Todo>> searchTodo(String keyword) async {
    final dbClient = await db;
    final todos = await dbClient!.query(
      'todos',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<int> addTodo(Todo todo) async {
    final dbClient = await db;
    return await dbClient!.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTodo(Todo todo) async {
    final dbClient = await db;
    return await dbClient!.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final dbClient = await db;
    return await dbClient!.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
