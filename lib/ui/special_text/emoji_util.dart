import 'package:cobiz_client/tools/cobiz.dart';

class EmojiUitl {
  final Map<String, Emoji> _emojis = Map();

  Map<String, Emoji> get emojis => _emojis;

  final String _pathPrefix = "assets/images/emoji/";

  static EmojiUitl _instance;

  static EmojiUitl get instance {
    if (_instance == null) _instance = EmojiUitl._();
    return _instance;
  }

  EmojiUitl._() {
    for (int i = 1; i <= 100; i++) {
      _emojis['e$i'] = Emoji(
          id: i, path: '${_pathPrefix}sg$i.png', text: '[${texts['t$i']}]');
    }
  }

  bool isEmoji(String text) {
    return texts.values.any((element) => '[$element]' == text);
  }

  String parseText(String text) {
    if (text.contains('[') && text.contains(']')) {
      Set<String> emojis = findEmojis(text);
      if (emojis != null && emojis.length > 0) {
        emojis.forEach((element) {
          text = text.replaceAll(element, '');
        });
      }
      return text;
    } else {
      return text;
    }
  }

  dynamic findEmojis(String data) {
    if (!strNoEmpty(data)) return null;

    final Set<String> sets = Set();
    String textStack = '';
    String specialText;
    for (int i = 0; i < data.length; i++) {
      final String char = data[i];
      textStack += char;
      if (specialText != null) {
        if (!textStack.endsWith(']')) {
          specialText += char;
        } else {
          sets.add(textStack);
          specialText = null;
          textStack = '';
        }
      } else if (textStack.startsWith('[')) {
        specialText = data.substring(i);
      } else {
        textStack = '';
      }
    }
    return sets;
  }

  Map<String, String> texts = {
    't1': '微笑',
    't2': '撇嘴',
    't3': '色',
    't4': '发呆',
    't5': '得意',
    't6': '流泪',
    't7': '害羞',
    't8': '闭嘴',
    't9': '睡觉',
    't10': '大哭',
    't11': '笑哭',
    't12': '大汗',
    't13': '糗大了',
    't14': '尴尬',
    't15': '发怒',
    't16': '调皮',
    't17': '呲牙',
    't18': '惊讶',
    't19': '难过',
    't20': '折磨',
    't21': '抓狂',
    't22': '吐',
    't23': '偷笑',
    't24': '愉快',
    't25': '白眼',
    't26': '傲慢',
    't27': '困',
    't28': '惊吓',
    't29': '流汗',
    't30': '憨笑',
    't31': '悠闲',
    't32': '奋斗',
    't33': '咒骂',
    't34': '疑问',
    't35': '嘘',
    't36': '晕',
    't37': '衰',
    't38': '骷髅',
    't39': '敲打',
    't40': '再见',
    't41': '搽汗',
    't42': '扣鼻',
    't43': '鼓掌',
    't44': '坏笑',
    't45': '左哼哼',
    't46': '右哼哼',
    't47': '哈欠',
    't48': '鄙视',
    't49': '委屈',
    't50': '快哭了',
    't51': '阴险',
    't52': '亲亲',
    't53': '可怜',
    't54': '菜刀',
    't55': '西瓜',
    't56': '啤酒',
    't57': '咖啡',
    't58': '猪头',
    't59': '玫瑰',
    't60': '凋谢',
    't61': '嘴唇',
    't62': '爱心',
    't63': '心碎',
    't64': '蛋糕',
    't65': '炸弹',
    't66': '便便',
    't67': '月亮',
    't68': '太阳',
    't69': '拥抱',
    't70': '强',
    't71': '弱',
    't72': '握手',
    't73': '胜利',
    't74': '抱拳',
    't75': '勾引',
    't76': '拳头',
    't77': 'OK',
    't78': '爱意',
    't79': '小视',
    't80': '大笑',
    't81': '口罩',
    't82': '笑哭2',
    't83': '发呆2',
    't84': '惊恐',
    't85': '无语',
    't86': '埋怨',
    't87': '开心',
    't88': '捂脸',
    't89': '奸笑',
    't90': '机智',
    't91': '皱眉',
    't92': '耶',
    't93': '冷酷',
    't94': '惊惧',
    't95': '灵魂',
    't96': '祈祷',
    't97': '肌肉',
    't98': '礼花',
    't99': '礼物',
    't100': '红包',
  };
}

class Emoji {
  int id;
  String path;
  String text;

  Emoji({this.id, this.path, this.text});
}
