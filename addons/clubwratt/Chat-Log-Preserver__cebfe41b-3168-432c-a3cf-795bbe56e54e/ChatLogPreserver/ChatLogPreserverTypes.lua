---@meta ChatLogPreserverTypes
-- ChatLogPreserverTypes.lua: Centralized type definitions

---@alias object ZO_Object
---@class ZO_ColorDef

---@class ChatLogPreserver
---@field name string
---@field version string
---@field savedVarsName string
---@field savedVarsVersion number
---@field state ChatLogPreserverStateData|nil
---@field State? ChatLogPreserverState
---@field Actions? ChatLogPreserverActions
---@field Utils? ChatLogPreserverUtils
---@field Settings? ChatLogPreserverSettings
---@field LogDialog? ChatLogPreserverLogDialog

---@class ChatLogPreserverSavedMessage
---@field message string
---@field category number

---@class ChatLogPreserverSettingsData
---@field enabled boolean
---@field maxEntries number

---@class ChatLogPreserverSavedVars
---@field settings ChatLogPreserverSettingsData
---@field history ChatLogPreserverSavedMessage[]

---@class ChatLogPreserverStateData
---@field savedVars ChatLogPreserverSavedVars
---@field settingsDefaults ChatLogPreserverSettingsData
---@field isRestoring boolean
---@field didRestore boolean
---@field isChatCallbackRegistered boolean

---@class ChatLogPreserverState
---@field Create fun(): ChatLogPreserverStateData

---@class ChatLogPreserverUtils
---@field BuildHistoryText fun(history: ChatLogPreserverSavedMessage[]|nil, maxLines: number|nil, newestFirst: boolean|nil): string
---@field TrimHistory fun(history: ChatLogPreserverSavedMessage[]|nil, maxEntries: number)

---@class ChatLogPreserverActions
---@field OnAddonLoaded fun()
---@field OnPlayerActivated fun(initial: boolean)
---@field ClearHistory fun()
---@field EnforceMaxEntries fun()
---@field RegisterChatCallback fun()
---@field RestoreHistory fun()

---@class ChatLogPreserverSettings
---@field Initialize fun()
---@field ResetToDefaults fun()

---@class ChatLogPreserverLogDialog
---@field Show fun(self: ChatLogPreserverLogDialog)
---@field Hide fun(self: ChatLogPreserverLogDialog)
---@field RefreshIfVisible fun(self: ChatLogPreserverLogDialog, history: ChatLogPreserverSavedMessage[]|nil)
