# Receipts Spec — TASK-015

---

## TASK-015 · Receipt Upload + Management

**Purpose:** Upload receipt images/PDFs, store in Supabase Storage, link to transactions. Replaces the "📎 Attach Receipt" placeholder in the transaction form.

---

### Database

No new SQL migration needed — `receipts` table already exists in schema. Fields: `id, org_id, transaction_id (nullable), filename, storage_path, mime_type, size_bytes, uploaded_by, created_at`.

Supabase Storage bucket: `receipts` (already created per TASK-001 schema).

Storage path pattern: `{org_id}/{year}/{month}/{receipt_id}_{filename}`
Example: `abc-123/2026/03/xyz-789_grocery_receipt.jpg`

**pubspec additions:**
- `file_picker: ^8.0.0` — file selection
- `mime: ^1.0.5` — MIME type detection

---

### Receipt Model (Freezed)

File: `lib/features/receipts/models/receipt.dart`

```dart
@freezed
class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    required String orgId,
    String? transactionId,
    required String filename,
    required String storagePath,
    required String mimeType,
    required int sizeBytes,
    required String uploadedBy,
    required DateTime createdAt,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}
```

JSON mapping: `org_id` → `orgId`, `transaction_id` → `transactionId`, `storage_path` → `storagePath`, `mime_type` → `mimeType`, `size_bytes` → `sizeBytes`, `uploaded_by` → `uploadedBy`, `created_at` → `createdAt`

---

### Receipt Filter Model (Freezed)

File: `lib/features/receipts/models/receipt_filter.dart`

```dart
@freezed
class ReceiptFilter with _$ReceiptFilter {
  const factory ReceiptFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? searchText,       // matches filename
    bool? linkedOnly,         // true = only receipts with transactionId
    bool? unlinkedOnly,       // true = only receipts without transactionId
  }) = _ReceiptFilter;
}
```

---

### Service

File: `lib/features/receipts/data/receipt_service.dart`

```dart
class ReceiptService {
  const ReceiptService(this._client);
  final SupabaseClient _client;

  Future<List<Receipt>> fetchReceipts(String orgId, {ReceiptFilter filter = const ReceiptFilter()}) async { ... }
  Future<Receipt> uploadReceipt(String orgId, Uint8List bytes, String filename, String mimeType) async { ... }
  Future<void> linkReceiptToTransaction(String receiptId, String transactionId) async { ... }
  Future<void> unlinkReceipt(String receiptId) async { ... }
  Future<void> deleteReceipt(String receiptId, String storagePath) async { ... }
  Future<String> getDownloadUrl(String storagePath) async { ... }
}
```

`uploadReceipt`:
1. Generate `receiptId = const Uuid().v4()`
2. Parse year/month from `DateTime.now()`
3. Build `storagePath = '$orgId/${now.year}/${now.month.toString().padLeft(2,'0')}/${receiptId}_$filename'`
4. Upload to Supabase Storage: `client.storage.from('receipts').uploadBinary(storagePath, bytes, fileOptions: FileOptions(contentType: mimeType))`
5. Insert row into `receipts` table with `uploaded_by = client.auth.currentUser!.id`
6. Return `Receipt` object

Max file size check before upload: if `bytes.length > 10 * 1024 * 1024`, throw with message "File is too large. Maximum size is 10MB."

`getDownloadUrl`:
- `client.storage.from('receipts').createSignedUrl(storagePath, 3600)` — 1-hour signed URL. Do not cache.

`deleteReceipt`:
1. Delete from storage: `client.storage.from('receipts').remove([storagePath])`
2. Delete from `receipts` table by id

`fetchReceipts` filters:
- Always filter by `org_id = orgId`
- If `startDate`: filter `created_at >= startDate`
- If `endDate`: filter `created_at <= endDate`
- If `searchText`: filter `filename ilike '%$searchText%'`
- If `linkedOnly`: filter `transaction_id IS NOT NULL`
- If `unlinkedOnly`: filter `transaction_id IS NULL`
- Order: `created_at DESC`

---

### Providers

File: `lib/features/receipts/presentation/providers/receipt_provider.dart`

