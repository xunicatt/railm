import 'package:railm/utils/plugin.dart';

enum ExpectedDelayType {
    unknown(-1);

    final int value;
    const ExpectedDelayType(this.value);
}

class ExpectedDelay extends Plugin {
    final num Function()? getSum;

    ExpectedDelay({this.getSum}) : super(
        "Expected Delay",
        "Shows total expected delay",
    );

    @override
    Future<num> fetch() async {
        if (getSum == null) {
            return ExpectedDelayType.unknown.value;
        }

        final delay = getSum!();
        return delay;
    }
}
