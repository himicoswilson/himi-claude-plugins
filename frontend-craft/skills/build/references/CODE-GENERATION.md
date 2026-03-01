# Code Generation Rules

Reference guide for tech-stack-specific conventions and patterns.

## Framework-Specific Patterns

### React / Next.js

```tsx
// Component file: PascalCase.tsx
// Default export for pages, named export for components

// Props interface above component
interface ButtonProps {
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
  onClick?: () => void;
  isDisabled?: boolean;
}

// Function declaration (not arrow) for components
export function Button({ variant = "primary", size = "md", children, onClick, isDisabled }: ButtonProps) {
  return (
    <button
      className={cn(baseStyles, variantStyles[variant], sizeStyles[size])}
      onClick={onClick}
      disabled={isDisabled}
    >
      {children}
    </button>
  );
}
```

**Conventions**:
- `"use client"` directive only when the component uses hooks, event handlers, or browser APIs
- Server Components by default in Next.js App Router
- Prefer `className` with Tailwind over inline styles
- Use `cn()` (clsx/tailwind-merge) for conditional classes

### Vue 3 / Nuxt

```vue
<!-- Component file: PascalCase.vue -->
<!-- script setup + TypeScript -->

<script setup lang="ts">
interface Props {
  variant?: "primary" | "secondary" | "ghost";
  size?: "sm" | "md" | "lg";
  disabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  variant: "primary",
  size: "md",
  disabled: false,
});

const emit = defineEmits<{
  click: [];
}>();
</script>

<template>
  <button
    :class="[baseStyles, variantStyles[variant], sizeStyles[size]]"
    :disabled="disabled"
    @click="emit('click')"
  >
    <slot />
  </button>
</template>
```

**Conventions**:
- `<script setup lang="ts">` as default
- `defineProps` with TypeScript generics for type safety
- `withDefaults` for default prop values
- Template refs with `useTemplateRef()` (Vue 3.5+) or `ref()`
- `defineModel()` for v-model bindings

### Svelte / SvelteKit

```svelte
<!-- Component file: PascalCase.svelte -->

<script lang="ts">
  interface Props {
    variant?: "primary" | "secondary" | "ghost";
    size?: "sm" | "md" | "lg";
    disabled?: boolean;
    onclick?: () => void;
  }

  let { variant = "primary", size = "md", disabled = false, onclick, children }: Props = $props();
</script>

<button
  class="{baseStyles} {variantStyles[variant]} {sizeStyles[size]}"
  {disabled}
  {onclick}
>
  {@render children?.()}
</button>
```

**Conventions**:
- Svelte 5 runes (`$props`, `$state`, `$derived`, `$effect`)
- `$props()` for component props with destructuring defaults
- `{@render children?.()}` for slot content (Svelte 5 snippets)
- Event handlers as callback props (`onclick`, `onchange`)

## File Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Components | PascalCase | `ProductCard.tsx`, `ProductCard.vue`, `ProductCard.svelte` |
| Utilities / Helpers | camelCase | `formatPrice.ts`, `useAuth.ts` |
| Route files | kebab-case or framework default | `product-list/page.tsx`, `product-list.vue` |
| Style files | Match component name | `ProductCard.module.css` |
| Constants | camelCase file, UPPER_SNAKE values | `constants.ts` → `export const MAX_ITEMS = 50` |
| Type definitions | camelCase file | `types.ts`, `product.types.ts` |

## Import Organization

Order imports consistently within each file:

```
1. Framework imports (react, vue, svelte)
2. Third-party library imports (clsx, lucide-react, etc.)
3. Internal absolute imports (~/components, @/lib)
4. Relative imports (./ComponentName, ../utils)
5. Style imports (./styles.module.css)
6. Type-only imports (import type { ... })
```

Separate groups with a blank line.

## Styling Approach Selection

| Scenario | Recommended Approach |
|----------|---------------------|
| Tailwind is in the project | Tailwind utility classes, extend theme for tokens |
| CSS Modules detected | CSS Modules with CSS custom properties for tokens |
| styled-components detected | Styled-components with ThemeProvider for tokens |
| UnoCSS detected | UnoCSS utilities, extend config for tokens |
| No existing preference (new project) | Tailwind CSS (most widely supported, good DX) |

### Tailwind-Specific Rules

- Use `@apply` sparingly — only for repeated utility combinations in base styles
- Extend the theme in `tailwind.config.ts` for design tokens, don't use arbitrary values
- Use `cn()` helper (clsx + tailwind-merge) for conditional class composition
- Responsive: mobile-first (`sm:`, `md:`, `lg:` prefixes)

### CSS Modules Rules

- One module per component
- Use `composes` for shared styles
- Reference CSS custom properties for design tokens: `color: var(--color-primary)`

## Accessibility Requirements

These are the **minimum** requirements for every component:

### Semantic HTML

| Visual Element | Correct Tag |
|---------------|-------------|
| Clickable action | `<button>` (not `<div onClick>`) |
| Navigation link | `<a href>` |
| List of items | `<ul>` / `<ol>` + `<li>` |
| Form field | `<input>` / `<select>` / `<textarea>` with `<label>` |
| Page section | `<section>`, `<nav>`, `<main>`, `<aside>`, `<header>`, `<footer>` |
| Heading hierarchy | `<h1>` through `<h6>` in order |
| Image | `<img alt="descriptive text">` |

### ARIA Labels

- Add `aria-label` only when the visible text is insufficient or absent
- Use `aria-labelledby` to reference an existing visible label
- Add `role` only when the semantic HTML element is not available
- Interactive custom components need `aria-expanded`, `aria-haspopup`, etc. as appropriate

### Keyboard Navigation

- All interactive elements must be focusable (`tabIndex={0}` only if needed beyond native)
- Buttons and links must respond to Enter/Space
- Custom dropdowns/menus must support Arrow keys, Escape, and Enter
- Focus must be visible (never remove `outline` without a replacement)
- Modal dialogs must trap focus

### Focus Management

- When a modal opens, move focus to the first focusable element inside
- When a modal closes, return focus to the trigger element
- After deleting an item, move focus to a logical next element

## Performance Considerations

### Lazy Loading

Apply lazy loading when:
- Component is below the fold (not visible on initial render)
- Component is inside a tab that isn't the default tab
- Component is conditionally shown (modal content, dropdown panels)
- Route-level: pages should be lazy-loaded by default (frameworks handle this)

### Image Optimization

- Use `next/image` (Next.js), `nuxt-img` (Nuxt), or native `loading="lazy"` for images
- Provide `width` and `height` attributes to prevent layout shift
- Use `srcset` / responsive images when multiple sizes are available
- Prefer modern formats (WebP, AVIF) when the toolchain supports them

### Code Splitting Triggers

- Route-based splitting (automatic in Next.js, Nuxt, SvelteKit)
- Heavy third-party libraries (chart libraries, rich text editors): dynamic import
- Components that use large dependencies: dynamic import with loading state
