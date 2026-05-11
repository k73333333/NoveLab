import 'package:flutter/material.dart';
import '../models/outline_chapter.dart';
import '../models/character.dart';
import '../models/location.dart';
import '../services/data_service.dart';
import '../services/ai_service.dart';

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
  final _chapterCountController = TextEditingController(text: '10');
  List<String> _selectedCharacterIds = [];
  String? _selectedLocationId;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId != null) {
      setState(() {
        _chapters = widget.dataService.getOutlineChapters(projectId);
      });
    }
  }

  Future<void> _showChapterDialog([OutlineChapter? chapter]) async {
    _clearForm();
    
    if (chapter != null) {
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _summaryController.text = chapter.summary;
      _selectedCharacterIds = List.from(chapter.characterIds);
      _selectedLocationId = chapter.locationId;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chapter == null ? '创建章节大纲' : '编辑章节大纲'),
        content: SizedBox(
          width: 500,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '章节标题 *'),
                    validator: (value) => value?.isEmpty ?? true ? '请输入标题' : null,
                  ),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(labelText: '内容概要 *'),
                    maxLines: 6,
                    validator: (value) => value?.isEmpty ?? true ? '请输入内容概要' : null,
                  ),
                  _buildCharacterSelector(),
                  _buildLocationSelector(),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _saveChapter();
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelector() {
    final projectId = widget.dataService.currentProjectId;
    final characters = projectId != null ? widget.dataService.getCharacters(projectId) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('涉及角色:'),
        Wrap(
          children: characters.map((char) {
            final isSelected = _selectedCharacterIds.contains(char.id);
            return FilterChip(
              label: Text(char.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCharacterIds.add(char.id);
                  } else {
                    _selectedCharacterIds.remove(char.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    final projectId = widget.dataService.currentProjectId;
    final locations = projectId != null ? widget.dataService.getLocations(projectId) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('发生地点:'),
        DropdownButtonFormField<String>(
          value: _selectedLocationId,
          hint: const Text('选择地点'),
          items: [
            const DropdownMenuItem(value: null, child: Text('无')),
            ...locations.map((loc) => DropdownMenuItem(
              value: loc.id,
              child: Text(loc.name),
            )),
          ],
          onChanged: (value) {
            _selectedLocationId = value;
          },
        ),
      ],
    );
  }

  void _clearForm() {
    _selectedChapter = null;
    _titleController.clear();
    _summaryController.clear();
    _selectedCharacterIds.clear();
    _selectedLocationId = null;
  }

  Future<void> _saveChapter() async {
    final projectId = widget.dataService.currentProjectId!;
    final chapter = OutlineChapter(
      id: _selectedChapter?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      summary: _summaryController.text,
      order: _selectedChapter?.order ?? _chapters.length,
      characterIds: _selectedCharacterIds,
      locationId: _selectedLocationId,
    );

    await widget.dataService.saveOutlineChapter(chapter);
    _loadChapters();
  }

  Future<void> _deleteChapter(String id) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个章节大纲吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.dataService.deleteOutlineChapter(id);
              Navigator.pop(context);
              _loadChapters();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateOutline() async {
    final chapterCount = int.tryParse(_chapterCountController.text) ?? 10;
    
    setState(() => _isGenerating = true);
    
    try {
      final outline = await widget.aiService.generateOutline(
        storySummary: '生成小说大纲',
        chapterCount: chapterCount,
      );
      
      final lines = outline.split('\n');
      int order = 0;
      
      for (final line in lines) {
        if (line.trim().isNotEmpty && !line.startsWith(' ')) {
          final chapter = OutlineChapter(
            id: widget.dataService.generateId(),
            projectId: widget.dataService.currentProjectId!,
            title: line.trim(),
            summary: '',
            order: order++,
          );
          await widget.dataService.saveOutlineChapter(chapter);
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('大纲生成成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
    
    _loadChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chapterCountController,
                    decoration: const InputDecoration(
                      labelText: '章节数量',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateOutline,
                  child: _isGenerating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                      : const Text('AI生成大纲'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _chapters.isEmpty
                ? const Center(child: Text('暂无章节大纲'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _chapters[index];
                      final characters = chapter.characterIds
                          .map((id) => widget.dataService.getCharacter(id))
                          .whereType<Character>()
                          .toList();
                      final location = chapter.locationId != null 
                          ? widget.dataService.getLocation(chapter.locationId!) 
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('第${chapter.order + 1}章: ${chapter.title}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (chapter.summary.isNotEmpty)
                                Text(chapter.summary),
                              if (characters.isNotEmpty)
                                Text('角色: ${characters.map((c) => c.name).join(', ')}'),
                              if (location != null)
                                Text('地点: ${location.name}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showChapterDialog(chapter),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteChapter(chapter.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChapterDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
