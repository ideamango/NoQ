import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

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

callPhone(String phone) async {
  String phoneStr = "tel://$phone";
  if (await UrlLauncher.canLaunch(phoneStr)) {
    await UrlLauncher.launch(phoneStr);
  } else {}
}
