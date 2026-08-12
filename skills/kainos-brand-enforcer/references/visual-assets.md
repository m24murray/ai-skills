# Visual assets (use these instead of recreating)

Load this file when a deliverable needs a logo variant beyond the bundled three, an icon, a sub-brand/customer/partner lockup, an illustration, or photography — or when you need to fill a picture/icon placeholder frame in a template layout.

When the template doesn't already place a logo or icon for you, pull from the asset library — never reconstruct, redraw, or use an external icon set.

## Logos — use the bundled copy by default (don't fetch the standard logos)

The three primary Kainos logos appear on virtually every deliverable, are tiny (~20 KB), and effectively never change. **Use the bundled copies in `references/assets/logos/` directly — do not fetch them from SharePoint.** This removes the slowest part of a typical run (resolve site → list drives → search Logos library → download). The bundled files are kept byte-identical to the SharePoint originals; only re-fetch a standard logo if you have a specific reason to believe it changed.

Reach out to the **Logos** library on SharePoint only for assets that are **not** bundled — sub-brand/product lockups (DavisPier, Smart, Evolve, Workday, RAI-BOW, etc.), customer logos, or partner logos — and fetch those on demand (in batches of 10 if there are many).

| SharePoint file (Logos library) | Bundled fallback | When to use |
|---------------------------------|------------------|-------------|
| `Kainos 800x250 Logo (Transparent BG).png` | `references/assets/logos/kainos-logo-primary-transparent.png` | Default. Place on white, light, or photographic backgrounds. Use for cover slides, document headers, footers. |
| `Kainos 800x250 Logo.png` | `references/assets/logos/kainos-logo-primary.png` | Same as above when a transparent background isn't supported (e.g. legacy PDF tooling). |
| `Kainos-alt-transparent.png` | `references/assets/logos/kainos-logo-alt-transparent.png` | Alternate variant — use only when the primary clashes with the background (e.g. on Kainos green or on the gradient). |

These three are the **bundled-by-default** set above — reference the local `references/assets/logos/` path directly. The Logos library on SharePoint also holds sub-brand and product lockups (DavisPier, Smart, Smart-Audit, Smart-Shield, Smart-Test, Evolve, Workday, RAI-BOW, etc.) that are **not** bundled — fetch those on demand (resolve the **Logos** `drive_id` via `ListDrives`, then `SearchDrive`/`GetDriveChildren` → `ReadFileContent` into `grounding/`). See the sub-brand logo guidance below.

Logo placement rules: never rotate, recolour, stretch, or crop. Maintain the exclusion zone defined in section 2.1.3 of the brand guide.

## Icons, sub-brand logos, illustrations, photography — fetch from SharePoint on demand

Icons and sub-brand/product logos are **not** bundled with the skill (they were removed to keep it lightweight). Fetch them from the Organization Assets site only when the deliverable actually needs them.

Source of truth: `https://kainossoftwareltd.sharepoint.com/sites/OrganizationAssets`

| Library | What's there | Use when |
|---------|--------------|----------|
| `Icons` | ~80 brand-approved icons. Each concept has a light-bg version (e.g. `Cloud.png`) and a dark-bg "Rev" version (e.g. `Cloud Rev.png`). | Statistics callouts, agenda slides, process diagrams, feature lists. |
| `Logos` | Sub-brand and product logos: DavisPier, Smart, Smart-Audit, Smart-Shield, Smart-Test, Evolve, Workday lockup, RAI-BOW, etc. | The deliverable is *for* a specific product or sub-brand. |
| `Customer Logos` | Approved customer/client logos. | Co-branding for a named client. |
| `Partner Logos` | Approved partner logos (Workday, AWS, Microsoft, etc.). | Co-branding with a named partner. |
| `Illustrations` | Brand-approved illustrations. | Filling placeholder picture frames where a stylised illustration fits better than a photo. |
| `Approved Imagery` | Brand-approved photography. | Filling placeholder picture frames where a real photo is the right call. |

**Fetch workflow**

Use the SharePoint tools in this order:

