--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Main)
--------------------------------------------------------------------------------
-- Create main table.
if Zolan_JH == nil then Zolan_JH = {} end

local ZJH = Zolan_JH
-- Create all sub tables.
if ZJH.AddonMenu     == nil then ZJH.AddonMenu     = {} end
if ZJH.BagCache      == nil then ZJH.BagCache      = {} end
if ZJH.Destroyer     == nil then ZJH.Destroyer     = {} end
if ZJH.Handler       == nil then ZJH.Handler       = {} end
if ZJH.Junker        == nil then ZJH.Junker        = {} end
if ZJH.Marker        == nil then ZJH.Marker        = {} end
if ZJH.Seller        == nil then ZJH.Seller        = {} end
--
if ZJH.Vars          == nil then ZJH.Vars          = {} end
--
if ZJH.ZL            == nil then ZJH.ZL            = LibStub("LibZolan-1.0") end

local ZL = ZJH.ZL

-- ZO
local d            = d
local zo_strjoin   = zo_strjoin
local zo_strsplit  = zo_strsplit
local ZO_SavedVars = ZO_SavedVars
-- Lua
local pairs        = pairs

function ZJH:loadVariables()
    ---------------------------------------------------
    ---------------------------------------------------
    ----  APP VERSION DO NOT FORGET TO CHANGE!!!!!!! --
    ---------------------------------------------------
    ---------------------------------------------------
    self.appVersion              = '2.18'
    self.addonName               = 'Zolan_JunkHandler'

    self.Vars.headerColor        = ZL.colors.light_blue
    self.Vars.defaultColor       = "|cFFFFFF" -- White
    self.Vars.currencyColor      = ZL.colors.gold

    self.Vars.outputHeader       = self.Vars.headerColor .. "Zolan's Junk Handler:"

    self.Vars.MARK_AS_JUNK_REASON_NEW_ITEM      = 1
    self.Vars.MARK_AS_JUNK_REASON_SCAN_BACKPACK = 2

    -- SavedVars Variables
    self.Vars.savedVariablesName = 'Zolan_JH_SavedVariables'
    self.Vars.configVersion      = 3
    self.Vars.configNamespace    = 'JH'
    self.Vars.profile            = nil
    self.Vars.configDefaults     = {
        ["configVersion"]           = self.Vars.configVersion,
        ["debug"]                   = false,
        ["enabled"]                 = true,
        ["outputChatTab"]           = '',
        --
        ["markAsJunkSound"]         = SOUNDS.BOOK_OPEN,
        ["markAsJunkNotify"]        = true,
        ["markTrashAsJunk"]         = true,
        ["markOrnateAsJunk"]        = false,
		["markWeaponsArmorsAsJunk"] = false,
        ["markIckyFoodAsJunk"]      = false,
        ["markUserMarkedAsJunk"]    = false,
        ["scanBackpackForJunk"]     = true,
        --
        ["sellJunk"]                = true,
        ["sellNotify"]              = true,
        ["scanNotify"]              = true,
        ["showItemized"]            = true,
        ["showSummary"]             = true,
        ["useOldSellAllItems"]      = false,
        ["msDelayBetweenSells"]     = 20,
        --
        ["destroySound"]            = SOUNDS.BLACKSMITH_EXTRACTED_BOOSTER,
        ["destroyAcknowledge"]      = false,
        ["destroyZeroGold"]         = false,
        ["destroyDelayInSeconds"]   = 30,
        ["destroyBlindTrust"]       = false,
        ["destroyItemNotify"]       = true,
        ["destroyCheap"]            = false,
        ["destroyCheapUnitPrice"]   = true,
        ["destroyCheapValue"]       = 1,
        ["noDestroyStackOver"]      = true,
        ["noDestroyStackOverCount"] = 1,
        ["tracking"]                = {
            ["userMarked"] = {}
        }
    }

    self.settings = ZO_SavedVars:New(
        self.Vars.savedVariablesName,
        self.Vars.configVersion,
        self.Vars.configNamespace,
        self.Vars.configDefaults,
        self.Vars.profile
    )

    self:migrateSettings()
    self:defaultMissingSettings()
    self:removeVestigialSettings()

    self.ZL:setSettings({
        ["debugEnabled"]  = self.settings.debug,
        ["debugPrefix"]   = 'ZJH',
        ["outputChatTab"] = self.settings.outputChatTab
    })

    self.loaded = true
end

function ZJH:migrateSettings()
    -- Nothing for now.
    -- After version 0.5
    --
    -- Removed itemTexture from unique key, so need to switch
    -- the existing keys to the new format.
    for key,value in pairs(self.settings.tracking.userMarked) do
        local parts = { zo_strsplit(':', key) }
        if #parts == 10 then
            local newKey = zo_strjoin(':',
                parts[1], parts[2],
                parts[3], parts[4],
                parts[5], -- NUKE #6
                parts[7], parts[8],
                parts[9], parts[10]
            )
            self.settings.tracking.userMarked[newKey] = self.settings.tracking.userMarked[key]
            self.settings.tracking.userMarked[key]    = nil
        end
    end
    -- /After version 0.5

end

function ZJH:defaultMissingSettings()
    self.ZL.table:setMissingValuesFromTemplate(
        self.settings,
        self.Vars.configDefaults
    )
end

function ZJH:removeVestigialSettings()
    self.ZL.table:removeValuesNotInTemplate(
        self.settings,
        self.Vars.configDefaults
    )
end
