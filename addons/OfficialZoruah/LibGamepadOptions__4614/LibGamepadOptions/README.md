# LibGamepadOptions

`LibGamepadOptions` lets ESO addon authors register controller-friendly settings inside the native gamepad Options UI without hooking LibAddonMenu globally.

This library is intentionally explicit: addons opt in by calling the library and providing a small options table. It supports headers, descriptions, checkboxes, sliders, dropdowns, buttons, and nested submenus.

## Basic Usage

This registers your addon inside the shared `Add-Ons` category. Add `LibGamepadOptions` as a manifest dependency before calling it.

```lua
LibGamepadOptions:RegisterAddon("MyAddon", {
    name = "My Addon",
    tooltip = "Controller-friendly settings for My Addon.",
    sortOrder = 100,
}, {
    { type = "header", name = "General" },
    {
        type = "checkbox",
        name = "Enable feature",
        tooltip = "Turns the feature on or off.",
        getFunc = function() return MyAddon.saved.enabled end,
        setFunc = function(value) MyAddon.saved.enabled = value end,
        default = true,
    },
    {
        type = "slider",
        name = "Size",
        tooltip = "Adjusts the feature size.",
        min = 1,
        max = 10,
        step = 1,
        getFunc = function() return MyAddon.saved.size end,
        setFunc = function(value) MyAddon.saved.size = value end,
        default = 5,
    },
})
```

```text
## DependsOn: LibGamepadOptions>=7
```

If you intentionally make the library optional, check for it before calling.

## Direct Addon Category

This creates a top-level gamepad Options category named after your addon and opens your panel directly.

```lua
LibGamepadOptions:RegisterAddon("MyAddon", {
    name = "My Addon",
    categoryName = "My Addon",
    directOpen = true,
    showInRoot = false,
    tooltip = "Controller-friendly settings for My Addon.",
    sortOrder = 100,
}, {
    { type = "header", name = "General" },
    {
        type = "button",
        name = "Do Thing",
        tooltip = "Runs the addon action.",
        func = function() MyAddon.DoThing() end,
    },
    {
        type = "description",
        text = "More option rows can go here.",
    },
})
```

Multiple addons can register their own `categoryName`; each one gets its own top-level category. If `showInRoot` is omitted and `categoryName` is set, the addon does not also appear in the shared `Add-Ons` hub by default.

## Example Addon

This repository includes a complete minimal addon at:

```text
examples/LibGamepadOptionsExample
```

Copy that folder into your ESO `AddOns` folder beside `LibGamepadOptions`, enable it, then open Settings -> Options in gamepad mode. It registers its own direct category and demonstrates:

- one checkbox
- one dropdown
- one slider with min/current/max labels
- one button

The key pattern is:

```lua
LibGamepadOptions:RegisterAddon("MyAddon", {
    name = "My Addon",
    displayName = "My Addon",
    categoryName = "My Addon",
    directOpen = true,
    showInRoot = false,
    tooltip = "Controller-friendly settings for My Addon.",
    sortOrder = 100,
}, optionsTable)
```

## Supported Option Types

- `header`: Sets the next option's section header.
- `description`: Adds a disabled informational row.
- `checkbox`: Boolean setting.
- `slider`: Numeric setting.
- `dropdown`: Finite list setting.
- `button`: Invokes a callback.
- `submenu`: Opens a nested option panel.

Slider rows display current, minimum, and maximum values in gamepad UI when `showValue` is not `false`. Use `decimals` to control numeric display precision, and use `showValueFunc` when a custom display string is needed.

## Notes

- This library does not bundle or modify LibAddonMenu.
- It is meant for PC gamepad UI. ESO console clients do not support user addons.
- Addons should list this as `OptionalDependsOn` if they still provide a normal PC settings panel.
- Use `categoryName` when your addon should have its own top-level category.
- Use `showInRoot = true` if your addon should appear both in its own category and in the shared `Add-Ons` hub.
