# frontend-craft

Turn design prototypes into maintainable, component-based frontend code.

Not pixel-perfect UI-to-code translation — instead: **design mockup -> component architecture -> incremental component generation**.

## Installation

Add this plugin to your Claude Code configuration:

```json
{
  "plugins": ["./frontend-craft"]
}
```

## Usage

Provide a design prototype (screenshot, image, or PDF) and optionally specify your tech stack:

```
Build this design using Next.js and Tailwind CSS
[attach screenshot]
```

```
Implement this UI with Vue 3 and Element Plus
[provide image path: ./designs/dashboard.png]
```

```
Turn this prototype into React components
[provide PDF path: ./designs/landing-page.pdf]
```

If you don't specify a tech stack, the skill will ask you to choose one.

## Workflow

1. **Input Validation** — Verify design asset and tech stack; detect existing project conventions
2. **Design Analysis** — Extract visual hierarchy, color system, typography, spacing, and interactive elements
3. **Architecture Planning** — Decompose into component tree (Atomic Design), define design tokens, plan file structure — **requires your confirmation before proceeding**
4. **Foundation Setup** — Scaffold project (if new), generate design tokens config and base layout
5. **Component Generation** — Build components incrementally: atoms -> molecules -> organisms
6. **Page Assembly** — Compose components into pages, add data fetching and routing
7. **Quality Review** — Check type safety, token consistency, responsiveness, and accessibility

## Supported Tech Stacks

| Framework | Styling | Component Libraries |
|-----------|---------|-------------------|
| React / Next.js | Tailwind CSS, CSS Modules, styled-components | shadcn/ui, Radix UI, Headless UI |
| Vue 3 / Nuxt | Tailwind CSS, UnoCSS, CSS Modules | Element Plus, Naive UI, Radix Vue |
| Svelte / SvelteKit | Tailwind CSS, UnoCSS | Skeleton, shadcn-svelte |

## License

MIT
