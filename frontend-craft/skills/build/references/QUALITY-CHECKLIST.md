# Quality Checklist

Use this checklist during Phase 6 (Quality Review) to verify generated code meets standards.

## Design Token Consistency

- [ ] All color values reference design tokens (Tailwind theme, CSS variables, or theme object)
- [ ] All spacing values come from the spacing scale — no arbitrary pixel values
- [ ] All font sizes come from the typography scale
- [ ] All border radii use token values
- [ ] All shadows use token values
- [ ] No hardcoded hex codes, rgb values, or raw pixel values in component files

## TypeScript (if applicable)

- [ ] Every component has a defined Props interface
- [ ] Props interface uses specific types (not `any` or `object`)
- [ ] Optional props have sensible defaults via destructuring or framework defaults
- [ ] Event handler types are specific (not `Function` or `(...args: any[]) => void`)
- [ ] No `@ts-ignore` or `@ts-expect-error` without explanation

## Component Quality

- [ ] Each component has a single, clear responsibility
- [ ] No component file exceeds 200 lines
- [ ] Complex components are split into sub-components
- [ ] Components use design tokens exclusively for visual properties
- [ ] Library components are used where available (no reimplemented modals, selects, etc.)
- [ ] No unused imports in any component file
- [ ] No dead code or commented-out code blocks
- [ ] Export pattern is consistent across all components

## Interactive States

- [ ] Buttons have hover, focus, active, and disabled states
- [ ] Inputs have focus, error, and disabled states
- [ ] Links have hover and focus states
- [ ] Toggle/checkbox elements have checked and unchecked states
- [ ] Cards or list items have hover states (if clickable)
- [ ] Focus indicators are visible and meet contrast requirements

## Accessibility

- [ ] Semantic HTML tags used (button, a, nav, main, section, ul/li, h1-h6)
- [ ] No interactive `<div>` or `<span>` without `role` and keyboard handling
- [ ] All images have `alt` attributes (empty `alt=""` for decorative images)
- [ ] Form inputs have associated `<label>` elements
- [ ] ARIA labels present where visible text is insufficient
- [ ] Focus order follows visual reading order
- [ ] Basic keyboard navigation works for all interactive elements
- [ ] Color is not the only indicator of state (add icons, text, or patterns)

## Responsiveness

- [ ] Layout responds to at least two breakpoints (mobile + desktop)
- [ ] Text remains readable at all breakpoints
- [ ] Touch targets are at least 44x44px on mobile
- [ ] No horizontal scrolling at any breakpoint
- [ ] Images scale appropriately (no overflow or distortion)
- [ ] Navigation adapts to mobile (hamburger, drawer, or bottom nav)

## Code Style

- [ ] File naming follows project conventions
- [ ] Import order is consistent (framework, libraries, internal, relative, styles)
- [ ] No inline styles when a class-based approach is used elsewhere
- [ ] Consistent use of the chosen styling approach (no mixing Tailwind with inline styles)
- [ ] Component naming matches file naming (PascalCase)

## Performance

- [ ] Below-the-fold components use lazy loading where appropriate
- [ ] Images use optimized loading (next/image, loading="lazy", width/height set)
- [ ] No unnecessary re-renders from unstable references (missing useMemo, useCallback, computed)
- [ ] Heavy third-party imports use dynamic import
- [ ] No large inline data structures (extract to constants or fetch from API)
