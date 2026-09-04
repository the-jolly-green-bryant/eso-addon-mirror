local TT, LAM = ThiefTools, LibAddonMenu2
local function refresh() TT:ScanStolenItems(); TT:ApplyDisplaySettings() end
function TT:RegisterSettings()
 self.settingsPanel=LAM:RegisterAddonPanel("ThiefToolsOptions",{type="panel",name=self.displayName,displayName=self.displayName,author=self.author,version=self.version,slashCommand="/tt.settings",registerForRefresh=true,registerForDefaults=true})
 local controls={{type="description",text="Classify stolen items as Fence, Launder, or Ignore. The counter shows categorized item totals, remaining daily transactions, and total Fence gold value."},{type="header",name="Stolen Item Categories"}}
 for _,category in ipairs(self.categoryDefinitions) do local c=category;controls[#controls+1]={type="dropdown",name=c.name,choices=self.modes,getFunc=function() return TT.saved.categories[c.key] end,setFunc=function(v) TT.saved.categories[c.key]=v;refresh() end,default=c.default,width="half"} end
 controls[#controls+1]={type="header",name="Counter Panel"}
 controls[#controls+1]={type="checkbox",name="Lock panel position",getFunc=function() return TT.saved.display.locked end,setFunc=function(v) TT.saved.display.locked=v;refresh() end,default=false}
 controls[#controls+1]={type="checkbox",name="Show background",getFunc=function() return TT.saved.display.background end,setFunc=function(v) TT.saved.display.background=v;refresh() end,default=true}
 controls[#controls+1]={type="slider",name="Panel scale",min=75,max=150,step=5,getFunc=function() return TT.saved.display.scale*100 end,setFunc=function(v) TT.saved.display.scale=v/100;refresh() end,default=100}
 LAM:RegisterOptionControls("ThiefToolsOptions",controls)
end
SLASH_COMMANDS["/tt.settings"]=function() LAM:OpenToPanel(TT.settingsPanel) end
