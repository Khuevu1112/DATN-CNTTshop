# Admin Product Management Overhaul — Implementation Plan

## Path correction (verified against working tree)

The survey referenced `Frontend cho admin springboot/admin-vue/...`. The actual current working-tree
location (confirmed via `git status` — this is an uncommitted repo restructure already in progress) is:

- Admin frontend: `D:\STUDY\CNTTShop_Merged\admin-vue\...` (NOT nested under "Frontend cho admin springboot")
- Customer frontend: `D:\STUDY\CNTTShop_Merged\cnttshop-vue\...` (the copy under "PC va laptop ban hang/cnttshop-vue" is a stale/different tree — do not touch it)
- Backend: `D:\STUDY\CNTTShop_Merged\src\main\java\com\fpoly\...` (unchanged from survey)
- Database migrations: `D:\STUDY\CNTTShop_Merged\database\...`, confirmed latest is `48_trim_spec_keys.sql`

All file paths below use the corrected locations. All other survey details were verified accurate against
the actual files (line numbers shift slightly release to release but content/structure matches).

---

## Cross-cutting technical findings from verification (not in original survey)

1. **`ProductCard.vue` and `DetailView.vue`'s gallery are pure CSS-gradient placeholders** — neither renders
   a real `<img>` tag today; the "photo" area is a decorative hue-tinted gradient with category-initial text
   and a "[ ANH SAN PHAM ]" caption. `CartView.vue` is the only place in cnttshop-vue that renders a real
   `<img v-if="line.imageUrl">`. This means requirement #5's "confirm DetailView.vue has a fallback" has
   nothing to attach to yet — there's no `<img>` consuming `ImageDto`/`imageUrl` there at all. The plan below
   adds a minimal real `<img>` element to the gallery (using the already-correct `pickImageUrl` fallback
   backend logic) since that's the only way "fallback to first image" can mean anything concretely on that
   page. This is a small, additive, in-scope fix, not a new initiative — flagged explicitly in the plan.
2. **`CatalogApiService.pickImageUrl()` (`src/main/java/com/fpoly/service/CatalogApiService.java:243-249`)
   already has the correct fallback** (if any image isPrimary=true, use it; else images.get(0)) — confirmed
   exactly as surveyed. No backend change needed there. The only server-side gap is in `AdminProductService`
   at save time (never enforces exactly-one-primary on write).
3. **The admin product list (`PRODUCTS` in `admin-vue/src/data/adminData.js`) already carries `catSlug`
   per product**, loaded once via `getAdminProducts()` / `refreshAdminProducts()`. This means requirement #2's
   "candidate products restricted to `ngoai-vi` category" can be done with a pure client-side `computed` filter
   over the already-loaded `PRODUCTS` store — no new backend endpoint is required.
4. **Categories are loaded with `.slug` already** (`CategoryDto(id, name, slug, imageUrl, sortOrder)` via
   `/api/categories`, consumed as `getCategories()` in admin.js). `ProductFormModal.vue`'s `form.categoryId`
   plus the already-fetched `categories` array is enough to resolve "current category's slug" for requirement
   #6's preset-key map — no new field/endpoint needed.
5. **Customer-facing variant/option matching today** (`cnttshop-vue/src/data/products.js`):
   - `loadDetail(p)` builds `p.cfg` = array of `{ key, label, ch: [{ l, d }] }` per option group, where `d`
     (price delta) is computed by finding the cheapest variant that has that value, **independently per
     option-value, with no notion of which other option-values are actually co-selected**. This is the exact
     code that must change for requirement #7.
   - `resolveVariantId(p, sel)` finds the variant whose `_variants[].options` map (keyed by **option name**,
     not id) matches every selected group's label value. This already does the right kind of matching; the
     new filtering logic needed for #7 is structurally very similar (just needs to run progressively/reactively
     as `state.cfgSel` changes, restricted to "linked" groups) rather than only at cart-add time.
   - Backend's `VariantDto.options` (`CatalogDtos.java`) is `Map<String,String>` of optionName -> value, built
     in `CatalogApiService.getProductBySlug()` (line ~128-134) from `variant.getOptionValues()`. This is
     already sufficient data for client-side cross-filtering — no DTO shape change needed for the customer
     detail API, only for the *admin* save/detail DTOs (which need the new linked flag).
6. **Migration numbering**: next available is `49_...sql`. Existing pattern for additive columns
   (`database/13_product_extras.sql`) uses the idempotent style:
   ```sql
   IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='X' AND COLUMN_NAME='y')
       ALTER TABLE X ADD y ... ;
   GO
   ```
   Follow this exact style for the new migration.

---

## Requirement #7 — Core architectural piece (design first, since #4's UI copy and #7's UX interlock)

### Decision: boolean `linked` flag directly on `PRODUCT_OPTION`, no separate `link_group_id`

Reasoning: the requirement only asks for a binary per-group state ("locked together" vs "independent"), and
critically, "locked together" is defined *relative to every other linked group simultaneously* — i.e. there's
effectively only ever one "linked set" per product in the UX described (admin manually pairs values across
*all* linked groups together when creating a variant row; independent groups auto-cross against the result).
A `linkGroupId` would only add value if a single product could have *two separate* linked clusters that don't
cross-constrain each other (e.g. "CPU+GPU" locked as one cluster, and separately "Color+Case-material" locked
as another, unrelated cluster) — the requirement doesn't ask for that, and speculatively building it adds
schema/UX complexity with no current use case. A plain boolean is simpler, matches "explicit per-option-group
toggle," and is trivially forward-compatible: if multi-cluster linking is ever needed later, `linked BOOLEAN`
can be widened to `link_group_id INT NULL` (NULL = independent, shared int = same cluster) as a follow-up
migration without touching unrelated tables.

