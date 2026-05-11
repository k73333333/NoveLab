import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'template_list_screen.dart';
import 'project_settings_screen.dart';
import '../models/project.dart';

class SettingsScreen extends StatelessWidget {
  final DataService dataService;
  final Project? currentProject;

  const SettingsScreen({
    super.key,
    required this.dataService,
    this.currentProject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('模板管理'),
          _buildSettingCard(
            icon: Icons.description,
            title: '模板列表',
            description: '管理和编辑所有模板',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateListScreen(
                    dataService: dataService,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('当前项目'),
          if (currentProject != null)
            _buildSettingCard(
            icon: Icons.settings,
            title: '项目设置',
            description: '管理项目独立的字段配置',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectSettingsScreen(
                    dataService: dataService,
                    project: currentProject!,
                  ),
                ),
              );
            },
          )
          else
            _buildEmptyCard('请先选择项目'),
          const SizedBox(height: 24),
          _buildSectionTitle('其他'),
          _buildSettingCard(
            icon: Icons.info,
            title: '关于',
            description: '查看应用信息',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('关于'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('小说生成器', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('版本: 1.0.0'),
                      SizedBox(height: 16),
                      Text('一个基于AI的小说创作辅助工具，帮助你更好地组织和创作小说。'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}