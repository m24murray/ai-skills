---
name: kainos-brand-enforcer
description: Enforces Kainos brand identity on Word documents (.docx), PowerPoint decks (.pptx), PDFs, and frontend/web UI in any language or framework. Use when asked to create a Word document, report, proposal, one-pager, brochure, deck, pitch deck, presentation or PDF; or to brand, style or theme a UI, website, app, page, component, stylesheet or design tokens - "make this look like Kainos", "apply Kainos branding", "update the CSS" - in React, Vue, Angular, Svelte, Nunjucks, Django, Rails, Laravel, Spring, .NET or mobile. Every document and deck must start from the bundled templates in references/templates/, never a from-scratch generator; if a template is missing or fails verification, stop and flag it. Applies only approved palette colours and typography, then runs a brand-compliance check before delivery, auto-fixing violations rather than warning. Do NOT use for emails, Teams messages, chat replies, calendar invites, spreadsheets (.xlsx), or inline summaries with no file or UI output.
---

# Kainos Brand Enforcer

Every Word doc, PowerPoint deck, PDF, or branded frontend UI produced with this skill must conform to the Kainos visual identity. This skill is the single source of truth for templates, colours, fonts, logo usage, tone, and UI brand application.

---

## Where the reference files live (READ FIRST — common failure)

**Every `references/...` path in this skill and in its reference files is relative to the installed skill directory, NOT to the repo or project you are currently working in.**

The skill directory is the folder containing this `SKILL.md`. When installed for Copilot it is normally:

```
~/.copilot/skills/kainos-brand-enforcer/
```

So `references/templates/kainos-pptx-master.pptx` means `~/.copilot/skills/kainos-brand-enforcer/references/templates/kainos-pptx-master.pptx`.

Do **not** search the user's working repo for `references/`, `brand-rules.md`, `assets/logos/`, or the templates. They are not there, and they are not supposed to be. Searching the working repo and finding nothing is the most common way this skill goes wrong — it leads to a "the brand package is missing" false alarm, or worse, a from-scratch colours-only build.

**Resolve the skill directory once at the start of a run**, then use absolute paths. If the host agent exposes the skill's own path, prefer that — the package is designed to be copied into other repos and agents, so it will not always sit under `~/.copilot`.

```bash
SKILL_DIR="$HOME/.copilot/skills/kainos-brand-enforcer"
ls "$SKILL_DIR/references/"
```

**Which paths are working-directory-relative:** only the outputs — `working/`, `working/unpacked/`, `output/`, and `grounding/downloads/`. Those belong in the user's current project or a scratch directory. Never write build artefacts into `$SKILL_DIR`, and never edit the bundled templates in place.

---

## Before you run — pre-flight (READ FIRST)

Surface these to the user up front and resolve them **before** building anything. They keep runs cheap, fast, and on-brand.

1. **A Copilot-built script beats ad-hoc editing.** For anything beyond a couple of slides or pages, it's better to have the build script written by Copilot first — a reusable Python edit-script that runs over the unpacked template — then execute it, rather than hand-editing XML slide by slide. Cache that script so the next run is near-free (see *Reuse cached build scripts* in the workflow).
2. **Don't build a massive deck in one pass.** This skill is tuned for focused deliverables, not 50-slide monsters. Cap a single run at **~20 content slides**. If the user wants more, split it into sections, build each section, then combine — and tell the user that's the approach. A 50-slide deck attempted in one shot will be slow, expensive, and error-prone.
3. **Batch diagrams and image work in tens.** When a deck needs many diagrams built, or many images made editable / dropped into placeholders, work in **batches of 10** — fetch/build 10, verify them, then the next 10. Never try to process 40 images in a single step.
4. **Confirm the template and assets before building.** The templates and primary logos are **bundled**, so they're available from `references/templates/` and `references/assets/logos/`. Verify the selected local template before editing it. Only optional live assets — sub-brand/customer/partner logos, specific icons, photos, or illustrations — need to be fetched separately. **If a bundled template is missing/corrupt, or a required live asset can't be fetched and verified, stop and flag it before the skill runs;** do not silently fall back to a colours-only build.

