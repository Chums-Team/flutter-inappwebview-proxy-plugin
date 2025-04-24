import 'package:http/http.dart';

final domainRegexp = RegExp(r'.+\.([0-9a-zA-Z]+)$');

bool useProxy(final String host, final List<String> domains) {
  final domain = domainRegexp.firstMatch(host)?.group(1);
  return domain != null && domains.contains(domain);
}

List<String> responseContentTypeItems(Response response) {
  final contentTypeHeader = response.headers['content-type'];
  return contentTypeHeader != null
      ? contentTypeHeader
      .split(';')
      .map((i) => i.trim())
      .toList(growable: false)
      : [];
}

String responseContentType(Response response) {
  final contentTypeItems = responseContentTypeItems(response);
  return contentTypeItems.isNotEmpty ? contentTypeItems[0] : '';
}

String responseContentEncoding(Response response) {
  final contentTypeItems = responseContentTypeItems(response);
  return contentTypeItems.length > 1 ? contentTypeItems[1] : 'utf-8';
}
