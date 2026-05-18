# Tesco Clone — UI/UX Design Guidelines

> Authoritative design reference for the customer storefront and admin panel.
> All values in this file are the source of truth. Never hardcode colours, spacing, or type sizes inline — always use tokens from `_tokens.scss`.

---

## Design Principles

- **Clarity over decoration.** Grocery shopping is a task, not an experience. Remove anything that slows the user's path to finding, adding, and buying.
- **Brand through structure.** Use Tesco blue for navigation, primary CTAs, and Clubcard moments. Let white space and product images carry most of the visual weight.
- **Mobile first.** Design and test at 375px width before expanding to tablet and desktop. Every layout must be functional on a phone.
- **Accessible by default.** Every interactive element must be keyboard-reachable, have a visible focus ring, and meet WCAG 2.1 AA contrast ratios.
- **Consistent over clever.** Reuse existing components before inventing new patterns. A new card design is technical debt if an existing one can be adapted.
- **Performance is a feature.** Skeleton loaders, optimistic UI updates, and debounced search inputs all reduce perceived latency.

---

## Styling Decision

Use **SCSS with BEM-style class names** as the primary styling approach. Do not add Tailwind CSS without a team decision — the token file is Tailwind-ready (see end of this document) if that decision is made later.

---

## Brand Tokens

### Colour Palette

```scss
// Primary brand
$color-tesco-blue:       #00539f;   // nav, primary CTAs, links, focus rings
$color-tesco-blue-dark:  #003f7d;   // hover state on blue buttons
$color-tesco-blue-light: #e8f2fc;   // active nav backgrounds, info banners

$color-tesco-red:        #e31837;   // sale badges, destructive actions, urgent alerts
$color-tesco-red-dark:   #b5122b;   // hover on red buttons
$color-tesco-red-light:  #fde8ec;   // error state backgrounds

// Clubcard
$color-clubcard-yellow:  #ffdd00;   // Clubcard price badges, loyalty highlights ONLY
$color-clubcard-yellow-soft: #fff7bf; // Clubcard section backgrounds

// Semantic
$color-success:          #007a3d;
$color-warning:          #b36b00;
$color-error:            #b00020;
$color-info:             #00539f;

// Neutrals
$color-ink:              #1f1f1f;   // primary text
$color-muted:            #5f6368;   // secondary text, captions
$color-border:           #d8dde6;   // borders, dividers
$color-surface:          #ffffff;   // card and page backgrounds
$color-surface-alt:      #f5f7fa;   // page background, sidebar, table rows
$color-surface-blue:     #f1f7fd;   // Clubcard section fills
```

Usage rules:
- Blue is the **only** primary brand colour for buttons, links, and active states
- Yellow is **exclusively** for Clubcard pricing and loyalty moments — never for warnings
- Red is for sale badges, destructive warnings, and error states only — not general accents
- Never use colour alone to communicate state — always pair with an icon or text label

### Typography

```scss
$font-family-base: Arial, Helvetica, sans-serif;  // system font — fast, native

// Scale
$font-size-xs:   0.75rem;    // 12px — labels, captions, per-unit price
$font-size-sm:   0.875rem;   // 14px — body small, helper text
$font-size-md:   1rem;       // 16px — default body text
$font-size-lg:   1.125rem;   // 18px — lead text, subheadings
$font-size-xl:   1.5rem;     // 24px — page titles
$font-size-2xl:  2rem;       // 32px — hero headlines

// Weight
$font-weight-regular: 400;
$font-weight-bold:    700;

// Line height
$line-height-base:  1.5;
$line-height-tight: 1.2;
```

Guidance:
- Body copy: `$font-size-md` / `$line-height-base`
- Product names: `$font-size-sm` to `$font-size-md`, two-line clamp
- Prices: `$font-weight-bold`, `$font-size-lg` — larger than metadata
- Section headings: compact; avoid oversized marketing type inside grocery flows

### Spacing Scale

All spacing must be a multiple of 4px. Never use `px` values directly in component styles.

```scss
$space-1: 0.25rem;   // 4px
$space-2: 0.5rem;    // 8px
$space-3: 0.75rem;   // 12px
$space-4: 1rem;      // 16px
$space-5: 1.5rem;    // 24px
$space-6: 2rem;      // 32px
$space-7: 3rem;      // 48px
```

### Layout Constants

