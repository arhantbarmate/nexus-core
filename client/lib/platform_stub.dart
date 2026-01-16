// platform_stub.dart
// This acts as a shield for non-web platforms (Windows, Android).
// It mimics the structure of dart:js so the app compiles safely.

class MockContext {
  // Matches the signature of the real js.context.callMethod
  void callMethod(String method, [List? args]) {
    // Intentionally empty. 
    // On desktop, we just ignore these calls instead of crashing.
  }
}

// CRITICAL: This must be named 'context' to match dart:js
final MockContext context = MockContext();