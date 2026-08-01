AboveMe = AboveMe or {}
local AM = AboveMe
AM.name="AboveMe"
AM.version="0.5.0-dev1"
local CURRENT_SETTINGS_VERSION=7
local defaults={settingsVersion=CURRENT_SETTINGS_VERSION,enabled=true,iconId=101,selectedCategory="classic",showOwnIcon=true,showGroupIcons=true,combatOnly=false,size=48,height=2.7,opacity=1,maxDistance=55,distanceScaling=true,fadeWithDistance=false,updateRate=75,selectedPlayer="",playerIcons={},playerOverrides={},selectedOverrideMode="remote",favorites={},recentIcons={},randomFavoriteOnLogin=false}
local LEGACY_ICON_MAP={[1]=1,[101]=101,[102]=102,[103]=103,[104]=104,[105]=105,[106]=106,[107]=107,[108]=108}
local function MigrateIconId(id) id=tonumber(id) or 1; if AM.ICONS_BY_ID[id] then return id end; return LEGACY_ICON_MAP[id] or 101 end
function AM:MigrateSavedVariables()
    local version=self.saved.settingsVersion or 0
    self.saved.iconId=MigrateIconId(self.saved.iconId); self.saved.playerOverrides=self.saved.playerOverrides or {}; self.saved.favorites=self.saved.favorites or {}; self.saved.recentIcons=self.saved.recentIcons or {}
    if not self.saved.selectedCategory or not self.PACKS_BY_ID[self.saved.selectedCategory] then self.saved.selectedCategory=self:GetIcon(self.saved.iconId).pack or "classic" end
    for n,o in pairs(self.saved.playerOverrides) do if type(o)=="table" then o.iconId=MigrateIconId(o.iconId) end end
    self.saved.settingsVersion=CURRENT_SETTINGS_VERSION
end
function AM:Initialize()
    self.saved=ZO_SavedVars:NewAccountWide("AboveMeSavedVariables",1,nil,defaults); self:MigrateSavedVariables()
    if self.saved.randomFavoriteOnLogin then self:ChooseRandomFavorite() end
    self:CreateRenderer(); self:CreateIconBrowser(); self:CreateSettings(); self:StartRenderer()
end
local function OnAddonLoaded(eventCode,addonName) if addonName~=AM.name then return end; EVENT_MANAGER:UnregisterForEvent(AM.name,EVENT_ADD_ON_LOADED); AM:Initialize() end
EVENT_MANAGER:RegisterForEvent(AM.name,EVENT_ADD_ON_LOADED,OnAddonLoaded)