## Model selection (cost control)

- Use a reliable general coding/writing model for routine decks, documents, and UI work — mechanical XML editing, component styling, placing images, building tables, applying tokens.
- Reserve the strongest reasoning model for genuinely complex jobs: multi-section reports, dense narrative decks, content strategy, heavy synthesis. Escalate only when the *content reasoning* needs it, never because the file mechanics are tedious.

## What to load each run (keep context lean)

Loading everything on every run is slow and expensive. Load only what the job needs. Every path below is under the skill directory (`$SKILL_DIR`), not the user's repo:

- **Always:** `references/brand-rules.md` — the pre-summarised cheat sheet. It distils the brand guide into the rules you actually enforce, so it's the only brand reference you load by default.
- **For Word/PowerPoint/PDF:** the ONE template you need — copy just the single bundled template for the output type from `references/templates/` (the PowerPoint master *or* the Kainos Word template). Never load all templates into context.
- **For PowerPoint:** `references/powerpoint-authoring.md` (deck structure, layout planning, positional ordering, Excel charts/tables) and `references/layout-cheatsheet.md` (the 48-layout map) — only when building a PowerPoint.
- **For UI/code:** `references/ui-branding.md` (tokens, gradients, components, per-stack guidance) plus the three logo files in `references/assets/logos/`, plus the existing app's CSS/templates/components so you can adapt the current design rather than replacing the whole interface.
- **When you need a non-bundled asset:** `references/visual-assets.md` — icons, sub-brand/customer/partner logos, illustrations, photography, and placeholder-frame filling. Skip it if the deliverable only needs the bundled logos.
- **For agents that cannot read Office binaries:** use the manually exported PDF previews in `references/templates/` to understand the visual structure, but still use the Office files in `references/templates/` as the source templates for generation.
- **On demand only:** the full brand guide PDF (`references/docs/brand-guide.pdf`) — consult it *only* for genuine edge cases the cheat sheet doesn't cover (logo exclusion zones, partner co-branding, photography rules). Never load the full PDF as a matter of course.
- **Icons, sub-brand logos, photography** — not bundled in this repo-local package; fetch from the Kainos Organization Assets site only when the deliverable actually uses them, in batches of 10 (see pre-flight).

---

## CRITICAL: How "starting from the template" works (READ FIRST)

This is the rule the skill exists to enforce. Read it before doing anything else.

**On-brand means: the output file is a copy of the Kainos template with content edited inside it.** It does NOT mean "a new file built from scratch that happens to use Kainos colours."

A deck built with `pptxgenjs`, `python-pptx`, or any from-scratch generator — even one that uses the correct hex codes and Century Gothic — is **off-brand by definition**, because:

- It does not carry the template's slide masters
- It does not carry the template's slide layouts
- It does not carry the template's theme colours, theme fonts, or theme effects
- It does not carry the template's pre-designed title and closing slides
- It does not carry the template's pre-built layouts (section divider, two-column, stat callout, etc.)

The only acceptable workflow for `.pptx` and `.docx` is:

1. **Copy** the bundled template from `references/templates/` into `working/`. Use `references/templates/kainos-pptx-master.pptx` for PowerPoint and `references/templates/kainos-word-comprehensive.dotx` for Word. **Verify the copy actually worked** (see the gate below). If the bundled template is missing or fails verification, **stop and flag it to the user before building**; never generate a colours-only file from scratch.
2. **Unpack** the file with the `pptx` or `docx` skill's editing scripts.
3. **Edit XML** in place: change text content, swap images, duplicate or reorder existing slide/page layouts.
4. **Pack** the modified files back into a single `.pptx`/`.docx`.
5. **Save** the result to `output/`.

If you find yourself writing `new pptxgen()`, `pptx.addSlide()`, `Presentation()`, or any from-scratch generator call to satisfy a brand-enforced request — **stop**. You are about to produce an off-brand file. Switch to the editing workflow.

### Verify the working template (every run)

The most-reported failure of this skill is *"the colours come through but the template doesn't."* That happens when a build falls through to a from-scratch generator that hard-codes the right hex codes but carries none of the template's masters or layouts. Because the template file is mandatory, the verify gate **always runs** before you build:

