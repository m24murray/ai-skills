# PowerPoint authoring rules

> All `references/...` paths below are relative to the installed skill directory (normally `~/.copilot/skills/kainos-brand-enforcer/`), not to the repo you are working in. `working/` and `output/` paths are relative to the user's current project or a scratch directory.

Load this file when building a `.pptx`. It covers mandatory deck structure, layout planning, the positional-ordering rule for multi-slot layouts, and Excel-sourced charts/tables. Pair it with `references/layout-cheatsheet.md`, which maps all 48 layouts in the current master.

## Slide structure (mandatory)

Every PowerPoint deck must follow this structure:

1. **Start with the template's title slide.** Use the cover/title layout exactly as the template defines it.
2. **Content slides in the middle.** When the user requests N slides, that count refers to content slides only — the title and closing slides are **not** counted toward N.
3. **End with the template's closing slide.** Use the closing/thank-you layout exactly as the template defines it.

**Vary the content slide layouts.** Do not use the same content layout for every slide — rotate through the layouts the template provides (e.g. section divider, two-column, image + text, statistic callout, agenda, quote) to match the content of each slide. Repetition of a single layout is a brand violation; pick the layout that fits each slide's purpose.

## Layout planning (mandatory before building)

Before duplicating or editing a single slide, write a **layout map** to a working note (or to the chat as a brief plan). For each content slide, list:

| Slide # | Headline / topic | Layout chosen (filename + name) | Why this layout fits |
|---------|------------------|---------------------------------|----------------------|

Rules for the map:

1. **Enumerate the available layouts first.** Read `references/layout-cheatsheet.md` — it lists all **48 layouts** in the current master by `L<n>` (= `slideLayout<n>.xml`) with their names, placeholder `idx`/role/position, and ordering quirks. Most decks will only ever touch 6–10 layouts, but you have to *see* the menu before you can choose. If the environment has PPTX thumbnail tooling, you may also generate a visual grid from `working/deck.pptx`; otherwise read `working/unpacked/ppt/slideLayouts/` after unpacking.
2. **No layout used twice** unless the content slide count exceeds the number of *content-suitable* layouts in the master. If the user asks for 6 slides, you should be picking 6 distinct layouts. The title and closing layouts are exempt — they are fixed by template.
3. **Match layout to content shape, not to habit.** Bullets-of-three → stat callout or icon row, not another title-and-body. A quote → quote layout (L47). A comparison → two-column (L18). A chapter break → section divider (L46). A chart → L41. A short table → L40. A long table → L42.
4. **Confirm the map before building.** Re-read the map against the slide content. If two consecutive slides have the same layout, or three of the layouts in the map are minor variants of "title + body bullets", redo the map — the user will see the deck as monotonous regardless of how good the writing is.

Only after the map is written and re-checked should you start duplicating layouts and editing XML.

## Hard rule: multi-slot layouts assign content by POSITION, not `idx` order

On layouts with repeated parallel slots — **timelines (L9, L12), agendas (L5, L26), icon grids (L30, L31, L34, L35, L37), stat rows (L28)** — the placeholder `idx` numbers do **not** run in visual reading order. A timeline's phase slots, for example, interleave high and low `idx` across the left-to-right axis. If you fill them in `idx` order, the content comes out **scrambled** (this is a real defect that has shipped: a 4-step process rendered as step 1 → step 3 → step 2 → step 4).

**The rule:** before assigning content, sort the layout's content placeholders by their `<a:off>` **x** (then **y** for vertical stacks) and map your ordered content onto that sorted sequence. Never assume `idx=12` sits left of `idx=13`.

**Build-time check (run for any timeline/sequence/agenda slide before packing):** confirm your phase labels appear in the intended order when sorted by x-position.

```bash
python3 - "working/unpacked/ppt/slides/slideN.xml" << 'EOF'
import sys, re
xml = open(sys.argv[1], encoding='utf-8').read()
shapes = []
for m in re.finditer(r'<p:sp>(.*?)</p:sp>', xml, re.S):
    b = m.group(1)
    off = re.search(r'<a:off x="(-?\d+)"', b)
    txt = ' '.join(t for t in re.findall(r'<a:t>([^<]*)</a:t>', b) if t.strip())
    if off and txt:
        shapes.append((int(off.group(1)), txt[:40]))
print("Left-to-right reading order:")
for x, t in sorted(shapes):
    print(f"  {t}")
EOF
```

