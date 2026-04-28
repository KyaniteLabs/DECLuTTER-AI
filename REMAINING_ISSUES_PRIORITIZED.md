# Remaining Issues — Sorted by ROI & Leverage

> **Last updated:** 2026-04-28 after PR #36 (provider-agnostic vision adapters + backlog cleanup).
> **Current test state:** 130 backend tests passing, 41 Flutter tests passing, analyzer clean.
> **Backend:** Rate limiting, request size limits, structured logging, and all vision adapters are tested.
> **Flutter:** SQLite persistence, history screen, session summary + CSV export, settings, and valuation UI are all functional.

---

## ✅ Fixed in PR #33 (2026-04-24)

### Tier 0 — Security Critical

| # | Issue | Files | PR #33 Fix |
|---|---|---|---|
| 0.1 | Reflected XSS via `Host` header in `launch.py` | `launch.py` | `html.escape()` on canonical URL replacement; strengthened `_sanitize_host` |
| 0.2 | Basic Auth username not validated | `operator.py` | Username comparison added against expected operator env var |
| 0.3 | Sensitive error disclosure leaks Firebase internals | `dependencies.py` | Generic error messages returned; real errors logged server-side |
| 0.4 | CORS credentials + wildcard origin risk | `main.py`, `settings.py` | Reject `*` in origins when credentials enabled |
| 0.5 | LLM prompt injection via `image_storage_key` | `analysis_adapter.py` | Validation + sanitization before prompt interpolation |
| 0.6 | Event-loop blocking in async endpoints | `analysis.py`, `operator.py`, `seller.py` | `asyncio.to_thread()` wrappers for sync I/O |

### Tier 1 — High ROI

| # | Issue | Files | PR #33 Fix |
|---|---|---|---|
| 1.1 | `list_sessions` N+1 query bomb | `session_store.py` | Single JOIN query replacing looped lookups |
| 1.2 | Public Listing Ownership Bypass | `session_store.py` | Optional `owner_uid` filter added |
| 1.3 | CSV injection in eBay export | `marketplace_ebay_service.py` | Formula-triggering characters sanitized |
| 1.4 | Firebase Admin Init Race Condition | `security/firebase.py` | Module-level `threading.Lock()` wraps `initialize_app()` |
| 1.5 | `list_sessions` Auth Crash = 500 Instead of 401 | `security/dependencies.py`, `main.py` | Default `user_claims` set when `auth_mode=off` |
| 1.6 | `valuation.py` Module-Level Service (Not Thread-Safe) | `api/routes/valuation.py` | Replaced module-level instance with `@lru_cache` factory + `Depends()` |
| 1.7 | Path traversal via symlinks in uploads | `analysis_adapter.py` | `realpath()` resolution + boundary validation |
| 1.8 | Unbounded memory for base64 encoding | `analysis_adapter.py` | 10MB file size caps enforced |
| 1.9 | `setState() after dispose()` in 4 async methods | `session_timer_screen.dart` | `mounted` guards added |
| 1.10 | `setState() after dispose()` in `CaptureScreen` | `capture_screen.dart` | `mounted` guards added |
| 1.11 | `FocusTimer` `setState()` after dispose on resume | `focus_timer.dart` | `mounted` guards added |
| 1.12 | `Timer.periodic` executes after `dispose()` + drift | `focus_timer.dart` | Timer lifecycle cleanup + `_timerTarget` drift fix |
| 1.13 | `FocusTimer` loses state on process death | `focus_timer.dart` | `SharedPreferences` persistence for `_remaining`, `_isRunning` |
| 1.14 | `CashToClearApiClient` no request timeout | `cash_to_clear_api.dart` | 15s `Future.timeout()` on `_requestJson` |
| 1.15 | `CashToClearApiClient` no response size limit | `cash_to_clear_api.dart` | 10MB response/image caps enforced |
| 1.16 | Decision spam bug (same group, infinite decisions) | `session_timer_screen.dart` | Decision deduplication per group |
| 1.17 | `CaptureScreen` silently swallows analysis errors | `capture_screen.dart` | `_analyzeCaptureWithFeedback()` with try/catch + SnackBar |
| 1.18 | Camera disposed on system dialogs | `capture_screen.dart` | `_cameraInitFuture` + `_disposed` lifecycle cleanup |
| 1.19 | `Image.file` re-decodes JPEG on every `setState` | `capture_screen.dart` | `Image.memory` byte caching |
| 1.20 | Timer doesn't pause/reset on completion | `focus_timer.dart` | Timer stops itself at 00:00, clears persisted state |

