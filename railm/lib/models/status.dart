// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:railm/configs/configs.dart';

class TrainStatus {
    static const running = 0;
    static const arrived = 1;
    static const left = 2;
}

class Status {
    final String number;
    final String station;
    final int state;

    const Status({
        required this.number,
        required this.station,
        required this.state,
    });

    factory Status.fromJson(Map<String, dynamic> json) {
        return Status(
            number: json["number"],
            station: json["station"],
            state: json["state"],
        );
    }

    static Future<Status?> fetchStatus(String number) async {
        final String url = "${Configs.baseUrl}/status/$number?auth=${Configs.token}";
        var response = await http.get(Uri.parse(url));
        var data = jsonDecode(response.body) as Map<String, dynamic>;

        if ((data.containsKey("status") && data["status"] == "failed") ||
                (data.containsKey("reason") && data["reason"] == "unknown")) {
            return null; 
        }

        return Status.fromJson(data);
    }

    static Future<bool> updateStatus(String trainNumber, String stationId) async {
        final String url = "${Configs.baseUrl}/status/$trainNumber/$stationId?auth=${Configs.token}";
        var response = await http.post(Uri.parse(url));
        var data = jsonDecode(response.body) as Map<String, dynamic>;

        return data.containsKey("status") && data["status"] == "success";
    }
}
