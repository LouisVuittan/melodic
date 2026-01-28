/// 가사 학습 데이터 모델 및 더미 데이터

// 단어 타입
class Word {
  final String word;
  final String meaning;
  final String example;

  const Word({
    required this.word,
    required this.meaning,
    required this.example,
  });
}

// 문법 타입
class Grammar {
  final String pattern;
  final String explanation;
  final String example;

  const Grammar({
    required this.pattern,
    required this.explanation,
    required this.example,
  });
}

// 표현 타입
class Expression {
  final String expression;
  final String meaning;
  final String example;

  const Expression({
    required this.expression,
    required this.meaning,
    required this.example,
  });
}

// 가사 라인 타입
class LyricLine {
  final int lineId;
  final String original;
  final String translated;
  final List<Word> words;
  final List<Grammar> grammar;
  final List<Expression> expressions;
  final double startTime;
  final double endTime;

  const LyricLine({
    required this.lineId,
    required this.original,
    required this.translated,
    required this.words,
    required this.grammar,
    required this.expressions,
    required this.startTime,
    required this.endTime,
  });
}

// 노래 전체 데이터 타입
class SongLyrics {
  final String songId;
  final String title;
  final String artist;
  final String language;
  final String youtubeId;
  final String albumImageUrl;
  final List<LyricLine> lyricsAnalysis;

  const SongLyrics({
    required this.songId,
    required this.title,
    required this.artist,
    required this.language,
    required this.youtubeId,
    required this.albumImageUrl,
    required this.lyricsAnalysis,
  });
}

