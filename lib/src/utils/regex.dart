import 'package:linkfy_text/src/enum.dart';

// String urlRegExp =

// url regex that accept https, http, www
String urlRegExp =
    r'\b((https?:\/\/)?(www\.)?[a-zA-Z0-9-]{2,}\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?(\/[^\s]*)?)';

String hashtagRegExp = r'#[a-zA-Z\u00C0-\u01B4\w_\u1EA0-\u1EF9!$%^&]{1,}(?=\s|$)';

String userTagRegExp = r'@[a-zA-Z\u00C0-\u01B4\w_\u1EA0-\u1EF9!$%^&]{1,}(?=\s|$)';
String phoneRegExp =
    r'\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*';
String emailRegExp =
    r"([a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+)";

/// construct regexp. pattern from provided link types
RegExp constructRegExpFromLinkType(List<LinkType> types) {
  // default case where we always want to match url strings
  final len = types.length;
  if (len == 1 && types.first == LinkType.url) {
    return RegExp(urlRegExp);
  }
  final buffer = StringBuffer();
  for (var i = 0; i < len; i++) {
    final type = types[i];
    final isLast = i == len - 1;
    switch (type) {
      case LinkType.url:
        isLast ? buffer.write("($urlRegExp)") : buffer.write("($urlRegExp)|");
        break;
      case LinkType.hashTag:
        isLast
            ? buffer.write("($hashtagRegExp)")
            : buffer.write("($hashtagRegExp)|");
        break;
      case LinkType.userTag:
        isLast
            ? buffer.write("($userTagRegExp)")
            : buffer.write("($userTagRegExp)|");
        break;
      case LinkType.email:
        isLast
            ? buffer.write("($emailRegExp)")
            : buffer.write("($emailRegExp)|");
        break;
      case LinkType.phone:
        isLast
            ? buffer.write("($phoneRegExp)")
            : buffer.write("($phoneRegExp)|");
        break;
      default:
    }
  }
  return RegExp(buffer.toString());
}

LinkType getMatchedType(String match) {
  late LinkType type;
  if (RegExp(emailRegExp).hasMatch(match)) {
    type = LinkType.email;
  } else if (RegExp(urlRegExp).hasMatch(match)) {
    type = LinkType.url;
  }else if (RegExp(phoneRegExp).hasMatch(match)) {
    type = LinkType.phone;
  } else if (RegExp(userTagRegExp).hasMatch(match)) {
    type = LinkType.userTag;
  }  else if (RegExp(hashtagRegExp).hasMatch(match)) {
    type = LinkType.hashTag;
  }
  return type;
}
