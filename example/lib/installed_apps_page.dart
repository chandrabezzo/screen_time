import 'package:flutter/material.dart';
import 'package:screen_time/screen_time.dart';

import 'app_monitoring_settings.dart';
import 'app_usage_page.dart';

class InstalledAppsPage extends StatefulWidget {
  const InstalledAppsPage({super.key, required this.installedApps});

  final List<InstalledApp> installedApps;

  @override
  State<InstalledAppsPage> createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _screenTime = ScreenTime();
  final Set<String> _selectedApps = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All Apps'), Tab(text: 'By Category')],
        ),
        actions: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onActionPressed(context),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllAppsList(), _buildCategorizedAppsList()],
      ),
    );
  }

  void onActionPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('App Usage'),
              subtitle: Text('App Usage History'),
              trailing: const Icon(Icons.history),
              onTap: () async {
                final ctx = context;
                final packagesName = _selectedApps.isEmpty
                    ? widget.installedApps.map((app) => app.packageName ?? '').toList()
                    : _selectedApps.toList();
                final result = await _screenTime.appUsageData(
                  packagesName: packagesName,
                );

                if (!ctx.mounted) return;
                Navigator.pop(context);
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (context) => AppUsagePage(apps: result),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('App Monitoring'),
              subtitle: Text('App Monitoring Foreground'),
              trailing: const Icon(Icons.monitor),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AppMonitoringSettingsScreen(
                          packagesName: _selectedApps.isEmpty
                              ? widget.installedApps.map((app) => app.packageName ?? '').toList()
                              : _selectedApps.toList(),
                        ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllAppsList() {
    return ListView.builder(
      itemCount: widget.installedApps.length,
      itemBuilder: (context, index) {
        final app = widget.installedApps[index];
        final packageName = app.packageName ?? '';
        return ListTile(
          leading: app.iconInBytes != null ? Image.memory(app.iconInBytes!) : const Icon(Icons.android),
          title: Text(app.appName ?? "Unknown"),
          subtitle: Text(packageName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _selectedApps.contains(packageName),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedApps.add(packageName);
                    } else {
                      _selectedApps.remove(packageName);
                    }
                  });
                },
              ),
              Text(app.category.name),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorizedAppsList() {
    // Group apps by category
    final Map<AppCategory, List<InstalledApp>> categorizedApps = {};

    for (var app in widget.installedApps) {
      if (!categorizedApps.containsKey(app.category)) {
        categorizedApps[app.category] = [];
      }
      categorizedApps[app.category]!.add(app);
    }

    // Sort categories
    final sortedCategories =
        categorizedApps.keys.toList()..sort((a, b) => a.name.compareTo(b.name));

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final appsInCategory = categorizedApps[category]!;

        return ExpansionTile(
          title: Text(category.name),
          subtitle: Text('${appsInCategory.length} apps'),
          children:
              appsInCategory
                  .map(
                    (app) => ListTile(
                      leading: app.iconInBytes != null
                          ? Image.memory(app.iconInBytes!)
                          : const Icon(Icons.android),
                      title: Text(app.appName ?? "Unknown"),
                      subtitle: Text(app.packageName ?? "-"),
                      trailing: Checkbox(
                        value: _selectedApps.contains(app.packageName),
                        onChanged: (value) {
                          setState(() {
                            if (value == true && app.packageName != null) {
                              _selectedApps.add(app.packageName!);
                            } else if (app.packageName != null) {
                              _selectedApps.remove(app.packageName!);
                            }
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