```scss
$container-max:    1280px;
$header-height:    72px;
$sidebar-width:    240px;   // admin sidebar expanded
$sidebar-min:      72px;    // admin sidebar collapsed (icon-only)
$radius-sm:        4px;     // inputs, small tags
$radius-md:        8px;     // cards, buttons, modals
$shadow-card:      0 1px 3px rgba(31, 31, 31, 0.16);
$shadow-popover:   0 8px 24px rgba(31, 31, 31, 0.18);
```

### Breakpoints

```scss
$breakpoint-sm:  480px;    // large phones
$breakpoint-md:  768px;    // tablet portrait
$breakpoint-lg:  1024px;   // desktop
$breakpoint-xl:  1280px;   // wide desktop
```

Responsive rules:
- Mobile (<768px): search bar full-width, departments in hamburger menu, 2-column product grid
- Tablet (768–1023px): 3-column product grid, collapsible filter panel
- Desktop (1024px+): full header nav, 4–5 column product grid, basket sidebar, filter panel expanded

---

## SCSS File Structure

```text
frontend/
  tesco-storefront/src/styles/
    _tokens.scss        ← all variables (colours, spacing, type, shadows, breakpoints)
    _reset.scss         ← CSS reset / normalize
    _mixins.scss        ← reusable SCSS mixins (container, truncate, visually-hidden, etc.)
    _typography.scss    ← base type styles
    _layout.scss        ← container, grid, page-section utilities
    _buttons.scss       ← .btn and all variants
    _forms.scss         ← .form-group, .form-label, .form-control, .form-error
    _badges.scss        ← .badge, offer/Clubcard/status variants
    _cards.scss         ← .card base styles
    styles.scss         ← imports all partials; global body/html rules

  tesco-admin/src/styles/
    _tokens.scss        ← same token values (shared colour/spacing/type)
    _mixins.scss
    _admin-layout.scss  ← sidebar, topbar, main content shell
    _admin-table.scss   ← data table patterns
    _admin-forms.scss   ← admin form cards and fieldsets
    styles.scss
```

### BEM Class Naming

```scss
.product-card { }                        // block
.product-card__image { }                 // element
.product-card__title { }                 // element
.product-card__price { }                 // element
.product-card__clubcard-badge { }        // element
.product-card__actions { }              // element
.product-card--out-of-stock { }          // modifier
.product-card--in-basket { }             // modifier
```

Rules:
- One block per component file
- Never nest more than 3 levels deep in BEM (`block__element__sub` is wrong — extract a new block)
- Use modifiers for state, not JavaScript classes — Angular should bind `[class.product-card--loading]="isLoading"`

---

## Component Standards

### Header

- Fixed/sticky — always visible
- Desktop structure: [Logo] [Department nav tabs] [Search] [Clubcard] [Account] [Basket]
- Mobile: [Logo] [Search icon] [Basket icon] [Hamburger]
- On scroll past 60px: height reduces from `$header-height` to 56px with CSS transition
- Department nav: show category tabs; active tab has `$color-tesco-blue` underline
- Account dropdown: "Sign in", "Register", or avatar with "My Account" / "Orders" / "Sign out"
- Basket icon: shows item count badge (red, `$font-size-xs`, max "99+")

### Product Card

Required elements in every card:

```
┌─────────────────────────────┐
│  [Image — 3:2 aspect ratio] │  ← lazy-loaded, stable CLS-safe dimensions
│  [Offer badge top-left]     │  ← red or Clubcard yellow
├─────────────────────────────┤
│  Brand name  (xs, muted)    │
│  Product name (sm, 2-line)  │
│  Price: £2.50    (lg, bold) │
│  Clubcard: £2.00  (yellow)  │
│  Per unit: £0.50/100g (xs)  │
│                             │
│  [Add to basket ────────]   │  ← converts to stepper once in basket
└─────────────────────────────┘
```

States to implement: default, hover (+shadow +translateY), loading (skeleton), out-of-stock (greyed, no CTA), offer-applied (badge visible), in-basket (stepper replaces button).

### Quantity Stepper

```
[−]  [  2  ]  [+]
```

- Min: 1; Max: 99 (or current stock)
- Debounce API call by **400ms**
- Show inline spinner during API call; disable both buttons
- At quantity 1: `−` shows trash icon — click removes item from cart
- Minimum touch target: 44×44px on all buttons

### Buttons

