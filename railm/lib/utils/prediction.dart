// SPDX-License-Identifier: GPL-2.0
// Author: xunicatt
// Project: railm (railm) 
// Copyright (c) 2026 xunicatt <contact.aniket.biswas@gmail.com>

import 'package:localstore/localstore.dart';

enum Weekday {
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday;

    factory Weekday.fromInt(int value) {
        value = (value - 1) % value;
        return values[value];
    }
}

extension AverageExtension on List<double> {
    double get average {
        if (isEmpty) return 0;
        return fold(0.0, (a, b) => a + b) / length;
    }
}

class LinearRegression {
    final double slope;
    final double intercept;

    const LinearRegression({
        required this.slope,
        required this.intercept,
    });

    factory LinearRegression.fromData(List<double> data) {
        final n = data.length;

        if (n == 0) {
            return LinearRegression(
                slope: 0,
                intercept: 0,
            );
        }

        if (n == 1) {
            return LinearRegression(
                slope: 0,
                intercept: data.first,
            );
        }

        final sumX = n * (n - 1) / 2;
        final sumY = data.fold(0.0, (a, b) => a + b);

        double sumXX = 0;
        double sumXY = 0;

        for (var x = 0; x < n; x++) {
            sumXX += x * x;
            sumXY += x * data[x];
        }

        final denominator = n * sumXX - sumX * sumX;

        if (denominator == 0) {
            return LinearRegression(
                slope: 0,
                intercept: sumY / n,
            );
        }

        final slope = (
            n * sumXY - sumX * sumY
        ) / denominator;

        final intercept =(
            sumY - slope * sumX
        ) / n;

        return LinearRegression(
            slope: slope,
            intercept: intercept,
        );
    }

    double predictNext(int currentLength) {
        return slope * currentLength + intercept;
    }
}

class DelayPredictor {
    final int maxHistory;
    final Localstore _db = Localstore.getInstance(useSupportDir: true);

    DelayPredictor({
        this.maxHistory = 12,
    });

    Map<String, List<double>> _emptyWeekMap() {
        return {
            for (final day in Weekday.values)
                day.name: <double>[],
        };
    }

    Future<Map<String, dynamic>> _loadTraffic() async {
        return await _db
            .collection('prediction')
            .doc('traffic-delays')
            .get() ??
            _emptyWeekMap();
    }

    Future<Map<String, dynamic>> _loadTrain() async {
        return await _db
            .collection('prediction')
            .doc('train-delays')
            .get() ??
            <String, dynamic>{};
    }

    Future<void> addTrafficDelay(
        Weekday day,
        double delay,
    ) async {
        final data = await _loadTraffic();

        final delays = List<double>.from(
            (data[day.name] as List?) ?? [],
        );

        delays.add(delay);

        if (delays.length > maxHistory) {
            delays.removeAt(0);
        }

        data[day.name] = delays;

        await _db
            .collection('prediction')
            .doc('traffic-delays')
            .set(data);
    }

    Future<void> addTrainDelay(
        String trainNumber,
        Weekday day,
        double delay,
    ) async {
        final data = await _loadTrain();

        final train = Map<String, dynamic>.from(
            (data[trainNumber] as Map?) ??
                _emptyWeekMap(),
        );

        final delays = List<double>.from(
            (train[day.name] as List?) ?? [],
        );

        delays.add(delay);

        if (delays.length > maxHistory) {
            delays.removeAt(0);
        }

        train[day.name] = delays;
        data[trainNumber] = train;

        await _db
            .collection('prediction')
            .doc('train-delays')
            .set(data);
    }

    Future<double> predictTrafficDelay(
        Weekday day,
    ) async {
        final data = await _loadTraffic();

        final delays = List<double>.from(
            (data[day.name] as List?) ?? [],
        );

        if (delays.isEmpty) {
            return 0;
        }

        if (delays.length < 5) {
            return delays.average;
        }

        return LinearRegression
            .fromData(delays)
            .predictNext(delays.length);
    }

    Future<double> predictTrainDelay(
        String trainNumber,
        Weekday day,
    ) async {
        final data = await _loadTrain();

        final train = Map<String, dynamic>.from(
            (data[trainNumber] as Map?) ??
                <String, dynamic>{},
        );

        final delays = List<double>.from(
            (train[day.name] as List?) ?? [],
        );

        if (delays.isEmpty) {
            return 0;
        }

        if (delays.length < 5) {
            return delays.average;
        }

        return LinearRegression
            .fromData(delays)
            .predictNext(delays.length);
    }

    Future<double> predictTotalDelay(
        String trainNumber,
        Weekday day,
    ) async {
        return await predictTrainDelay(
            trainNumber,
            day,
        ) +
        await predictTrafficDelay(day);
    }
}