1. **Quick gate first (cheap):** confirm the file opens as a zip and is a sane size — `python3 -c "import zipfile,os;p='working/deck.pptx';z=zipfile.ZipFile(p);print('ppt/presentation.xml' in z.namelist(), os.path.getsize(p))"`. A 0-byte/tiny size or an exception means the local template copy failed or the bundled file is corrupt — stop here. (Use `zipfile.ZipFile(...).namelist()`, **not** `zipfile.is_zipfile()` — a freshly re-saved/synced `.potx` can carry trailing bytes that make `is_zipfile()` return a false `False` even though the file is valid; `testzip()` confirms CRC integrity if you want certainty.)
2. **Full gate only if the quick gate passes:** confirm it actually contains the template's layouts — `python3 -c "import zipfile,re;z=zipfile.ZipFile('working/deck.pptx');print(sum(1 for n in z.namelist() if re.match(r'ppt/slideLayouts/slideLayout\d+\.xml$',n)))"` should return ≥ 8 (a from-scratch file returns 1).

- **Required images** follow the same rule: verify every asset you fetched **live** this run. The three primary logos served from the bundle (see *Visual assets*) are already on disk and need no live fetch.
- **If the template fails verification, stop and flag it to the user before the skill runs** — name what is missing or corrupt and ask for the clean brand package to be restored. A surfaced gap is the correct outcome — never a silent colours-only deck.

The pre-delivery checklist below contains a mechanical check (a `python3` `zipfile` scan for `ppt/slideLayouts/`) that confirms the template's layouts are present. An output file that fails this check must be rebuilt before delivery.

---

## When to Use

Activate this skill whenever the user requests any of the following:

- A Word document (`.docx`) — report, memo, proposal, one-pager, letter, briefing note, statement of work
- A PowerPoint deck (`.pptx`) — pitch deck, internal slides, client presentation, board update, training material
- A PDF deliverable — brochure, formal report, exported deck, client-facing document
- A website, app, UI, page, component, stylesheet, design refresh, landing page, internal tool, frontend prototype, or code change that should look and sound like Kainos

If the user asks for "a doc", "a report", "slides", "a deck", "a brochure", or "a PDF" without further specifying, default to Word for prose and PowerPoint for visual content. If the user asks to brand code, style a page, update CSS, or make an app look like Kainos, apply the UI workflow below.

## When NOT to Use

- Emails, Teams messages, chat replies (those use the standard outgoing-content footer — branding is handled separately)
- Spreadsheets (`.xlsx`) — Kainos does not yet supply an Excel template; defer to the standard `xlsx` skill and apply the colour palette manually if charting
- Inline answers, summaries, or tables rendered in chat (no file or UI produced = no brand package needed)
- Calendar invites, meeting bodies, or scheduled-task descriptions

## UI and Web Branding Workflow

**Load `references/ui-branding.md` before doing any UI work.** It carries the full workflow: the portable CSS token layer, gradient recipes, web typography fallbacks, logo placement per framework, component recipes (header, hero, cards, buttons, forms, badges), page patterns, a stack-by-stack table for where tokens/assets/components belong in ~13 ecosystems, and the UI delivery checklist.

Applies to UI code in any stack: HTML, CSS, JavaScript, TypeScript, React, Vue, Angular, Svelte, Nunjucks, Handlebars, Django/Jinja, Flask templates, Rails ERB, Laravel Blade, Java/Spring Thymeleaf/JSP, ASP.NET Razor/Blazor, PHP, static sites, component libraries, native/mobile UI wrappers, internal tools, forms, dashboards, and prototypes.

Non-negotiables, even if you read nothing else:

- Use exact Kainos palette values — never generic blue/green near-matches. Secondary colours (`#ec6608`, `#cfd600`, `#009fda`) are accents only.
- Copy logos from `references/assets/logos/` into the target repo's static asset folder. Never recolour, stretch, crop, or redraw them; match the variant to the background.
- Gradient direction is diagonal or vertical-ish (`45deg`, `0deg`, `-22.4deg`) — never ~`90deg`.
- Do not invent font imports or use unlicensed font sources. Fall back to `"Century Gothic", "Avenir Next", sans-serif`.
- Map brand values into the repo's *existing* token/theme system. Do not introduce a parallel styling system, and do not change business logic to apply branding.
- Preserve accessibility: contrast, focus states, form labels, responsive layout, and non-colour-only status.

