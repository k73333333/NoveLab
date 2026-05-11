abstract class AIService {
  Future<String> generateContent({
    required String prompt,
    String? context,
    Map<String, dynamic>? options,
  });

  Future<String> generateOutline({
    required String storySummary,
    int chapterCount = 10,
  });

  Future<String> generateChapter({
    required String outline,
    required int chapterNumber,
    String? previousContent,
  });
}

class DummyAIService implements AIService {
  @override
  Future<String> generateContent({
    required String prompt,
    String? context,
    Map<String, dynamic>? options,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return '''根据你的要求，我已经为你生成了一段小说内容：

这是一段示例文本，展示了AI生成小说的能力。在实际应用中，这里将显示由真正的AI模型生成的内容。

故事发生在一个遥远的国度，主角踏上了一段未知的旅程...

当你配置好AI服务后，就可以获得真实的AI生成内容了。''';
  }

  @override
  Future<String> generateOutline({
    required String storySummary,
    int chapterCount = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final outline = StringBuffer();
    for (int i = 1; i <= chapterCount; i++) {
      outline.writeln('第$i章：故事发展阶段$i');
      outline.writeln('  - 本章将继续推进故事主线');
      outline.writeln('  - 引入新的情节转折');
      outline.writeln('  - 角色关系进一步发展');
      outline.writeln();
    }
    
    return outline.toString();
  }

  @override
  Future<String> generateChapter({
    required String outline,
    required int chapterNumber,
    String? previousContent,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return '''第$chapterNumber章：新篇章

这是第$chapterNumber章的内容。根据大纲的指引，本章将继续推进故事的发展。

（AI生成的小说内容将在这里呈现）

---

当前使用的是模拟AI服务。配置真实的AI服务后，将生成更丰富的内容。''';
  }
}
