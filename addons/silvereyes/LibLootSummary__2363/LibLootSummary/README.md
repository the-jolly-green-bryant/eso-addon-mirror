# LibLootSummary

A powerful ESO addon library for generating formatted item and loot summaries in chat.

[![ESO Version](https://img.shields.io/badge/ESO-101047%20|%20101048-blue.svg)](https://www.elderscrollsonline.com/)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](LICENSE)

## 🎯 Features

- **Smart Chat Output**: Efficiently formats item lists with intelligent line wrapping
- **Multi-Language Support**: Full localization for English, German, French, Japanese, and Russian
- **Console Compatible**: Works seamlessly on both PC and console platforms  
- **LibAddonMenu Integration**: Auto-generates settings controls with localized labels
- **LibChatMessage Support**: Enhanced chat output with extended line length capabilities
- **Flexible Sorting**: Sort by quality, name, or maintain insertion order
- **Rich Formatting**: Icons, traits, quality filters, and custom delimiters
- **Robust Error Handling**: Graceful fallbacks for missing translations and edge cases
- **Developer Friendly**: Comprehensive documentation and defensive programming practices

## 📸 Screenshots

*Minimal output with quality filtering*

![Minimal Output](https://i.imgur.com/yXTQWDo.png)

*Full features: icons, traits, and quality sorting*

![Full Features](https://i.imgur.com/2T74WDi.png)

## 🚀 Quick Start

### Installation

1. **For Addon Developers**: Add to your manifest:
   ```
   ## OptionalDependsOn: LibLootSummary
   ```

2. **For End Users**: Download from [ESOUI.com](https://www.esoui.com)

### Basic Usage

```lua
local lls = LibLootSummary()

-- Add items to summary
lls:AddItem(bagId, slotIndex, quantity)
lls:AddItemLink(itemLink, quantity)

-- Configure options
lls:SetMinQuality(ITEM_FUNCTIONAL_QUALITY_NORMAL)
lls:SetShowIcon(true)
lls:SetSorted(true)

-- Output to chat
lls:Print()
```

## 📖 Documentation

- **[Complete Usage Guide](USAGE.md)** - Detailed API documentation and examples
- **[Integration Examples](USAGE.md#libaddonmenu-integration)** - LibAddonMenu and LibChatMessage setup

## 🛠️ Technical Details

- **Current Version**: 3.1.6
- **API Version**: 101047, 101048
- **Original Author**: silvereyes
- **Current Maintainer**: dlrgames
- **Dependencies**: None (LibChatMessage optional for enhanced features)
- **Localization**: 5 languages supported (EN/DE/FR/JP/RU) with 48 strings each
- **Code Quality**: Comprehensive documentation, defensive programming, and production-ready error handling

## 📝 License

This addon is maintained under the original author's license. All rights reserved.

## 🤝 Contributing

This is a maintained fork. For issues or suggestions, please create an issue in this repository.