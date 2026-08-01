---
--@module Addon
local addon = {} --#Addon
addon.name = "AssistRapidRiding" --#string
addon.version = "2.0.4" --#string
---
--@field [parent=#global] #Addon AssistRapidRiding
AssistRapidRiding = addon

local _classMap = {}--#map<#string,#Class>
local _extensionsMap = {}--#map<#string,#list<#function>>
local _initiatorsMap = {}--#map<#string,#list<#function>>

---
-- @type SavedVars
local _savedVarsDefaults = {
    _name="ARRSV",
    _version = "1.1",
    _accountWide = false,
}
local _accountSavedVars --#SavedVars
local _characterSavedVars --#SavedVars

local _menuOptions = {} --#list<#table>
local gettext = LibStub("LibTextDict")("AssistRapidRiding").gettext
_menuOptions[1] = {
    type = "checkbox",
    name = gettext("Account Wide Configuration"),
    getFunc = function() return _accountSavedVars._accountWide end,
    setFunc = function(value)
        _accountSavedVars._accountWide = value
    end,
    width = "full",
    default = true,
}



---
--@param #string className
--@param #function constructor
--@return #Class class
function addon.AddClass(className, constructor)
    ---
    -- @type Class
    local class = {
        className = className,
        ---
        --@param #list<#string> dependList
        --@param #function logic
        AddInitiator = function(dependList, logic)
            local initiated = false
            _initiatorsMap[className]=function()
                if initiated then return end
                initiated = true
                if dependList then
                    for i, depend in ipairs(dependList) do
                        local initiator = _initiatorsMap[depend]
                        if initiator then initiator() end
                    end
                end
                if logic then logic() end
            end
        end,
        ---
        --@param #Class self
        --@param #string extensionName
        CallExtension=function(self, extensionName, ...)
            addon.CallExtension(className..':'..extensionName,self,...)
        end
    }
    _classMap[className] = class
    setmetatable(class, {
        __call = function (cls, ...)
            local instance = setmetatable({}, {__index=class})
            if constructor then constructor(instance, ...) end
            return instance
        end,
    })
    return class
end

---
--@param #string fullExtensionName
--@param #function extensionFunc
function addon.AddExtension(fullExtensionName, extensionFunc)
    local extensionFuncList = _extensionsMap[fullExtensionName] --#list<#function>
    if not extensionFuncList then
        extensionFuncList = {}
        _extensionsMap[fullExtensionName] = extensionFuncList
    end
    table.insert(extensionFuncList,extensionFunc)
end

function addon.AddMenuOptions(...)
    for i=1,select('#',...) do
        local option = select(i, ...)
        _menuOptions[#_menuOptions+1] = option
    end
end

function addon.AddSavedVarsDefaults(...)
    zo_mixin(_savedVarsDefaults,...)
end

---
--@param #string fullExtensionName
function addon.CallExtension(fullExtensionName, ...)
    local extensionFuncList = _extensionsMap[fullExtensionName]
    if extensionFuncList then
        for i, extensionFunc in ipairs(extensionFuncList) do
            extensionFunc(...)
        end
    end
end

---
--@param #string className
--@return #Class class
function addon.GetClass(className)
    local initiator = _initiatorsMap[className]
    if initiator then initiator() end
    return _classMap[className]
end
---
--@param #string text enStr text
--@reutrn #string i18nStr text
function addon.GetText(text)
    return gettext(text)
end

---
--@return #SavedVars
function addon.SavedVars()
    return _accountSavedVars._accountWide and _accountSavedVars or _characterSavedVars
end

---
--@return #SavedVars
function addon.CharacterSavedVars()
    return _characterSavedVars
end

local function LoadVars()
    _accountSavedVars = ZO_SavedVars:NewAccountWide(_savedVarsDefaults._name, _savedVarsDefaults._version, nil, _savedVarsDefaults)
    _characterSavedVars = ZO_SavedVars:New(_savedVarsDefaults._name, _savedVarsDefaults._version, nil, _savedVarsDefaults)
end

local function LoadMenus()
    --- Init Menu
    local LAM2 = LibStub("LibAddonMenu-2.0")
    if LAM2 == nil then return end
    local panelData = {
        debugLevel = 0,
        type = 'panel',
        name = addon.name,
        displayName = "ARR Settings",
        author = "Cloudor",
        version = addon.version,
        website = "http://www.esoui.com/downloads/fileinfo.php?id=1554#info",
        slashCommand = "/arrset",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM2:RegisterAddonPanel('ARRAddonOptions', panelData)
    LAM2:RegisterOptionControls('ARRAddonOptions', _menuOptions)
end

local function OnAddOnLoaded(eventCode, addonName)
    if addon.name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
    LoadVars()
    LoadMenus()
    addon.CallExtension("addon:Start", addon)
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

return addon