**New column: `PRODUCT_OPTION.is_linked BIT NOT NULL DEFAULT 0`**
(Naming matches existing `is_required`/`is_visible` convention in the same table — see
`src/main/java/com/fpoly/model/ProductOption.java:34-38`.)

Default `0` (independent) exactly preserves today's behavior for every existing option group — this is the
explicit "safe no-op default" requested. No backfill data migration needed beyond the `DEFAULT 0` on `ALTER
TABLE ADD`.

### Migration file: `database/49_option_link_group.sql`

```sql
-- 49_option_link_group.sql
-- Cho phep admin danh dau 1 nhom Option la "khoa cung" (is_linked=1) voi cac nhom khac duoc
-- danh dau is_linked=1 tren cung san pham — admin phai khai bao thu cong to hop gia tri hop le
-- giua cac nhom khoa cung khi tao bien the; nhom khong khoa (is_linked=0, mac dinh) van duoc
-- tu dong nhan cheo (cross-product) voi moi nhom khac nhu hanh vi hien tai.
USE ShopDB;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='PRODUCT_OPTION' AND COLUMN_NAME='is_linked')
    ALTER TABLE PRODUCT_OPTION ADD is_linked BIT NOT NULL DEFAULT 0;
GO
```

Safe/no-op for existing data: every existing `ProductOption` row gets `is_linked=0` — i.e. "independent" —
which is precisely today's implicit behavior (options are freely cross-combined by whatever variants the
admin manually typed; the customer picker treats every group as always-fully-selectable). No functional
change to any existing product until an admin explicitly opts a group into `is_linked=1`.

### Entity change: `src/main/java/com/fpoly/model/ProductOption.java`

Add field + getter/setter, following the exact style of the adjacent `required`/`visible` fields:

```java
@Column(name = "is_linked")
private Boolean linked = false;
...
public Boolean getLinked() { return linked; }
public void setLinked(Boolean linked) { this.linked = linked; }
```

### DTO changes: `src/main/java/com/fpoly/dto/AdminProductDtos.java`

Add `Boolean linked` to `OptionRequest` (both request-in and response-out reuse this same record, matching
existing pattern where `OptionRequest` doubles as both save-payload and detail-payload shape):

```java
public record OptionRequest(
        Integer id,
        String optionName,
        String selectionType,
        Integer minSelect,
        Integer maxSelect,
        String description,
        Boolean required,
        Boolean visible,
        Boolean linked,        // NEW
        Integer sortOrder,
        List<OptionValueRequest> values
) {}
```

No change needed to `VariantRequest` — variants still resolve via `optionValueKeys` exactly as today; `linked`
only affects *admin-side variant generation UX* and *customer-side picker filtering logic*, not the persisted
variant-to-option-value linkage shape itself.

### Service changes: `src/main/java/com/fpoly/service/AdminProductService.java`

In `saveOptions()` (lines ~317-364), when building the `ProductOption` entity, add:

```java
option.setLinked(Boolean.TRUE.equals(req.linked()));
```

In `getDetail()` (lines ~192-201), when mapping `ProductOption` -> `OptionRequest`, add `o.getLinked()` as the
new positional argument matching the DTO's new field order.

No change needed to `saveVariants()` — it's agnostic to linked/independent; it just resolves whatever
`optionValueKeys` each submitted `VariantRequest` carries. The *generation* of which `VariantRequest` rows to
submit is entirely an admin-vue client-side concern (see below) — the backend keeps its existing "trust
whatever variant list you're given" contract.

### Admin UX: `admin-vue/src/components/ProductFormModal.vue` — Options section (~lines 150-169) and Variants section (~lines 99-110)

1. Add a per-option-group checkbox/toggle "Khoa cung nhom khac" (bind to a new `o.linked` field on each
   `form.options[oi]` object; default `false` via `addOption()`'s pushed object literal — add `linked: false`
   there).
2. Add a **"Sinh bien the tu Tuy chon"** button below the Options section, before the (renamed, see #4 below)
   Variants section. Clicking it runs a pure client-side generation helper (new function, e.g.
   `generateVariantRows()`, colocated in `<script setup>`):
   - Partition `form.options` (that have `optionName` and at least 1 non-blank value) into `linkedGroups`
     (`o.linked === true`) and `independentGroups` (`o.linked !== true`).
   - If `linkedGroups.length <= 1`: no cross-group locking is actually needed (locking is meaningless with 0
     or 1 linked group) — treat as if there are zero linked groups, i.e. skip straight to full cross-product
     of all groups (independent + the lone "linked" group, if any) exactly like today's manual-typing baseline.
   - If `linkedGroups.length >= 2`: **do not auto-generate combinations across linked groups.** Instead,
     render an inline mini-table/picker UI: for each linked group, a `<select>` of its values; a "Them to hop"
     button appends one row `{ [group1]: selectedValueClientKey, [group2...]: ... }` to a
     `linkedCombos` working array the admin builds up value-combination by value-combination (this exactly
     mirrors "manually pick the paired values when creating each variant row spanning those linked groups,"
     scoped only to the linked groups). Each confirmed row in this mini-table becomes one "anchor" combination.
   - For every anchor combination from `linkedCombos` (or, if 0 or 1 linked groups, a single implicit anchor
     with no linked-group constraint), cross-product it against every independent group's values (standard
     cartesian product) to produce the full set of `VariantRequest`-shaped rows, each carrying the full set of
     `optionValueKeys` (linked group's chosen clientKeys + independent groups' clientKeys for that
     cartesian slot).
   - Push all generated rows into `form.variants` (dedup against any manually-typed rows the admin might have
     already added, keyed by the sorted `optionValueKeys` set, to avoid double-adding on repeated clicks) with
     `price`/`originalPrice`/`stock` left blank/0 for the admin to fill in (this is exactly why requirement #4
     renames the section — the admin's remaining manual work per row becomes "set price/stock", not "define
     which options this row represents").
   - This generation is a convenience/pre-fill helper only — the admin can still freely add/edit/delete rows
     in the resulting list afterward (existing `addVariant()`/`splice()` controls untouched), matching "same as
     full manual entry today" for anything the generator doesn't cover well (e.g. an admin wanting an oddball
     variant with a subset of option values).

