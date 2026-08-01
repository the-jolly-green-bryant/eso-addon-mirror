-- Author      : LintyDruid
-- Floating Message Area with queuing library

local qmess_ver=0.1

-- Manage alternate versions

if ldrude_qmess ~= nil then
	if ldrude_qmess.ver>qmess_ver then -- new version overwrite but preserve any data save call backs
		old_cbs=save_callbacks
		ldrude_qmess={ver=qmess_ver, save_callbacks=old_cbs}
	else
		return --- better version do not overwrite
	end
else
	ldrude_qmess={ver=qmess_ver, save_callbacks={}}
end

-- Init


ldrude_qmess={ver=qmess_ver, save_callbacks={}, 
				scales={
							["Large"]={f=1.1,d=64,s=80},
							["Normal"]={f=.8,d=64,s=74},
							["Small"]={f=.6,d=32,s=38},
							["Tiny"]={f=.4,d=16,s=24},
						}
			}
ldrude_qmess.data={x=0, y=-320, scale="Normal", lastset=0} -- Settings (local)
ldrude_qmess.ui={} -- core UI object
ldrude_qmess.ui.msgCache={} -- cached message to show
ldrude_qmess.ui.alert={} --- alert

ldrude_qmess.locked = true --- Is the message interface locked?

---- Manage Save Data Coordination
function ldrude_qmess.RegisterForConfigChangeEvent(rFunc)

	table.insert(ldrude_qmess.save_callbacks,rFunc)
end

function ldrude_qmess.ui.PushSaveData()

	ldrude_qmess.data.lastset=GetTimeStamp()

	for n=1,#ldrude_qmess.save_callbacks,1 do
		ldrude_qmess.save_callbacks[n](ldrude_qmess.data)
	end

end

function ldrude_qmess.Config(oSaveData)
	
	if oSaveData.lastset>ldrude_qmess.data.lastset then
		ldrude_qmess.data=oSaveData
		--****Need to update display***********
		ldrude_qmess.UpdateLayout()
		
	end

end

function ldrude_qmess.UpdateLayout()
	ldrude_qmess.ui.alert.window:SetAnchor(CENTER, GuiRoot, CENTER, ldrude_qmess.data.x,ldrude_qmess.data.y)
		
	ldrude_qmess.ui.alert.icon:SetDimensions(ldrude_qmess.scales[ldrude_qmess.data.scale].d,ldrude_qmess.scales[ldrude_qmess.data.scale].d)
	ldrude_qmess.ui.alert.label:SetScale(ldrude_qmess.scales[ldrude_qmess.data.scale].f)
	ldrude_qmess.ui.alert.label:SetAnchor(CENTER, ldrude_qmess.ui.alert.icon, CENTER, 0,ldrude_qmess.scales[ldrude_qmess.data.scale].s)

end
---------------- Main Code

function ldrude_qmess.ui.refreshIn(time_ms)
	zo_callLater(ldrude_qmess.ui.alert_refresh, time_ms)
	--d("Refresh in "..time_ms)
end


