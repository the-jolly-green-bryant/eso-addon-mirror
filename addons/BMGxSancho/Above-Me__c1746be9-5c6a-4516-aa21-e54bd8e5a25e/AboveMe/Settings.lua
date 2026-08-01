AboveMe = AboveMe or {}
local AM = AboveMe
local LHA
local CREDIT_YELLOW = "|cE5C100"
local COLOR_END = "|r"
local function CurrentGroupChoices()
    local items={{name="Select a player",data=""}}
    if IsUnitGrouped("player") then for i=1,12 do local tag="group"..i; if DoesUnitExist(tag) and IsUnitPlayer(tag) then local n=GetUnitDisplayName(tag); if n and n~="" then items[#items+1]={name=n,data=n} end end end end
    return items
end
local OVERRIDE_MODES={{name="Use Player's Choice",data="remote"},{name="Override Locally",data="local"},{name="Hide This Player's Icon",data="hide"}}
local function ResolveMode(itemName,itemData) if itemData=="local" or itemData=="hide" or itemData=="remote" then return itemData end; if itemName=="Override Locally" then return "local" elseif itemName=="Hide This Player's Icon" then return "hide" end; return "remote" end
function AM:CreateSettings()
    if not LibHarvensAddonSettings then return end; LHA=LibHarvensAddonSettings
    local panel=LHA:AddAddon("Above Me",{allowDefaults=true,allowRefresh=true}); if not panel then return end
    panel:AddSetting({type=LHA.ST_LABEL,label=CREDIT_YELLOW.."A BMG ADDON\nCreated and maintained by @BMGXSANCHO\nVersion 0.5.0-dev1"..COLOR_END})
    panel:AddSetting({type=LHA.ST_SECTION,label="My Icon"})
    panel:AddSetting({type=LHA.ST_LABEL,label=function() local i=AM:GetIcon(AM.saved.iconId); return "CURRENT ICON\n"..i.name end})
    panel:AddSetting({type=LHA.ST_BUTTON,label="Choose My Icon",tooltip="Open the full-screen icon browser with categories, previews, and favorites.",buttonText="OPEN BROWSER",clickHandler=function() AM:OpenIconBrowser() end})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Favorite Current Icon",getFunction=function() return AM:IsFavorite(AM.saved.iconId) end,setFunction=function(v) AM:SetFavorite(AM.saved.iconId,v) end,default=false})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Random Favorite on Login",getFunction=function() return AM.saved.randomFavoriteOnLogin end,setFunction=function(v) AM.saved.randomFavoriteOnLogin=v end,default=false})
    panel:AddSetting({type=LHA.ST_BUTTON,label="Random Favorite Now",buttonText="CHOOSE",clickHandler=function() AM:ChooseRandomFavorite() end})
    panel:AddSetting({type=LHA.ST_SECTION,label="Visibility"})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Enable Above Me",getFunction=function() return AM.saved.enabled end,setFunction=function(v) AM.saved.enabled=v end,default=true})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Show My Own Icon",getFunction=function() return AM.saved.showOwnIcon end,setFunction=function(v) AM.saved.showOwnIcon=v end,default=true})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Show Group Icons",getFunction=function() return AM.saved.showGroupIcons end,setFunction=function(v) AM.saved.showGroupIcons=v end,default=true})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Only Show During Combat",getFunction=function() return AM.saved.combatOnly end,setFunction=function(v) AM.saved.combatOnly=v end,default=false})
    panel:AddSetting({type=LHA.ST_SECTION,label="Appearance"})
    panel:AddSetting({type=LHA.ST_SLIDER,label="Icon Size",min=24,max=96,step=2,getFunction=function() return AM.saved.size end,setFunction=function(v) AM.saved.size=v end,default=48})
    panel:AddSetting({type=LHA.ST_SLIDER,label="Height Above Player",min=1.5,max=5,step=0.1,getFunction=function() return AM.saved.height end,setFunction=function(v) AM.saved.height=v end,default=2.7})
    panel:AddSetting({type=LHA.ST_SLIDER,label="Opacity",min=0.2,max=1,step=0.05,getFunction=function() return AM.saved.opacity end,setFunction=function(v) AM.saved.opacity=v end,default=1})
    panel:AddSetting({type=LHA.ST_SLIDER,label="Icon Visibility Distance",tooltip="Maximum distance at which another player's icon remains visible.",min=10,max=100,step=5,getFunction=function() return AM.saved.maxDistance end,setFunction=function(v) AM.saved.maxDistance=v end,default=55})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Scale With Distance",getFunction=function() return AM.saved.distanceScaling end,setFunction=function(v) AM.saved.distanceScaling=v end,default=true})
    panel:AddSetting({type=LHA.ST_CHECKBOX,label="Fade Near Visibility Limit",getFunction=function() return AM.saved.fadeWithDistance end,setFunction=function(v) AM.saved.fadeWithDistance=v end,default=false})
    panel:AddSetting({type=LHA.ST_SECTION,label="Local Group Overrides"})
    panel:AddSetting({type=LHA.ST_DROPDOWN,label="Group Member",items=CurrentGroupChoices(),getFunction=function() return AM.saved.selectedPlayer~="" and AM.saved.selectedPlayer or "Select a player" end,setFunction=function(control,itemName,itemData) AM.saved.selectedPlayer=itemData or itemName or "" end,default="Select a player"})
    panel:AddSetting({type=LHA.ST_DROPDOWN,label="Display Mode",items=OVERRIDE_MODES,getFunction=function() local o=AM.saved.playerOverrides[AM.saved.selectedPlayer or ""]; if o and o.mode=="local" then return "Override Locally" elseif o and o.mode=="hide" then return "Hide This Player's Icon" end; return "Use Player's Choice" end,setFunction=function(control,itemName,itemData) local player=AM.saved.selectedPlayer; if not player or player=="" then return end; local mode=ResolveMode(itemName,itemData); if mode=="remote" then AM.saved.playerOverrides[player]=nil else AM.saved.playerOverrides[player]={mode=mode,iconId=AM.saved.iconId} end end,default="Use Player's Choice"})
    panel:AddSetting({type=LHA.ST_BUTTON,label="Use My Current Icon as Local Override",buttonText="ASSIGN",clickHandler=function() local p=AM.saved.selectedPlayer; if p and p~="" then AM.saved.playerOverrides[p]={mode="local",iconId=AM.saved.iconId} end end})
    panel:AddSetting({type=LHA.ST_BUTTON,label="Clear Local Group Overrides",buttonText="CLEAR ALL",clickHandler=function() AM.saved.playerOverrides={} end})
    self.settingsPanel=panel
end
