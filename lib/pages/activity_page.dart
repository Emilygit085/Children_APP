import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/mock_parent_data.dart';
import '../models/approval_request.dart';
import '../widgets/screen_time_banner.dart';
import '../utils/navigation_helper.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // 假数据：活动列表
  final List<Activity> _activities = [
    Activity(
      id: '1',
      title: '一起踢足球',
      description: '周六下午在公园踢足球，欢迎喜欢足球的小朋友加入！',
      date: '2024-01-20',
      time: '14:00',
      location: '中央公园',
      organizerId: '1',
      organizerName: '小明',
      organizerAvatar: 'assets/images/avatar1.png',
      participantIds: ['1', '2'],
      maxParticipants: 6,
      interest: '⚽ 足球',
      image: 'assets/images/football.jpg',
    ),
    Activity(
      id: '2',
      title: 'Lego 创意搭建',
      description: '一起用 Lego 搭建城堡，发挥想象力！',
      date: '2024-01-21',
      time: '15:00',
      location: '社区活动中心',
      organizerId: '3',
      organizerName: '小刚',
      organizerAvatar: 'assets/images/avatar2.png',
      participantIds: ['3', '4'],
      maxParticipants: 8,
      interest: '🧩 Lego',
      image: 'assets/images/lego.jpg',
    ),
    Activity(
      id: '3',
      title: '画画小课堂',
      description: '一起学习画画，画出美丽的风景！',
      date: '2024-01-22',
      time: '10:00',
      location: '艺术教室',
      organizerId: '2',
      organizerName: '小红',
      organizerAvatar: 'assets/images/avatar4.png',
      participantIds: ['2'],
      maxParticipants: 5,
      interest: '🎨 画画',
      image: 'assets/images/drawing.jpg',
    ),
  ];

  ApprovalStatus? _getStatus(String activityId) {
    return MockParentData.getStatusByActivityId(activityId);
  }

  String _buildStatusText(ApprovalStatus? status) {
    if (status == null) {
      return '尚未发起家长审批';
    }
    switch (status) {
      case ApprovalStatus.pending:
        return '审批状态：待家长确认';
      case ApprovalStatus.approved:
        return '审批状态：家长已同意';
      case ApprovalStatus.rejected:
        return '审批状态：家长已拒绝';
    }
  }

  Color _statusColor(BuildContext context, ApprovalStatus? status) {
    final colorScheme = Theme.of(context).colorScheme;
    if (status == null) {
      return colorScheme.onSurfaceVariant;
    }
    switch (status) {
      case ApprovalStatus.pending:
        return colorScheme.secondary;
      case ApprovalStatus.approved:
        return colorScheme.tertiary;
      case ApprovalStatus.rejected:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          '活动广场',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/create-activity');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const ScreenTimeBanner();
          }
          final activity = _activities[index - 1];
          final status = _getStatus(activity.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            child: InkWell(
              onTap: () {
                // 可以跳转到活动详情页
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(activity.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: colorScheme.secondaryContainer,
                          backgroundImage: AssetImage(activity
                              .organizerAvatar), // use asset instead of networkImage()
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.organizerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '发起了活动',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            activity.interest,
                            style: TextStyle(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.date} ${activity.time}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          activity.location,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _buildStatusText(status),
                      style: TextStyle(
                        color: _statusColor(context, status),
                        fontSize: 13,
                        fontWeight: status == null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${activity.currentParticipants}/${activity.maxParticipants} 人参加',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _buildButtonEnabled(activity, status)
                              ? () {
                                  MockParentData.createActivityRequest(
                                    activityId: activity.id,
                                    activityTitle: activity.title,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已发送家长确认'),
                                    ),
                                  );
                                  setState(() {});
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _buildButtonText(activity, status),
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationHelper.buildBottomNav(
        context,
        2,
        selectedColor: colorScheme.primary,
      ),
    );
  }

  bool _buildButtonEnabled(Activity activity, ApprovalStatus? status) {
    if (!activity.hasSpace) {
      return false;
    }
    if (status == null) {
      return true;
    }
    switch (status) {
      case ApprovalStatus.pending:
      case ApprovalStatus.approved:
      case ApprovalStatus.rejected:
        return false;
    }
  }

  String _buildButtonText(Activity activity, ApprovalStatus? status) {
    if (!activity.hasSpace) {
      return '名额已满';
    }
    if (status == null) {
      return '加入活动';
    }
    switch (status) {
      case ApprovalStatus.pending:
        return '等待审批';
      case ApprovalStatus.approved:
        return '已同意';
      case ApprovalStatus.rejected:
        return '已拒绝';
    }
  }
}
