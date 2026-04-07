# H work log - 2026-04-07

## Scope

- Investigated the deployed web register error.
- Focused on `build/web`, token persistence on web, and backend CORS defaults.

## Findings

1. The backend CORS default did not include `http://101.35.25.32`.
2. The web token persistence path used `flutter_secure_storage`, whose web
   implementation depends on Web Crypto APIs and is fragile on HTTP sites.
3. `flutter build web --no-web-resources-cdn` already emits local CanvasKit.
   The remaining `gstatic` string is a Flutter font-fallback path, not a
   hand-written external image/script dependency in this repo.

## Changes

- Added `http://101.35.25.32` to the tracked backend CORS defaults.
- Split token persistence by platform:
  - web: `localStorage`
  - IO/mobile: `flutter_secure_storage`

## Files changed

- `lib/services/token_storage.dart`
- `lib/services/token_storage_platform.dart`
- `lib/services/token_storage_platform_io.dart`
- `lib/services/token_storage_platform_web.dart`
- `backend/.env`
- `backend/.env.example`

## Verification

- Rebuild web with a local API target.
- Start local backend.
- Run `flutter run` and check for obvious display-stage issues.
