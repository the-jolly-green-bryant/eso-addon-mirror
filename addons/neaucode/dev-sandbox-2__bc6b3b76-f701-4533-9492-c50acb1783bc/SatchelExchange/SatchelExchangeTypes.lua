---@meta SatchelExchangeTypes
-- SatchelExchangeTypes.lua: Centralized type definitions for SatchelExchange

---@class SatchelExchangeSavedVars
---@field enabled boolean Master switch for all automation
---@field watchdogMs integer Time allowed in the buying phase before aborting
---@field autoCloseStore boolean Exit the vendor interaction automatically after the buy
---@field resumeWindowMs integer How long the auto-resume arm survives between visits
---@field autoUnbox boolean Built-in unboxer: use the satchel after leaving the vendor
---@field unboxDelayMs integer Wait after the interaction ends before the first unbox attempt
---@field unboxMaxAttempts integer Unbox readiness checks/attempts before giving up

---@class SatchelExchangeRunState
---@field active boolean
---@field phase string "idle" | "buying"
---@field token integer Monotonic counter that invalidates stale timers/watchdogs
---@field entryIndex integer|nil Store entry index of the target item
---@field itemLink string|nil
---@field itemId integer|nil
---@field entryName string|nil
---@field startedAtMs integer

---@class SatchelExchangeSessionState
---@field resumeItemLink string|nil Item to auto-buy on the next store open (nil = disarmed)
---@field resumeArmedAtMs integer
---@field buysThisSession integer Total satchels bought since UI load

---@class SatchelExchangeUnboxState
---@field active boolean
---@field itemId integer|nil
---@field attemptsLeft integer

---@class SatchelExchangeUseReadiness
---@field usable boolean
---@field usableOnlyFromActionSlot boolean
---@field canInteract boolean
---@field cooldownRemainMs integer

---@class SatchelExchangeState
---@field savedVars SatchelExchangeSavedVars
---@field run SatchelExchangeRunState
---@field session SatchelExchangeSessionState
---@field unbox SatchelExchangeUnboxState

---@class SatchelExchangeEntryDiagnostics
---@field name string
---@field stack integer
---@field price integer
---@field currencyType1 integer
---@field currencyQuantity1 integer
---@field currencyType2 integer
---@field currencyQuantity2 integer
---@field entryType integer
---@field meetsRequirementsToBuy boolean
---@field buyStoreFailure integer
---@field buyErrorStringId integer
---@field maxBuyable integer
---@field itemLink string
