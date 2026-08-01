LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities

--[[ --------------------------- ]]
--[[ -- Profile Manager Class -- ]]
--[[ --------------------------- ]]

local ProfileManager = {}
ProfileManager.__index = ProfileManager 

local function InitProfileManager(...) 
    return ProfileManager:New(...) 
end


-- moony black magic
function ProfileManager:__call(...) 
   return ProfileManager:New(...) 
end
-- ProfileManager() ist das gleiche wie ProfileManager:New() 


function ProfileManager:New(name, store, sv, defaults, dialogTitle, callback) 
    if ZO_IsTableEmpty(defaults) then return end
    local pm = setmetatable({}, ProfileManager )
    pm.name = name
    pm.manager = store.profileManager 
    pm.profiles = store.profiles
    pm.defaults = defaults
    pm.sv = sv
    pm.callback = LibExoY.IsTable(callback) and callback or nil 
    pm:InitSubmenu(dialogTitle)
    pm:SetProfile(pm:GetProfileId())
    return function() return pm:GetSubmenu() end
end

function ProfileManager:GetProfileList() 
    return self.manager.profileNames 
end 

-- provides current profile id
function ProfileManager:GetProfileId() 
    return self.manager.characterProfiles[LibExoY.vars.charId]
end

-- provides current profile name
function ProfileManager:GetProfileName() 
    return self:GetNameById(self:GetProfileId())
end


function ProfileManager:SetProfileName(name)
    self.manager.profileNames[self:GetProfileId()] = name
end

function ProfileManager:SetProfile(id)
    -- changes id in manager list
    self.manager.characterProfiles[LibExoY.vars.charId] = id
    self.edit = self:GetNameById(id)
    -- updates self variables 
    self.sv.p = self.profiles[id]
    -- executes OnProfileChange callbacks
    self:OnProfileChange() 
end

function ProfileManager:OnProfileChange() 
    if not self.callback then return end
    if LibExoY.CallFunc(self.callback.trigger) then 
        LibExoY.CallFunc(self.callback.func)
    end
end

function ProfileManager:GetNameById(id) 
    return self:GetProfileList()[id]
end

function ProfileManager:GetIdByName(name) 
    return LibExoY.FindNumericKey(self:GetProfileList(), name, 0)
end

-- provides number of existing profiles
function ProfileManager:GetProfileNum() 
    return self.manager.profileNum
end

-- set number of available profiles, returns false if set to zero
function ProfileManager:SetProfileNum(num) 
    self.manager.profileNum = num 
end

-- creates a new profile with the provided variables
-- dialog for name or generic name with increasing number 
-- switch current profile to new profile 

-- if id= zero -> copy default values, else copy vars of profile with id=id
function ProfileManager:CreateProfile(id) 
    local num = self:GetProfileNum() + 1
    -- define profile name 
    self.manager.profileNames[num] = zo_strformat("<<1>> <<2>> (<<3>>)", LIB_EXOY_PROFILE, num, id == 0 and "Default" or self:GetNameById(id) )
    if id == 0 then 
        self.profiles[num] = ZO_DeepTableCopy(self.defaults)
    else
        self.profiles[num] = ZO_DeepTableCopy(self.profiles[id]) 
    end
    self:UpdateMenu()
    self:SetProfileNum(num)
    self:SetProfile(num) 
end


function ProfileManager:DeleteProfile() 
    local id = self:GetProfileId() 
    local num = self:GetProfileNum()
    
    if num > 1 then -- if another profile exists delete the current one
        table.remove(self.manager.profileNames, id)
        table.remove(self.profiles, id)
        self:SetProfileNum(num-1)
    else -- if it is the last profile, set it back to default
        self:SetProfileName("Default")
        self.profiles[1] = ZO_DeepTableCopy(self.defaults)
    end
    self:UpdateMenu()
    self:SetProfile(1)
    
    -- iterate through all characters
    for charId, profileId in pairs(self.manager.characterProfiles) do 
        -- if their profile gets deleted, set their id to 1
        self.manager.characterProfiles[charId] = profileId == id and 1 or profileId
    end
 
end



-- ToDO: add callback list to execute when profile changes 
    -- need to be able to register/unregister 
    -- update menu 

--[[ ------------------- ]]
--[[ -- Addon Submenu -- ]]
--[[ ------------------- ]]

function ProfileManager:UpdateMenu() 
    -- check if menu control have been created by LAM 
    if _G[self.name.."_MENU_PROFILE_LIST"] then 
        _G[self.name.."_MENU_PROFILE_LIST"]:UpdateChoices( self:GetProfileList() )
    end
end

