import 'dart:collection';

import 'package:bibliotekkart/src/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'result.dart';

class MapView extends StatefulWidget {
  const MapView({
    super.key,
  });

  static const routeName = "/map";
  @override
  State<MapView> createState() => _MapState();
}

class _MapState extends State<MapView> {
  late Future<Result> result;
  @override
  void initState() {
    super.initState();
    result = fetchLibraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.restorablePushNamed(
                      context, SettingsView.routeName);
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: Center(
            child: FutureBuilder<Result>(
                future: result,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var _element;
                    List<Marker> markerList = [];
                    // Generate all markers
                    snapshot.data?.elements.forEach((_element) {
                      double lat;
                      double lon;
                      // If the element is of type "way", we do a little extra magic
                      if (_element['type'] == "way") {
                        lat = _element['bounds']['maxlat'];
                        lon = _element['bounds']['maxlon'];
                      } else {
                        lat = _element['lat'];
                        lon = _element['lon'];
                        if (_element['lat'].runtimeType.toString() !=
                                "double" ||
                            _element['lon'].runtimeType.toString() !=
                                "double") {
                          return;
                        }
                      }
                      markerList.add(Marker(
                          point: LatLng(lat, lon),
                          width: 80,
                          height: 80,
                          child: IconButton(
                            iconSize: 12,
                            tooltip: _element['tags']['name'],
                            hoverColor: Colors.brown.shade400,
                            icon: const Icon(Icons.book, color: Colors.black),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(_element['tags']['name'])));
                            },
                          )));
                    });
                    return FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(59.990556, 8.307778),
                        initialZoom: 7,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: AppLocalizations.of(context)!.appTitle,
                        ),
                        RichAttributionWidget(
                          animationConfig: const ScaleRAWA(),
                          showFlutterMapAttribution: false,
                          attributions: [
                            TextSourceAttribution(
                              AppLocalizations.of(context)!.mapAttribution,
                              onTap: () => launchUrl(Uri.parse(
                                  'https://openstreetmap.org/copyright')),
                            )
                          ],
                        ),
                        MarkerLayer(markers: markerList)
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return Center(
                      child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.loadingText),
                      const SizedBox(height: 10),
                      const CircularProgressIndicator()
                    ],
                  ));
                })));
  }
}
