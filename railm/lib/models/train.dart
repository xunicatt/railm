// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class TrainStop {
    final String station;
    final String route;
    final String arrival;
    final String departure;

    const TrainStop({
        required this.station,
        required this.route,
        required this.arrival,
        required this.departure
    });

    factory TrainStop.fromJson(Map<String, dynamic> json) {
        return TrainStop(
            station: json["station"],
            route: json["route"],
            arrival: json["arrival"],
            departure: json["departure"],
        );
    }

    factory TrainStop.fromMap(Map<String, dynamic> map) {
        return TrainStop(
            station: map["station"],
            route: map["route"],
            arrival: map["arrival"],
            departure: map["departure"],
        );
    }

    Map<String, dynamic> toMap() {
        return {
            "station": station,
            "route": route,
            "arrival": arrival,
            "departure": departure,
        };
    }
}

class Train {
    final String number;
    final String name;
    final String start;
    final String end;
    final List<TrainStop> stops;

    const Train({
        required this.number,
        required this.name,
        required this.start,
        required this.end,
        required this.stops,
    });

    factory Train.fromJson(Map<String, dynamic> json) {
        List<TrainStop> stops = (json["stops"] as List<dynamic>).map(
            (e) => TrainStop.fromJson(e)
        ).toList();

        return Train(
            number: json["number"],
            name: json["name"],
            start: json["start"],
            end: json["end"],
            stops: stops,
        );
    }

    factory Train.fromMap(Map<String, dynamic> data) {
        final stops = (data["stops"] as List<dynamic>).map(
            (e) => TrainStop.fromMap(e)
        ).toList();

        return Train(
            number: data["number"],
            name: data["name"],
            start: data["start"],
            end: data["end"],
            stops: stops,
        );
    }

    Map<String, dynamic> toMap() {
        final stopsMap = stops.map((e) => e.toMap()).toList();

        return {
            "number": number,
            "name": name,
            "start": start,
            "end": end,
            "stops": stopsMap,
        };
    }

    static Future<Train?> fetchTrain(String number) async {
        final String url = "${Configs.railApiBaseUrl}/trains/$number";
        final response = await http.get(
            Uri.parse(url), headers: {
                'Authorization': 'Token ${Configs.railApiToken}',
            },
        );
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json.containsKey("status") && json["status"] == "failed") {
            return null;
        }

        return Train.fromJson(json);
    }

    static Future<List<String>> fetchTrainNumbersBetweenStations(
        String src,
        String dest,
    ) async {
        final String url = "${Configs.railApiBaseUrl}/trains/between/$src/$dest";
        final response = await http.get(
            Uri.parse(url), headers: {
                'Authorization': 'Token ${Configs.railApiToken}',
            },
        );
        return List<String>.from(jsonDecode(response.body));
    }

    static Future<List<Train>> fetchTrainsBetweenStations(
        String src,
        String dest,
    ) async {
        final String url = "${Configs.railApiBaseUrl}/trains";
        final numbers = await fetchTrainNumbersBetweenStations(
            src, dest,
        );

        final futures = numbers.map((number) async {
            final resp = await http.get(
                Uri.parse("$url/$number"), headers: {
                    'Authorization': 'Token ${Configs.railApiToken}',
                },
            );
            final data = jsonDecode(resp.body);
            return Train.fromJson(data);
        });

        return await Future.wait(futures);
    }
}