For current UI cues, `https://www.kainos.com/` and its `/careers`, `/our-work`, `/digital-services`, and `/workday` pages are useful public references when browser tools are available — but they are secondary. If a site conflicts with `references/brand-rules.md`, follow the local brand rules.

## Templates (mandatory starting point)

**Templates are bundled locally in `references/templates/`** — see Step 2 for the copy-and-verify workflow. If the local template is missing or fails verification, stop and flag it rather than building from scratch. **Never create a Word doc or PowerPoint from scratch — always start from the appropriate template.**

Source of truth: this self-contained skill package, originally extracted from the Kainos brand guidelines package.

| Output | Local template file | When to use |
|--------|---------------------|-------------|
| Word document (any length) | `references/templates/kainos-word-comprehensive.dotx` | Every Word deliverable — memos, reports, proposals, anything with cover + TOC |
| PowerPoint | `references/templates/kainos-pptx-master.pptx` | The single Kainos master template — used for every deck |
| PDF | Generate from a Kainos Word or PowerPoint output, then export | Never produce a PDF that wasn't built from a Kainos template |

Optional manual previews for agents that cannot inspect Office binaries:

| Template | Manual PDF preview path |
|----------|-------------------------|
| `references/templates/kainos-word-comprehensive.dotx` | `references/templates/kainos-word-comprehensive.pdf` |
| `references/templates/kainos-pptx-master.pptx` | `references/templates/kainos-pptx-master.pdf` |

These PDFs are previews only. Do not treat them as generation templates; they are for visual/reference reading by agents that cannot open `.dotx` or `.pptx` directly.

The PowerPoint master is `Powerpoint master template v2.potx` — the **single approved PowerPoint template**. The legacy `Powerpoint template Style 1/2/3.potx` variants and the older `Powerpoint branded master template.potx` have been **retired**: never pull them in. If a user asks for a "Style" variant, explain the v2 master is now the canonical template and proceed with it.

**Template workflow:** see **Step 2** for the full logic — in short, copy the needed local template into `working/` and verify it before building. The brand guide PDF is bundled at `references/docs/brand-guide.pdf` if you need to consult it on demand.

There is a single Kainos Word template (the Comprehensive template) — use it for every Word deliverable, short or long.

**Use the current brand template for PowerPoint or Word and use the theme on the slides — don't deviate.** The template's theme (colours, fonts, master slides, layouts) is the single source of truth. Do not override theme colours, swap fonts, or apply custom layouts that bypass the template. If the template defines a style for a heading, body, callout, or shape — use it as-is.

## PowerPoint slide structure (mandatory)

**Load `references/powerpoint-authoring.md` before building any deck.** It carries the mandatory deck structure, the layout-map planning step, the positional-ordering rule for multi-slot layouts, and the full Excel-to-chart/table guidance. Pair it with `references/layout-cheatsheet.md` for the 48-layout menu.

The rules you must not get wrong:

1. **Start with the template's title slide and end with the template's closing slide**, exactly as the template defines them. When the user requests N slides, N counts **content slides only** — title and closing are not counted.
2. **Vary the content layouts.** Write a layout map (slide → headline → chosen layout → why) *before* editing any XML, and pick a distinct layout per content slide unless you run out of content-suitable layouts. Repeating one layout throughout is a brand violation.
3. **Multi-slot layouts assign content by POSITION, not `idx` order.** On timelines (L9, L12), agendas (L5, L26), icon grids (L30, L31, L34, L35, L37) and stat rows (L28), placeholder `idx` numbers do **not** run in reading order. Sort content placeholders by `<a:off>` x (then y) and map your ordered content onto that sequence. Filling in `idx` order has shipped scrambled timelines. Run the x-sort build-time check in `references/powerpoint-authoring.md` for any sequence slide.
4. **Excel/CSV sources become native chart or table objects** on L41 (chart), L40 (short table), or L42 (large table) — never a screenshot, a hand-built text-box table, or a bullet list of numbers. Chart series colours follow the primary order: blue `#283583` → green `#61a83f` → mid blue `#41679f` → dark green `#004631` → grey `#575756`.