```scss
.btn { border-radius: $radius-md; font-weight: $font-weight-bold; min-height: 44px; }

.btn--primary   { background: $color-tesco-blue; color: $color-surface; }
.btn--secondary { background: $color-surface; border: 1px solid $color-tesco-blue; color: $color-tesco-blue; }
.btn--danger    { background: $color-tesco-red; color: $color-surface; }
.btn--ghost     { background: transparent; color: $color-tesco-blue; }
.btn--loading   { opacity: 0.7; pointer-events: none; /* show spinner */ }
.btn--full      { width: 100%; }
.btn--sm        { min-height: 36px; font-size: $font-size-sm; }
```

Rules:
- All buttons must have a **visible focus ring**: `outline: 2px solid $color-tesco-blue; outline-offset: 2px`
- Disabled: `opacity: 0.5; cursor: not-allowed; pointer-events: none`
- Loading state must show a spinner and disable the button to prevent double-submit
- Never use `<div>` or `<span>` as a button

### Forms

```scss
.form-group    { margin-bottom: $space-4; }
.form-label    { font-size: $font-size-sm; font-weight: $font-weight-bold; margin-bottom: 6px; }
.form-control  { width: 100%; height: 44px; border: 1px solid $color-border; border-radius: $radius-sm; padding: 0 $space-3; }
.form-control:focus    { border-color: $color-tesco-blue; outline: 2px solid $color-tesco-blue; outline-offset: 1px; }
.form-control--error   { border-color: $color-error; }
.form-error    { font-size: $font-size-xs; color: $color-error; margin-top: 4px; }
.form-hint     { font-size: $font-size-xs; color: $color-muted; margin-top: 4px; }
```

Rules:
- Every input must have an associated `<label for="...">` — no placeholder-only labels
- Error messages must use `role="alert"` or `aria-describedby` so screen readers announce them
- Validate on **blur** for a better UX — not only on submit

### Clubcard Badge

```scss
.clubcard-badge {
  background: $color-clubcard-yellow;
  color: $color-ink;
  font-size: $font-size-xs;
  font-weight: $font-weight-bold;
  border-radius: $radius-sm;
  padding: 2px $space-2;
}
```

- Yellow background is used **exclusively** for Clubcard; never for other purposes
- Must appear on product card, product detail, and cart summary — same styling in all three places

### Alert / Toast Notifications

Variants: success (green), error (red), warning (amber), info (blue)

- Position: top-right stack on desktop; full-width banner on mobile
- Auto-dismiss: 5 seconds for success/info; stay open for error/warning
- Must carry `role="alert"` so screen readers announce the message
- Never auto-dismiss an error

### Pagination

```
[← Prev]  1  2  [3]  4  5  ...  12  [Next →]
```

- Show max 7 page numbers; `…` ellipsis for large counts; always show first and last
- Current page: `$color-tesco-blue` fill, white text
- Disabled Prev on page 1; disabled Next on last page

### Skeleton Loading States

Replace generic spinners with shimmer skeletons for:
- Product grids (card-shaped shimmer blocks)
- Data tables in admin (row shimmer)
- Order/account page sections

```scss
@keyframes shimmer {
  from { background-position: -400px 0; }
  to   { background-position: 400px 0; }
}
.skeleton {
  background: linear-gradient(90deg, $color-surface-alt 25%, $color-border 50%, $color-surface-alt 75%);
  background-size: 800px 100%;
  animation: shimmer 1.5s infinite;
  border-radius: $radius-sm;
}
```

---

## Page-Level Layout Guidelines

### Home Page — Section Order

1. Hero banner (full-width, 560px tall on desktop, 300px mobile)
2. Quick-access icon strip (Groceries / Fresh Food / Deals / Clubcard / Recipes)
3. "Top picks" product carousel (horizontal scroll with arrows)
4. "Deals and offers" horizontal product strip
5. Clubcard promotional banner (yellow background section)
6. Recipe cards (3-column desktop, 1-column mobile)
7. Secondary banner (seasonal / category highlight)
8. Footer promo links

### Category Page — Layout

```
[ Sub-category chip strip — sticky below header, horizontal scroll on mobile ]
┌────────────────────────────────┬─────────────────────────────────────────────┐
│  Filter panel  (240px desktop) │  Sort bar: "240 items" + sort dropdown      │
│  - Price range slider          │  Product grid (4-col desktop, 2-col mobile) │
│  - Brand checkboxes            │  ...                                        │
│  - Dietary / Free-from         │  [ Load more / Pagination ]                 │
│  - Special offers toggle       │                                             │
│  ← drawer on mobile            │                                             │
│                                ├─────────────────────────────────────────────┤
│                                │  Basket sidebar (320px, desktop only)       │
└────────────────────────────────┴─────────────────────────────────────────────┘
```

