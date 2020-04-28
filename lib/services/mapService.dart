import 'package:map_launcher/map_launcher.dart';

launchURL(String tit, String addr, double lat, double long) async {
  final title = tit;
  final description = addr;
  final coords = Coords(lat, long);
  if (await MapLauncher.isMapAvailable(MapType.google)) {
    await MapLauncher.launchMap(
      mapType: MapType.google,
      coords: coords,
      title: title,
      description: description,
    );
  }
}