```dart
@Riverpod(keepAlive: true)
ReceiptService receiptService(Ref ref) =>
    ReceiptService(ref.watch(supabaseClientProvider));

@riverpod
Future<String?> receiptsOrgId(Ref ref) async { ... }

@riverpod
Future<List<Receipt>> receipts(
  Ref ref,
  String orgId, {
  ReceiptFilter filter = const ReceiptFilter(),
}) async {
  return ref.read(receiptServiceProvider).fetchReceipts(orgId, filter: filter);
}

@riverpod
class ReceiptController extends _$ReceiptController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Receipt?> pickAndUpload(String orgId) async { ... }
  Future<void> linkToTransaction(String receiptId, String transactionId) async { ... }
  Future<void> unlink(String receiptId) async { ... }
  Future<void> delete(String receiptId, String storagePath) async { ... }
}
```

`receiptsOrgId`: same pattern as existing org ID lookups — query `org_members` for current user, return `org_id`.

`pickAndUpload`:
1. Call `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg','jpeg','png','pdf'], withData: true)`
2. If user cancels (result is null), return null
3. Get `bytes = result.files.single.bytes!`, `filename = result.files.single.name`
4. Detect MIME: `lookupMimeType(filename) ?? 'application/octet-stream'`
5. Call `receiptService.uploadReceipt(orgId, bytes, filename, mimeType)`
6. Invalidate `receiptsProvider(orgId)`
7. Return the new `Receipt`

Run `build_runner` after.

---

### Receipt List Screen

File: `lib/features/receipts/receipts_screen.dart` — layout router (mobile vs desktop)

```dart
class ReceiptsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const ReceiptsMobileScreen()
        : const ReceiptsWebScreen();
  }
}
```

---

### Mobile Layout

File: `lib/features/receipts/layouts/mobile/receipts_mobile_screen.dart`

**Top bar:** "Receipts" title + upload `IconButton` (top right) → calls `ReceiptController.pickAndUpload(orgId)`

**Filter row** (horizontally scrollable chips):
- `All` | `Linked` | `Unlinked` — teal background when active, border when inactive

**Search field** below filter row: expands full width, filters by filename

**Receipt list:**

Each card:
- Left: file type icon — `Icons.image` for jpg/png, `Icons.description` for pdf
- Main: filename (bold, 14px) + upload date (12px muted) below
- File size below date (formatted: KB if < 1MB, MB otherwise)
- Right: `Linked` chip (teal) or `Unlinked` chip (amber) — if linked, show transaction merchant name below chip (12px muted)
- Tap → opens receipt detail bottom sheet

**Receipt detail bottom sheet:**
- Full-width `Image.network` preview (if jpg/png — use signed URL), or `Icons.picture_as_pdf` (large) + filename (if pdf)
- Filename, upload date, file size
- If linked: "Linked to: [merchant name]" row + `OutlinedButton` "Unlink" (calls `ReceiptController.unlink`)
- If unlinked: `ElevatedButton` "Link to Transaction" → opens transaction picker — a searchable list of recent transactions without a receipt attached; selecting one calls `ReceiptController.linkToTransaction`
- `OutlinedButton` "Download" → calls `receiptService.getDownloadUrl` → triggers download via `dart:html` `AnchorElement`
- `TextButton` "Delete" (red) → `AlertDialog` "Delete this receipt?" → calls `ReceiptController.delete` → pop sheet

**Empty state:** `Icons.receipt_long` icon + "No receipts yet" + "Tap the upload button to add your first receipt"

---

### Desktop Layout

File: `lib/features/receipts/layouts/web/receipts_web_screen.dart`

**Toolbar row:**
- Search input (expands left): filters by filename
- Date range pickers: "From" + "To" — filter `startDate` / `endDate`
- Filter dropdown: `All` | `Linked Only` | `Unlinked Only`
- "Upload Receipt" button (teal, right-aligned) → calls `ReceiptController.pickAndUpload(orgId)`

**Table:**

Sticky navy header row. Alternating white/lightGray rows.

| Preview | Filename | Uploaded | Size | Linked To | Actions |
|---|---|---|---|---|---|

- Preview: file type icon (40×40px box) — `Icons.image` for jpg/png, `Icons.description` for pdf. No thumbnail generation.
- Filename: bold
- Uploaded: formatted date
- Size: KB or MB
- Linked To: transaction merchant + date (muted), or "Unlinked" (amber text)
- Actions:
  - `Icons.link` (teal) — opens dialog with searchable transaction list to link/unlink
  - `Icons.download` (teal) — calls `receiptService.getDownloadUrl` → download via `dart:html` `AnchorElement`
  - `Icons.delete_outline` (red) — `AlertDialog` confirmation → calls `ReceiptController.delete`

