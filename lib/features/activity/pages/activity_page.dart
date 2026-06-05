import 'package:flutter/material.dart';
import 'package:kasir_app/features/activity/widgets/activity_filter_bar.dart';
import 'package:kasir_app/features/activity/widgets/activity_item_card.dart';
import 'package:kasir_app/features/activity/widgets/activity_summary_card.dart';

import '../../../../data/local/activity_repo.dart';
import '../../widgets/app_drawer.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final repo = ActivityRepo();
  String selectedFilter = 'semua';
  

  List<Map<String, dynamic>> activities = [];
  Map<String, dynamic>? summary;
  List<Map<String, dynamic>> get filteredActivities {
    if (selectedFilter == 'SEMUA') {
      return activities;
    }

    return activities.where((item) {
      return item['tipe'] == selectedFilter;
    }).toList();
  }
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final activityResult = await repo.getTodayActivity();
    final summaryResult = await repo.getTodayCashSummary();

    if (!mounted) return;

    setState(() {
      activities = activityResult;
      summary = summaryResult;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(
        currentPage: 'Aktivitas',
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : activities.isEmpty
                ? const Center(
                    child: Text('Belum ada aktivitas hari ini'),
                  )
                : ListView.builder(
                    itemCount: activities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return 
                          ActivitySummaryCard(
                          summary: summary,
                        );
                      }

                      if (index == 1) {
                        return ActivityFilterBar(
                          selectedFilter: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value;
                            });
                          },
                        );
                      }
                      return 
                        ActivityItemsCard(
                          item: filteredActivities[index-2],
                        );
                    },
                  ),
      ),
    );
  }
}