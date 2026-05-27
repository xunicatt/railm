// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class Station {
    final String id;
    final String name;
    final String route;
    final int position;

    const Station({
        required this.id,
        required this.name,
        required this.route,
        required this.position,
    });

    factory Station.fromJson(Map<String, dynamic> json) {
        return Station(
            id: json["id"],
            name: json["name"],
            route: json["route"],
            position: json["position"],
        );
    }

    factory Station.fromMap(Map<String, dynamic> data) {
        return Station(
            id: data["id"],
            name: data["name"],
            route: data["route"],
            position: data["position"],
        );
    }

    Map<String, dynamic> toMap() {
        return {
            "id": id,
            "name": name,
            "route": route,
            "position": position,
        };
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