1. `SearchDrive(drive_id=<library>, query="<concept>")` — fastest when you know the asset name (e.g. "Cloud", "Smart-Audit", "Workday").
2. If search misses, `GetDriveChildren(drive_id=<library>)` and page with `next_link` until you find the right file.
3. **Before picking an asset, inspect the candidates' metadata** — the filename, image tags, and description / alt-text fields surfaced by SharePoint. Choose the one whose metadata best matches the slide's inferred concept (from the slide title, body text, and any placeholder name or alt-text in the template). Do not just take the first `SearchDrive` hit — a search for "data" might return a generic chart icon, a database icon, and a "Data & AI" sub-brand mark, and only one of those fits the slide. If two candidates match equally, prefer the one whose tags/description are more specific to the slide's topic.
4. `ReadFileContent(drive_id=…, item_id=…)` — pulls the binary into `grounding/downloads/`. **Always call `ReadFileContent` to get the bytes** — a `SearchDrive`/`GetDriveChildren` result stages only a **0-byte stub** on disk, so never try to read the file straight from the search-result path; it will be empty.
5. Reference the local `grounding/downloads/` path when injecting the image into the unpacked template XML.

**Batch fetches in parallel.** When a deliverable needs several live assets (e.g. a few icons), issue their `ReadFileContent` calls **together in one batch** rather than one after another — and cap each batch at 10 (see pre-flight). Sequential per-asset downloads are the main avoidable cost once the logo and template are served from the bundle.

The `drive_id` for each library is resolved via `ListDrives` against the OrganizationAssets site at the moment of use — IDs are not hardcoded here because they can rotate.

**Picking the right variant**

- Light background → use the plain icon (`Cloud.png`).
- Kainos blue, dark green, or gradient background → use the "Rev" variant (`Cloud Rev.png`).
- One concept = one icon. Never combine, recolour, or modify. If no SharePoint icon matches the concept, leave the placeholder empty rather than substituting a generic icon — and note it in the delivery message.

## Filling placeholder picture and icon frames in the template

The master `.pptx` ships with empty picture/icon placeholder frames on several layouts. When you reuse one of those layouts:

1. **Identify the placeholder** in the slide XML — picture placeholders have `<p:ph type="pic">`, content placeholders may be empty `<p:pic>` or `<p:sp>` shapes flagged for imagery.
2. **Pick an asset that matches the slide's meaning.** Read the slide's title and body text, choose a concept that fits (e.g. a slide about cloud migration → "Cloud" icon; a slide about partnership → "Connect" or "Handshake" icon; a slide hero image about people collaborating → search `Approved Imagery` for a relevant photo).
3. **Fetch the asset from SharePoint** (icons → Icons library; product mark → Logos library; hero photo → Approved Imagery; illustration → Illustrations).
4. **Inject it into the placeholder** by replacing the placeholder's `<p:blipFill>` reference (or adding one if the placeholder is empty) and adding the image to `ppt/media/` plus the slide's `_rels/`. Use the `pptx` skill's pack/unpack helpers — never edit the binary `.pptx` directly.
5. **Preserve the image's aspect ratio.** Before sizing the placeholder, read the image's native pixel dimensions with Pillow (`from PIL import Image; w, h = Image.open(path).size`). Then resize the placeholder's `<a:ext cx="..." cy="..."/>` so `cx:cy` matches `w:h`, fitted inside the original frame's bounds (whichever dimension is the limiting one — landscape image into landscape slot scales width-first, portrait into landscape scales height-first). Re-centre the frame within the original placeholder's bounding box by adjusting `<a:off x="..." y="..."/>`. This stops PowerPoint stretching the image to fill a mismatched frame. A portrait image dropped into a landscape slot will render smaller than the layout intended — that is correct; do not stretch it to fill.
6. **Match the variant to the background** of the host layout (light vs dark/gradient → plain vs "Rev").

If the asset library has no fitting match for a placeholder, leave it empty and mention the gap in the delivery message — do not invent or substitute generic clip art.