3. Edge case — **toggling a group from independent to linked, or vice versa, after variants already exist**:
   the generator is opt-in (a button, not automatic-on-every-render), so flipping the toggle does *not* by
   itself touch `form.variants` — existing rows are left exactly as-is until the admin explicitly re-clicks
   "Sinh bien the" (and even then, existing rows are only *appended to*, never deleted, per the dedup-by-key
   rule above — the admin must manually remove any now-stale rows with the existing trash-can button). Flag
   this behavior in the UI copy under the button (e.g. small muted-text hint: "Chi them bien the moi, khong
   xoa bien the da co — hay tu xoa dong khong con phu hop").
4. Edge case — **admin deletes an `OptionValue` that's referenced by an existing (already-saved) variant**:
   this risk pre-dates #7 (it's inherent to the existing free-form join table), but #7 makes it more likely to
   surface because generation encourages bulk variant creation. Behavior today: `update()` clears all options
   and their values and resaves whatever's in the request (`AdminProductService.java:118-121`,
   `optionValueRepo.deleteByOptionId`), then `saveVariants()` resolves `optionValueKeys` against the freshly
   rebuilt `valueByKey` map — any `clientKey` (old `"v{id}"` form) that no longer exists in the new option
   payload simply resolves to `null` and is silently skipped, so the variant would end up with a *shrunken*
   `optionValues` list, not an error. This is a pre-existing latent bug independent of #7, but #7's plan should
   **not silently worsen it** — recommend (soft, not required for #7's core scope, call out as a follow-up):
   client-side validation in `save()` that warns if any `form.variants[].optionValueKeys` entry no longer
   resolves to a value present in `form.options[].values[].clientKey` before submitting, so the admin sees the
   problem instead of the variant quietly losing its option association. Flagged as a spawn-off task
   candidate, not blocking #7.

### Customer-facing: `cnttshop-vue/src/data/products.js` — `loadDetail()` (lines ~290-318) and `resolveVariantId()` (lines ~320-335)

Backend needs one small addition first: **`OptionDto` needs a `linked` boolean** so the frontend knows which
groups to cross-filter. Add to `CatalogDtos.java`:

```java
public record OptionDto(
        String name,
        Boolean linked,   // NEW
        List<String> values
) {}
```

And in `CatalogApiService.getProductBySlug()` (~line 114-123), when building `OptionDto`, pass
`o.getLinked()`.

Then in `cnttshop-vue/src/data/products.js`, `loadDetail()`'s `cfg` construction needs `linked` carried
through:

```js
const cfg = (d.options || []).map((o) => ({
  key: slugifyKey(o.name) || o.name,
  label: o.name,
  linked: !!o.linked,   // NEW
  ch: (o.values || []).map((val) => { /* unchanged price-delta calc */ }),
}));
```

**New helper function (colocated in `products.js`, exported for `DetailView.vue` to use)**:
`availableChoicesFor(p, sel, groupKey)` — given the product, the current full selection map `sel`, and the
option-group being rendered, returns the subset of that group's choice-indices that are actually selectable:

```js
export function availableChoicesFor(p, sel, groupKey) {
  const group = (p.cfg || []).find((g) => g.key === groupKey);
  if (!group) return [];
  if (!group.linked) return group.ch.map((_, idx) => idx); // independent: unchanged, all always enabled

  const linkedGroups = (p.cfg || []).filter((g) => g.linked);
  // Build "already selected" values for every OTHER linked group (not this one)
  const otherSelLabels = {};
  linkedGroups.forEach((g) => {
    if (g.key === groupKey) return;
    const idx = sel[g.key] || 0;
    otherSelLabels[g.label] = g.ch[idx] ? g.ch[idx].l : null;
  });

  return group.ch
    .map((c, idx) => idx)
    .filter((idx) => {
      const candidateLabel = group.ch[idx].l;
      // A choice is available iff at least 1 real variant exists whose options match
      // this candidate value AND every other linked group's currently-selected value.
      return (p._variants || []).some((v) => {
        if (!v.options) return false;
        if (v.options[group.label] !== candidateLabel) return false;
        return Object.entries(otherSelLabels).every(
          ([lbl, val]) => val == null || v.options[lbl] === val,
        );
      });
    });
}
```

This reuses the exact same `v.options[label] === value` matching idiom already established in
`resolveVariantId()` (line ~331-333) — no new matching strategy invented, just applied progressively per
render instead of once at "add to cart" time.

### Customer-facing: `cnttshop-vue/src/views/DetailView.vue` — `cfgGroups` computed (lines ~40-60) and template (~369-405)

`cfgGroups` computed needs to attach, per choice, whether it's currently disabled:

```js
const cfgGroups = computed(() => {
  if (!sp.value) return [];
  return (sp.value.cfg || []).map((g) => {
    const availableIdxs = g.linked ? availableChoicesFor(sp.value, state.cfgSel, g.key) : null;
    return {
      key: g.key,
      label: g.label,
      choices: g.ch.map((c, idx) => {
        const on = (state.cfgSel[g.key] || 0) === idx;
        const disabled = availableIdxs != null && !availableIdxs.includes(idx);
        return {
          idx,
          label: c.l,
          deltaText: c.d === 0 ? 'Tieu chuan' : '+' + fmt(c.d),
          disabled,
          bdr: on ? accent.value : 'rgba(var(--line-rgb),0.18)',
          bg: on ? 'color-mix(in srgb, ' + accent.value + ' 14%, transparent)' : 'var(--card2)',
          lblColor: disabled ? 'var(--muted)' : (on ? 'var(--text)' : 'var(--muted2)'),
          dColor: on ? accent.value : 'var(--muted)',
        };
      }),
    };
  });
});
```

Template change (~line 376-403): add `:style="{ opacity: ch.disabled ? 0.35 : 1, pointerEvents: ch.disabled ? 'none' : 'auto', cursor: ch.disabled ? 'not-allowed' : 'pointer' }"` to the choice `<div>`, and guard the
`@click="actions.setCfg(g.key, ch.idx)"` handler (either via the `pointer-events:none` above, or an explicit
`v-if`/early-return in the handler) so a disabled choice cannot be selected. This satisfies "disabling/hiding
dead-end combinations" — disabling (rather than hiding) is preferable here so the admin/customer can see what
combinations *would* exist if they changed their other linked selection, matching typical e-commerce variant
picker UX (grayed-out, not vanished).

**Also needs**: when a linked group's currently-selected choice becomes unavailable because the user just
changed a *different* linked group, `actions.setCfg` (in `cnttshop-vue/src/store.js`) should snap the
now-invalid group to its first still-available choice. This requires checking `store.js`'s `setCfg`
implementation before finalizing — flagged as a needed verification/adjustment when implementing (the current
`setCfg` almost certainly just does `state.cfgSel[key] = idx` with no cross-group awareness, since today no
groups ever constrain each other).

**Specs table row** (`specRows` computed, lines ~62-68) already does per-choice-label substitution keyed by
matching `g.label === r.k`, so it needs no change — it will automatically reflect whatever `state.cfgSel`
lands on after the above filtering/snapping logic runs.

---

## Requirement #1 — Redesign the 440px detail modal into a spacious DetailView-mirroring modal

### File: `admin-vue/src/views/Products.vue`

Replace the `detail` modal block (lines ~377-659) with a wider modal (`max-width: 1100px`-`1200px` is
reasonable — roomy without needing horizontal scroll on a typical admin monitor, comfortably fits a 2-col
image+info layout like `DetailView.vue`). The existing detail modal's data source (`detail.value = p` set by
the table row's `@click="detail = p"`, where `p` comes from the flattened `PRODUCTS`/`mapProduct()` shape) is
**insufficient** for a DetailView-mirroring layout — that shape has no images/promotions/specs/config-options,
only the flattened list-row fields (`name/sku/spec/price/stock/cat/brand/active`).

**Required change**: `openDetail(p)` (rename from the inline `@click="detail = p"`) must instead call
`getAdminProductDetail(p.id)` (already exists in `admin-vue/src/api/admin.js:19`, same endpoint
`ProductFormModal.vue` already uses for edit-prefill) to fetch the full `AdminProductDetailDto` (images,
specs, promotions, options+values, variants, bundleProductIds), then render sections modeled after
`cnttshop-vue/src/views/DetailView.vue`:
  - Image gallery + thumbnails (using `detail.images`, primary-first — reuse the same "first image or none"
    display logic being added to `DetailView.vue`'s gallery per the cross-cutting finding above)
  - Brand/title header
  - Price card (derive from `detail.variants` — cheapest price similar to how `products.js`'s `loadDetail`
    computes `basePrice`)
  - Description (rendered via the shared parser from requirement #3, not raw text)
  - Promotions list (`detail.promotions`)
  - "Cau hinh" (renamed per #6) / config-options **read-only** display: reuse the same group/choice rendering
    as `DetailView.vue`'s picker but without click handlers — just list each group's label and every value
    (with priceExtra shown as "+X" chip), no selection state
  - Specs table (`detail.specs`)
  - Bottom action row: replace "Them vao gio"/"Mua ngay" with **"Chinh sua"** (calls existing
    `openEdit(detail)` -> opens `ProductFormModal`) and **"Xoa"** (calls existing `confirmRemove(detail)`) —
    both handlers already exist in the current `<script setup>` (lines ~693, ~702) and need no logic change,
    only re-wiring to the new modal's buttons.

Given the data-shape mismatch, it's cleaner to introduce a small local `ref` (e.g. `detailFull`) populated by
a new `async function openDetail(p)` that sets `detail.value = p` (kept, for quick header display while
loading) and fetches+stores the full DTO into `detailFull.value`, with a loading spinner state while the fetch
is in flight (mirroring the `loading` pattern already used in `ProductFormModal.vue`).

**Alternative considered and rejected**: extending `mapProduct()` in `adminData.js` to eagerly fetch full
detail for every product in the list. Rejected because that would mean N+1 detail fetches on every products
list load — the current on-demand fetch (already what `ProductFormModal.vue` does for edit) is the right
pattern to reuse, not replace.

---

## Requirement #2 — Widen `ProductFormModal.vue`; redesign Bundle section

### File: `admin-vue/src/components/ProductFormModal.vue`

1. **Widen modal**: change line ~20's `max-width: 760px` to something like `1100px` (matches the widened
   detail modal from #1 for visual consistency across the two "big admin modals").

2. **Replace the Bundle section** (lines ~171-178, the native `<select multiple>`) entirely:
   - **Candidate restriction**: `const peripheralProducts = computed(() => PRODUCTS.filter(p => p.catSlug === 'ngoai-vi' && p.id !== props.productId))` — reusing the already-loaded `PRODUCTS` store from
     `adminData.js` (per the cross-cutting finding — no new backend call needed). Replaces today's
     `otherProducts` computed (line 220) for bundle purposes specifically (keep `otherProducts` if anything
     else in the file still needs the unfiltered list — currently nothing else does, so it can likely be
     removed/renamed outright, but verify no other usage before deleting).
   - **Horizontally-scrollable candidate row**: a flex row (`overflow-x: auto; display:flex; gap:10px`) of
     small cards, each showing product name (truncated) + a checkbox/tick overlay bound to
     `form.bundleProductIds.includes(p.id)`, toggling via a helper `toggleBundle(id)` that pushes/splices
     `form.bundleProductIds`.
   - **Search input with autocomplete**: a text `<input>` bound to a local `bundleSearch` ref; a `computed`
     `bundleSearchResults` filters `peripheralProducts` by case-insensitive substring match on `.name` (mirror
     the existing `matchesQuery`-style substring approach already used elsewhere, but simpler since it's a
     single term here, not the `|`-OR keyword syntax from `cnttshop-vue/src/data/products.js`). Render results
     as a dropdown list below the input (only when `bundleSearch` is non-empty and results exist), each row
     clickable to call the same `toggleBundle(id)` — this lets the admin add a peripheral product that isn't
     currently visible in the scroll row (e.g., because the row only renders first N or the admin scrolled
     past it) without needing to physically scroll to find it.
   - Selected items remain visually indicated in the scroll row (checked state) even after being added via
     search, since both write to the same `form.bundleProductIds` array — no separate "selected list" state
     needed, avoiding state-sync bugs between two representations of the same selection.
   - Keep the `otherProducts`/native-select fallback removed entirely — no reason to keep both UIs per the
     requirement ("Replace the current native `<select multiple>` entirely").

3. No backend/DTO changes needed for #2 — `bundleProductIds: Integer[]` round-trip is unchanged;
   `saveBundles()` in `AdminProductService.java` (lines ~303-314) already accepts any product id list with no
   category constraint server-side (the restriction is a UX-layer candidate-list filter only, matching how the
   requirement is scoped — it doesn't ask for server-side enforcement that bundle targets must be peripherals,
   only that the *admin's picker* only shows peripherals as candidates).

---

## Requirement #3 — Description: larger textarea, most prominent section, lightweight bullet/line-break parsing

### Design decision: shared plain-text-with-markup-conventions approach, stored value unchanged

- Admin types `- ` at line-start for a bullet, plain `Enter` for a line break. **Stored value stays exactly
  the same plain `NVARCHAR(MAX)` text** (`Product.description`, `ProductSaveRequest.description`,
  `AdminProductDetailDto.description`) — no schema change, no new column, no markup language to learn beyond
  "start a line with `- `". This is deliberately the same mental model as GitHub/Markdown bullets, minimizing
  admin retraining, while being trivial to parse without a library.

### New shared parsing utility

Since both `admin-vue` and `cnttshop-vue` are **separate Vue apps/npm projects** (no shared package/workspace
between them — confirmed by each having its own `package.json`/`node_modules`), a literal shared-import file
isn't possible without a monorepo-package restructure (out of scope). Instead: implement the **same small,
self-contained parsing function twice**, once per app, in near-identical form, each colocated with that app's
existing small-utility module:

- **`cnttshop-vue/src/data/products.js`**: add an exported `parseDescription(text)` near the other formatting
  helpers (`fmt`, `silverTokensFor`) since this file is already the established home for small display-format
  helpers consumed by `DetailView.vue`.
- **`admin-vue/src/data/adminData.js`**: add the identical `parseDescription(text)` alongside `money`/`short`
  (same rationale — established home for small formatting helpers in that app).

```js
/** Chuyen mo ta dang text thuan (dong bat dau bang "- " = gach dau dong, Enter = xuong dong) thanh mang
 * block de render <p>/<ul><li> that thay vi 1 doan van phang. Khong can thu vien markdown ngoai. */
export function parseDescription(text) {
  if (!text) return [];
  const lines = String(text).replace(/\r\n/g, '\n').split('\n');
  const blocks = [];
  let currentList = null;
  for (const raw of lines) {
    const line = raw.trimEnd();
    const bulletMatch = line.match(/^\s*-\s+(.*)$/);
    if (bulletMatch) {
      if (!currentList) { currentList = { type: 'ul', items: [] }; blocks.push(currentList); }
      currentList.items.push(bulletMatch[1]);
    } else {
      currentList = null;
      if (line.trim() === '') {
        blocks.push({ type: 'br' });
      } else {
        blocks.push({ type: 'p', text: line });
      }
    }
  }
  return blocks;
}
```

Render side (in both `DetailView.vue`'s description paragraph, lines ~312-321, and the new admin detail
modal's description section from #1) replaces the flat `<p>{{ detail.desc }}</p>` with:

```html
<template v-for="(b, i) in parseDescription(detail.desc)" :key="i">
  <p v-if="b.type === 'p'" style="...same p styling as before...">{{ b.text }}</p>
  <ul v-else-if="b.type === 'ul'" style="margin: 0 0 12px; padding-left: 20px">
    <li v-for="(it, j) in b.items" :key="j" style="font-size:14px; line-height:1.65; color: var(--muted2)">{{ it }}</li>
  </ul>
  <div v-else style="height: 8px"></div>
</template>
```

This is preferable to the alternative "CSS `white-space: pre-line` + bullet-line detection via `::before`"
approach mentioned as an option in the requirement, because CSS alone cannot restructure `- item` lines into
a real `<ul><li>` (screen-reader/semantic correctness, and consistent bullet glyph/indent across browsers) —
parsing into real block elements is strictly better and barely more code.

### Admin form change: `admin-vue/src/components/ProductFormModal.vue`

- Move the description block (currently lines ~72-73, `<textarea rows="3">`) to be the visually largest/most
  prominent section. Concretely: keep it directly below name/slug (already near-top, good position — no need
  to relocate vertically), but change `rows="3"` to something like `rows="8"` or `min-height: 180px` with
  `resize: vertical`, and add a small live-preview panel beside/below it rendering
  `parseDescription(form.description)` through the same block-renderer, so the admin can see bullets/line
  breaks forming in real time (nice-to-have, cheap given the parser already exists — recommend including
  since it directly de-risks "admin typed the convention wrong and doesn't find out until viewing the live
  customer page").
- No DTO/service change — `form.description` round-trips as plain text exactly as today
  (`payload.description: form.description` at `ProductFormModal.vue` line ~305 unchanged).

---

## Requirement #4 — Rename "Bien the" section label (UI-only reframing)

### File: `admin-vue/src/components/ProductFormModal.vue`

Line ~101: change

```html
<span>Bien the (gia / kho hang) *</span>
```
to something like
```html
<span>Uu dai / Giam gia &amp; so luong con *</span>
```
(exact Vietnamese copy left to final polish, but must communicate: this row-per-variant editor is now where
the admin sets promotional price + remaining stock per option-combination, not where they *define* the
combination itself — that's now driven by requirement #7's generator). Optionally also update each row's
placeholder text (`v.price`/`v.originalPrice` inputs, lines ~106-107) from generic "Gia ban"/"Gia goc" to
something reflecting "gia khuyen mai"/"gia niem yet" if desired, though the requirement's core ask is just the
section header. No data-model change — `ProductVariant` entity, `VariantRequest` DTO, and all service logic
are explicitly untouched per the requirement.

Recommend placing this rename together with the #7 generator-button addition in the same edit, since the new
copy only makes sense once the generator exists above it (otherwise the label change reads as confusing on its
own for an admin who hasn't seen #7 yet, if these two requirements were ever deployed non-atomically — flag
this dependency: **#4 depends on #7 shipping in the same release**, not an independent standalone change).

---

## Requirement #5 — Enforce/default primary image; verify client fallbacks

### Backend: `src/main/java/com/fpoly/service/AdminProductService.java` — `saveImages()` (lines ~260-272)

Add enforcement right before/within the loop, so the very first image request always gets guaranteed onto a
non-zero-primary path, and at most one image ends up primary even if the incoming payload has multiple:

```java
private void saveImages(Product product, List<ImageRequest> images) {
    if (images == null) return;
    boolean hasPrimary = images.stream().anyMatch(i -> Boolean.TRUE.equals(i.isPrimary()));
    boolean primaryAssigned = false;
    int i = 0;
    for (ImageRequest req : images) {
        ProductImage img = new ProductImage();
        img.setProduct(product);
        img.setUrl(req.url());
        boolean wantsPrimary = hasPrimary
                ? Boolean.TRUE.equals(req.isPrimary())
                : i == 0; // khong anh nao duoc danh dau chinh -> ep anh dau tien lam anh chinh
        boolean isPrimary = wantsPrimary && !primaryAssigned;
        if (isPrimary) primaryAssigned = true;
        img.setIsPrimary(isPrimary);
        img.setSortOrder(req.sortOrder() != null ? req.sortOrder() : i);
        imageRepo.save(img);
        i++;
    }
}
```

This is the exact mechanism requested: "if no image in the incoming request has `isPrimary=true`, force the
first one to `true`." The `primaryAssigned` guard also closes an adjacent gap: if the incoming list somehow has
*multiple* `isPrimary=true` entries (a client-side bug), this dedupes it down to exactly one instead of leaving
multiple `PRODUCT_IMAGE` rows with `is_primary=1` for the same product (which would make `pickImageUrl()`'s
`for` loop non-deterministic about which one wins, since it just returns the first match it iterates to). This
is a two-line addition beyond the literal ask, flagged as a defensive improvement worth bundling in the same
edit since it directly protects the same invariant.

### Client-side: `admin-vue/src/components/ProductFormModal.vue` — image list add/remove/reorder (lines ~117-127, `addImage()` line ~228-230)

Verified: `addImage()` sets `isPrimary: form.images.length === 0` — i.e. only the very first image added ever
defaults to primary; every subsequent `addImage()` call adds `isPrimary: false`. This is correct *only if* the
admin never removes the one primary image afterward. Verified gap: removing an image via
`form.images.splice(i, 1)` (the trash-can button, line ~126) has **no logic to reassign primary** if the
removed image happened to be the one with `isPrimary: true` — this can absolutely produce a
zero-primary submission today, exactly matching the survey's concern. Fix: replace the raw `splice` call with
a wrapper function:

```js
function removeImage(i) {
  const wasPrimary = form.images[i]?.isPrimary;
  form.images.splice(i, 1);
  if (wasPrimary && form.images.length && !form.images.some((img) => img.isPrimary)) {
    form.images[0].isPrimary = true;
  }
}
```

...and bind the trash-can button's `@click` to `removeImage(i)` instead of the inline splice.

This is a genuine, concrete client-side bug-fix (not merely "confirm it's fine" as the requirement hedged) —
the plan should flag this to the user as a found-and-fixed issue, not a false alarm.

No change needed for the checkbox itself (`v-model="img.isPrimary"`, line ~120) — Vue's reactivity already
keeps that in sync per-row; the gap was specifically the remove-path, not manual toggling. Reordering: there is
no drag-reorder UI today (rows are simply in array order with a `sortOrder` field set at save time from array
index) — so "reorder" for now just means "remove + re-add," which the fix above already covers.

### `DetailView.vue` gallery fallback (new — see cross-cutting finding #1)

Since there's currently no real `<img>` in the gallery, add one, backed by the already-loaded
`sp.value.images`. Need to first fix a silent data-drop: `products.js`'s `loadDetail()` currently does **not**
carry `d.images` onto the mapped product object at all — it maps `d.specs`/`d.promotions`/`d.bundles`/
`d._variants` but drops `d.images` silently (lines ~310-317). Fix: in `loadDetail()`, add
`p.images = d.images || [];`. Then in `DetailView.vue`, add a computed:

```js
const galleryImageUrl = computed(() => {
  const imgs = sp.value?.images || [];
  if (!imgs.length) return null;
  const primary = imgs.find((i) => i.isPrimary);
  return (primary || imgs[0]).url;
});
```

And render `<img v-if="galleryImageUrl" :src="API_ORIGIN + galleryImageUrl" style="position:absolute; inset:0; width:100%; height:100%; object-fit:cover" />` layered above the existing gradient placeholder div (so
products with no images at all keep exactly today's placeholder look, satisfying "fallback" at both the
data layer — pickImageUrl-style logic — and the true no-image-exists case). Needs `API_ORIGIN` import (already
imported in this file from `'../api.js'` for review photos, line 12 — reuse it).

This is additive/small but real — flagged clearly to the user as slightly expanding scope beyond a "confirm"
into an actual fix, because the thing to confirm didn't exist yet.

---

## Requirement #6 — Rename Specs to "Cau hinh"; add category-based preset spec-key filler

### File: `admin-vue/src/components/ProductFormModal.vue`

1. Rename section header, line ~131: `<span>Thong so ky thuat</span>` -> `<span>Cau hinh</span>`.

2. **New hardcoded preset map** (frontend-only, no backend table) — add near the top of the `<script setup>`
   block or in a small new colocated const:

```js
// slug danh muc -> danh sach khoa thong so theo thu tu hien thi chuan cho danh muc do.
// Da thong nhat bo khoa PC o giai doan truoc; Laptop la bo hop ly ban dau — danh muc khac co the
// bo sung sau theo cung cach (them 1 dong vao map nay).
const SPEC_PRESETS = {
  'pc-may-tinh-ban': ['CPU', 'Card do hoa', 'RAM', 'O cung', 'Mainboard', 'Nguon', 'Vo case', 'Tan nhiet'],
  laptop: ['CPU', 'Card do hoa', 'RAM', 'O cung', 'Man hinh', 'Pin', 'Trong luong', 'He dieu hanh'],
};
```
(Category slugs must match real `CATEGORY.slug` values — confirmed `pc-may-tinh-ban` and `laptop` both exist
as real category slugs in `cnttshop-vue/src/data/products.js`'s `CATEGORY_SEGMENTS` and are the two most
established/data-rich categories in the DB per the survey's PC config key set reference. NOTE: the Vietnamese
diacritics above are elided for this plan-file plain-text rendering only — actual code must use the real
Vietnamese strings, e.g. "Card đồ họa", "Ổ cứng", "Mainboard", "Nguồn", "Vỏ case", "Tản nhiệt", matching
`database/46_pc_case_mainboard_cooler.sql`'s exact `spec_key` values verbatim so preset-added rows match
existing data conventions and downstream keyword-matching in `cnttshop-vue/src/data/products.js`'s
`CATEGORY_SEGMENTS`/`matchesQuery`. Verify against the live `categories` array fetched in `onMounted()` before
finalizing the exact Laptop key list, since "Pin"/"Trong luong"/"He dieu hanh" are this plan's best-guess
placeholder Laptop preset — the requirement explicitly says "a reasonable Laptop preset" and defers exact
tuning, and flags other categories as later additions.)

3. **Two entry-mode buttons** replacing the single existing "+ Them" add-link (line ~132):
   - **"Them tu"** — keep exactly today's behavior, calls existing `addSpec()` unchanged (blank key+value row).
   - **"Them bo da cau hinh san"** — new function:
     ```js
     function addPresetSpecs() {
       const cat = categories.value.find((c) => c.id === form.categoryId);
       const preset = cat ? SPEC_PRESETS[cat.slug] : null;
       if (!preset) { error.value = 'Danh muc nay chua co bo cau hinh mau.'; return; }
       preset.forEach((key) => {
         if (!form.specs.some((s) => s.specKey === key)) {
           form.specs.push({ id: null, specKey: key, specValue: '', sortOrder: form.specs.length });
         }
       });
     }
     ```
     (Skips keys already present, so repeated clicks / partially-filled products don't duplicate rows.) Button
     disabled (or hidden) when `!SPEC_PRESETS[currentCategorySlug]` — i.e. gracefully degrade to "chi co Them
     tu" for categories without a preset yet, matching "other categories can get presets added later."
   - Resulting rows are the exact same `form.specs` array/row UI as today (key+value inputs, trash-can
     button) — the admin fills in values and can add/remove/edit freely, per the requirement's "the admin then
     fills in and can still freely add/remove/edit like normal."

4. No backend/DTO/entity change whatsoever for #6 — `ProductSpec`/`SpecRequest` round-trip unchanged; this is
   purely a client-side convenience layer generating the same shape of rows the admin would have typed by hand.

---

## File-by-file summary (representative, not exhaustive where patterns repeat)

### Backend
- `database/49_option_link_group.sql` — **new**, adds `PRODUCT_OPTION.is_linked BIT NOT NULL DEFAULT 0`
- `src/main/java/com/fpoly/model/ProductOption.java` — add `linked` field + accessors
- `src/main/java/com/fpoly/dto/AdminProductDtos.java` — add `Boolean linked` to `OptionRequest`
- `src/main/java/com/fpoly/dto/CatalogDtos.java` — add `Boolean linked` to `OptionDto`
- `src/main/java/com/fpoly/service/AdminProductService.java` — `saveOptions()` persist `linked`; `getDetail()`
  map `linked` out; `saveImages()` enforce/dedupe exactly-one-primary
- `src/main/java/com/fpoly/service/CatalogApiService.java` — `getProductBySlug()` populate `OptionDto.linked`
  (no change needed to `pickImageUrl()` — already correct)

### admin-vue
- `admin-vue/src/views/Products.vue` — widen+redesign detail modal (mirror DetailView.vue sections), add
  `openDetail()` async fetch of full DTO, wire Chinh sua/Xoa buttons to existing `openEdit`/`confirmRemove`
- `admin-vue/src/components/ProductFormModal.vue` — widen modal; larger+preview-enabled description
  (top-of-form prominence); renamed Variants section label; new "Sinh bien the" generator UI + per-option
  `linked` toggle; renamed+dual-mode Specs("Cau hinh") section with `SPEC_PRESETS` map; fully replaced Bundle
  section (peripheral-only scroll-row + search/autocomplete); `removeImage()` primary-reassignment fix
- `admin-vue/src/data/adminData.js` — add `parseDescription()` helper (mirrors cnttshop-vue's copy)

### cnttshop-vue
- `cnttshop-vue/src/data/products.js` — `loadDetail()`: carry `linked` into `cfg`, carry `images` onto mapped
  product; new exported `parseDescription()` and `availableChoicesFor()` helpers
- `cnttshop-vue/src/views/DetailView.vue` — `cfgGroups` computed: compute per-choice `disabled` via
  `availableChoicesFor` for linked groups; template: disable/gray dead-end choices; render description via
  `parseDescription()` blocks instead of flat `<p>`; add real `<img>` gallery element with primary/first-image
  fallback
- `cnttshop-vue/src/store.js` — verify/adjust `setCfg()` to snap a linked group's selection to its first
  still-available choice when a sibling linked group's selection changes (needs source inspection at
  implementation time; not yet read in this exploration pass — flagged as a required check before coding #7's
  customer-side piece)

---

## Open risks / edge cases flagged for the user

1. **`is_linked` boolean vs `link_group_id`**: chosen boolean per the reasoning above; if the user later wants
   *multiple independent linked-clusters* on one product (e.g., two separate locked pairs that don't
   cross-constrain each other), this needs a follow-up migration widening the column — flagged, not built
   speculatively.
2. **Toggling linked <-> independent after variants exist**: no destructive auto-cleanup; the generator only
   appends, dedup by option-value-key-set. Admin must manually delete stale rows. This is a deliberate design
   choice (safer than auto-deleting variants that might have order history — recall `saveVariants()` already
   throws `DataIntegrityViolationException`-derived errors if the admin tries to delete a variant that has
   order items, so an auto-delete-on-toggle approach would be actively unsafe against that constraint anyway).
3. **Deleting an OptionValue referenced by an existing variant**: pre-existing latent issue (silent
   `optionValueKeys` shrinkage on `update()`), not newly introduced by #7 but more likely to be hit given #7
   encourages bulkier option/variant sets. Recommend as a small separate follow-up (client-side pre-save
   validation warning) — not blocking, can be spun off as its own task.
4. **`ProductCard.vue`/`DetailView.vue` gallery having no real `<img>` today**: the plan adds one minimal real
   `<img>` to `DetailView.vue`'s gallery (needed to give requirement #5's "client-side fallback" something to
   attach to) but does **not** attempt to wire up `ProductCard.vue`'s placeholder into a real image — that's
   a materially bigger, separate initiative (grid-wide image rendering across every card on every page) that
   the 7 requirements don't ask for. Flagged explicitly so the user can decide whether to scope that in
   separately.