---

## Brand rules (must be applied to every output)

The full operational rules live in `references/brand-rules.md`. Read it before generating content. Highlights:

- **Colour palette:** primary = Kainos blue `#283583`, Kainos green `#61a83f`, white, mid blue `#41679f`, dark green `#004631`, grey `#575756`. Secondary (max 20% of any page) = orange `#ec6608`, bright green `#cfd600`, bright blue `#009fda`. Never lead with a secondary colour.
- **Typography:** Foundry Gridnik (UPPERCASE only) for large display headlines; Galano Grotesque for everything else. **Century Gothic is the fallback** in Word and PowerPoint because the brand fonts are not installed in MS Office — this is by design, per the brand guide.
- **Logo:** primary full-colour logo wherever possible; mono negative only on bright green or gradient backgrounds. Never alter, recolour, or stretch.
- **Gradient:** dark green → green → mid blue → blue. Permitted angles: 0°, 45°, -22.4° (or similar) — never ~90°.
- **Tone of voice:** confident, plain-spoken, optimistic, human. Sentence case in body copy; ALL CAPS reserved for Foundry Gridnik display headlines.

For edge cases (logo exclusion zones, partner co-branding, photography rules, iconography), consult the bundled full brand guide at `references/docs/brand-guide.pdf` **on demand** — don't load it as a matter of course.

## Visual assets (use these instead of recreating)

**Load `references/visual-assets.md` when you need an asset the bundle doesn't ship** — icons, sub-brand/product lockups, customer or partner logos, illustrations, or photography — or when you need to fill a picture/icon placeholder frame. It carries the SharePoint library map, the `ListDrives` → `SearchDrive` → `ReadFileContent` fetch workflow, the metadata-matching rules, and the aspect-ratio-preserving placeholder injection steps.

Never reconstruct, redraw, or substitute an external icon set for a Kainos asset.

**The three primary logos are bundled — use them directly, don't fetch them.** They are tiny, appear on virtually every deliverable, and effectively never change. Fetching them from SharePoint is the slowest avoidable part of a run.

| Bundled file | When to use |
|--------------|-------------|
| `references/assets/logos/kainos-logo-primary-transparent.png` | Default. White, light, or photographic backgrounds — cover slides, document headers, footers. |
| `references/assets/logos/kainos-logo-primary.png` | Same, when a transparent background isn't supported (e.g. legacy PDF tooling). |
| `references/assets/logos/kainos-logo-alt-transparent.png` | Only when the primary clashes with the background (Kainos green, or the gradient). |

Never rotate, recolour, stretch, or crop a logo. Maintain the exclusion zone defined in section 2.1.3 of the brand guide.

Everything else — icons (light-bg vs `Rev` dark-bg variants), sub-brand/product lockups (DavisPier, Smart, Smart-Audit, Smart-Shield, Smart-Test, Evolve, Workday, RAI-BOW), customer logos, partner logos, illustrations, and approved photography — lives on `https://kainossoftwareltd.sharepoint.com/sites/OrganizationAssets` and is **not** bundled. Fetch on demand only, in batches of 10. If nothing in the library fits a placeholder, leave it empty and say so in the delivery message — never substitute generic clip art.

---

## Workflow (strict block-and-fix mode)

Follow this sequence exactly — do not improvise, and do not substitute a from-scratch generator at any step.

### Step 1 — Pick the template

Use the templates table above: `kainos-pptx-master.pptx` for PowerPoint and `kainos-word-comprehensive.dotx` for Word (the single Kainos Word template).

### Step 2 — Copy the template into `working/` (local, every run)

Templates are bundled in the **skill directory**, not in the user's repo — see *Where the reference files live*. Copy, verify, then build:

