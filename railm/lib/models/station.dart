import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class Station {
    String id;
    String name;
    String route;
    int position;

    Station(this.id, this.name, this.route, this.position);

    factory Station.fromJson(Map<String, dynamic> json) {
        return Station(
            json["id"],
            json["name"],
            json["route"],
            json["position"],
        );
    }

    static Future<List<String>> fetchIds() async {
        final String url = "${Configs.baseUrl}/stations";
        var response = await http.get(Uri.parse(url));
        return List<String>.from(jsonDecode(response.body));
    }

    static Future<List<Station>> fetchStations() async {
        final String url = "${Configs.baseUrl}/stations";
        final ids = await fetchIds();

        final futures = ids.map((id) async {
            final resp = await http.get(Uri.parse("$url/$id"));
            final data = jsonDecode(resp.body);
            return Station.fromJson(data);
        });

        return await Future.wait(futures);
    }
}
