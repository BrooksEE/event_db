/// Only the web build opens its login in a tab of its own.
Future<String?> webLoginPopup(String url, String serverOrigin, Duration timeout) =>
    throw UnsupportedError("webLoginPopup is web only");