/// 튜토리얼용 샘플 노래 데이터 (ベテルギウス - Yuuri)
const tutorialSongData = SongLyrics(
  songId: 'betelgeuse_yuuri',
  title: 'ベテルギウス',
  artist: 'Yuuri',
  language: 'JP-KR',
  youtubeId: 'cbqvxDTLMps',
  albumImageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/77/5d/e6/775de6c8-5977-f326-0f86-2b7691132de5/cover.jpg/600x600bb.jpg',
  lyricsAnalysis: [
    LyricLine(
      lineId: 1,
      original: '空にある何かを見つめてたら',
      translated: '하늘에 있는 무언가를 바라보고 있으면',
      startTime: 0.0,
      endTime: 5.5,
      words: [
        Word(word: '空 (そら)', meaning: '하늘', example: '空を見上げる (하늘을 올려다보다)'),
        Word(word: 'ある', meaning: '있다, 존재하다 (무생물)', example: '机の上に本がある (책상 위에 책이 있다)'),
        Word(word: '何か (なにか)', meaning: '무언가', example: '何か食べたい (뭔가 먹고 싶다)'),
        Word(word: '見つめる (みつめる)', meaning: '응시하다, 바라보다', example: '未来を見つめる (미래를 바라보다)'),
      ],
      grammar: [
        Grammar(pattern: '〜にある', explanation: '어떤 장소에 존재함을 나타냄', example: '空にある星 (하늘에 있는 별)'),
        Grammar(pattern: '〜を見つめる', explanation: '직접 목적어를 응시하는 동작', example: '何かを見つめる (무언가를 바라보다)'),
        Grammar(pattern: '〜てたら', explanation: '가정형(~하면)', example: '空を見つめてたら (하늘을 바라보고 있으면)'),
      ],
      expressions: [
        Expression(expression: '何かを見つめる', meaning: '무언가를 응시하다', example: '彼は遠くの何かを見つめていた (그는 멀리 있는 무언가를 응시하고 있었다)'),
      ],
    ),
    LyricLine(
      lineId: 2,
      original: 'それは星だって君がおしえてくれた',
      translated: '그건 별이라고 네가 가르쳐 줬어',
      startTime: 5.5,
      endTime: 11.0,
      words: [
        Word(word: 'それ', meaning: '그것', example: 'それは何？ (그건 뭐야?)'),
        Word(word: '星 (ほし)', meaning: '별', example: '夜空の星 (밤하늘의 별)'),
        Word(word: '教える (おしえる)', meaning: '가르치다, 알려주다', example: '先生が数学を教える (선생님이 수학을 가르친다)'),
        Word(word: '君 (きみ)', meaning: '너', example: '君の名前は？ (너의 이름은 뭐야?)'),
      ],
      grammar: [
        Grammar(pattern: '〜だって', explanation: '직접 인용 (~라고)', example: '星だって (별이라고)'),
        Grammar(pattern: '〜てくれる', explanation: '상대방이 나를 위해 어떤 행동을 해주는 표현', example: '教えてくれた (가르쳐 줬다)'),
      ],
      expressions: [
        Expression(expression: '星だって', meaning: '별이라고 (꿈, 희망의 상징)', example: '君は星だって信じてる (너는 별이라고 믿고 있어)'),
        Expression(expression: '教えてくれる', meaning: '가르쳐 주다, 알려주다 (배려의 의미)', example: '先生が優しく教えてくれる (선생님이 친절하게 가르쳐 준다)'),
      ],
    ),
    LyricLine(
      lineId: 3,
      original: 'まるでそれは僕らみたいに 寄り添ってる',
      translated: '마치 그건 우리처럼 가까이 있어',
      startTime: 11.0,
      endTime: 17.0,
      words: [
        Word(word: 'まるで', meaning: '마치', example: 'まるで夢のようだ (마치 꿈 같다)'),
        Word(word: '僕ら (ぼくら)', meaning: '우리들', example: '僕らの未来 (우리들의 미래)'),
        Word(word: 'みたい', meaning: '~처럼, ~같은', example: '子供みたい (아이 같다)'),
        Word(word: '寄り添う (よりそう)', meaning: '곁에 있다, 가까이 다가가다', example: '彼女に寄り添う (그녀 곁에 있다)'),
      ],
      grammar: [
        Grammar(pattern: '〜みたいに', explanation: '비유를 나타내는 표현 (~처럼)', example: '夢みたいに (꿈처럼)'),
        Grammar(pattern: '〜てる', explanation: '~하고 있다 (진행형의 구어체)', example: '寄り添ってる (곁에 있어)'),
      ],
      expressions: [
        Expression(expression: 'まるで〜みたい', meaning: '마치 ~처럼', example: 'まるで映画みたいだ (마치 영화 같다)'),
      ],
    ),
    LyricLine(
      lineId: 4,
      original: '離れていても 光で繋がれる',
      translated: '떨어져 있어도 빛으로 연결돼',
      startTime: 17.0,
      endTime: 23.0,
      words: [
        Word(word: '離れる (はなれる)', meaning: '떨어지다, 멀어지다', example: '家から離れる (집에서 떨어지다)'),
        Word(word: '光 (ひかり)', meaning: '빛', example: '朝の光 (아침 빛)'),
        Word(word: '繋がる (つながる)', meaning: '연결되다', example: '心が繋がる (마음이 연결되다)'),
      ],
      grammar: [
        Grammar(pattern: '〜ていても', explanation: '~해 있어도 (상태 지속 + 양보)', example: '離れていても (떨어져 있어도)'),
        Grammar(pattern: '〜で繋がる', explanation: '~로/으로 연결되다', example: '光で繋がる (빛으로 연결되다)'),
      ],
      expressions: [
        Expression(expression: '光で繋がる', meaning: '빛으로 연결되다 (정서적 유대)', example: '星は光で繋がっている (별은 빛으로 연결되어 있다)'),
      ],
    ),
    LyricLine(
      lineId: 5,
      original: '同じ空の下 僕らは一つ',
      translated: '같은 하늘 아래 우리는 하나',
      startTime: 23.0,
      endTime: 28.0,
      words: [
        Word(word: '同じ (おなじ)', meaning: '같은', example: '同じ夢を見る (같은 꿈을 꾸다)'),
        Word(word: '下 (した)', meaning: '아래', example: '机の下 (책상 아래)'),
        Word(word: '一つ (ひとつ)', meaning: '하나', example: '心は一つ (마음은 하나)'),
      ],
      grammar: [
        Grammar(pattern: '〜の下', explanation: '~의 아래', example: '空の下 (하늘 아래)'),
        Grammar(pattern: 'AはB', explanation: 'A는 B다 (주어 + 서술)', example: '僕らは一つ (우리는 하나)'),
      ],
      expressions: [
        Expression(expression: '同じ空の下', meaning: '같은 하늘 아래 (공유하는 존재)', example: '私たちは同じ空の下にいる (우리는 같은 하늘 아래에 있다)'),
      ],
    ),
    LyricLine(
      lineId: 6,
      original: 'ベテルギウスのように',
      translated: '베텔게우스처럼',
      startTime: 28.0,
      endTime: 33.0,
      words: [
        Word(word: 'ベテルギウス', meaning: '베텔게우스 (오리온자리의 붉은 별)', example: 'ベテルギウスは赤い星だ (베텔게우스는 붉은 별이다)'),
        Word(word: 'のように', meaning: '~처럼', example: '風のように (바람처럼)'),
      ],
      grammar: [
        Grammar(pattern: '〜のように', explanation: '~처럼 (비유)', example: '星のように輝く (별처럼 빛나다)'),
      ],
      expressions: [
        Expression(expression: 'ベテルギウスのように', meaning: '베텔게우스처럼 (멀리서도 빛나는 존재)', example: '君はベテルギウスのように輝いている (너는 베텔게우스처럼 빛나고 있어)'),
      ],
    ),
  ],
);