function ldrude_qmess.ui.create()
	 
	 
	 
	 -------------------------  Create Alert Box Interface -------------------
	 
	 
		ldrude_qmess.ui.alert.window = WINDOW_MANAGER:CreateTopLevelWindow("ldrude_qmess.ui.alert.window")
		
		ldrude_qmess.ui.alert.window:SetDimensions(200,44)
		ldrude_qmess.ui.alert.window:SetAnchor(CENTER, GuiRoot, CENTER, ldrude_qmess.data.x,ldrude_qmess.data.y)
		ldrude_qmess.ui.alert.window:SetHandler("OnUpdate", ldrude_qmess_ui_alert_refresh)
		ldrude_qmess.ui.alert.window:SetHidden(true)
		
	ldrude_qmess.ui.alert.icon = WINDOW_MANAGER:CreateControl("ldrude_qmess.ui.alert.icon",ldrude_qmess.ui.alert.window, CT_TEXTURE )
		ldrude_qmess.ui.alert.icon:SetDimensions(64,64)
		ldrude_qmess.ui.alert.icon:SetTexture("/esoui/art/campaign/campaign_tabicon_history_down.dds")
		ldrude_qmess.ui.alert.icon:SetDrawLayer(1)
		ldrude_qmess.ui.alert.icon:SetAnchor(CENTER, ldrude_qmess.ui.alert.window, CENTER, 0,0)
		
		ldrude_qmess.ui.alert.icon:SetHidden(true)
	
	ldrude_qmess.ui.alert.label = WINDOW_MANAGER:CreateControl("ldrude_qmess.ui.alert.label", ldrude_qmess.ui.alert.icon, CT_LABEL )
		ldrude_qmess.ui.alert.label:SetColor(0.8, 0.8, 0.8, 1)
		ldrude_qmess.ui.alert.label:SetFont("ZoFontAlert")
		ldrude_qmess.ui.alert.label:SetScale(.8)
		ldrude_qmess.ui.alert.label:SetWrapMode(TEX_MODE_WRAP)
		ldrude_qmess.ui.alert.label:SetDrawLayer(1)
		ldrude_qmess.ui.alert.label:SetText("ldrude_qmess message")
		ldrude_qmess.ui.alert.label:SetAnchor(CENTER, ldrude_qmess.ui.alert.icon, CENTER, 0,74)
		ldrude_qmess.ui.alert.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		ldrude_qmess.ui.alert.label:SetVerticalAlignment(TEXT_ALIGN_TOP)
		ldrude_qmess.ui.alert.label:SetHidden(true)
		ldrude_qmess.ui.alert.label:SetDimensions(600,80)
		ldrude_qmess.ui.alert.label:SetHandler("OnUpdate", ldrude_qmess_ui_alert_refresh)

		
	--- Globals
		
	 ldrude_qmess.ui.alert.maxticks=5000 -- Max Time alert will show for in ms
	 ldrude_qmess.ui.alert.visible=false -- Is it visible?
	 
	 
	 ldrude_qmess.init=true;
end



function ldrude_qmess.add(alertText, alertIconPath, alertLength_ms)
	
	if (alertLength_ms>ldrude_qmess.ui.alert.maxticks) then -- ensure max length not too long
	
		alertLength_ms=ldrude_qmess.ui.alert.maxticks
	end
	
	if (alertLength_ms<500) then -- ensure length not too small
	
		alertLength_ms=500
	end
	
	
	
	table.insert(ldrude_qmess.ui.msgCache,{alert=alertText,icon=alertIconPath,duration=alertLength_ms})
	
end

function ldrude_qmess.ui.showlert()
	
	if (IsReticleHidden() and ldrude_qmess.locked ) then
		return
	end
	
	ldrude_qmess.ui.alert.window:SetHidden(false)
	ldrude_qmess.ui.alert.icon:SetHidden(false)
	ldrude_qmess.ui.alert.label:SetHidden(false)
	ldrude_qmess.ui.alert.visible=true 

end

function ldrude_qmess.ui.hidealert()

	ldrude_qmess.ui.alert.window:SetHidden(true)
	ldrude_qmess.ui.alert.label:SetHidden(true)
		
	ldrude_qmess.ui.alert.label:SetText("")
		
	ldrude_qmess.ui.alert.start=0 
	ldrude_qmess.ui.alert.visible=false

end

function ldrude_qmess.ui.lock()
			--d("lock")
			ldrude_qmess.ui.hidealert()
			--ldrude_qmess.ui.refreshIn(500)
end

function ldrude_qmess.ui.unlock()
			--d("unlock")
			ldrude_qmess.ui.alert.icon:SetTexture("/esoui/art/actionbar/abilitybar_unlockedslot.dds")
			ldrude_qmess.ui.alert.label:SetText("This is a test message for an alert.")
			ldrude_qmess.ui.showlert()
			--ldrude_qmess.ui.refreshIn(500)
end