1. **Choose the local template.** PowerPoint → `$SKILL_DIR/references/templates/kainos-pptx-master.pptx`; Word → `$SKILL_DIR/references/templates/kainos-word-comprehensive.dotx`.
2. **Copy it into `working/`** in the user's current project or a scratch directory — e.g. `cp "$SKILL_DIR/references/templates/kainos-pptx-master.pptx" working/deck.pptx`. Use `working/deck.pptx` or `working/doc.docx` as the editable copy.
3. **Verify it.** Run the verify gate (see *Verify the working template* above): the quick zip/size check, then the layout-count check for PowerPoint.
4. **If the copy or verification fails, stop and flag it before building.** Say whether the local template is missing, empty, corrupt, or has too few layouts. First re-check that you looked in the skill directory and not the working repo — that mistake produces a false "missing template" report. Do not attempt a workaround build.

Never edit the bundled template in place. Always operate on the working copy in `working/`, and leave `$SKILL_DIR/references/templates/` as the pristine source.

### Step 3 — Edit the working copy via the editing workflow

For `.pptx` use the **edit mode** path in the `pptx` skill (its `office/unpack.py` → modify slide XML → `office/pack.py` helpers). For `.docx` use the equivalent docx editing path.

**Unpack the local working copy.** Run the available Office/PPTX/DOCX unpack helper on the working copy to expand it into `working/unpacked/`, then edit the XML there. The skill does not ship a pre-unpacked snapshot, so unpack the copied template each run. Always edit the copy in `working/unpacked/`, never the bundled template under `references/templates/`.

**You must not generate the file with `pptxgenjs`, `python-pptx`, `docx-templater`, or any from-scratch library.** These produce files that do not inherit the template's slide masters, layouts, or theme — and are off-brand even when the colours are correct.

When editing slide XML or document XML:

- **Reuse the template's slide layouts and master placeholders.** Duplicate an existing slide that uses the layout you want, then change its text — do not author a new layout.
- **Do not introduce hex colours in `<a:srgbClr>` tags** unless they exactly match the approved palette. Prefer `<a:schemeClr val="accent1"/>` style references so the theme drives the colour.
- **Do not introduce font names in `<a:latin>` tags.** Let the theme's heading and body fonts apply.
- **Title and closing slides come from the template.** Use the existing title and closing slides; replace text only.

### Reuse cached build scripts (save time and money)

If you turn the template into a reusable **Python edit-script** — one that unpacks the template, edits its XML, and repacks it (*not* a from-scratch generator) — save that script into the skill so future runs reuse it instead of re-deriving it:

- Save it under the skill's `scripts/` folder with a descriptive name — for example `build-pptx-from-master.py` or `build-word-doc.py`.
- On a later run of the same output type, **read the cached script first** and adapt its inputs/content, rather than rebuilding the edit logic from scratch. This is the single biggest time-and-cost saving in the skill.
- Keep cached scripts in sync with the template: if the master changes, re-derive and overwrite the cached script (note the template version in a comment at the top).
- Run shape-building and edit scripts on the standard coding model available in the host agent; reserve stronger models for content reasoning only (see *Model selection*).

### After packing — normalise the .pptx (REQUIRED when built from the .potx master)

The Kainos master is a **template (`.potx`)**. When you pack a deck from it, the package still declares the **template** main content type and can carry **dangling `customXml` relationships** left over after cleanup. A `.pptx` that announces itself as a template — or points at parts that don't exist — makes **PowerPoint throw "found a problem with content / needs repair" on open** (LibreOffice and the QA render tolerate it, so this slips past visual QA). Always normalise the packed file before delivery:

```bash
python3 - "output/<file>.pptx" << 'EOF'
import zipfile, re, os, sys
p=sys.argv[1]; T="presentationml.template.main+xml"; P="presentationml.presentation.main+xml"
z=zipfile.ZipFile(p); items={n:z.read(n) for n in z.namelist()}; z.close()
ct=items['[Content_Types].xml'].decode('utf-8').replace(T,P); items['[Content_Types].xml']=ct.encode()
rk='ppt/_rels/presentation.xml.rels'
items[rk]=re.sub(r'<Relationship\b[^>]*?Target="[^"]*customXml/item[^"]*"[^>]*?/>','',items[rk].decode('utf-8')).encode()
tmp=p+'.tmp'
with zipfile.ZipFile(tmp,'w',zipfile.ZIP_DEFLATED) as o:
    for n,d in items.items(): o.writestr(n,d)
os.replace(tmp,p)
print('normalised:', 'application/vnd.openxmlformats-officedocument.'+P in ct)
EOF
```

