import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Result {
  late double version;
  late String generator;
  late Map<String, dynamic> osm3s;
  late List<dynamic> elements;

  Result({
    required this.version,
    required this.generator,
    required this.osm3s,
    required this.elements,
  });

  Result.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    generator = json['generator'];
    osm3s = json['osm3s'];
    if (json['elements'] != null) {
      elements = <Element>[];
      elements = json['elements'];
    }
  }
}

class Element {
  late String type;
  late int id;
  late double lat;
  late double lon;
  late Tags tags;

  Element(
      {required this.type,
      required this.id,
      required this.lat,
      required this.lon,
      required this.tags});

  Element.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    lat = json['lat'];
    lon = json['lon'];
    tags = (json['tags'] != null ? Tags.fromJson(json['tags']) : null)!;
  }
}

class Tags {
  late String access;
  late String amenity;
  late String name;
  late String phone;
  late String refIsil;
  late String website;
  late String email;
  late String internetAccess;
  late String internetAccessFee;
  late String openingHours;
  late String operator;
  late String operatorType;
  late String wheelchair;
  late String wikidata;
  late String building;
  late String oldName;
  late String refBygningsnr;
  late String nameEn;

  Tags(
      {required this.access,
      required this.amenity,
      required this.name,
      required this.phone,
      required this.refIsil,
      required this.website,
      required this.email,
      required this.internetAccess,
      required this.internetAccessFee,
      required this.openingHours,
      required this.operator,
      required this.operatorType,
      required this.wheelchair,
      required this.wikidata,
      required this.building,
      required this.oldName,
      required this.refBygningsnr,
      required this.nameEn});

  Tags.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    amenity = json['amenity'];
    name = json['name'];
    phone = json['phone'];
    refIsil = json['ref:isil'];
    website = json['website'];
    email = json['email'];
    internetAccess = json['internet_access'];
    internetAccessFee = json['internet_access:fee'];
    openingHours = json['opening_hours'];
    operator = json['operator'];
    operatorType = json['operator:type'];
    wheelchair = json['wheelchair'];
    wikidata = json['wikidata'];
    building = json['building'];
    oldName = json['old_name'];
    refBygningsnr = json['ref:bygningsnr'];
    nameEn = json['name:en'];
  }
}

Future<Result> fetchLibraries() async {
  final map = <String, dynamic>{};
  map['data'] =
      '[out:json][timeout:25];area(id:3601059668)->.searchArea;nwr["amenity"="library"](area.searchArea);out geom;';
  final response = await http.post(
    Uri.parse("https://overpass-api.de/api/interpreter"),
    body: map,
  );
  if (response.statusCode == 200) {
    return Result.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  } else {
    throw Exception("Failed to load data from Overpass!");
  }
}
