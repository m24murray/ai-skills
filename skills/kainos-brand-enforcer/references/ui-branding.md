# UI and Web Branding Workflow

Load this file when the task is to brand a website, app, page, component, stylesheet, design-token file, or any frontend implementation. For Word/PowerPoint/PDF work you do not need this file.

Use this workflow for UI code in any stack: HTML, CSS, JavaScript, TypeScript, React, Vue, Angular, Svelte, Nunjucks, Handlebars, Django/Jinja, Flask templates, Rails ERB, Laravel Blade, Java/Spring Thymeleaf/JSP, ASP.NET Razor/Blazor, PHP, static sites, component libraries, native/mobile UI wrappers, internal tools, forms, dashboards, and prototypes.

## 1. Read the local brand references first

- Load `references/brand-rules.md` for the exact colour palette, logo rules, typography hierarchy, gradient rules, and tone.
- Use `references/assets/logos/kainos-logo-primary-transparent.png` as the default logo for light backgrounds.
- Use `references/assets/logos/kainos-logo-primary.png` only when transparent PNGs are not supported.
- Use `references/assets/logos/kainos-logo-alt-transparent.png` on Kainos green, dark blue, dark green, or gradient backgrounds when the primary logo would clash.
- Consult `references/docs/brand-guide.pdf` only for edge cases such as logo exclusion zones, co-branding, photography, or complex brand interpretation.

## 2. Inspect public Kainos websites for current UI cues

Use these public sites as live visual references when internet/browser tools are available. Do not scrape private content; use them for layout, tone, hierarchy, spacing, navigation, and current brand expression.

- `https://www.kainos.com/` — primary corporate site; use for overall brand feel, navigation, colour balance, cards/sections, and CTA style.
- `https://www.kainos.com/careers` — careers tone and recruitment content patterns.
- `https://www.kainos.com/our-work` — case study structure, proof-point presentation, and content hierarchy.
- `https://www.kainos.com/digital-services` — service-page structure and enterprise/product language.
- `https://www.kainos.com/workday` — partner/service branding patterns where Kainos appears alongside Workday context.

Public websites are secondary references. If a site appears to conflict with `references/brand-rules.md`, follow the local brand rules for colours, logo treatment, and typography.

## 3. Start every UI from portable brand tokens

In a new repo, create the smallest useful token layer first. In an existing repo, map these values into the current design-token, Tailwind, CSS module, Sass, or theme system instead of introducing a parallel styling system.

```css
:root {
  --kainos-blue: #283583;
  --kainos-green: #61a83f;
  --kainos-mid-blue: #41679f;
  --kainos-dark-green: #004631;
  --kainos-grey: #575756;
  --kainos-white: #ffffff;
  --kainos-orange: #ec6608;
  --kainos-bright-green: #cfd600;
  --kainos-bright-blue: #009fda;

  --kainos-surface: #ffffff;
  --kainos-surface-soft: #f5f8fb;
  --kainos-text: #1f2933;
  --kainos-text-muted: #575756;
  --kainos-border: #d9e2ec;
  --kainos-focus: #009fda;

  --kainos-radius-sm: 4px;
  --kainos-radius-md: 8px;
  --kainos-shadow-sm: 0 1px 3px rgb(31 41 51 / 0.12);
  --kainos-shadow-md: 0 12px 28px rgb(40 53 131 / 0.16);
  --kainos-container: 1120px;
}
```

Rules:

- Use exact Kainos palette values for brand colour. Do not use generic blue/green near-matches.
- Keep secondary colours limited: orange `#ec6608`, bright green `#cfd600`, and bright blue `#009fda` are accents only and must not dominate a page.
- Use Kainos grey primarily for text and supporting rules, not as the main page fill.
- Keep the UI practical and confident: clear hierarchy, generous but not wasteful whitespace, useful content density, restrained motion, and no decorative shapes that fight the brand.

## 4. Build gradients as brand surfaces

Use the Kainos gradient for high-emphasis surfaces: hero bands, page headers, major section dividers, report covers, CTA bands, or empty-state headers. Do not make every card or button a gradient.

