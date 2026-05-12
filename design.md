# Tesco Clone Design System

This document defines the CSS and visual design direction for the Tesco Clone storefront and admin UI. It is based on the current Tesco homepage reviewed on 2026-05-12, while keeping the implementation modern, maintainable, responsive, and distinct enough for a clone project.

## Styling Decision

Use SCSS with BEM-style class names as the primary styling approach, matching the project standard in `CLAUDE.md`.

Tailwind CSS is not currently part of this project standard. Do not add Tailwind by default unless the frontend implementation is later changed to require it. If Tailwind is introduced, map the design tokens in this file into `tailwind.config.ts` and keep reusable grocery UI patterns in Angular components rather than repeating long utility strings across templates.

## Design Principles

- Prioritize clarity, speed, and trust over decorative styling.
- Make grocery shopping flows dense but calm: search, departments, offers, basket, delivery, and account actions should be easy to scan.
- Use strong brand color only for navigation, primary actions, Clubcard pricing, and important promotional moments.
- Keep product cards compact, predictable, and comparable.
- Design mobile first, then expand into multi-column desktop layouts.
- Maintain accessibility: visible focus states, sufficient contrast, keyboard-friendly controls, and meaningful touch targets.

## Brand Direction

The live Tesco experience relies on a practical retail layout:

- Top utility links for services such as bank, mobile, delivery saver, store locator, and help.
- Header emphasis on Tesco identity, account entry points, department navigation, and search.
- Promotional sections such as "What's new this week?", "Top picks", "Ways to shop and save", Clubcard messaging, brand rails, help/community panels, and footer support links.
- A clean white content surface, blue brand framing, red accents, and yellow Clubcard offer moments.

The clone should feel familiar through structure, color, and shopping behavior, not through exact copied assets.

## Color Tokens

```scss
$color-tesco-blue: #00539f;
$color-tesco-blue-dark: #003f7d;
$color-tesco-blue-light: #e8f2fc;

$color-tesco-red: #e31837;
$color-tesco-red-dark: #b5122b;
$color-tesco-red-light: #fde8ec;

$color-clubcard-yellow: #ffdd00;
$color-clubcard-yellow-soft: #fff7bf;

$color-success: #007a3d;
$color-warning: #b36b00;
$color-error: #b00020;
$color-info: #00539f;

$color-ink: #1f1f1f;
$color-muted: #5f6368;
$color-border: #d8dde6;
$color-surface: #ffffff;
$color-surface-alt: #f5f7fa;
$color-surface-blue: #f1f7fd;
```

Usage guidance:

- Blue is the primary brand color for header, links, primary buttons, active tabs, and focus rings.
- Red is an accent for Tesco brand highlights, urgent offers, and destructive warnings only when appropriate.
- Yellow is reserved for Clubcard pricing, loyalty benefits, and savings badges.
- Neutral surfaces should do most of the work so product images, prices, and promotions remain readable.

## Typography

Use a modern system font stack for performance and native rendering:

```scss
$font-family-base: Arial, Helvetica, sans-serif;
```

Recommended scale:

```scss
$font-size-xs: 0.75rem;
$font-size-sm: 0.875rem;
$font-size-md: 1rem;
$font-size-lg: 1.125rem;
$font-size-xl: 1.5rem;
$font-size-2xl: 2rem;
```

Guidance:

- Body copy: `1rem` with `1.5` line height.
- Product names: `0.875rem` to `1rem`, two-line clamp where needed.
- Prices: bold, clear, and larger than product metadata.
- Section headings: direct and compact; avoid oversized marketing hero type inside grocery workflows.

## Spacing And Layout

```scss
$space-1: 0.25rem;
$space-2: 0.5rem;
$space-3: 0.75rem;
$space-4: 1rem;
$space-5: 1.5rem;
$space-6: 2rem;
$space-7: 3rem;

$container-max: 1280px;
$header-height: 72px;
$radius-sm: 4px;
$radius-md: 8px;
$shadow-card: 0 1px 3px rgba(31, 31, 31, 0.16);
$shadow-popover: 0 8px 24px rgba(31, 31, 31, 0.18);
```

Layout rules:

- Page content should sit inside a centered container with `max-width: 1280px`.
- Use full-width bands for navigation, promotional strips, and footer regions.
- Use cards only for products, offers, repeated content items, modals, and basket summaries.
- Keep card radius at `8px` or below.
- Avoid nested cards.

## Breakpoints

```scss
$breakpoint-sm: 480px;
$breakpoint-md: 768px;
$breakpoint-lg: 1024px;
$breakpoint-xl: 1280px;
```

Responsive behavior:

- Mobile: search and basket remain prominent; departments collapse into a menu.
- Tablet: use two to three columns for promotions and product rails.
- Desktop: use dense grids, sticky basket summary where useful, and horizontal department navigation.

## Core Components

### Header