### Tier 2 — Architectural

| # | Issue | Files | PR #33 Fix |
|---|---|---|---|
| 2.1 | SQLite persistence (sessions survive restarts) | `focus_timer.dart` | `SharedPreferences` for timer state; Drift deferred |
| 2.3 | Backend rate limiting + request size limits | `main.py`, `middleware/` | `RateLimitMiddleware`, `RequestSizeLimitMiddleware` |
| 2.4 | ONNX Runtime abstraction | `detect/services/` | `OnnxDetectionInterpreter` adapter added; `TensorType` enum extracted |
| 2.5 | Backend standardized error handling + request logging | `main.py`, `middleware/` | `RequestLoggingMiddleware` with correlation IDs |

---

## ✅ Fixed in PR #36 (2026-04-28)

| # | Issue | Files | PR #36 Fix |
|---|---|---|---|
| — | Provider-agnostic vision adapters | `analysis_adapter.py` | `OpenAICompatible`, `Anthropic`, `Ollama` adapters + factory |
| — | Adapter factory routing | `analysis_adapter.py` | `create_analysis_adapter_from_env()` with 18 env var aliases |
| — | Factory empty-config bug | `analysis_adapter.py` | Falls back to mock when `base_url`/`model` empty |
| — | Local SQLite persistence | `data/db/`, `data/repositories/` | `SessionDatabase` + `SessionRepository` with full CRUD |
| — | History screen | `history/presentation/` | Lists persisted sessions with stats |
| — | Session controller persistence | `session/presentation/session_controller.dart` | `_persistLocal()` after every decision/undo/valuation |
| — | Runtime backend settings | `settings/services/settings_service.dart` | `SharedPreferences` for `baseUrl`, `idToken`, `appCheckToken` |
| — | Backend analysis service | `detect/services/backend_analysis_service.dart` | Uploads image, runs backend analysis, parses results |
| — | TFLite removal | `pubspec.yaml`, `detect/services/` | `tflite_flutter` dependency and code removed |
| — | Flutter analyzer cleanup | Multiple | Removed unnecessary imports, added `const` constructors |

---

## ✅ Fixed Today (2026-04-28)

| # | Issue | Files | Fix |
|---|---|---|---|
| — | FocusTimer not resetting on "Start New Sprint" | `session_timer_screen.dart` | Call `_focusTimerKey.currentState?.reset()` in `onStartNewSprint` |
| — | History cards not tappable | `history/presentation/history_screen.dart` | `InkWell` wrapper + `_openSessionSummary()` navigation |
| — | Missing Anthropic adapter tests | `tests/test_app.py` | 4 tests: parsing, retry, empty content, headers |
| — | Missing Ollama adapter tests | `tests/test_app.py` | 4 tests: parsing, native format, retry, empty response |
| — | Missing factory routing tests | `tests/test_analysis_adapter_factory.py` | 14 tests: all provider names, fallback logic, env var precedence |

---

## 🔴 TIER 0 — Security Critical (Still Open)

> None remaining.

---

## 🟠 TIER 2 — High Leverage (Architectural)

