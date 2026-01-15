class _JsContext {
  bool hasProperty(String name) => false;
  _JsObject operator [](String name) => _JsObject();
}
class _JsObject {
  void callMethod(String method, [List<dynamic>? args]) {}
  dynamic operator [](String name) => null;
}
final context = _JsContext();