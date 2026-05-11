abstract class AIService {
  Future<String> generateOutline({
    required String prompt,
    required List<String> characters,
    required List<String> locations,
  });

  Future<String> generateContent({
    required String prompt,
    String? context,
  });

  Future<String> chatCompletion({
    required List<Map<String, String>> messages,
  });
}

class DummyAIService implements AIService {
  @override
  Future<String> generateOutline({
    required String prompt,
    required List<String> characters,
    required List<String> locations,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final charList = characters.join(', ');
    final locList = locations.join(', ');
    final firstChar = characters.isNotEmpty ? charList.split(', ').first : '主角';
    final firstLoc = locations.isNotEmpty ? locList.split(', ').first : '一个神秘的地方';
    
    String travelDesc = '在这片土地上';
    if (locations.isNotEmpty && locList.split(', ').length > 1) {
      final locs = locList.split(', ');
      travelDesc = '从${locs[0]}到${locs[1]}';
    }
    
    String result = '';
    result += '## 第一章：序幕\n\n';
    result += '在一个遥远的世界，${characters.isNotEmpty ? charList : '主人公'}踏上了一段不平凡的旅程。';
    result += '故事从$firstLoc开始，命运的齿轮开始转动。\n\n';
    result += '## 第二章：相遇\n\n';
    result += '$firstChar遇到了重要的伙伴，他们共同面对未知的挑战。';
    result += '$travelDesc，他们的羁绊逐渐加深。\n\n';
    result += '## 第三章：危机\n\n';
    result += '突如其来的危机打破了平静，$firstChar必须做出艰难的抉择。';
    result += '敌人的阴谋浮出水面，一场大战即将爆发。\n\n';
    result += '## 第四章：成长\n\n';
    result += '在逆境中成长，$firstChar掌握了新的力量。';
    result += '${locations.isNotEmpty ? '穿越' + locList : '历经艰险'}，他们离真相越来越近。\n\n';
    result += '## 第五章：决战\n\n';
    result += '最终的决战来临，${characters.isNotEmpty ? charList : '众人'}齐心协力对抗最终Boss。';
    result += '正义战胜邪恶，世界恢复和平。\n\n';
    result += '## 第六章：尾声\n\n';
    result += '故事落下帷幕，但新的冒险即将开始。$firstChar踏上了新的旅程，留下无限遐想。';
    
    return result;
  }

  @override
  Future<String> generateContent({
    required String prompt,
    String? context,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    String result = '';
    result += '这是一段根据你的需求生成的小说内容：\n\n';
    result += '$prompt\n\n';
    result += '（AI生成的内容将在此处显示。当前为演示模式，实际内容会根据你的输入动态生成。）\n\n';
    result += '示例段落：夕阳的余晖洒落在${context ?? '古老的城堡'}上，给整个建筑镀上了一层金色。';
    result += '${context ?? '主角'}站在窗前，凝视着远方，思绪万千。';
    result += '过去的种种如同电影般在脑海中闪过，而未来，正等待着他去书写新的篇章。';
    
    return result;
  }

  @override
  Future<String> chatCompletion({
    required List<Map<String, String>> messages,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final lastMessage = messages.last['content'] ?? '';
    
    if (lastMessage.toLowerCase().contains('开头') || lastMessage.toLowerCase().contains('开始')) {
      return '好的，我来为你生成故事的开头：\n\n晨光穿透窗帘的缝隙，洒在木质地板上，形成斑驳的光影。林晓从睡梦中醒来，窗外传来清脆的鸟鸣声。今天，是他人生中最重要的一天——他即将踏上寻找失落宝藏的旅程。';
    }
    
    if (lastMessage.toLowerCase().contains('续写') || lastMessage.toLowerCase().contains('继续')) {
      return '好的，我来继续这个故事：\n\n他整理好行囊，告别了年迈的母亲，毅然踏上了未知的旅途。穿过茂密的森林，越过湍急的河流，他终于来到了传说中的遗迹入口。古老的石门上刻满了神秘的符文，仿佛在诉说着千年前的故事。';
    }
    
    if (lastMessage.toLowerCase().contains('对话')) {
      return '好的，我来为你生成一段对话：\n\n"你确定要进去吗？"李雪担忧地看着他。\n\n林晓坚定地点了点头："这是我必须完成的使命。"\n\n"那……我陪你一起。"李雪握紧了手中的剑，眼中闪烁着坚定的光芒。';
    }
    
    String preview = lastMessage;
    if (lastMessage.length > 10) {
      preview = '${lastMessage.substring(0, 10)}……';
    }
    return '收到！我来为你生成相关的小说内容：\n\n根据你的需求，这里是一段精心创作的文字：\n\n暮色渐浓，$preview。在这片神秘的土地上，故事正悄然展开，等待着勇敢的冒险者去揭开它的面纱。';
  }
}
