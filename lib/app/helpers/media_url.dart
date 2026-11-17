import '../config/constants.dart';
import '../config/environment.dart';

/// Resolves a file path returned by the backend (`/uploads/services/x.png`)
/// into a full, downloadable URL.
///
/// The backend stores paths relative to **its own** origin, so they must be
/// joined with the origin of the API the app is actually talking to
/// (`Environment.baseUrl`, i.e. the `API_BASE_URL` dart-define).
///
/// Using the hardcoded `Constants.imageBaseUrl` instead is what made service and
/// advertisement images fail with `404`: the files were uploaded to the
/// backend the app is connected to, but were then requested from the public
/// website domain, where they do not exist. Offer images always worked because
/// they already went through this resolution.
///
/// Rules:
///  * empty / blank          -> `''` (caller shows its own placeholder)
///  * absolute `http(s)://`  -> returned untouched (old rows may hold a URL)
///  * anything else          -> `<api origin>/<path>` with exactly one slash
String resolveMediaUrl(
  String? raw, {
  String fallbackBase = Constants.imageBaseUrl,
}) {
  final value = (raw ?? '').trim().replaceAll('\\', '/');
  if (value.isEmpty) return '';

  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return value;
  }

  final path = value.startsWith('/') ? value : '/$value';
  return '${mediaOrigin(fallbackBase: fallbackBase)}$path';
}

/// Origin (`scheme://host[:port]`) of the backend the app is configured with.
///
/// Falls back to [fallbackBase] when no `API_BASE_URL` was supplied, so a build
/// without a dart-define still resolves against the public site.
String mediaOrigin({String fallbackBase = Constants.imageBaseUrl}) {
  final raw = Environment.baseUrl.trim();

  if (raw.isNotEmpty) {
    final uri = Uri.tryParse(raw);
    if (uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return uri.origin;
    }
  }

  return fallbackBase;
}
