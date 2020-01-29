import 'dart:io';
import 'dart:math';
import 'package:hiking4nerds/services/pointofinterest.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// singleton class to manage the database
class DatabaseHelper {
  // database table and column names
  final String tableRoutes = 'routes';
  final String columnId = '_id';
  final String columnLength = 'length';
  final String columnDate = 'date';

  final String tableNodes = 'nodes';
  final String columnRouteId = 'route_id';
  final String columnNodeId = 'node_id';
  final String columnLat = 'latitude';
  final String columnLng = 'longitude';

  final String tablePois = 'pois';
  final String columnPoiId = 'poi_id';
  final String columnCategory = 'category';
  // + Lat / Lng

  final String tableElevations = 'elevations';
  final String columnElevationId = 'elevation_id';
  final String columnElevationData = 'data';

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "h4n.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableRoutes (
        $columnId INTEGER PRIMARY KEY,
        $columnLength DOUBLE NOT NULL,
        $columnDate STRING NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableNodes (
        $columnRouteId INTEGER NOT NULL,
        $columnNodeId INTEGER NOT NULL,
        $columnLat DOUBLE NOT NULL,
        $columnLng DOUBLE NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tablePois (
        $columnRouteId INTEGER NOT NULL,
        $columnPoiId INTEGER NOT NULL,
        $columnLat DOUBLE NOT NULL,
        $columnLng DOUBLE NOT NULL,
        $columnCategory STRING
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableElevations (
        $columnRouteId INTEGER NOT NULL,
        $columnElevationId INTEGER NOT NULL,
        $columnElevationData REAL NOT NULL
      )
    ''');
  }

  // Database helper methods:

  Future<int> insert(HikingRoute route) async {
    Database db = await database;
    int id = await db.insert(tableRoutes, route.toMap());
    route.path.forEach((node) async => await db.insert(tableNodes, node.toMap(id)));
    route.pointsOfInterest.forEach((poi) async => await db.insert(tablePois, poi.toMap(id)));
    int elevationId = Random().nextInt(1000);
    route.elevations.forEach((elevation) async => await db.insert(tableElevations, _elevationToMap(elevation, elevationId, id)));
    return id;
  }

  Map _elevationToMap(double elevation, int id, int routeid) {
    return <String, dynamic>{
      columnRouteId: routeid,
      columnElevationId: id,
      columnElevationData: elevation
    };
  }

  double _elevationFromMap(Map<String, dynamic> map) {
    return map[columnElevationData];
  }

  Future<List<HikingRoute>> queryAllRoutes() async {
    Database db = await database;
    List<Map> maps = await db.query(tableRoutes);
    List<HikingRoute> routes = [];
    if (maps.length > 0) {
      for(var map in maps) {
        routes.add(await HikingRoute.fromMap(map));
      }
      return routes;
    }
    return null;
  }

  Future<List<Node>> queryPath(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableNodes,
        columns: [columnNodeId, columnLat, columnLng],
        where: '$columnRouteId = ?',
        whereArgs: [id]);
    return maps.map((n) => Node.fromMap(n)).toList();
  }

  Future<List<PointOfInterest>> queryPois(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tablePois,
        columns: [columnPoiId, columnLat, columnLng, columnCategory],
        where: '$columnRouteId = ?',
        whereArgs: [id]);
    maps.forEach((row) => print('POI $row'));
    return maps.map((n) => PointOfInterest.fromMap(n)).toList();
  }

  Future<List<double>> queryElevations(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableElevations,
        columns: [columnElevationId, columnElevationData],
        where: '$columnRouteId = ?',
        whereArgs: [id]);
    maps.forEach((row) => print('Elevation $row'));
    return maps.map((n) => _elevationFromMap(n)).toList();
  }

  // TODO: delete(int id)

  deleteRoute(int id) async {
    Database db = await database;
    int route = await db.delete(
      tableRoutes,
      where: '$columnId = ?',
      whereArgs: [id]);
    int nodes = await db.delete(tableNodes,
      where: '$columnRouteId = ?',
      whereArgs: [id]);
    int pois = await db.delete(tableNodes,
      where: '$columnRouteId = ?',
      whereArgs: [id]);
    int elevations = await db.delete(tableElevations,
      where: '$columnRouteId = ?',
      whereArgs: [id]);
    print('$route routes deleted, $nodes nodes deleted, $pois pois deleted, $elevations elevations deleted');
  }

  deleteAll() async {
    Database db = await database;
    int routes = await db.delete(tableRoutes, where: '1');
    int nodes = await db.delete(tableNodes, where: '1');
    int pois = await db.delete(tablePois, where: '1');
    int elevations = await db.delete(tableElevations, where: '1');
    print('$routes routes deleted, $nodes nodes deleted, $pois pois deleted, $elevations elevations deleted');
  }
}