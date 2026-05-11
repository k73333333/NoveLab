import 'package:flutter/material.dart';
import '../models/novel_chapter.dart';
import '../models/outline_chapter.dart';
import '../services/data_service.dart';
import '../services/ai_service.dart';

class NovelScreen extends StatefulWidget {
  final DataService dataService;
  final AIService aiService;

  const NovelScreen({
    super.key,
    required this.dataService,
    required this.aiService,
  });

  @override
  State<NovelScreen> createState() => _NovelScreenState();
}

class _NovelScreenState extends State<NovelScreen> {
  List<NovelChapter> _chapters = [];
  NovelChapter? _selectedChapter;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _aiPromptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _aiMode = '续写';
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
        _chapters = widget.dataService.getNovelChapters(projectId);
      });
    }
  }

  Future<void> _showChapterDialog([NovelChapter? chapter]) async {
    _clearForm();

    if (chapter != null) {
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _contentController.text = chapter.content;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chapter == null ? '创建章节' : '编辑章节'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: '章节标题 *'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '请输入标题' : null,
                  ),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: '章节内容'),
                    maxLines: 20,
                  ),
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

  void _clearForm() {
    _selectedChapter = null;
    _titleController.clear();
    _contentController.clear();
  }

  Future<void> _saveChapter() async {
    final projectId = widget.dataService.currentProjectId!;
    final chapter = NovelChapter(
      id: _selectedChapter?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      content: _contentController.text,
      order: _selectedChapter?.order ?? _chapters.length,
    );

    await widget.dataService.saveNovelChapter(chapter);
    _loadChapters();
  }

  Future<void> _deleteChapter(String id) async {
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
              await widget.dataService.deleteNovelChapter(id);
              Navigator.pop(context);
              _loadChapters();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _selectChapter(NovelChapter chapter) {
    setState(() {
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _contentController.text = chapter.content;
    });
  }

  Future<void> _generateContent() async {
    setState(() => _isGenerating = true);

    final prompt = _aiPromptController.text.isNotEmpty
        ? _aiPromptController.text
        : '继续写小说内容';

    try {
      String result;

      if (_aiMode == '续写') {
        result = await widget.aiService.generateContent(
          prompt: prompt,
          context: _contentController.text.isNotEmpty
              ? _contentController.text.substring(
                  0,
                  _contentController.text.length > 500
                      ? 500
                      : _contentController.text.length,
                )
              : null,
        );
      } else {
        result = await widget.aiService.generateContent(
          prompt: prompt,
        );
      }

      setState(() {
        _contentController.text += '\n\n' + result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容生成成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成失败: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateFromOutline() async {
    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) return;

    final outlines = widget.dataService.getOutlineChapters(projectId);
    if (outlines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先创建章节大纲')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      for (int i = 0; i < outlines.length; i++) {
        final outline = outlines[i];
        final chapter = NovelChapter(
          id: widget.dataService.generateId(),
          projectId: projectId,
          title: outline.title,
          content: '',
          order: i,
        );
        await widget.dataService.saveNovelChapter(chapter);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已从大纲创建章节')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建失败: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }

    _loadChapters();
  }

  Future<void> _saveCurrentContent() async {
    if (_selectedChapter != null) {
      await widget.dataService.saveNovelChapter(
        _selectedChapter!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        ),
      );
      _loadChapters();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Column(
              children: [
                Expanded(
                  child: _chapters.isEmpty
                      ? const Center(child: Text('暂无章节'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = _chapters[index];
                            return ListTile(
                              title: Text(
                                  '第${chapter.order + 1}章: ${chapter.title}'),
                              selected: _selectedChapter?.id == chapter.id,
                              onTap: () => _selectChapter(chapter),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteChapter(chapter.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showChapterDialog(),
                          child: const Text('新建章节'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isGenerating ? null : _generateFromOutline,
                          child: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator())
                              : const Text('从大纲生成'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: '章节标题',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saveCurrentContent,
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _aiMode,
                        items: [
                          const DropdownMenuItem(
                              value: '续写', child: Text('续写')),
                          const DropdownMenuItem(
                              value: '生成开头', child: Text('生成开头')),
                          const DropdownMenuItem(
                              value: '生成对话', child: Text('生成对话')),
                          const DropdownMenuItem(
                              value: '生成场景', child: Text('生成场景')),
                        ],
                        onChanged: (value) => setState(() => _aiMode = value!),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _aiPromptController,
                          decoration: const InputDecoration(
                            labelText: 'AI提示词',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isGenerating ? null : _generateContent,
                        child: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator())
                            : const Text('AI生成'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '章节内容',
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