```css
.kainos-gradient {
  background:
    linear-gradient(45deg,
      var(--kainos-dark-green) 0%,
      var(--kainos-green) 34%,
      var(--kainos-mid-blue) 68%,
      var(--kainos-blue) 100%);
  color: var(--kainos-white);
}

.kainos-gradient--subtle {
  background:
    linear-gradient(45deg,
      rgb(0 70 49 / 0.95) 0%,
      rgb(97 168 63 / 0.92) 38%,
      rgb(65 103 159 / 0.94) 70%,
      rgb(40 53 131 / 0.96) 100%);
  color: var(--kainos-white);
}
```

Gradient rules:

- Approved direction is diagonal or vertical-ish: `45deg`, `0deg`, `-22.4deg`, or similar. Avoid `90deg` because it reads as a flat horizontal band.
- Place the alternate logo on gradient surfaces when the primary logo loses contrast.
- Put text directly on the gradient only when contrast is strong. Otherwise add a solid content area nearby rather than a translucent blur panel.
- Avoid one-note blue/green pages: pair gradient surfaces with white sections, grey text, and occasional secondary accents.

## 5. Use typography pragmatically on the web

Preferred brand fonts are Foundry Gridnik for large display headlines and Galano Grotesque for body/UI text. In most fresh repos those licensed web fonts will not be available.

Use this fallback strategy:

```css
:root {
  --font-display: "Foundry Gridnik", "Century Gothic", "Avenir Next", sans-serif;
  --font-body: "Galano Grotesque", "Century Gothic", "Avenir Next", sans-serif;
}

body {
  font-family: var(--font-body);
  color: var(--kainos-text);
  line-height: 1.55;
}

.display-heading {
  font-family: var(--font-display);
  font-weight: 700;
  letter-spacing: 0;
  text-transform: uppercase;
}
```

Rules:

- If the repo does not already include licensed web fonts, do not invent imports, download font files, or use unlicensed sources.
- Reserve all-caps treatment for short display headlines, eyebrow labels, or campaign-style statements. Body copy, buttons, forms, navigation, tables, and errors should use sentence case unless the existing product pattern says otherwise.
- Keep letter spacing at `0`; do not use heavy tracking as a substitute for brand fonts.

## 6. Use logos correctly in any repo

Copy the relevant PNG from this skill package into the target repo's public/static asset folder, then reference the copied asset from code. Examples:

- Vite/React: copy to `public/images/kainos-logo-primary-transparent.png`, reference `/images/kainos-logo-primary-transparent.png`.
- Next.js: copy to `public/images/kainos-logo-primary-transparent.png`, use `<Image src="/images/kainos-logo-primary-transparent.png" ... />` or a normal `img` if the project does not use `next/image`.
- Express/Nunjucks/static HTML: copy to `src/public/images/` or `public/images/`, matching the existing static middleware.
- Component library: store in the package's assets folder and export a `Logo` component that preserves aspect ratio.

Logo rules:

- Use `kainos-logo-primary-transparent.png` by default on white, light, or photographic backgrounds.
- Use `kainos-logo-primary.png` only when transparent PNGs are not supported.
- Use `kainos-logo-alt-transparent.png` on Kainos green, dark blue, dark green, or gradient backgrounds when the primary logo would clash.
- Do not crop, recolour, stretch, rotate, recreate, trace, inline-redraw, or replace the globe device.
- Preserve aspect ratio and give the logo enough clear space. Do not crowd it against nav links, page edges, or card borders.
- Use meaningful alt text when the logo links to home, e.g. `Kainos home`. Use empty alt text only when the logo is purely decorative and the brand/name is already present nearby.

## 7. Component recipes for new repos

When there is no existing component system, create these baseline components or equivalent template/CSS patterns. Keep the implementation idiomatic for the framework in use.

### App shell / header

- White header for normal pages; gradient or Kainos blue header only for high-emphasis experiences.
- Logo on the left, primary navigation next, compact action area on the right.
- Active nav state uses Kainos blue text with a Kainos green underline or left border.
- Mobile nav should collapse into a standard menu button with visible focus states.

```css
.site-header {
  background: var(--kainos-white);
  border-bottom: 1px solid var(--kainos-border);
}

.site-header__inner {
  align-items: center;
  display: flex;
  gap: 32px;
  margin: 0 auto;
  max-width: var(--kainos-container);
  min-height: 72px;
  padding: 0 24px;
}

.site-header__logo {
  display: block;
  height: 38px;
  width: auto;
}
```

### Hero / page intro

