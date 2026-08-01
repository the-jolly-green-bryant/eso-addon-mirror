-- Type annotations for LuaLS (EmmyLua) to describe saved variable schema.

---@class UDGM_SavedVars
---@field filtered table<string, any>
---@field Friends string[]            # Favorite friend display names (length 3)
---@field FriendZones string[]        # Cached zone names for favorites
---@field willAcceptLFGCheck boolean
---@field willAcceptGroupInvite boolean
---@field willNotAcceptTravelToLeader boolean
---@field canLeaveLFG boolean
---@field ActivityIdList integer[]
---@field ActivitySetIdNames table<number,string>
---@field ActivityIdNames table<number,string>
---@field ActivitySetIdList integer[]
---@field SelectedQName string
---@field selectedQ integer
---@field isDifficultyVisible boolean
---@field isTitleVisible boolean
---@field isRoleVisible boolean
---@field isReadyCheckVisible boolean
---@field didVoteNewName boolean
---@field left number|nil
---@field top number|nil
---@field dungeonAchievementDump { id: integer, name: string }[]|nil  # From last scan
---@field autoDungeonActivityToAchievement table<number,integer>|nil  # activityId->achievementId
---@field autoDungeonExtras table<number,table<string,integer>>|nil   # activityId->extra achieves

---@class UDGM_Addon
---@field SavedVariables UDGM_SavedVars
---@field defaults UDGM_SavedVars

---@diagnostic disable: unused-local
local _sample ---@type UDGM_Addon
