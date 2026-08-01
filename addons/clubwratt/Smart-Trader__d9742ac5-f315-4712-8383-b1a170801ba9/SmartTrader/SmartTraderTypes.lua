---@meta SmartTraderTypes
-- SmartTraderTypes.lua: Centralized type definitions for SmartTrader

---@class SmartTraderState
---@field savedVars SavedVars
---@field scanState ScanState
---@field reticleState ReticleState
---@field mapState MapState

---@class SavedVars
---@field guildDataById table<number, CachedGuildData>
---@field guildDataByTraderName table<string, CachedGuildData>
---@field nextFlipTime number|nil
---@field logExport LogExportConfig

---@class LogExportConfig
---@field url string
---@field maxUrlLength number

---@class CachedGuildData
---@field guildId number
---@field size number|nil
---@field memberCount number|nil
---@field guildName string|nil
---@field kioskName string|nil
---@field traderName string|nil
---@field city string|nil

---@class ScanState
---@field active boolean
---@field cancelled boolean
---@field searchQueue SearchParams[]
---@field currentSearchId number|nil
---@field currentSearchParams SearchParams|nil
---@field searchesCompleted number
---@field totalSearches number
---@field overflowWarnings string[]

---@class SearchParams
---@field focus FocusType
---@field sizes SizeType[]
---@field alliance AllianceType|nil

---@class FocusType
---@field value number
---@field name string

---@class SizeType
---@field value number
---@field name string

---@class AllianceType
---@field value number
---@field name string

---@class ReticleState
---@field lastCheckedGuildId number|nil
---@field lastCheckedTraderName string|nil
---@field lastFormattedText string|nil

---@class MapTooltipLineEntry
---@field icon textureName|nil
---@field name string|nil
---@field groupingId integer|nil
---@field categoryName string|nil

---@class MapState
---@field hoverLogEnabled boolean
---@field hoverLogSessionId number
---@field hoverLogSeenKeys table<string, boolean>
---@field hoverLogLines string[]
---@field hoverLogKeys string[]
---@field hoverLogBytes number