function ldrude_qmess.ui.alert_refresh()
	
	if (ldrude_qmess.locked==false) then
			ldrude_qmess.ui.refreshIn(500)
			return
	end
	
	
	if (#ldrude_qmess.ui.msgCache<1) then --- nothing to do check back in 1/2 sec
		if (ldrude_qmess.ui.alert.visible) then
			ldrude_qmess.ui.hidealert()
		end	
		ldrude_qmess.ui.refreshIn(500)
		return
	end
	
	--if ldrude_qmess.ui.alert.start==0 then 
	--	return
	--end
	

	if (#ldrude_qmess.ui.msgCache>0 and IsReticleHidden()==false) then ---  MOre to show and in play mode
		
		
		ldrude_qmess.ui.alert.label:SetText(ldrude_qmess.ui.msgCache[1].alert)
		
		ldrude_qmess.ui.alert.icon:SetTexture(ldrude_qmess.ui.msgCache[1].icon)
		
		ldrude_qmess.ui.showlert()
		ldrude_qmess.ui.refreshIn(ldrude_qmess.ui.msgCache[1].duration) -- call back when message is finished.
		table.remove(ldrude_qmess.ui.msgCache,1)
		return
	else
		
		ldrude_qmess.ui.hidealert()
		ldrude_qmess.ui.refreshIn(500)
		return
	end
		

end

---------------------------------------  Configuration Functions
--[[ Moved to settings.create()
function ldrude_qmess.ui.addconfig( olam, panId, class_stub )

	olam:AddHeader(panId, class_stub.."_qmess", "Alert Window")
	
	olam:AddDescription(panId, class_stub.."_qmess_desc", "Adjust the location where alerts from this and other add-ons will appear.")

	olam:AddCheckbox(panId, class_stub.."_qmess_lock", "Lock Message Window.", "Lock the message window for configuration.", ldrude_qmess.ui.getlock,ldrude_qmess.ui.setlock, false, "")
	
	olam:AddSlider(panId, class_stub.."_qmess_xpos", "Message Window X Position", "Zero (0) is the centre of the screen", -2000, 2000,10, ldrude_qmess.ui.getx, ldrude_qmess.ui.setx,true, "If you cannot see the message panel, set this value to 0")
	olam:AddSlider(panId, class_stub.."_qmess_ypos", "Message Window Y Position", "Zero (0) is the centre of the screen", -2000, 2000,10, ldrude_qmess.ui.gety, ldrude_qmess.ui.sety,true, "If you cannot see the message panel, set this value to 0")
	
	olam:AddDropdown(panId, class_stub.."_qmess_scale", "Alert Message Size", "", {"Large","Normal", "Small", "Tiny"},ldrude_qmess.ui.getscale, ldrude_qmess.ui.setscale, false,"" )

end
]]--


function ldrude_qmess.ui.getscale()
	
	return ldrude_qmess.data.scale
end

function ldrude_qmess.ui.setscale(value)
	
	ldrude_qmess.data.scale=value
	
	ldrude_qmess.UpdateLayout()
	
	ldrude_qmess.ui.PushSaveData()
end

function ldrude_qmess.ui.getlock()
	
	return ldrude_qmess.locked
end

function ldrude_qmess.ui.setlock(value)
	ldrude_qmess.locked=value
	 if (ldrude_qmess.locked) then
		ldrude_qmess.ui.lock()
	else
		ldrude_qmess.ui.unlock()
	end
end

function ldrude_qmess.ui.getx()
	return ldrude_qmess.data.x
end

function ldrude_qmess.ui.gety()
	return ldrude_qmess.data.y
end

function ldrude_qmess.ui.setx(value)
	ldrude_qmess.data.x=value
	ldrude_qmess.UpdateLayout()
	ldrude_qmess.ui.PushSaveData()
end

function ldrude_qmess.ui.sety(value)
	ldrude_qmess.data.y=value
	ldrude_qmess.UpdateLayout()
	ldrude_qmess.ui.PushSaveData()
end




--- Off we go


ldrude_qmess.ui.create()

ldrude_qmess.ui.alert_refresh() -- first refresh 