### 2.2 Extract Presentation Widgets from `SessionTimerScreen`
- **File:** `app/lib/src/features/session/presentation/session_timer_screen.dart` (873 lines)
- **Issue:** Six helper widgets (`_CapturedPhotoPreview`, `_SprintProgressHeader`, `CashToClearStatusCard`, `SessionDecisionComposer`, `SessionDecisionHistory`, `SessionSummaryCard`) are defined in the same file. Purely organizational — all are stateless and already well-factored.
- **Impact:** Code navigation, slightly faster compiles.
- **Effort:** XS (~30 min)
- **Note:** The actual business logic was already extracted to `SessionController` in PR #36. This is cosmetic widget file splitting only.

---

## 🟡 TIER 3 — Medium Impact / Medium Effort (Backlog)

### 3.1 WP4: Decision Card UX Polish
- **Issue:** DecisionCard already has accessibility labels, haptic feedback, and 48dp touch targets. Minor polish: add tooltip to valuation range toggle, improve empty-state copy.
- **Impact:** UX refinement.
- **Effort:** XS (~20 min)

### 3.4 Frontend: Web Compatibility Verification
- **Status:** Web build compiles successfully (`flutter build web` passes). `onnxruntime` Wasm warnings are expected (uses `dart:ffi`, mobile-only). Backend analysis path is functional on web.
- **Impact:** Verified working. No action needed unless switching to Wasm output.

### 3.5 Backend: Test Coverage
- **Status:** 130 tests passing. Coverage gaps: `valuation_service.py` (has some tests in test_app.py), `listing_drafts.py`, `public_listings.py` HTML rendering.
- **Impact:** Regressions in listing generation and pricing logic go undetected.
- **Effort:** S (~2-3 hours)

### 3.8 Backend: Signed-Upload Session is Non-Functional
- **File:** `server/app/api/routes/analysis.py`
- **Issue:** `create_intake_session` returns a signed upload stub, but `intake_image` ignores the session token entirely and writes to a fresh UUID path.
- **Fix:** Either wire the session token through intake validation, or remove the stub endpoint.
- **Effort:** S (~1 hour)

### 3.9 Frontend: `CaptureScreen` Photo File Race Condition
- **Status:** Already fixed in current code. File is copied to `declutter_capture_$timestamp.jpg` in app temp directory before passing to `SessionTimerScreen`.

### 3.10 Backend: `analysis_adapter.py` Payload Retry Loses Original Errors
- **Status:** Already fixed. All three adapters collect errors in a list and raise a compound `RuntimeError` with all attempts.

---

## 🔵 TIER 4 — Strategic / Post-MVP

### 4.1 On-Device Vision (Optional Future)
- **Status:** Deferred. Backend-primary for ALL platforms. Mobile may later get optional on-device YOLO/MobileNet for fast offline detection (NOT VLM).
- **Note:** Moondream 2 is not viable (no Flutter SDK, proprietary format, abandoned mobile attempts). ONNX Runtime mobile-only via `flutter_onnxruntime_genai` for Phi-3.5 Vision is the only path, requires flagship hardware.

### 4.2 WP7: Self-Hosted Server Mode
- **Impact:** Power-user feature, privacy-first server option.
- **Effort:** M (2-3 days)

### 4.3 WP8: Full Test Suite, Polish, Empty States
- **Impact:** Ship-quality bar.
- **Effort:** M (2-3 days)
- **Current gap:** Need widget tests for history screen navigation, capture screen file persistence.

### 4.4 Multi-Photo Sessions & Zone Memory
- **Impact:** Post-MVP feature per spec §14.
- **Effort:** L (1-2 weeks)

---

## Summary: What to Do Next

1. **Today (30 min):** Split `SessionTimerScreen` helper widgets into separate files (cosmetic, unlocks nothing but cleanliness).
2. **This Week:** Add tests for `valuation_service.py`, `listing_drafts.py`, and `public_listings.py` routes.
3. **Before Ship:** Either wire or remove the signed-upload session stub (3.8).
4. **Post-MVP:** On-device vision, multi-photo sessions, self-hosted server mode.

The app is now **functionally complete for MVP**. Core loop works: capture → analyze → decide → summary → CSV → history. Backend is secured, rate-limited, and tested. All vision providers are supported.