(If you ever have `python-pptx` available, `import pptx; pptx.Presentation('output/<file>.pptx')` is the fastest confirmation — it raises on a template content type and loads cleanly once normalised.)

### Step 4 — Apply brand rules to content

- **Colours** — only the HEX codes in `references/brand-rules.md`. Lead with primary; cap secondary at 20% of any one page or slide.
- **Typography** — headlines = Foundry Gridnik Bold UPPERCASE (Century Gothic Bold UPPERCASE in Office fallback). Body = Galano Grotesque Regular (Century Gothic Regular). Hierarchy ratios per `brand-rules.md` §4.
- **Logo** — primary on light/white/photographic backgrounds; alt variant on Kainos green or the gradient. Used from the bundled `references/assets/logos/` by default (SharePoint Logos library only for non-bundled lockups), unaltered.
- **Tone** — confident, plain-spoken, optimistic, human. Sentence case in body copy; UPPERCASE reserved for Foundry Gridnik display headlines.

### Step 5 — Brand-compliance check (single-shot, same run)

**Bake compliance into the first build — don't make it a second run.** Apply the brand rules *as you build* (Step 4), then run the checklist below **once** at the end of the same pass, before telling the user the file is ready. Fix any violation in place — do not regenerate the file from scratch, and do not surface violations as warnings.