**Empty state:** single row spanning all columns, centered text "No receipts found"

---

### Transaction Form Integration

File: `lib/features/transactions/presentation/widgets/transaction_form.dart`

Replace the placeholder "Attach Receipt" `OutlinedButton`:

- In edit mode with `existing.receiptId != null`: show `OutlinedButton` "📎 View Receipt" (teal) — tapping opens receipt detail bottom sheet for that receipt
- Otherwise: show `OutlinedButton` "📎 Attach Receipt" (teal) — tapping calls `ReceiptController.pickAndUpload(orgId)` → on success, store the returned `Receipt.id` in a local `String? attachedReceiptId` state variable
- Once attached: show filename below the button (e.g. "grocery_receipt.jpg ✓", 12px muted)
- On save: pass `receiptId: attachedReceiptId ?? (isEdit ? existing.receiptId : null)` into the `Transaction` object

---

### Settings Screen Integration

File: `lib/features/settings/presentation/widgets/settings_editor.dart`

In the data section (desktop layout only), add a storage usage row:
- Label: "Receipts storage:"
- Value: sum all `size_bytes` from `receipts` rows for the org (fetch via `receiptService.fetchReceipts(orgId)`, sum in Dart, convert to MB)
- Display: "X.X MB used"
- No Supabase Storage API call needed — use the `size_bytes` column values

---

## File Map

| File | Task | What |
|---|---|---|
| `lib/features/receipts/models/receipt.dart` | 015 | Freezed model |
| `lib/features/receipts/models/receipt_filter.dart` | 015 | Freezed filter model |
| `lib/features/receipts/data/receipt_service.dart` | 015 | Upload, fetch, delete, link, signed URL |
| `lib/features/receipts/presentation/providers/receipt_provider.dart` | 015 | Riverpod providers |
| `lib/features/receipts/receipts_screen.dart` | 015 | Layout router |
| `lib/features/receipts/layouts/mobile/receipts_mobile_screen.dart` | 015 | Mobile list |
| `lib/features/receipts/layouts/web/receipts_web_screen.dart` | 015 | Desktop table |
| `lib/features/transactions/presentation/widgets/transaction_form.dart` | 015 | Replace placeholder receipt button |
| `lib/features/settings/presentation/widgets/settings_editor.dart` | 015 | Add storage usage display |
| `pubspec.yaml` | 015 | Add `file_picker: ^8.0.0`, `mime: ^1.0.5` |
| `lib/core/routing/app_router.dart` | 015 | No new route needed — receipts accessed from transaction form + settings |

---

## Acceptance Criteria

- [ ] `Receipt` and `ReceiptFilter` Freezed models generate cleanly
- [ ] `build_runner` runs clean
- [ ] File picker opens and allows jpg/png/pdf selection only
- [ ] File size > 10MB shows error "File is too large. Maximum size is 10MB."
- [ ] File uploads to correct Supabase Storage path: `{org_id}/{year}/{month}/{receipt_id}_{filename}`
- [ ] Receipt row inserted in `receipts` table with correct fields
- [ ] Receipt list loads, filtered correctly for all filter combinations
- [ ] Download: signed URL generated, download triggers in browser via `dart:html` `AnchorElement`
- [ ] Link to transaction: updates `transaction_id` on receipt row
- [ ] Unlink: clears `transaction_id`
- [ ] Delete: removes from storage AND database
- [ ] Transaction form "Attach Receipt" button works end-to-end
- [ ] Receipt attached in form is saved with transaction on submit
- [ ] Settings shows storage usage in MB (desktop only)
- [ ] `flutter analyze` — zero issues

---

## Key Rules

- `build_runner` after any `@riverpod` or `@freezed` changes
- Org scope on every query — receipts always scoped to `org_id`
- Storage path must follow pattern: `{org_id}/{year}/{month}/{receipt_id}_{filename}`
- Always use `Uuid().v4()` for receipt IDs (client-generated)
- Signed URLs expire in 1 hour — do not cache them
- On web: use `dart:html` `AnchorElement` for downloads, NOT `url_launcher`
- Max file size: 10MB — check `bytes.length` before upload
- Accepted file types: jpg, jpeg, png, pdf only
- Capture `ScaffoldMessenger` before any `await`
