import '../../recording/models/record_entry.dart';
import '../models/ai_correction_result.dart';

class DummyCorrectionService {
  const DummyCorrectionService();

  Future<AiCorrectionResult> analyze(RecordEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return AiCorrectionResult(
      transcript: _transcriptFor(entry.language),
      correctedText: _correctedTextFor(entry.language),
      naturalExpression: _naturalExpressionFor(entry.language),
      translation: _translationFor(entry.language),
      grammarNotes: _grammarNotesFor(entry.language),
      vocabularyNotes: _vocabularyNotesFor(entry.language),
      score: 82,
      encouragement: '短い文でも最後まで話せています。次は理由や感想を一文足すと、もっと自然なスピーキングになります。',
    );
  }

  String _transcriptFor(String language) {
    return switch (language) {
      '英語' => 'Today I went to a cafe and I drank coffee. It was very good.',
      'フランス語' =>
        'Aujourd’hui je suis alle dans un cafe et j’ai bu un cafe. C’etait tres bon.',
      'ドイツ語' =>
        'Heute bin ich in ein Cafe gegangen und habe Kaffee getrunken. Es war sehr gut.',
      'イタリア語' =>
        'Oggi sono andato in un bar e ho bevuto un caffe. Era molto buono.',
      '韓国語' => '오늘은 카페에 가서 커피를 마셨어요. 아주 좋았어요.',
      '中国語' => '今天我去了咖啡店，喝了咖啡。很好喝。',
      _ => 'Hoy fui a una cafeteria y tome cafe. Fue muy bueno.',
    };
  }

  String _correctedTextFor(String language) {
    return switch (language) {
      '英語' =>
        'Today, I went to a cafe and had some coffee. It was really good.',
      'フランス語' =>
        'Aujourd’hui, je suis alle dans un cafe et j’ai bu un cafe. C’etait tres bon.',
      'ドイツ語' =>
        'Heute bin ich in ein Cafe gegangen und habe Kaffee getrunken. Es war sehr gut.',
      'イタリア語' =>
        'Oggi sono andato in un bar e ho bevuto un caffe. Era molto buono.',
      '韓国語' => '오늘은 카페에 가서 커피를 마셨어요. 정말 좋았어요.',
      '中国語' => '今天我去了咖啡店，喝了一杯咖啡。味道很好。',
      _ => 'Hoy fui a una cafeteria y tome un cafe. Estuvo muy bueno.',
    };
  }

  String _naturalExpressionFor(String language) {
    return switch (language) {
      '英語' => 'I stopped by a cafe today and had a really nice coffee.',
      'フランス語' =>
        'Je suis passe dans un cafe aujourd’hui, et le cafe etait vraiment bon.',
      'ドイツ語' =>
        'Ich war heute kurz in einem Cafe, und der Kaffee war wirklich gut.',
      'イタリア語' =>
        'Oggi sono passato in un bar e ho bevuto un caffe davvero buono.',
      '韓国語' => '오늘 카페에 들러서 정말 맛있는 커피를 마셨어요.',
      '中国語' => '我今天去了一家咖啡店，喝了一杯很好喝的咖啡。',
      _ => 'Hoy pase por una cafeteria y tome un cafe muy rico.',
    };
  }

  String _translationFor(String language) {
    return '今日はカフェに行ってコーヒーを飲みました。とてもおいしかったです。';
  }

  List<String> _grammarNotesFor(String language) {
    return switch (language) {
      '英語' => [
        'drink coffee でも通じますが、体験として話す時は had coffee のほうが自然です。',
        'Today の後にカンマを入れると、文の流れが読みやすくなります。',
      ],
      _ => [
        '意味は十分伝わっています。冠詞や動詞の選び方を少し整えると、より自然になります。',
        '短い文を並べるだけでなく、理由や感想を足すと会話らしくなります。',
      ],
    };
  }

  List<String> _vocabularyNotesFor(String language) {
    return switch (language) {
      '英語' => ['stop by: 少し立ち寄る', 'really nice: とても良い、感じが良い'],
      _ => [
        '「立ち寄る」に近い表現を覚えると、日常の出来事を自然に話しやすくなります。',
        '「とてもよかった」だけでなく、「おいしかった」「落ち着いた」など具体的な感想を足すと表現が豊かになります。',
      ],
    };
  }
}