The first three items are mechanical and can be verified with a few lines of `python3 -c "import zipfile…"` over the packed file (this container has no `unzip` binary — use Python's `zipfile`). They guarantee the file came from the template, not a from-scratch generator.

### Step 6 — Confirm and deliver

Save to `output/` with a descriptive filename. Tell the user the file is ready and name the template you used. Add one line on the choice only if it was a judgement call.

---

## Pre-delivery checklist

**Mechanical checks (file must come from the template, not a generator):**

- [ ] **Slide layouts present** — `python3 -c "import zipfile,re;z=zipfile.ZipFile('output/<file>.pptx');print(sum(1 for n in z.namelist() if re.match(r'ppt/slideLayouts/slideLayout\d+\.xml$',n)))"` returns at least 8 (the v2 master carries 48). A pptxgenjs file returns 1.
- [ ] **Theme inherited** — `python3 -c "import zipfile;print('Century Gothic' in zipfile.ZipFile('output/<file>.pptx').read('ppt/theme/theme1.xml').decode('utf-8','ignore'))"` prints `True` (the brand theme font). A pptxgenjs file uses generic Calibri.
- [ ] **Presentation content type (opens in PowerPoint)** — the deck was built from a `.potx`, so confirm it now declares the *presentation* type, not *template*: `python3 -c "import zipfile;ct=zipfile.ZipFile('output/<file>.pptx').read('[Content_Types].xml').decode();print('presentation.main+xml' in ct and 'template.main+xml' not in ct)"` prints `True`. If `False`, run the post-pack normalisation above — otherwise PowerPoint errors on open even though the QA render looked fine.
- [ ] **No dangling relationships** — `presentation.xml.rels` has no `customXml/item*` targets that aren't in the package (the normalisation step strips them). Broken rels are a second PowerPoint "needs repair" trigger.
- [ ] **File size sanity** — output `.pptx` is comparable in size to the source template (the v2 master is ~19MB; a generated deck of 5–10 slides should be in the same order of magnitude because it carries the master's images and layouts). A multi-slide pptxgenjs file under 1MB indicates the template wasn't loaded.

**Brand checks:**

- [ ] (PowerPoint) Deck starts with the template title slide and ends with the template closing slide; neither counted toward the user's requested slide count
- [ ] (PowerPoint) Content slide layouts are varied — no repeated use of the same layout where a different one fits better
- [ ] (PowerPoint) **Layout diversity check** — count the distinct layouts used across content slides. The number of distinct layouts should equal the content slide count (no repeats) unless content slides exceed available content-suitable layouts. Verify with: `python3 -c "import zipfile, re; z=zipfile.ZipFile('output/<file>.pptx'); slides=[n for n in z.namelist() if re.match(r'ppt/slides/_rels/slide\d+\.xml\.rels', n)]; layouts=set(); [layouts.update(re.findall(r'slideLayouts/(slideLayout\d+\.xml)', z.read(s).decode())) for s in slides]; print(f'{len(slides)} slides, {len(layouts)} distinct layouts: {sorted(layouts)}')"`. If the slide count comes back as 0, the regex path is wrong — the `_rels/` segment must be present. If distinct layouts < (content slides − 1), redo the layout map and rebuild — the deck is too repetitive.
- [ ] (PowerPoint) Excel-sourced slides use L41 (chart), L40 (short table), or L42 (large table) with a native chart/table object — never a screenshot, hand-built table, or generic bullet list of numbers
- [ ] (PowerPoint) **Sequence ordering** — for any timeline / agenda / numbered-process slide, the content reads in the correct order when sorted by x-position (run the build-time check above). A scrambled timeline is a shipped-defect, not a cosmetic nitpick
- [ ] (PowerPoint) Chart series colours follow the Kainos primary order (blue → green → mid blue → dark green → grey) before any secondary colour is used
- [ ] Every colour used appears in the approved palette
- [ ] Secondary colours occupy ≤ 20% of any page or slide
- [ ] Headlines use Foundry Gridnik (or Century Gothic fallback) in UPPERCASE
- [ ] Body uses Galano Grotesque (or Century Gothic fallback) in sentence case
- [ ] Kainos logo present where appropriate (cover, title slide, final slide), unaltered — pulled from bundled `references/assets/logos/`, not recreated
- [ ] Any icons used come from the SharePoint Icons library (`https://kainossoftwareltd.sharepoint.com/sites/OrganizationAssets/Icons`) — never generic third-party icons
- [ ] Any sub-brand or product logo used comes from the SharePoint Logos library (`/Logos`) — never recreated
- [ ] Picture and icon placeholder frames in template layouts have been filled with concept-appropriate assets from SharePoint, or left empty (with a note in the delivery message) — never filled with generic clip art
- [ ] Logo variant matches background (primary on light, alt on bright green / gradient; reverse-variant icons on dark backgrounds)
- [ ] Tone of voice matches the Kainos style (confident, plain, no jargon-heavy filler)
- [ ] No gradient applied at ~90°
- [ ] File saved to `output/` with a descriptive filename

If any item fails, regenerate or edit the file until it passes — then deliver.

---

## Delivery message template

> Your [Word document / PowerPoint deck / PDF] is ready — I've saved it for you. Built on the **[template name]** template with full Kainos branding applied.

Add a single optional line if the template choice was a judgement call ("Used the Comprehensive template because it's a long-form report").

---

## Guardrails

- **Never create a document from scratch.** Always start from a Kainos template via the copy → unpack → edit → pack workflow.
- **Never use `pptxgenjs`, `python-pptx`, or any from-scratch generator** to produce a Kainos-branded deliverable. These bypass the template and are off-brand by definition, even when the hex codes match.
- **Missing or corrupt bundled template = stop, don't work around it.** If a local template in `references/templates/` is absent, empty, corrupt, or missing expected layouts, ask for the clean brand package to be restored — never fall back to a from-scratch or colours-only build.
- **Never invent a colour.** Only use the HEX codes in `references/brand-rules.md`.
- **Never deliver without running the pre-delivery checklist.** This is the "block-and-fix" guarantee. The mechanical checks are the safety net for the from-scratch failure mode.
- **Never edit the bundled template in place while building.** Always copy it into `working/` first and edit the copy, and leave `references/templates/` as the pristine source.
- **Don't argue with the user about brand rules.** If they ask for something off-brand, apply the closest on-brand alternative and note it briefly in the delivery message.