Read the printed order against your intended sequence. If it's scrambled, swap the slot contents (not the slots) until the x-sorted order is correct, then re-check. The pre-delivery checklist enforces this for any sequence slide.

## Excel-sourced content (charts and tables)

When the source material is an Excel file, a CSV, or any tabular dataset, the output should be a **native PowerPoint chart or table** placed into one of the master's data layouts — not a screenshot of the spreadsheet, not a hand-built table made of text boxes, and not a generic content slide with the numbers typed out as bullets.

### Pick the right layout

| Layout | Use when |
|--------|----------|
| **L41 — Chart and text** | The data tells a story best as a chart (trend, comparison, distribution, share of total). Has a native chart placeholder (`<p:ph type="chart" idx="18"/>`) plus a title (`idx=0`) and caption body (`idx=13`). **Default for any Excel-sourced slide unless the user specifically asks for the raw figures.** |
| **L40 — Table and text** | The audience needs the actual numbers and the table is short (≤ ~6 rows × ~5 columns). Native table placeholder (`idx=15`) with a caption body (`idx=13`) alongside. |
| **L42 — Large table** | Tabular data that needs more room (longer row count, more columns, or the table is the slide's main content). Full-width table placeholder (`idx=15`). |

If a slide needs both a chart and the underlying figures, prefer two slides over cramming both onto one — the master doesn't supply a chart-plus-table layout and improvising one is off-brand.

### Choose the chart type from the data, not from habit

| Data shape | Chart type |
|------------|------------|
| Change over time (months, quarters, years) | Line or column |
| Comparing categories at a single point | Horizontal bar (better than vertical when category labels are long) |
| Share of a whole, ≤ 5 segments | Donut (preferred over pie) |
| Two variables, looking for correlation | Scatter |
| Cumulative progress against a target | Stacked bar or progress bar |

Avoid 3D effects, exploding pie slices, and chart junk (gridline overload, redundant legends, drop shadows). The brand voice is plain-spoken — the chart should be too.

### Apply the brand palette in series order

Charts inherit the template's theme by default — keep it that way. If you must override series colours, apply them in this order so the dominant data colour is always Kainos primary:

1. Kainos blue `#283583`
2. Kainos green `#61a83f`
3. Mid blue `#41679f`
4. Dark green `#004631`
5. Grey `#575756`

Only reach for the secondary palette (`#ec6608`, `#cfd600`, `#009fda`) for highlighting a single series that needs to stand out — and keep it within the 20% rule.

### Authoring rules

- **Use a native PowerPoint chart object**, not an image. The chart is a `<p:graphicFrame>` containing a `<c:chart>` element; the actual data lives in a small embedded xlsx under `ppt/embeddings/` and is referenced from the slide's `_rels/`. The `pptx` skill's pack/unpack workflow handles this — stay inside the editing path, do not switch to a from-scratch generator to "make the chart easier".
- **Keep titles in sentence case**, axis labels short, and legends on the right (or omitted when there's only one series). The slide title is the headline; the chart title can usually be removed.
- **Round numbers** in data labels for readability (e.g. £1.2M, not £1,237,491). Reserve precision for the appendix or a follow-up table slide.
- **Source line** goes in the caption body (`idx=13` on both L41 and L40) — small, grey `#575756`, prefixed with "Source:".

### When the user uploads an .xlsx

1. Read the file with the `xlsx` skill to understand sheet structure and identify the cells/range that should drive the chart.
2. Decide chart-vs-table per the rules above; pick L41 (chart), L40 (table), or L42 (large table) accordingly.
3. Duplicate the chosen layout's slide, drop in the data and title, apply the palette order, and verify visually via the standard QA pass.
4. Note the source file name in the caption so the audience can trace the figures.
