import 'package:flutter/material.dart';
import 'package:screen_time/screen_time.dart';

class AppUsagePage extends StatelessWidget {
  const AppUsagePage({super.key, required this.apps});

  final List<AppUsage> apps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Usage Data')),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                (app.iconInBytes != null)
                    ? Image.memory(app.iconInBytes!, width: 40, height: 40)
                    : SizedBox.shrink(),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.appName ?? "Unknown"),
                    Text(app.packageName ?? "Unknown"),
                    Text("First Time: ${app.firstTime?.toLocal()}"),
                    Text("Last Time: ${app.lastTime?.toLocal()}"),
                    Text("Usage Time: ${app.usageTime?.toLocal().toString()}"),
                    Text(
                      "Last Time Used: ${app.lastTimeUsed?.toLocal().toString()}",
                    ),
                    Text("Category: ${app.category.name}"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