- Use a concise, confident headline with a clear supporting line.
- Put the logo in the nav/header, not inside every hero.
- Use a Kainos gradient hero for brand-forward pages; use a white intro for product/admin workflows.
- Do not put hero copy inside a decorative card unless the product design system already uses that pattern.

```css
.hero {
  background: linear-gradient(45deg, var(--kainos-dark-green), var(--kainos-green) 34%, var(--kainos-mid-blue) 68%, var(--kainos-blue));
  color: var(--kainos-white);
  padding: clamp(56px, 9vw, 112px) 24px;
}

.hero__inner {
  margin: 0 auto;
  max-width: var(--kainos-container);
}

.hero__title {
  font-family: var(--font-display);
  font-size: clamp(2.25rem, 6vw, 5rem);
  line-height: 0.98;
  margin: 0;
  max-width: 900px;
  text-transform: uppercase;
}
```

### Cards / content tiles

- Use cards for repeated items, search results, case studies, job roles, stats, or dashboard summaries.
- Keep radii modest: `4px` to `8px`. Avoid pillowy rounded cards unless the product already uses them.
- Use white cards on soft surfaces; reserve coloured cards for meaningful categorisation or status.

```css
.card {
  background: var(--kainos-white);
  border: 1px solid var(--kainos-border);
  border-radius: var(--kainos-radius-md);
  box-shadow: var(--kainos-shadow-sm);
  padding: 24px;
}

.card__title {
  color: var(--kainos-blue);
  font-size: 1.25rem;
  margin: 0 0 8px;
}
```

### Buttons and links

- Primary action: Kainos blue background, white text.
- Secondary action: white background, Kainos blue border/text.
- Destructive actions should not use Kainos green or orange as a shortcut; use the repo's existing danger colour or an accessible red if necessary.
- Links use Kainos blue and a visible underline on hover/focus.

```css
.button {
  align-items: center;
  border-radius: var(--kainos-radius-sm);
  border: 2px solid transparent;
  cursor: pointer;
  display: inline-flex;
  font-weight: 700;
  gap: 8px;
  justify-content: center;
  min-height: 44px;
  padding: 10px 18px;
  text-decoration: none;
}

.button--primary {
  background: var(--kainos-blue);
  color: var(--kainos-white);
}

.button--secondary {
  background: var(--kainos-white);
  border-color: var(--kainos-blue);
  color: var(--kainos-blue);
}

.button:focus-visible,
a:focus-visible {
  outline: 3px solid var(--kainos-focus);
  outline-offset: 3px;
}
```

### Forms

- Labels above fields, sentence case, clear helper/error text.
- Inputs use neutral borders and a Kainos bright-blue focus outline.
- Required/error states must not rely on colour alone.

```css
.form-field {
  display: grid;
  gap: 6px;
}

.form-field label {
  color: var(--kainos-blue);
  font-weight: 700;
}

.input {
  border: 1px solid var(--kainos-border);
  border-radius: var(--kainos-radius-sm);
  min-height: 44px;
  padding: 10px 12px;
}

.input:focus {
  border-color: var(--kainos-bright-blue);
  box-shadow: 0 0 0 3px rgb(0 159 218 / 0.22);
  outline: none;
}
```

### Status badges

- Use status colours sparingly and ensure text contrast.
- For neutral/open states, prefer blue/green combinations from the primary palette.
- For warning states, orange is allowed as an accent but must not dominate the surrounding UI.

```css
.badge {
  border-radius: 999px;
  display: inline-flex;
  font-size: 0.875rem;
  font-weight: 700;
  line-height: 1;
  padding: 6px 10px;
}

.badge--open {
  background: rgb(97 168 63 / 0.15);
  color: var(--kainos-dark-green);
}

.badge--closed {
  background: rgb(87 87 86 / 0.14);
  color: var(--kainos-grey);
}
```

## 8. Page patterns for common Kainos-style UIs

- **Careers / job listings:** clear page intro, filters/search if needed, list cards with role, capability/team, location, status, and deadline. Use the Kainos tone: direct, human, optimistic.
- **Service pages:** hero or intro, proof points, capability cards, case-study links, CTA band. Use primary colours and one secondary accent at most.
- **Dashboards/internal tools:** quieter, denser, white/soft-grey surfaces, Kainos blue headings, green for positive state, bright blue for focus/links. Avoid marketing-style hero treatments.
- **Error/empty states:** concise explanation, practical next action, optional logo/brand mark. Do not over-decorate.
- **Case studies:** strong headline, client/context summary, outcomes/stat cards, body sections with restrained imagery.

