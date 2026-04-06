import 'package:linkfy_text/src/enum.dart';

// ✅ Pre-compile một lần duy nhất — không tạo lại mỗi lần gọi
// urlRegExp chỉ dùng để EXTRACT từ văn bản (false positive OK)
// isUrl() sẽ validate lại sau → không cần TLD list phức tạp ở đây
const String _urlPattern = r'(?:(?:https?|ftp):\/\/|www\.)[^\s\n]+'
    r'|(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)'
    r'+(?:com|net|org|io|dev|xyz|tech|ai|app|co|gov|edu|info|biz|me|'
    r'vn|uk|us|ca|au|br|de|fr|jp|cn|ru|sg|hk|tw)[^\s\n]*';

const String _hashtagPattern =
    r'#[a-zA-Z\u00C0-\u01B4\w_\u1EA0-\u1EF9!$%^&]{1,}(?=\s|$)';
const String _userTagPattern =
    r'@[a-zA-Z\u00C0-\u01B4\w_\u1EA0-\u1EF9!$%^&]{1,}(?=\s|$)';
const String _specialPattern = r'&0+&';
const String _phonePattern =
    r'\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*';
const String _emailPattern =
    r"([a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+)";

// ✅ Compile một lần, tái sử dụng mãi
final RegExp _urlRegExp = RegExp(_urlPattern, caseSensitive: false);
final RegExp _hashtagRegExp = RegExp(_hashtagPattern);
final RegExp _userTagRegExp = RegExp(_userTagPattern);
final RegExp _phoneRegExp = RegExp(_phonePattern);
final RegExp _emailRegExp = RegExp(_emailPattern);
final RegExp _specialRegExp = RegExp(_specialPattern);

// ✅ Cache kết quả constructRegExp theo key
final Map<String, RegExp> _regExpCache = {};

RegExp constructRegExpFromLinkType(List<LinkType> types) {
  final cacheKey = types.map((t) => t.index).join(',');
  if (_regExpCache.containsKey(cacheKey)) return _regExpCache[cacheKey]!;

  final len = types.length;
  if (len == 1 && types.first == LinkType.url) {
    return _regExpCache[cacheKey] = _urlRegExp;
  }

  final buffer = StringBuffer();
  for (var i = 0; i < len; i++) {
    final isLast = i == len - 1;
    final pattern = switch (types[i]) {
      LinkType.url => _urlPattern,
      LinkType.hashTag => _hashtagPattern,
      LinkType.userTag => _userTagPattern,
      LinkType.email => _emailPattern,
      LinkType.phone => _phonePattern,
      LinkType.special => _specialPattern,
      _ => null,
    };
    if (pattern != null) {
      buffer.write(isLast ? '($pattern)' : '($pattern)|');
    }
  }

  return _regExpCache[cacheKey] =
      RegExp(buffer.toString(), caseSensitive: false);
}

LinkType getMatchedType(String match) {
  // ✅ Dùng pre-compiled RegExp, không tạo mới
  if (_emailRegExp.hasMatch(match)) return LinkType.email;
  if (isUrl(match)) return LinkType.url;
  if (_phoneRegExp.hasMatch(match)) return LinkType.phone;
  if (_userTagRegExp.hasMatch(match)) return LinkType.userTag;
  if (_hashtagRegExp.hasMatch(match)) return LinkType.hashTag;
  if (_specialRegExp.hasMatch(match)) return LinkType.special;
  return LinkType.url; // fallback
}

bool isUrl(String input) {
  final text = input.trim();
  if (text.isEmpty || text.contains('..') || text.contains(' ')) return false;

  final lower = text.toLowerCase();

  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('ftp://')) {
    return RegExp(r'^(https?|ftp)://[^\s/$.?#][^\s]*$', caseSensitive: false)
        .hasMatch(text);
  }

  if (lower.startsWith('www.')) {
    return RegExp(
      r'^www\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?'
      r'(\.[a-zA-Z0-9]{2,})+([/?#][^\s]*)?$',
      caseSensitive: false,
    ).hasMatch(text);
  }

  if (!text.contains('.')) return false;

  const knownTlds =
      r'com|net|org|io|dev|xyz|tech|ai|app|co|gov|edu|info|biz|me|tv|cc|'
      r'vn|uk|us|ca|de|fr|jp|cn|ru|in|it|es|nl|au|br|kr|mx|ar|cl|sg|hk|tw|nz';

  return RegExp(
    r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+(' +
        knownTlds +
        r')([/?#][^\s]*)?$',
    caseSensitive: false,
  ).hasMatch(text);
}
