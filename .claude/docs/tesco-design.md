# Tesco.com – UI/UX Design Reference

A comprehensive design document derived from analysing the Tesco.com homepage and its component patterns. Use this as a reference for replicating or building upon Tesco's design system.

---

## 1. Brand Identity

| Property | Value |
|---|---|
| Brand Name | Tesco |
| Primary Brand Colour | `#005DAA` (Tesco Blue) |
| Accent Colour | `#EE1C2E` (Tesco Red) |
| Loyalty Programme Colour | `#004F9F` (Clubcard Deep Blue) |
| Background | `#FFFFFF` (White) |
| Surface / Card Background | `#F2F2F2` (Light Grey) |
| Text Primary | `#1A1A1A` (Near Black) |
| Text Secondary | `#555555` (Medium Grey) |
| Border / Divider | `#D8D8D8` (Light Grey) |
| Success / Offer Badge | `#007A33` (Green) |

---

## 2. Typography

### Font Stack
- Primary: `"Tesco Modern", "Arial", sans-serif`
- Fallback: `Arial, Helvetica, sans-serif`

### Scale

| Role | Size | Weight | Line Height |
|---|---|---|---|
| Page Title / H1 | 28px | 700 (Bold) | 1.2 |
| Section Heading / H2 | 22px | 700 | 1.3 |
| Card Heading / H3 | 18px | 600 (Semibold) | 1.35 |
| Body Text | 16px | 400 (Regular) | 1.5 |
| Secondary / Caption | 14px | 400 | 1.4 |
| Small Label / Badge | 12px | 600 | 1.2 |

### Text Styles
- Headings are sentence-case (not ALL CAPS).
- CTA link text uses short, action-oriented phrases: "Explore the range", "Shop now", "Find out more".
- Descriptions are concise — typically 1–2 lines under the card heading.

---

## 3. Layout & Grid

### Page Container
- Max width: `1280px`
- Horizontal padding: `16px` (mobile), `24px` (tablet), `32px` (desktop)
- Centred on page

### Grid System
- Desktop: 12-column grid, `24px` gutters
- Tablet: 8-column grid, `16px` gutters
- Mobile: 4-column grid, `16px` gutters

### Content Sections (Rows)
Each homepage section follows a consistent vertical rhythm:
- Section top padding: `32px`
- Section bottom padding: `32px`
- Section heading margin-bottom: `16px`

---

## 4. Navigation

### Top Utility Bar
- Background: `#005DAA` (Blue)
- Text colour: `#FFFFFF`
- Font size: 13px
- Links: Tesco Bank, Tesco Mobile, Delivery Saver, Store Locator, Help
- Alignment: Right-aligned on desktop

### Primary Navigation Bar
- Background: `#FFFFFF`
- Logo: Tesco wordmark, left-aligned
- Search bar: Centre-positioned, full-width on mobile
- Sign In / Register: Right-aligned, ghost button style
- Height: ~64px desktop, ~56px mobile

### Secondary Nav / Department Bar
- Background: `#F2F2F2`
- Items: All Departments (mega menu), Groceries & Essentials, My Favourites, Special Offers, Tesco Clubcard, F&F Clothing, New and Trending, Recipes
- Active item: Underline with `#005DAA` blue, `3px` thick
- Overflow items collapsed into a "More" dropdown

### Mega Menu (All Departments)
- Full-width overlay panel
- Two-column grid listing all department categories
- Category icons (circular thumbnails, `40px`) alongside text labels
- Close button top-right

---

## 5. Components

### 5.1 Circular Category Roundels
Used for the "Shop by Department" section and "Shop by Brand" section.

```
• Size: 160px × 160px (desktop), 100px × 100px (mobile)
• Image: Circular crop (border-radius: 50%)
• Label: Below image, centred, 14px, semibold
• Hover: Slight scale-up (transform: scale(1.03)) with shadow
• Scroll: Horizontally scrollable carousel on mobile
```

### 5.2 Promotional Banner Cards
Used in "What's new this week?", "Top picks for you", "Ways to shop and save" sections.

```
• Layout: Rectangular card, image top, text below
• Image aspect ratio: 16:9 or 3:2
• Card title: 18px bold
• Card body: 14px regular, 2-line max
• CTA text link: 14px, blue, underline on hover
• Border radius: 4px
• Box shadow: none by default; subtle on hover
• Columns: 3-up on desktop, 2-up on tablet, 1-up on mobile
```

### 5.3 Hero / Feature Banners
Large full-width or 2/3-width promotional areas.

```
• Height: 320px (desktop), 200px (mobile)
• Overlay text: Left-aligned on image
• Heading: 24–28px bold, white or dark depending on image
• Body: 16px
• CTA Button: Primary blue button
• Border radius: 4px
```

### 5.4 Buttons

**Primary Button**
```css
background: #005DAA;
color: #FFFFFF;
border: none;
border-radius: 4px;
padding: 12px 24px;
font-size: 16px;
font-weight: 600;
cursor: pointer;
```

**Secondary / Ghost Button**
```css
background: transparent;
color: #005DAA;
border: 2px solid #005DAA;
border-radius: 4px;
padding: 10px 22px;
font-size: 16px;
font-weight: 600;
```

**Clubcard / Loyalty Button**
```css
background: #004F9F;
color: #FFFFFF;
border-radius: 20px; /* pill shape */
padding: 8px 20px;
font-size: 14px;
font-weight: 700;
```

**Add to Basket Button**
```css
background: #007A33; /* Green */
color: #FFFFFF;
border-radius: 4px;
padding: 10px 16px;
font-size: 15px;
font-weight: 600;
```