## 9. Adapt to the target repo and language

Start by identifying where the target stack keeps four things: design tokens/theme values, static assets, reusable UI components/templates, and page-level layouts. Put the Kainos brand rules into those existing places.

| Stack/language | Put tokens/styles here | Put logos here | Build components/views here |
|----------------|------------------------|----------------|-----------------------------|
| Plain HTML/CSS/JS | `styles.css`, `tokens.css`, or a shared CSS file | `public/images/` or `assets/images/` | HTML partials or repeated semantic markup |
| React/TypeScript/Vite | global CSS, CSS modules, styled components, or theme object | `public/images/` or `src/assets/` | `components/Logo`, `Header`, `Button`, `Card`, `FormField` |
| Next.js | `app/globals.css`, CSS modules, Tailwind config, or theme provider | `public/images/` | `app/` layouts and reusable components |
| Vue/Nuxt | global CSS, scoped component styles, or theme config | `public/images/` or `assets/` | Vue components and layouts |
| Angular | `styles.scss`, theme files, component styles | `src/assets/images/` | Angular components/modules |
| Svelte/SvelteKit | `app.css`, component styles, or route layouts | `static/images/` | Svelte components and layouts |
| Tailwind | `theme.extend.colors`, CSS variables, and component classes | framework public/static folder | components/templates using utilities plus extracted classes |
| Django/Flask/Jinja | static CSS plus template blocks/includes | `static/images/` | templates, includes, macros |
| Rails ERB | asset pipeline/importmap CSS or app stylesheets | `app/assets/images/` or `public/images/` | ERB partials, helpers, view components |
| Laravel Blade/PHP | app CSS/theme file | `public/images/` | Blade components/includes or PHP templates |
| Java/Spring Thymeleaf/JSP | static CSS under resources | `src/main/resources/static/images/` | Thymeleaf fragments/JSP includes |
| ASP.NET Razor/Blazor | `wwwroot/css`, scoped CSS, theme files | `wwwroot/images/` | Razor components, layouts, partials |
| Mobile/native wrappers | platform theme files/style objects | platform asset catalog/drawables | reusable screen/header/button/card components |

Implementation rules across languages:

- Do not translate brand rules into language-specific business logic. Keep them in presentation/theme/assets layers.
- Use the idioms of the target language: CSS variables for web, theme objects for component frameworks, resource dictionaries for .NET/XAML, XML drawables/styles for Android, asset catalogs and design constants for iOS, or shared style objects for React Native/Flutter.
- If a stack cannot use CSS variables, still preserve the same token names semantically in constants or theme keys, e.g. `kainosBlue`, `kainosGreen`, `kainosGradient`, `primaryButton`, `surfaceSoft`.
- If a stack already has a design system, add Kainos as a theme or variant rather than bypassing existing primitives.
- If there is no frontend structure yet, create the smallest maintainable structure: a static image folder for logos, one shared stylesheet/theme file, and reusable header/button/card/form patterns.
- Do not change business logic just to apply branding. Keep UI branding changes in templates, styles, assets, component markup, view models for display-only copy, and accessibility metadata unless behaviour genuinely needs to change.
- Preserve accessibility in every language: semantic headings or platform equivalents, keyboard/focus states where applicable, sufficient contrast, labels for form controls, responsive/adaptive layouts, and non-colour-only status indicators.

## UI delivery checklist

- [ ] Uses exact Kainos palette values from `references/brand-rules.md`.
- [ ] Secondary colours are accents only and do not dominate the interface.
- [ ] Logo comes from `references/assets/logos/`, is copied into the app assets, and is not modified.
- [ ] Logo variant matches the background.
- [ ] Typography follows brand intent with licensed fonts if present, or sensible fallbacks if not.
- [ ] Tone is confident, plain-spoken, optimistic, and human.
- [ ] Layout is responsive and does not overlap or truncate important text.
- [ ] Colour contrast is accessible for text, controls, and focus states.
- [ ] Existing app conventions are preserved; unrelated behaviour is not changed.
- [ ] Browser/UI check or screenshot check has been run when available.
