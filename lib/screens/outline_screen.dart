import 'package:flutter/material.dart';
import '../models/outline_chapter.dart';
import '../models/character.dart';
import '../models/location.dart';
import '../services/data_service.dart';
import '../services/ai_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class OutlineScreen extends StatefulWidget {
  final DataService dataService;
  final AIService aiService;

  const OutlineScreen({
    super.key,
    required this.dataService,
    required this.aiService,
  });

  @override
  State<OutlineScreen> createState() => _OutlineScreenState();
}

class _OutlineScreenState extends State<OutlineScreen> {
  List<OutlineChapter> _chapters = [];
  OutlineChapter? _selectedChapter;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isGenerating = false;
  DateTime? _lastUpdateCheckTime;

  @override
  void initState() {
    super.initState();
    _loadChapters();
    _lastUpdateCheckTime = DateTime.now();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _chapters = widget.dataService.getAllOutlineChapters();
    });
  }

  void _selectChapter(OutlineChapter chapter) {
    setState(() {
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _summaryController.text = chapter.summary ?? '';
    });
  }

  void _clearForm() {
    setState(() {
      _selectedChapter = null;
      _titleController.clear();
      _summaryController.clear();
    });
  }

  String _getSummaryPreview(String? summary) {
    if (summary == null || summary.isEmpty) {
      return '';
    }
    if (summary.length <= 30) {
      return summary;
    }
    return '${summary.substring(0, 30)}...';
  }

  Future<void> _saveChapter() async {
    if (!_formKey.currentState!.validate()) return;

    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择项目')),
      );
      return;
    }

    final chapter = OutlineChapter(
      id: _selectedChapter?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      summary:
          _summaryController.text.isNotEmpty ? _summaryController.text : null,
      orderIndex: _selectedChapter?.orderIndex ?? _chapters.length,
    );

    await widget.dataService.saveOutlineChapter(chapter);
    _loadChapters();
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('章节保存成功')),
    );
  }

  Future<void> _deleteChapter() async {
    if (_selectedChapter == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个章节吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService
                  .deleteOutlineChapter(_selectedChapter!.id);
              _loadChapters();
              _clearForm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('章节删除成功')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdatesAndGenerate() async {
    final characters = widget.dataService.getAllCharacters();
    final locations = widget.dataService.getAllLocations();

    final hasUpdates =
        characters.any((c) => c.updatedAt.isAfter(_lastUpdateCheckTime!)) ||
            locations.any((l) => l.updatedAt.isAfter(_lastUpdateCheckTime!));

    if (hasUpdates) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('检测到数据更新'),
          content: const Text('角色或地图信息已更新，是否继续生成大纲？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _generateOutline();
              },
              child: const Text('继续'),
            ),
          ],
        ),
      );
    } else {
      await _generateOutline();
    }
  }

  Future<void> _generateOutline() async {
    setState(() => _isGenerating = true);

    final characters = widget.dataService.getAllCharacters();
    final locations = widget.dataService.getAllLocations();

    final charNames = characters.map((c) => c.name).toList();
    final locNames = locations.map((l) => l.name).toList();

    final result = await widget.aiService.generateOutline(
      prompt: '生成一个精彩的小说大纲',
      characters: charNames,
      locations: locNames,
    );

    await _parseAndSaveOutline(result);

    setState(() => _isGenerating = false);
    _lastUpdateCheckTime = DateTime.now();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('大纲生成成功')),
    );
  }

  Future<void> _parseAndSaveOutline(String outline) async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) return;

    final lines = outline.split('\n');
    List<OutlineChapter> newChapters = [];
    String? currentTitle;
    StringBuffer currentSummary = StringBuffer();

    for (final line in lines) {
      if (line.startsWith('## ')) {
        if (currentTitle != null) {
          newChapters.add(OutlineChapter(
            id: widget.dataService.generateId(),
            projectId: projectId,
            title: currentTitle,
            summary: currentSummary.toString().trim(),
            orderIndex: newChapters.length,
          ));
        }
        currentTitle = line.substring(3).trim();
        currentSummary.clear();
      } else if (currentTitle != null && line.trim().isNotEmpty) {
        if (currentSummary.isNotEmpty) currentSummary.write('\n');
        currentSummary.write(line);
      }
    }

    if (currentTitle != null) {
      newChapters.add(OutlineChapter(
        id: widget.dataService.generateId(),
        projectId: projectId,
        title: currentTitle,
        summary: currentSummary.toString().trim(),
        orderIndex: newChapters.length,
      ));
    }

    for (final chapter in _chapters) {
      await widget.dataService.deleteOutlineChapter(chapter.id);
    }

    for (final chapter in newChapters) {
      await widget.dataService.saveOutlineChapter(chapter);
    }

    _loadChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '大纲生成',
        actions: [
          CustomButton(
            text: 'AI生成',
            onPressed: _checkForUpdatesAndGenerate,
            isLoading: _isGenerating,
            height: 36,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return ListTile(
                  title: Text(chapter.title),
                  subtitle: Text(_getSummaryPreview(chapter.summary)),
                  selected: _selectedChapter?.id == chapter.id,
                  onTap: () => _selectChapter(chapter),
                );
              },
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: '章节标题',
                      hint: '输入章节标题',
                      controller: _titleController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入标题' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: '内容概要',
                      hint: '输入章节内容概要',
                      controller: _summaryController,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CustomButton(
                          text: '保存',
                          onPressed: _saveChapter,
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          text: '新建',
                          onPressed: _clearForm,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        if (_selectedChapter != null)
                          CustomButton(
                            text: '删除',
                            onPressed: _deleteChapter,
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