/// YOASOBI - アイドル 샘플 데이터
const idolSongData = SongLyrics(
  songId: 'idol_yoasobi',
  title: 'アイドル',
  artist: 'YOASOBI',
  language: 'JP-KR',
  youtubeId: 'ZRtdQ81jPUQ',
  albumImageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/7e/bd/c5/7ebdc5e4-8ea1-4a80-b9bf-f917a2085574/cover.jpg/600x600bb.jpg',
  lyricsAnalysis: [
    LyricLine(
      lineId: 1,
      original: '無敵の笑顔で荒らすメディア',
      translated: '무적의 미소로 미디어를 휩쓸어',
      startTime: 0.0,
      endTime: 3.0,
      words: [
        Word(word: '無敵 (むてき)', meaning: '무적', example: '無敵の力 (무적의 힘)'),
        Word(word: '笑顔 (えがお)', meaning: '미소, 웃는 얼굴', example: '素敵な笑顔 (멋진 미소)'),
        Word(word: '荒らす (あらす)', meaning: '휩쓸다, 어지럽히다', example: '部屋を荒らす (방을 어지럽히다)'),
        Word(word: 'メディア', meaning: '미디어', example: 'メディアに出る (미디어에 나오다)'),
      ],
      grammar: [
        Grammar(pattern: '〜で', explanation: '~로 (수단/방법)', example: '笑顔で挨拶する (미소로 인사하다)'),
      ],
      expressions: [
        Expression(expression: '無敵の笑顔', meaning: '무적의 미소 (누구도 이길 수 없는 미소)', example: '彼女は無敵の笑顔を持っている (그녀는 무적의 미소를 가지고 있다)'),
      ],
    ),
    LyricLine(
      lineId: 2,
      original: '知りたいその秘密ミステリアス',
      translated: '알고 싶어 그 비밀 미스테리어스',
      startTime: 3.0,
      endTime: 6.0,
      words: [
        Word(word: '知る (しる)', meaning: '알다', example: '真実を知る (진실을 알다)'),
        Word(word: '秘密 (ひみつ)', meaning: '비밀', example: '秘密を守る (비밀을 지키다)'),
        Word(word: 'ミステリアス', meaning: '신비로운, 미스테리어스', example: 'ミステリアスな雰囲気 (신비로운 분위기)'),
      ],
      grammar: [
        Grammar(pattern: '〜たい', explanation: '~하고 싶다 (희망)', example: '知りたい (알고 싶다)'),
        Grammar(pattern: 'その〜', explanation: '그~', example: 'その秘密 (그 비밀)'),
      ],
      expressions: [],
    ),
    LyricLine(
      lineId: 3,
      original: '抜けてるとこさえ彼女のエリア',
      translated: '빠진 곳조차 그녀의 영역',
      startTime: 6.0,
      endTime: 9.0,
      words: [
        Word(word: '抜ける (ぬける)', meaning: '빠지다, 빠져있다', example: '力が抜ける (힘이 빠지다)'),
        Word(word: 'さえ', meaning: '~조차', example: '彼さえ知らない (그조차 모른다)'),
        Word(word: '彼女 (かのじょ)', meaning: '그녀', example: '彼女の名前 (그녀의 이름)'),
        Word(word: 'エリア', meaning: '영역, 구역', example: '安全なエリア (안전한 구역)'),
      ],
      grammar: [
        Grammar(pattern: '〜さえ', explanation: '~조차 (극단적 예시)', example: '子供さえ知っている (아이조차 알고 있다)'),
        Grammar(pattern: '〜ているところ', explanation: '~하고 있는 곳/부분', example: '抜けてるとこ (빠진 곳)'),
      ],
      expressions: [],
    ),
  ],
);