---@meta PreviewAnywhereTypes
-- PreviewAnywhereTypes.lua: Centralized type definitions for PreviewAnywhere

---@class PreviewAnywhereSavedVars
---@field enabled boolean

---@class PreviewAnywhereState
---@field savedVars PreviewAnywhereSavedVars
---@field pendingLinkPreviews string[]|nil Item links queued for the link preview scene (nil when idle)
---@field pendingLinkPreviewIndex integer|nil Index within pendingLinkPreviews to preview first

---@class PreviewAnywhereGamepadLinksEntry
---@field link string The raw link text
---@field linkType string The parsed link type (e.g. ITEM_LINK_TYPE)

---@class PreviewAnywhereDiagnostics
---@field addonNames string[] Every addonName EVENT_ADD_ON_LOADED fired with
---@field initErrors string[] Error messages captured from module Initialize calls
---@field initialized boolean Whether Initialize ran
---@field lateInit boolean Whether Initialize ran via the EVENT_PLAYER_ACTIVATED fallback
---@field linkInjections integer How many ZO_GamepadLinks instances received the preview keybind
---@field bankSceneShows integer How many times the banking scene showed with our keybind installed
