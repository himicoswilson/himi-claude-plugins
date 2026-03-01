# Design Analysis Methodology

Reference guide for extracting visual systems from design prototypes (screenshots, images, PDFs).

## Color Extraction

### Identification Rules

1. **Dominant colors** — Large area fills (backgrounds, hero sections). These are typically neutrals or the primary brand color.
2. **Accent colors** — Small, high-contrast elements that draw attention (CTAs, badges, active states). Usually 1-2 colors.
3. **Neutral palette** — Text colors, borders, dividers, subtle backgrounds. Look for a grayscale ramp (typically 5-8 shades).
4. **Semantic colors** — Error (red), success (green), warning (amber/yellow), info (blue). Often visible in form validation, alerts, or status indicators.

### Classification Process

```
1. Scan large areas → identify background and surface colors (neutrals)
2. Find the most prominent non-neutral color → primary
3. Look for a second distinct hue used for differentiation → secondary
4. Identify small, attention-grabbing colored elements → accent
5. Check for status indicators (error states, success messages) → semantic
6. Build a palette: primary, secondary, accent, neutral[50-950], semantic
```

### Tips

- If only one hue is present, it serves as both primary and accent. Derive secondary by adjusting saturation or lightness.
- For neutral ramps, check text color, border color, and disabled state color — they usually form a consistent scale.
- Colors that appear only in icons or illustrations may be decorative, not part of the design system.

## Spacing System Inference

### Finding the Base Unit

1. Measure the smallest repeated gap between elements (e.g., between icon and label, between list items).
2. Check if gaps are multiples of a base unit. Common bases: **4px**, **8px**.
3. Derive the scale by collecting all observed spacing values and finding the pattern.

### Common Scales

| Base | Scale |
|------|-------|
| 4px | 0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96 (× 4px) |
| 8px | 0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32 (× 8px) |

### Where to Look

- **Padding inside cards/containers** — usually consistent within a component type
- **Gaps between list items** — reveals the base unit
- **Section margins** — larger multiples of the base
- **Form field spacing** — gaps between label, input, helper text

### Validation

If the inferred spacings don't fit a clean scale, round to the nearest multiple of 4px. Design tools often use 4px or 8px grids.

## Typography Hierarchy

### Identification Steps

1. **Headings**: Find the largest, boldest text. Typically 2-4 heading levels.
2. **Body text**: The default reading size, used in paragraphs and descriptions.
3. **Small / Caption**: Smaller text for metadata, timestamps, helper text.
4. **Labels**: Text on buttons, form labels, navigation items. May differ from body.

### Properties to Extract

For each level, note:

| Property | What to Look For |
|----------|-----------------|
| Font family | Serif vs sans-serif vs monospace. If unclear, default to system sans-serif. |
| Font size | Relative sizes between levels. Map to a type scale (e.g., 12, 14, 16, 18, 20, 24, 30, 36). |
| Font weight | Regular (400), Medium (500), Semibold (600), Bold (700). |
| Line height | Tight (1.2-1.3) for headings, relaxed (1.5-1.7) for body. |
| Letter spacing | Usually default. Tighter for large headings, wider for all-caps labels. |

### Common Type Scales

| Scale | Sizes (px) |
|-------|-----------|
| Minor Third (1.2) | 12, 14, 17, 20, 24, 29, 35 |
| Major Third (1.25) | 12, 15, 19, 23, 29, 36 |
| Perfect Fourth (1.333) | 12, 16, 21, 28, 38, 50 |

## Distinguishing Decorative vs Functional Elements

### Functional Elements

- Have interactive states (hover, focus, active)
- Convey information the user needs (status, navigation, data)
- Receive user input (forms, buttons, toggles)
- Part of the content hierarchy (headings, body text, lists)

### Decorative Elements

- Background patterns, gradients, or textures
- Illustrations that don't convey essential information
- Ornamental icons next to text that already conveys meaning
- Shadows and borders used purely for depth

### Why It Matters

- Functional elements become components with props, states, and accessibility requirements
- Decorative elements become CSS (backgrounds, pseudo-elements) or static assets
- Do not create interactive components for purely decorative elements

## Responsive Strategy Inference

### If Multiple Viewport Sizes Are Provided

- Compare layouts side-by-side to identify:
  - Elements that reflow (grid to stack)
  - Elements that hide/show at different sizes
  - Navigation changes (sidebar to hamburger)
  - Font size adjustments

### If Only One Size Is Provided

Apply these defaults:

| Single Design Size | Assumed Strategy |
|-------------------|-----------------|
| Desktop (>1024px) | Stack columns on mobile, collapse sidebar to hamburger, reduce font sizes |
| Mobile (<768px) | Expand to multi-column on desktop, show sidebar, increase whitespace |

### Breakpoint Conventions

| Name | Width | Common Usage |
|------|-------|-------------|
| sm | 640px | Large phones |
| md | 768px | Tablets |
| lg | 1024px | Small desktops |
| xl | 1280px | Standard desktops |
| 2xl | 1536px | Large screens |

Use the breakpoint convention of the chosen framework (Tailwind defaults match the table above).
