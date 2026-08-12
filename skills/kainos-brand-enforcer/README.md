# Kainos Brand Enforcer Package

This directory is a self-contained copy of the Kainos brand skill for documents, decks, PDFs, and frontend UI/code branding across different repos, frameworks, and languages. It does not depend on the old `branding guidlines/` source directory.

## Contents

- `SKILL.md` — instructions for applying the Kainos brand to Word, PowerPoint, PDF, website, app, component, stylesheet, and frontend UI deliverables.
- `references/brand-rules.md` — compact brand rules for colours, logo usage, typography, and tone.
- `references/ui-branding.md` — full UI/web workflow: tokens, gradients, web typography, logos per framework, component recipes, page patterns, per-stack guidance, UI delivery checklist.
- `references/powerpoint-authoring.md` — deck structure, layout planning, the positional-ordering rule for multi-slot layouts, and Excel-sourced charts/tables.
- `references/visual-assets.md` — logo variants, SharePoint asset libraries and fetch workflow, and placeholder picture/icon frame filling.
- `references/layout-cheatsheet.md` — PowerPoint master layout map.
- `references/docs/brand-guide.pdf` — full Kainos visual identity guide for edge cases.
- `references/docs/brand-overview.pdf` — brand overview document.
- `references/templates/kainos-word-comprehensive.dotx` — Word template.
- `references/templates/kainos-pptx-master.pptx` — PowerPoint master template.
- `references/templates/kainos-word-comprehensive.pdf` — manually exported PDF preview of the Word template.
- `references/templates/kainos-pptx-master.pdf` — manually exported PDF preview of the PowerPoint master template.
- `references/assets/logos/` — primary Kainos logo images that models can copy into target repos.
- `scripts/` — optional home for reusable template edit scripts created by an agent.

## Logo Files

- `kainos-logo-primary-transparent.png` — default logo for white, light, or photographic backgrounds.
- `kainos-logo-primary.png` — fallback when transparent PNGs are not supported.
- `kainos-logo-alt-transparent.png` — alternate logo for Kainos green or gradient backgrounds.

Do not recolour, stretch, rotate, crop, or recreate the logos. Copy the relevant PNG into the target repo and reference it directly.

## UI Usage

For web/app work, load `SKILL.md` when the task asks to brand a UI, style a website, update CSS, or make an app look like Kainos. The skill points models to:

- `references/brand-rules.md` for colour, logo, typography, gradient, and tone rules.
- `references/ui-branding.md` for the full UI workflow, tokens, component recipes, and per-stack guidance.
- `references/assets/logos/` for logo files to copy into target repos.
- Public Kainos sites such as `https://www.kainos.com/` and `https://www.kainos.com/careers` for current UI cues.
- Portable component recipes for fresh repos, including tokens, gradients, headers, heroes, cards, buttons, forms, badges, and common page patterns.
- Cross-language implementation guidance for React, Vue, Angular, Svelte, Django/Jinja, Rails ERB, Laravel Blade, Java/Spring templates, ASP.NET Razor/Blazor, PHP/static sites, and mobile/native wrappers.

This package can be copied into a new repo and used without this project. UI branding should normally stay in templates, styles, assets, and display copy. Do not change business logic just to apply brand styling.

## Copying Into Another Repo Or Agent

Copy the entire `kainos-brand-enforcer/` directory, preserving the relative `references/` and `scripts/` folders. The skill instructions use paths relative to this directory, so partial copies will break template, logo, or PDF references.

For UI/code branding, the package is ready on its own: models can use the brand rules, logo PNGs, token recipes, gradients, and component guidance directly.

For Word/PowerPoint/PDF generation, the package includes the templates, but the host agent still needs some way to unpack/edit/repack Office files, or an equivalent binary-safe document editing workflow. If the host agent cannot edit `.pptx`/`.docx` packages safely, it can still use the templates and brand rules as references, but should not claim to have produced a fully template-correct deliverable.

If an agent cannot read `.dotx` or `.pptx` files directly, use the manually exported PDF previews in `references/templates/` for visual understanding. The previews are not source templates; generation should still start from the Office files in `references/templates/`.

Optional live assets such as icons, sub-brand logos, client logos, partner logos, illustrations, and photography are not bundled. The skill tells models to fetch those from the Kainos Organization Assets site only when needed and only if the host environment has access.