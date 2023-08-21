import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.blueAccent,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color(0xFFF2F3F8),
      ),
      title: 'To Do List',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> retrievedData = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: 'Task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final task = taskController.text;
                final description = descriptionController.text;
                if (task.isNotEmpty) {
                  await dbHelper.insertData({
                    'task': task,
                    'description': description,
                  });
                  taskController.clear();
                  descriptionController.clear();
                }
              },
              child: Text('Insertar tarea'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final data = await dbHelper.getData();
                setState(() {
                  retrievedData = data;
                });
              },
              child: Text('Ver lista'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await dbHelper.resetDatabase();
                setState(() {
                  retrievedData = [];
                });
              },
              child: Text('Reiniciar BD'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: retrievedData.length,
                itemBuilder: (context, index) {
                  final item = retrievedData[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Task: ${item['task']}'),
                      subtitle: Text('Description: ${item['description']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'my_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE MyTable (
            id INTEGER PRIMARY KEY,
            task TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('MyTable', data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final dbClient = await db;
    return await dbClient.query('MyTable');
  }

  Future<void> resetDatabase() async {
    final dbClient = await db;
    await dbClient.delete('MyTable');
  }
}