### 5.5 Search Bar
```
• Width: ~50% of header on desktop, full-width on mobile
• Height: 44px
• Border: 1px solid #D8D8D8
• Border radius: 4px
• Search icon: Right-aligned inside input, #005DAA
• Placeholder text: "Search products, brands and more…"
• Focus state: Border colour changes to #005DAA, box-shadow
```

### 5.6 Carousel / Scroll Row
Used for roundels and promotional cards.

```
• Horizontal scroll on mobile (snap scroll)
• Navigation arrows on desktop (left/right chevrons, circular buttons)
• Arrow button: 40px circle, #FFFFFF background, #555555 icon, shadow
• Item count badge: Top-right of section heading (e.g. "22 items")
• Scroll indicator: Dots or none
```

### 5.7 Offer / Price Badge
```
• Background: #EE1C2E (Red) for general offers
• Background: #004F9F (Blue) for Clubcard Prices
• Text: White, 12px bold
• Shape: Pill or square with rounded corners (4px)
• Placement: Top-left corner of product card
```

### 5.8 Footer
Four columns on desktop, stacked on mobile.

**Columns:**
1. Here to Help — My Account, Orders, Help & FAQs, Product Recall, Privacy Centre, Pharmacy, Photo, Magazine
2. About — Accessibility, Sitemap, Privacy & Cookies, Cookie Settings, T&Cs
3. Ways to Save — Delivery Saver, Clubcard, Click+Collect, Clubcard Prices
4. Support — Contact Us, Store Locator

**Footer styling:**
```
• Background: #1C1C1C (Dark)
• Text colour: #CCCCCC
• Link hover: #FFFFFF
• Copyright bar background: #000000
• Payment icons (Visa, Mastercard, Amex) bottom-right
• Social media icons: Follow us row at bottom
```

---

## 6. Spacing & Sizing System

Based on an 8px base unit:

| Token | Value |
|---|---|
| `space-xs` | 4px |
| `space-sm` | 8px |
| `space-md` | 16px |
| `space-lg` | 24px |
| `space-xl` | 32px |
| `space-2xl` | 48px |
| `space-3xl` | 64px |

---

## 7. Imagery Guidelines

- **Roundel thumbnails:** Circular, 160×160px. Bright, product-focused photography on white or coloured backgrounds.
- **Promo banner images:** Rich, lifestyle or product photography. Warm tones. People shown with food/lifestyle context.
- **Aspect ratios used:** 1:1 (roundels), 3:2 (small promo cards), 16:9 (hero banners).
- **Lazy loading:** All images below fold lazy-loaded.
- **Alt text:** Descriptive (e.g. "image for Fresh Food").

---

## 8. Section Structure (Homepage)

The Tesco homepage follows a consistent section-row pattern:

1. **Utility Bar** — Secondary links, account, basket
2. **Header** — Logo, Search, Sign In, Register
3. **Navigation Bar** — Department menu + primary links
4. **Category Roundels** — 22-item horizontal scroll carousel
5. **Hero Row 1** — "What's new this week?" (3-column cards)
6. **Hero Row 2** — "Top picks for you" (4-column cards)
7. **Hero Row 3** — "Inspiration from sellers / Marketplace" (3-column cards)
8. **Hero Row 4** — "Ways to shop and save" (3-column cards)
9. **Hero Row 5** — "Discover more from Tesco" (3-column cards)
10. **Brand Roundels** — "Shop by brand" (10-item horizontal scroll)
11. **Community / CSR Row** — "We're here to help" (3-column cards)
12. **Services Row** — "Even more to explore" (4-column cards: Bank, Insurance, Travel Money, Gift Cards)
13. **Footer** — 4-column links + copyright + payment icons

---

## 9. Interaction & Animation

- **Hover transitions:** `transition: all 0.2s ease-in-out`
- **Card hover:** Subtle box-shadow lift `0 4px 12px rgba(0,0,0,0.12)`, no scale
- **Roundel hover:** `transform: scale(1.03)` + shadow
- **Button hover:** Slightly darker background (`darken(#005DAA, 10%)`)
- **Carousel arrows:** Appear on row hover (opacity: 0 → 1)
- **Accordion (mega menu):** Slide-down animation, `200ms ease`

---

## 10. Responsive Breakpoints

| Breakpoint | Width | Layout Notes |
|---|---|---|
| Mobile | `< 768px` | Single column, horizontal scroll carousels, stacked nav |
| Tablet | `768px – 1023px` | 2-column cards, condensed nav |
| Desktop | `1024px – 1279px` | 3-column cards, full nav |
| Wide | `≥ 1280px` | Max-width container centred, 4-column cards |

---

## 11. Accessibility

- **ARIA landmarks:** `<nav>`, `<main>`, `<footer>` used correctly
- **Skip links:** "Skip to main content" and "Skip to search" at top of page
- **Focus states:** Visible focus ring on all interactive elements (`outline: 2px solid #005DAA`)
- **Colour contrast:** Text on blue backgrounds meets WCAG AA (4.5:1 minimum)
- **Image alt text:** All images include descriptive alt attributes
- **Keyboard navigation:** Full keyboard support for menus and carousels

---

## 12. Key UX Patterns

- **Clubcard integration:** Clubcard pricing prominently badged on offers throughout; loyalty is a first-class design element.
- **Progressive disclosure:** "More" nav item hides lower-priority links; mega menu reveals full department tree on demand.
- **Social proof / urgency:** "What's new this week?" section creates recency/freshness cue.
- **Cross-sell ecosystem:** Services section (Bank, Insurance, Travel, Gift Cards) always present at bottom, upselling financial services.
- **Community/CSR:** Charity & sustainability section included on every homepage load, reinforcing brand trust.
- **Horizontal carousels:** Used extensively to pack many options (22 departments, 10 brands) into limited vertical space without scrolling fatigue.

---

*Document generated from: https://www.tesco.com/ | Last analysed: May 2026*
