
import 'package:flutter/material.dart';
import 'package:saber/data/nextcloud/file_syncer.dart';
import 'package:saber/data/prefs.dart';

class SyncingButton extends StatefulWidget {
  const SyncingButton({super.key});

  @override
  State<SyncingButton> createState() => _SyncingButtonState();
}

class _SyncingButtonState extends State<SyncingButton> {

  @override
  void initState() {
    FileSyncer.filesDone.addListener(listener);
    Prefs.username.addListener(listener);

    super.initState();
  }

  void listener() {
    setState(() {});
  }

  double? getPercentage() {
    if (FileSyncer.filesDone.value == null) return null;

    int done = FileSyncer.filesDone.value!;
    int toSync = FileSyncer.filesToSync;

    if (toSync == 0 || done > FileSyncer.filesDoneLimit) {
      return 1;
    } else {
      return done / (done + toSync);
    }
  }

  @override
  Widget build(BuildContext context) {
    double? percentage = getPercentage();
    bool loggedIn = Prefs.username.value.isNotEmpty;

    return IconButton(
      onPressed: loggedIn ? () {
        FileSyncer.filesDone.value = null; // reset progress indicator
        FileSyncer.startSync();
      } : null,
      icon: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity:  (loggedIn && (percentage ?? 0) < 1) ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: CircularProgressIndicator(
              semanticsLabel: 'Syncing progress',
              semanticsValue: '${(percentage ?? 0) * 100}%',
              value: percentage,
            ),
          ),
          const Icon(Icons.sync)
        ],
      ),
    );
  }

  @override
  void dispose() {
    FileSyncer.filesDone.removeListener(listener);
    Prefs.username.removeListener(listener);
    super.dispose();
  }
}