### Product Detail Page

- Breadcrumb at top: Home › Dairy › Milk › Semi-Skimmed Milk
- Image gallery left (with thumbnail strip below); product info right
- Below fold: tabbed content (Description | Nutritional Info | Storage | Reviews placeholder)
- "You may also like" carousel at the bottom

### Checkout — Three Steps

| Step | Description |
|---|---|
| 1 — Delivery | Postcode entry → available slot grid → select and confirm |
| 2 — Payment | Saved cards + "Add card" (Stripe Elements) + voucher/Clubcard apply |
| 3 — Review | Full order summary, delivery slot, total, "Place Order" |

- Sticky progress indicator (Step 1/2/3) at top of page
- "Place Order" button shows loading state; disabled until complete; prevents double-submit
- Redirect to order confirmation with order number after success

---

## Admin Panel UI Guidelines

### Sidebar Navigation

- Fixed left sidebar, `$sidebar-width` (240px)
- Groups: Dashboard / Catalogue / Orders / Promotions / Users / Content / Marketplace / Analytics / Audit
- Active item: `$color-tesco-blue` left border (3px) + `$color-surface-blue` background
- Collapse to icon-only (`$sidebar-min` = 72px) on tablet
- Mobile: hidden by default; toggle overlay with hamburger; **must trap focus** when open

### Admin Data Table Pattern

Every admin list view must follow this layout:

```
┌─ [Search]  [Filters...]  [Date range]  ──────────────  [+ Add New] ─┐
│  Col A ↕  │  Col B ↕  │  Col C  │  Status badge  │  Actions        │
│  ...      │  ...      │  ...    │  ● Active       │  [✏] [👁] [🗑] │
│  ...      │  ...      │  ...    │  ○ Inactive     │  ...            │
└─────────────────────────────────────────────────────────────────────┘
  Showing 1–20 of 150                    [1] [2] [3] ... [8]  [Next →]
```

Rules:
- Sortable columns show `↕`; active sort shows `↑` or `↓`
- Status badges: Active=green, Inactive=grey, Deleted=red, Pending=amber
- Action icons have tooltips on hover; show labels on mobile
- Destructive actions (delete, suspend) open a confirmation modal — never inline
- Empty state: illustration + "No results found" + "Clear filters" link

### Admin Form Pages

- Card container, `max-width: 800px`, centred
- Group related fields with `<fieldset>` + `<legend>`
- Show unsaved-changes warning on navigation away (`CanDeactivate` guard)
- Buttons: "Save" (primary, bottom-right) + "Cancel" (ghost, left of Save)
- Success: toast notification; Errors: inline field-level validation messages

---

## Accessibility Standards (WCAG 2.1 AA)

| Requirement | Implementation |
|---|---|
| Colour contrast | 4.5:1 for normal text; 3:1 for large text and UI components |
| Focus management | Visible `outline: 2px solid $color-tesco-blue` on all interactive elements; trap focus in modals/drawers |
| Screen reader labels | `aria-label` on icon-only buttons; `aria-describedby` linking inputs to error/hint text |
| Keyboard navigation | Tab order logical; modals close on `Escape`; dropdown menus navigate with arrow keys |
| Image alt text | Every `<img>` has descriptive `alt`; decorative images use `alt=""` |
| Skip link | "Skip to main content" anchor at top of every page (visible on focus) |
| Form errors | `role="alert"` on error containers; errors associated via `aria-describedby` |
| Loading states | `aria-busy="true"` on loading regions; announce completion to screen reader |
| Semantic HTML | `<nav>`, `<main>`, `<header>`, `<footer>`, `<section>`, `<article>` used correctly |
| Reduced motion | Wrap animations in `@media (prefers-reduced-motion: no-preference)` |
| Touch targets | Minimum 44×44px for all interactive elements on mobile |

---

## Performance Guidelines

### Images

- Always set `width` and `height` attributes to prevent CLS (Cumulative Layout Shift)
- Lazy-load below-the-fold images with `loading="lazy"`
- Product card: 400×300px; detail page: 800×600px; hero: 1200×560px
- Provide WebP via `<picture>` with JPEG fallback