function ProfileManager:InitSubmenu(dialogTitle) 
    
    local controls = {}
    table.insert(controls, {
        type = "dropdown",
        name = LIB_EXOY_SELECT..":",
        choices = self:GetProfileList(),
        getFunc = function() return self:GetProfileName() end,
        setFunc = function(profileName)
            local id = self:GetIdByName(profileName) 
            if id ~= 0 then 
                self:SetProfile(id)
            end
          end,
          width = "half",
          reference = self.name.."_MENU_PROFILE_LIST"
      })

    table.insert(controls, {
    type = "button", 
    name = LIB_EXOY_DELETE, 
    func = function() 
        self:DeleteProfile()
    end, 
    width = "half", 
    isDangerous = true,
    warning = LIB_EXOY_MENU_PROFILE_DELETE_WARNING,
    })

    table.insert(controls, {
        type = "header", 
        name = LIB_EXOY_MENU_PROFILE_RENAME_CURRENT,
    })

    table.insert(controls, {
        type = "editbox",
        name = "",
        warning = LIB_EXOY_MENU_PROFILE_RENAME_EDITBOX_TT,
        getFunc = function() return self.edit end,
        setFunc = function( text )
            self.edit = text
         end,
        isMultiline = false,
        width = "half",
      })

    table.insert(controls, {
    type = "button", 
    name = LIB_EXOY_RENAME, 
    func = function() 
        if LibExoY.HasDuplicateString(self:GetProfileList(),self.edit,true) then 
            LibExoY.WarningDialog(dialogTitle, LIB_EXOY_MENU_PROFILE_RENAME_WARNING_DUPLICATE )
        elseif LibExoY.IsStringEmpty(self.edit) then 
            LibExoY.WarningDialog(dialogTitle, LIB_EXOY_MENU_PROFILE_RENAME_WARNING_EMPTY)
        elseif LibExoY.IsFirstCharacterSpace(self.edit) then 
            LibExoY.WarningDialog(dialogTitle, LIB_EXOY_MENU_PROFILE_RENAME_WARNING_SPACE)
        else
            self:SetProfileName(self.edit)
            self:UpdateMenu()
        end
    end,
    width = "half", 
    })

    table.insert(controls, {
        type = "header", 
        name = LIB_EXOY_MENU_PROFILE_CREATE_NEW,
    })

    table.insert(controls, {
        type = "button", 
        name = LIB_EXOY_MENU_PROFILE_DUPLICATE_CURRENT, 
        tooltip = LIB_EXOY_MENU_PROFILE_DUPLICATE_CURRENT_TT,
        func = function() 
            self:CreateProfile(self:GetProfileId())    
        end, 
        width = "half", 
        })

    table.insert(controls, {
        type = "button", 
        name = LIB_EXOY_MENU_PROFILE_DUPLICATE_DEFAULT, 
        tooltip = LIB_EXOY_MENU_PROFILE_DUPLICATE_DEFAULT_TT,
        func = function() 
            self:CreateProfile(0) 
        end, 
        width = "half", 
        })

    self.submenu = controls
end


function ProfileManager:GetSubmenu() 
    local function GetSubmenuTitle() 
        local submenuName = zo_strformat("<<1>>: <<2>>", LIB_EXOY_PROFILE, self:GetProfileName() )
        return LibExoY.AddIconToString(submenuName, "esoui/art/icons/achievement_u31_dun1_hard_mode_boss2.dds", 36, "front")    
    end

    return {
        type = "submenu", 
        name = function() return GetSubmenuTitle()  end, 
        controls = self.submenu,
    }
end

--[[ --------------------- ]]
--[[ -- Local Functions -- ]]
--[[ --------------------- ]]

--[[ default structure: 
    defaults = {
        ["globals"] = {},               -- table with global variables 
        ["profiles"] = {                -- table with all profiles
            [1]={}                      -- table with profile variables of profile 1
        }, 
        ["profileManager"] = {
            ["profileNames"] = { 
                [1] = "default"         -- profile name list
            },
            ["characterProfiles"] = {   -- charId and corresponding "profileNumber"
                [*charId*] = 1,             
            }
            profileNum = 1              -- number of profiles in this SV (used to check for corruption etc.) 
        }
    }
]]

local function GetDefaultSV( globalDefaults, profileDefaults )
    local defaults = {}

    if LibExoY.IsTable( globalDefaults) then 
        defaults.globals = globalDefaults 
    else 
        --ToDo: error code 
    end 

    if LibExoY.IsTable( profileDefaults) then 
        defaults.profiles = {profileDefaults}
        defaults.profileManager = {
            characterProfiles = {[LibExoY.vars.charId] = 1},
            profileNames = {"Default"},
            profileNum = 1, 
        }
    else
        -- ToDo: error code 
    end

    return defaults 
end


--[[ ----------------------- ]]
--[[ -- Exposed Functions -- ]]
--[[ ----------------------- ]]

--[[ 
*name* - name of SavedVariables in SV file 
*version* - vavedVariable version number  
*globalDefaults* - table containing defaults variables that are independent! of profile  
*profileDefaults* - Table containing default variables that depent! on profiles 

*sv - table with subtables of global and profile variables: sv = { g= {}, p={} }
*dialogTitle: *string* to be displayed as title in dialog warning 
*callback: *table* with functions *func* and *trigger* 
            >>> *func* will be executed on a profile change, if *trigger* returns "true"
]]

function LibExoY.LoadSavedVariables( par )

    -- use ZOS-function to read SV-file of current account
    local store = ZO_SavedVars:NewAccountWide(par.svName, par.version, nil, GetDefaultSV( par.globalDefaults, par.profileDefaults ) )
    -- create sv table and load global variables 
    local sv = { g = store.globals, p = {} }
    -- only handle profiles if required
    local submenuHandler = InitProfileManager( par.svName, store, sv, par.profileDefaults, par.dialogTitle, par.callbacks) 
    
    -- return "sv" table and "submenu" table (submenu table is nil, if no profileDefaults were provided)
    return sv, submenuHandler
 end



