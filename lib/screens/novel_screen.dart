import 'package:flutter/material.dart';
import '../models/novel_chapter.dart';
import '../models/outline_chapter.dart';
import '../services/data_service.dart';
import '../services/ai_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _aiPromptController = TextEditingController();
  bool _isGenerating = false;
  String _aiMode = '开头';

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _chapters = widget.dataService.getAllNovelChapters();
    });
  }

  void _selectChapter(NovelChapter chapter) {
    setState(() {
      _selectedChapter = chapter;
      _titleController.text = chapter.title;
      _contentController.text = chapter.content;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedChapter = null;
      _titleController.clear();
      _contentController.clear();
    });
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

    final chapter = NovelChapter(
      id: _selectedChapter?.id ?? widget.dataService.generateId(),
      projectId: projectId,
      title: _titleController.text,
      content: _contentController.text,
      orderIndex: _selectedChapter?.orderIndex ?? _chapters.length,
      outlineChapterId: _selectedChapter?.outlineChapterId,
    );

    await widget.dataService.saveNovelChapter(chapter);
    _loadChapters();

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
              await widget.dataService.deleteNovelChapter(_selectedChapter!.id);
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

  Future<void> _generateWithAI() async {
    if (_aiPromptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入提示词')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final prompt = _buildPrompt();
    String result;

    if (_aiMode == '续写') {
      result = await widget.aiService.generateContent(
        prompt: prompt,
        context: _contentController.text.isNotEmpty
            ? _contentController.text.substring(
                0,
                _contentController.text.length > 500
                    ? 500
                    : _contentController.text.length)
            : null,
      );
    } else {
      result = await widget.aiService.generateContent(
        prompt: prompt,
      );
    }

    setState(() {
      _isGenerating = false;
      if (_contentController.text.isNotEmpty) {
        _contentController.text += '\n\n$result';
      } else {
        _contentController.text = result;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI生成完成')),
    );
  }

  String _buildPrompt() {
    final mode = _aiMode;
    final customPrompt = _aiPromptController.text;

    switch (mode) {
      case '开头':
        return '写一个小说开头，主题：$customPrompt';
      case '续写':
        return '继续写下面的内容：$customPrompt';
      case '对话':
        return '写一段对话，关于：$customPrompt';
      case '场景':
        return '描写一个场景：$customPrompt';
      default:
        return customPrompt;
    }
  }

  Future<void> _generateFromOutline() async {
    final outlineChapters = widget.dataService.getAllOutlineChapters();

    if (outlineChapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先生成大纲')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final projectId = widget.dataService.currentProjectId;
    if (projectId == null) {
      setState(() => _isGenerating = false);
      return;
    }

    for (final outline in outlineChapters) {
      final prompt = '根据以下大纲写一章小说：\n标题：${outline.title}\n概要：${outline.summary}';
      final content = await widget.aiService.generateContent(prompt: prompt);

      final chapter = NovelChapter(
        id: widget.dataService.generateId(),
        projectId: projectId,
        title: outline.title,
        content: content,
        orderIndex: outline.orderIndex,
        outlineChapterId: outline.id,
      );

      await widget.dataService.saveNovelChapter(chapter);
    }

    setState(() => _isGenerating = false);
    _loadChapters();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('根据大纲生成小说完成')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '小说生成',
        actions: [
          CustomButton(
            text: '从大纲生成',
            onPressed: _generateFromOutline,
            isLoading: _isGenerating,
            height: 36,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _chapters[index];
                      return ListTile(
                        title: Text(chapter.title),
                        selected: _selectedChapter?.id == chapter.id,
                        onTap: () => _selectChapter(chapter),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: '新建章节',
                    onPressed: _clearForm,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 3,
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
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: '章节内容',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('AI生成模式：'),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: _aiMode,
                          items: ['开头', '续写', '对话', '场景']
                              .map((mode) => DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _aiMode = value!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'AI提示词',
                      hint: '输入你想要生成的内容描述',
                      controller: _aiPromptController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CustomButton(
                          text: 'AI生成',
                          onPressed: _generateWithAI,
                          isLoading: _isGenerating,
                        ),
                        const SizedBox(width: 16),
                        CustomButton(
                          text: '保存',
                          onPressed: _saveChapter,
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