### Angular Performance

- `ChangeDetectionStrategy.OnPush` on **every** component — no exceptions
- `trackBy` on every `*ngFor` loop
- Use `@for ... track` for new components (Angular 17+ syntax)
- Debounce search input by **300ms** before API call
- Use `@defer` blocks for below-fold, non-critical sections
- Never inject `HttpClient` directly in a component — always go through a service

### Network

- Cache `GET` responses in signals/NgRx selectors — avoid redundant API calls on re-render
- Show skeleton loading state while data is in flight — never block the template
- Stripe.js loads asynchronously — `provideNgxStripe()` is already wired in `app.config.ts`

---

## Storefront vs Admin Design Alignment

| Concern | Storefront | Admin |
|---|---|---|
| Primary colour | `$color-tesco-blue` | Same |
| Background | White / `$color-surface-alt` | `$color-surface-alt` sidebar, white content |
| Typography | Retail, slightly larger scale | Compact, data-dense |
| Navigation | Horizontal top-bar with mega-menu | Fixed left sidebar with groups |
| Density | Spacious — shopping feel | Dense — power-user tools |
| Components | Cards, carousels, product grids | Tables, forms, status badges |
| Animations | Subtle hover/transition on cards | Minimal — favour performance |

When adding an admin component, always check if an existing storefront SCSS mixin (`_buttons.scss`, `_forms.scss`, `_badges.scss`) can be reused before writing new styles.

---

## Design Debt — Required Improvements

The following issues should be resolved in the next UI sprint. Ordered by impact:

| Issue | Priority | Detail |
|---|---|---|
| No skeleton loading states | **High** | All lists use a generic spinner; replace with shimmer skeletons for product grids and admin tables |
| Product card image fallback | **High** | No `onerror` handler; broken images show as empty boxes — add a placeholder SVG fallback |
| Mobile checkout UX | **High** | Three-step checkout scroll management and step transitions are unpolished on phones below 375px |
| Admin sidebar focus trap | **High** | Mobile overlay does not trap focus when open — keyboard users can tab behind the drawer |
| Clubcard badge inconsistency | **Medium** | Badge styling differs between product card, detail page, and cart — consolidate to one `.clubcard-badge` class |
| Admin empty states | **Medium** | Empty tables show nothing; add an empty-state illustration + CTA for every admin table |
| Pagination ellipsis | **Medium** | `…` ellipsis is absent on high page counts; implement the full 1…3 4 5…12 pattern |
| Form validation timing | **Medium** | Some forms validate on submit only; move to `blur` event for inline validation |
| Reduced motion support | **Medium** | No `@media (prefers-reduced-motion)` guards on card hover transitions or shimmer animations |
| Dark mode | **Low** | Token file is ready; no `@media (prefers-color-scheme: dark)` rules implemented |
| Animation consistency | **Low** | Card hover transitions exist in some places but not others — establish a single motion scale |

---

## Tailwind Option (Future)

If the project later adopts Tailwind CSS, map the token values directly:

```ts
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        tesco: { blue: '#00539f', blueDark: '#003f7d', red: '#e31837', yellow: '#ffdd00' },
        ink: '#1f1f1f',
        muted: '#5f6368',
        border: '#d8dde6',
        surface: '#ffffff',
        'surface-alt': '#f5f7fa',
      },
      borderRadius: { sm: '4px', md: '8px' },
      maxWidth: { page: '1280px' },
    },
  },
};
```

If Tailwind is introduced: keep repeated UI components as Angular components with semantic class names rather than duplicating long utility chains across templates. Preserve all focus, disabled, loading, and error state behaviours.

---

## Implementation Checklist

Before marking any UI feature as complete, verify:

- [ ] All values reference tokens from `_tokens.scss` — no hardcoded hex, px, or font sizes
- [ ] Component uses `ChangeDetectionStrategy.OnPush`
- [ ] Focus ring is visible on all interactive elements
- [ ] Colour contrast passes 4.5:1 for body text
- [ ] Loading state is a skeleton or spinner (not blank)
- [ ] Empty state is handled (not a blank page)
- [ ] Error state is handled with an inline message
- [ ] Tested at 375px, 768px, 1024px, and 1280px
- [ ] All `<img>` elements have `alt` text and `width`/`height` attributes
- [ ] No `console.error` or `console.warn` in browser DevTools