- Blue top-level brand bar with Tesco identity, search, account, and basket.
- Secondary navigation for departments and key links: groceries, favourites, offers, Clubcard, recipes, and seasonal campaigns.
- Search should be visually central and use a high-contrast input with clear submit control.
- Basket button should expose item count and total when available.

### Department Navigation

- Use a simple list/grid with clear categories such as Fresh Food, Bakery, Frozen Food, Drinks, Baby, Health and Beauty, Pets, Household, Home, Electronics, Toys, Garden, and Kiosk.
- Active department uses blue text, blue underline, or a blue left border depending on viewport.
- Menus must support keyboard navigation and visible focus.

### Promotional Tiles

- Use image-led tiles with concise title, supporting text, and one call to action.
- Clubcard savings tiles may use yellow accents.
- Sale or urgent value messages may use red accents sparingly.
- Avoid long copy inside tiles; tiles should remain scannable.

### Product Cards

Required content:

- Product image area with stable aspect ratio.
- Product name.
- Price and unit price where available.
- Promotion or Clubcard badge where relevant.
- Quantity stepper or add button.
- Favourite/save action.

States:

- Default
- Hover/focus
- Loading
- Out of stock
- Restricted item
- Offer applied
- In basket

### Clubcard Price Treatment

- Use yellow background with blue or dark text.
- Keep the badge compact and close to the relevant price.
- Do not use yellow for unrelated marketing or warning states.

### Forms

- Inputs use white backgrounds, grey borders, and blue focus rings.
- Validation errors use red text and clear field-level messages.
- Delivery slot selectors should support date tabs, time windows, price labels, availability, and disabled states.

### Buttons

```scss
.button {
  border-radius: $radius-md;
  font-weight: 700;
  min-height: 44px;
}

.button--primary {
  background: $color-tesco-blue;
  color: $color-surface;
}

.button--secondary {
  background: $color-surface;
  border: 1px solid $color-tesco-blue;
  color: $color-tesco-blue;
}

.button--danger {
  background: $color-tesco-red;
  color: $color-surface;
}
```

Button guidance:

- Primary buttons are for checkout, add to basket, sign in, and confirmation actions.
- Secondary buttons are for filtering, changing slots, editing basket, and alternate actions.
- Icon buttons should use recognizable symbols and include accessible labels.

## SCSS Structure

Recommended Angular app styling structure:

```text
frontend/
  tesco-storefront/
    src/
      styles/
        _tokens.scss
        _mixins.scss
        _reset.scss
        _typography.scss
        _layout.scss
        _buttons.scss
        _forms.scss
        _badges.scss
        _cards.scss
        styles.scss
  tesco-admin/
    src/
      styles/
        _tokens.scss
        _mixins.scss
        _admin-layout.scss
        styles.scss
```

Component class naming:

```scss
.product-card {}
.product-card__image {}
.product-card__title {}
.product-card__price {}
.product-card__clubcard-badge {}
.product-card__actions {}
.product-card--out-of-stock {}
```

## Tailwind Option

If the project later chooses Tailwind CSS, keep the same token values:

```ts
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        tesco: {
          blue: '#00539f',
          blueDark: '#003f7d',
          red: '#e31837',
          yellow: '#ffdd00',
        },
        ink: '#1f1f1f',
        muted: '#5f6368',
        border: '#d8dde6',
        surface: '#ffffff',
      },
      borderRadius: {
        sm: '4px',
        md: '8px',
      },
      maxWidth: {
        page: '1280px',
      },
    },
  },
};
```

Tailwind usage standards:

- Use Tailwind for layout utilities and simple spacing.
- Keep repeated components wrapped in Angular components with semantic class names.
- Avoid long, duplicated utility chains in templates for product cards, checkout, forms, and admin tables.
- Preserve accessible focus, disabled, loading, and error states.

## Admin UI Direction

The admin panel should be quieter and denser than the storefront:

- White and light grey surfaces.
- Blue primary actions.
- Red only for destructive or critical operational states.
- Data tables with sticky headers where useful.
- Filters, bulk actions, status chips, pagination, and export controls.
- No promotional hero sections in admin workflows.

## Accessibility Standards

- Minimum target size: `44px` by `44px`.
- All interactive elements need visible focus.
- Do not communicate offers or stock status by color alone.
- Maintain contrast ratios of at least 4.5:1 for normal text.
- Support keyboard navigation for menus, filters, modals, basket controls, and checkout.
- Respect reduced motion preferences.

## Implementation Checklist

- Create shared SCSS tokens before building components.
- Keep global styles limited to reset, typography, layout helpers, and shared primitives.
- Build storefront components around product discovery, offers, basket, checkout, delivery, and Clubcard.
- Build admin components around tables, forms, filters, workflows, and audit-friendly states.
- Test layouts at mobile, tablet, desktop, and wide desktop sizes.
- Verify focus states, hover states, loading states, empty states, and error states before release.
