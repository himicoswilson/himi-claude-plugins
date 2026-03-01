# Component Architecture Methodology

Reference guide for decomposing designs into component hierarchies.

## Atomic Design Levels

### Atoms

The smallest indivisible UI elements. They cannot be broken down further without losing meaning.

**Examples**: Button, Input, Label, Badge, Avatar, Icon, Checkbox, Radio, Toggle, Tooltip

**Criteria**:
- Renders a single HTML element or a minimal wrapper
- Has a clear, singular purpose
- Reusable across the entire application
- Typically under 30 lines

### Molecules

Combinations of 2-4 atoms that form a functional unit.

**Examples**: SearchBar (Input + Button), FormField (Label + Input + HelperText), NavLink (Icon + Text), UserChip (Avatar + Name)

**Criteria**:
- Combines atoms into a cohesive group
- Has a single responsibility that the individual atoms don't have alone
- Reusable in different contexts

### Organisms

Complex, distinct sections of UI composed of molecules and atoms.

**Examples**: Header (Logo + Navigation + UserMenu), Sidebar (NavLinks + SectionDividers), ProductCard (Image + Title + Price + AddToCartButton), CommentSection (CommentList + CommentForm)

**Criteria**:
- Represents a recognizable section of the interface
- May manage local state
- Often maps to a visual "block" in the design

### Templates

Page-level layout structures that define where organisms go, without real content.

**Examples**: DashboardLayout (Sidebar + TopBar + MainContent), AuthLayout (CenteredCard), MarketingLayout (FullWidthSections)

**Criteria**:
- Defines the spatial arrangement of organisms
- Uses slots/children for content injection
- Handles responsive layout shifts

### Pages

Templates populated with real data and specific content.

**Examples**: DashboardPage, ProductListPage, UserProfilePage

**Criteria**:
- Composes template + organisms with actual data
- Contains data fetching logic
- Maps to a route

## Component Responsibility Principles

### Single Responsibility

Each component should do one thing well. If a component description requires "and", it likely needs splitting.

**Good**: "Renders a user avatar with size variants"
**Bad**: "Renders a user avatar and handles image upload and displays online status"

### Props Minimization

Fewer props = simpler API = easier to use.

- Start with the minimum viable props
- Add props only when a real use case demands variation
- Prefer composition (children/slots) over configuration props for layout variation

## Props Design Guide

### Required vs Optional

| Category | Make Required | Make Optional |
|----------|--------------|---------------|
| Content | Primary content that defines what renders | Secondary/supplementary content |
| Behavior | Core functionality callbacks | Enhancement callbacks |
| Appearance | Nothing (use sensible defaults) | Size, variant, color overrides |

### Naming Conventions

| Type | Pattern | Examples |
|------|---------|---------|
| Boolean | `is*`, `has*`, `show*` | `isDisabled`, `hasError`, `showLabel` |
| Callback | `on*` | `onClick`, `onChange`, `onSubmit` |
| Content | Descriptive noun | `title`, `description`, `icon` |
| Variant | `variant`, `size`, `color` | `variant="outlined"`, `size="lg"` |
| Children | `children` (React/Svelte), default slot (Vue) | — |

### Render Props vs Children

| Pattern | Use When |
|---------|---------|
| `children` / default slot | Content structure is simple or determined by parent |
| Render prop / scoped slot | Component needs to pass data back to the rendered content |
| Named slots | Multiple insertion points in a layout component |

## State Management Decision Tree

```
Does this state affect only one component?
├── Yes → Local state (useState / ref / $state)
└── No → Is it shared between parent-child only?
    ├── Yes → Lift state to parent, pass via props
    └── No → Is it shared across distant siblings?
        ├── Yes → Context / provide-inject / Svelte context
        └── No → Is it app-wide or complex with many interactions?
            ├── Yes → Global store (Zustand / Pinia / Svelte stores)
            └── No → Server state? → React Query / SWR / TanStack Query
```

### Guidelines

- **Default to local state.** Only escalate when you have a concrete sharing need.
- **Server state is not client state.** Use data fetching libraries (React Query, SWR, useFetch) for API data, not global stores.
- **Form state** — use the framework's form solution (React Hook Form, VeeValidate, Superforms) for complex forms.

## Common UI Pattern to Component Mapping

| Design Pattern | Typical Components |
|---------------|-------------------|
| Card grid | Card (organism), CardGrid (template), CardImage/CardBody/CardFooter (molecules) |
| Data table | Table, TableHeader, TableRow, TableCell, TablePagination |
| Form | Form, FormField, FormSection, SubmitButton |
| Modal/Dialog | Modal, ModalHeader, ModalBody, ModalFooter |
| Navigation bar | Navbar, NavLink, NavMenu, MobileMenuToggle |
| Sidebar | Sidebar, SidebarSection, SidebarItem, SidebarToggle |
| Tabs | TabGroup, TabList, Tab, TabPanel |
| List | List, ListItem, ListItemIcon, ListItemText |
| Dropdown | Dropdown, DropdownTrigger, DropdownMenu, DropdownItem |
| Breadcrumb | Breadcrumb, BreadcrumbItem, BreadcrumbSeparator |
| Pagination | Pagination, PageButton, PrevButton, NextButton |
| Toast/Notification | Toast, ToastContainer, ToastTitle, ToastDescription |

### Library Component Preference

Before building any of the patterns above from scratch, check if the chosen component library provides them:

| Library | Commonly Provided |
|---------|------------------|
| shadcn/ui | Button, Input, Dialog, Sheet, Table, Tabs, Card, Select, Dropdown, Toast, Form |
| Radix UI | Dialog, Popover, Dropdown, Tabs, Accordion, Tooltip, Toggle, Checkbox, Select |
| Headless UI | Menu, Listbox, Combobox, Dialog, Disclosure, Popover, Tabs, Switch |
| Element Plus | Button, Input, Table, Dialog, Form, Select, DatePicker, Menu, Tabs, Message |
| Naive UI | Button, Input, DataTable, Modal, Form, Select, Menu, Tabs, Notification |

**Rule**: If the library provides it, use it. Wrap it in a project-specific component only if you need to enforce consistent props or styling.
