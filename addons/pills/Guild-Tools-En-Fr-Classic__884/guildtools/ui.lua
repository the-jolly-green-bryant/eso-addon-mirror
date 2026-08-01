-- Author: Linty Druid

-- Guild Tools Gui

guildtools.ui={}
guildtools.ui.status={}
guildtools.ui.status.visible = true;
guildtools.ui.status.moveable=false
guildtools.ui.status.locked=true




function guildtools.ui.create()
	guildtools.ui.status.window = WINDOW_MANAGER:CreateTopLevelWindow("guildtools.ui.status.window")
		
	guildtools.ui.status.window:SetDimensions(470,24)
	guildtools.ui.status.window:SetAnchor(CENTER, GuiRoot, CENTER, guildtools.data.status.x,guildtools.data.status.y)
	guildtools.ui.status.window:SetHandler("OnUpdate",  guildtools.ui.status.Window_OnUpdate)
	guildtools.ui.status.window:SetMovable(false)
	guildtools.ui.status.window:SetMouseEnabled(true)
	
	guildtools.ui.status.window.SetFrameCoords = function(self)
		local x, y = 0, 0
		local addOnX, addOnY = self:GetCenter()
		local guiRootX, guiRootY = GuiRoot:GetCenter()
		x = addOnX - guiRootX
		y = addOnY - guiRootY
		d(addonX, addonY, guiRootX, guiRootY)
		 guildtools.data.status.x = x
		 guildtools.data.status.y = y
		
		--self:SetAnchor(CENTER, GuiRoot,CENTER, x, y)
	end
	
	guildtools.ui.status.window:SetHandler("OnMoveStop", function(self) guildtools.ui.status.window:SetFrameCoords() end)
	guildtools.ui.status.window:SetHidden(true)
	
	 -- <Backdrop name="$(parent)_lblCombatLogBG" edgeColor="444444" centerColor="000000" alpha="0.8" >
         -- <Dimensions x="250" y="135" />
          -- <Anchor point="TOPLEFT" />
          -- <Edge edgeSize="1" />
	
	guildtools.ui.status.backdrop = WINDOW_MANAGER:CreateControl("guildtools.ui.status.backdrop",guildtools.ui.status.window, CT_BACKDROP )
	guildtools.ui.status.backdrop:SetAnchor(TOPLEFT, guildtools.ui.status.window, TOPLEFT,0,0)
	guildtools.ui.status.backdrop:SetDimensions(470,24)
	--guildtools.ui.status.backdrop:SetEdgeSize(1)
	guildtools.ui.status.backdrop:SetEdgeColor(.4,.4,.4)
	guildtools.ui.status.backdrop:SetCenterColor(.9,0,.1)
	guildtools.ui.status.backdrop:SetAlpha(0.5)
	guildtools.ui.status.backdrop:SetHidden(true)
	
	guildtools.ui.status.prevguild = WINDOW_MANAGER:CreateControl("guildtools.ui.status.prevguild",guildtools.ui.status.window, CT_BUTTON )
	guildtools.ui.status.prevguild:SetDimensions(16,16)
	guildtools.ui.status.prevguild:SetNormalTexture("/esoui/art/charactercreate/charactercreate_leftarrow_up.dds")
	guildtools.ui.status.prevguild:SetMouseOverTexture("/esoui/art/charactercreate/charactercreate_leftarrow_over.dds")
	guildtools.ui.status.prevguild:SetDrawLayer(1)
	guildtools.ui.status.prevguild:SetAnchor(LEFT, guildtools.ui.status.window, LEFT,0,2)
	guildtools.ui.status.prevguild:SetHandler("OnClicked", function(self)  guildtools.ChangeGuild(-1) end )
	guildtools.ui.status.prevguild:SetHidden(true)
	
	-- guildtools.ui.status.icon = WINDOW_MANAGER:CreateControl("guildtools.ui.status.icon",guildtools.ui.status.window, CT_TEXTURE )
	-- guildtools.ui.status.icon:SetDimensions(32,32)
	-- guildtools.ui.status.icon:SetTexture("/esoui/art/campaign/campaign_tabicon_history_down.dds")
	-- guildtools.ui.status.icon:SetDrawLayer(1)
	-- guildtools.ui.status.icon:SetAnchor(LEFT, guildtools.ui.status.window, LEFT,0,0)
	
	-- guildtools.ui.status.icon:SetHidden(true)
	
	

	guildtools.ui.status.label = WINDOW_MANAGER:CreateControl("guildtools.ui.status.label",guildtools.ui.status.prevguild, CT_LABEL )
	guildtools.ui.status.label:SetColor(0.8, 0.8, 0.8, 1)
	guildtools.ui.status.label:SetFont("ZoFontAlert")
	guildtools.ui.status.label:SetScale(.6)
	guildtools.ui.status.label:SetWrapMode(TEX_MODE_CLAMP)
	guildtools.ui.status.label:SetDrawLayer(1)
	guildtools.ui.status.label:SetText("Guild Status Win")
	guildtools.ui.status.label:SetAnchor(LEFT,guildtools.ui.status.prevguild, RIGHT, 0,-2)
	guildtools.ui.status.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	guildtools.ui.status.label:SetVerticalAlignment(TEXT_ALIGN_TOP)
	guildtools.ui.status.label:SetHidden(true)
	guildtools.ui.status.label:SetDimensions(450,24)
	guildtools.ui.status.label:SetHandler("OnUpdate",  guildtools.ui.status.label_OnUpdate)
	
	
	guildtools.ui.status.nextguild = WINDOW_MANAGER:CreateControl("guildtools.ui.status.nextguild",guildtools.ui.status.window, CT_BUTTON )
	guildtools.ui.status.nextguild:SetDimensions(16,16)
	guildtools.ui.status.nextguild:SetNormalTexture("/esoui/art/charactercreate/charactercreate_rightarrow_up.dds")
	guildtools.ui.status.nextguild:SetMouseOverTexture("/esoui/art/charactercreate/charactercreate_rightarrow_over.dds")
	guildtools.ui.status.nextguild:SetDrawLayer(1)
	guildtools.ui.status.nextguild:SetAnchor(LEFT, guildtools.ui.status.label, RIGHT,0,2)
	guildtools.ui.status.nextguild:SetHandler("OnClicked", function(self)  guildtools.ChangeGuild(1) end )
	guildtools.ui.status.nextguild:SetHidden(true)
	
	
	guildtools.ui.status.info = CreateControlFromVirtual("guildtools.ui.status.info", guildtools.ui.status.window, "ZO_Options_WarningIcon")
	guildtools.ui.status.info.data = { tooltipText = "Guild Info..."}
	guildtools.ui.status.info:SetTexture("/esoui/art/buttons/info_disabled.dds")
	guildtools.ui.status.info:SetAnchor(LEFT, guildtools.ui.status.nextguild, RIGHT,0,-2)
	--guildtools.ui.status.info:SetHandler("OnMouseEnter", function() end )
	
	
	--guildtools.ui.status.label:SetHandler("OnMouseDown",  guildtools.ui.status.mousedown)
	--guildtools.ui.status.label:SetHandler("OnMouseUp",  guildtools.ui.status.mouseup)
	--guildtools.ui.status.label:SetHandler("OnMouseExit",  guildtools.ui.status.mouseexit)
	
	--guildtools.ui.status.setVisibility()
	guildtools.ui.status.lock()
	

	
	
	--------------------------Attach to Mail UI---------------
	
	
	local parent = ZO_MailSendToLabel:GetParent()
	guildtools.ui.mail={}
	
	
	--guildtools.ui.mail.sendofficers = CreateControlFromVirtual("guildtools.ui.mail.sendofficers", parent, "ZO_Options_WarningIcon")
	--guildtools.ui.mail.sendofficers.tooltipText = "Send the message below to all |c008000guild officers|r. \n\nThis will only send the subject and message.  No attachments or gold will be sent."
	guildtools.ui.mail.sendofficers = WINDOW_MANAGER:CreateControl("guildtools.ui.mail.sendofficer",parent, CT_BUTTON )
	guildtools.ui.mail.sendofficers:SetDimensions(32,32)
	guildtools.ui.mail.sendofficers:SetNormalTexture("/esoui/art/contacts/social_status_online.dds")
	guildtools.ui.mail.sendofficers:SetMouseOverTexture("/esoui/art/contacts/social_status_highlight.dds")
	guildtools.ui.mail.sendofficers:SetDrawLayer(2)
	guildtools.ui.mail.sendofficers:SetAnchor(LEFT, ZO_MailSendToLabel, RIGHT,250,0)
	guildtools.ui.mail.sendofficers:SetHandler("OnClicked", function(self)  guildtools.ui.mailSendMails(1) end )
	
	--guildtools.ui.mail.sendall = CreateControlFromVirtual("guildtools.ui.mail.sendall", parent, "ZO_Options_WarningIcon")
	--guildtools.ui.mail.sendall.tooltipText = "Send the message below to all |cff0000guild members|r. \n\nThis will only send the subject and message.  No attachments or gold will be sent."
	guildtools.ui.mail.sendall = WINDOW_MANAGER:CreateControl("guildtools.ui.mail.sendall",parent, CT_BUTTON )
	guildtools.ui.mail.sendall:SetDimensions(32,32)
	guildtools.ui.mail.sendall:SetNormalTexture("/esoui/art/contacts/social_status_dnd.dds")
	guildtools.ui.mail.sendall:SetMouseOverTexture("/esoui/art/contacts/social_status_highlight.dds")
--	guildtools.ui.mail.sendall:SetText("Send the message below to all |cff0000guild members|r. \n\nThis will only send the subject and message.  No attachments or gold will be sent.")
	guildtools.ui.mail.sendall:SetDrawLayer(2)
	guildtools.ui.mail.sendall:SetAnchor(LEFT, guildtools.ui.mail.sendofficers, RIGHT,-10,0)
	guildtools.ui.mail.sendall:SetHandler("OnClicked", function(self)  guildtools.ui.mailSendMails(2) end )
	
	guildtools.ui.mail.help = CreateControlFromVirtual("guildtools.ui.mail.help", parent, "ZO_Options_WarningIcon")
	guildtools.ui.mail.help.data = { tooltipText = guildtools.lang.core.mail_tooltipA .. "\n\n"..string.format(guildtools.lang.core.mail_tooltipB,guildtools.lang.core.noGuildSelectedShort)}
	guildtools.ui.mail.help:SetTexture("/esoui/art/miscellaneous/help_icon.dds")
	guildtools.ui.mail.help:SetAnchor(LEFT, guildtools.ui.mail.sendall, RIGHT,-10,0)
	
end


function guildtools.ui.mailSendMails(target)
	
	
	local subject = MAIL_SEND["subject"]:GetText()
	local message = MAIL_SEND["body"]:GetText()
	
	
	guildtools.CreateMailMessage(target, subject, message)
	
	--d("Send mail to : "..target)
	
end

function guildtools.ui.status.unlock()
	guildtools.ui.status.backdrop:SetHidden(false)

	guildtools.ui.status.backdrop:SetEdgeColor(.4,.4,.4)
	guildtools.ui.status.backdrop:SetCenterColor(.9,0,.1)
	guildtools.ui.status.backdrop:SetAlpha(0.9)
	guildtools.ui.status.window:SetMovable(true)
	guildtools.ui.status.moveable=true
	guildtools.ui.status.window:SetMouseEnabled(true)
	
end

function guildtools.ui.status.lock()

	guildtools.ui.status.backdrop:SetHidden(true)

	guildtools.ui.status.window:SetMovable(false)
	guildtools.ui.status.window:SetMouseEnabled(true)
	guildtools.ui.status.moveable=false
	
end


function guildtools.ui.status.update(sGuild, gOnline, gTotal, nOnline, nTotal, nAlliance)

		if guildtools.ui.status.label==nil then
			return
		end
		
		guildtools.ui.mail.help.data = { tooltipText = guildtools.lang.core.mail_tooltipA .. "\n\n".. string.format(guildtools.lang.core.mail_tooltipB,sGuild) .."\n\n"..guildtools.GetMailStatus()}
		
		 if guildtools.mail.paused then guildtools.ui.mail.help.data = {tooltipText=guildtools.ui.mail.help.data.tooltipText.." "..guildtools.lang.core.mail_pauselbl} end
		
		local status=""
		
		local statusLen=string.len("["..gOnline.."/"..gTotal.."] ["..nOnline.."/"..nTotal.."]")
		
		if (string.len(sGuild)>(40-statusLen)) then
			sGuild=string.sub(sGuild,1,39-statusLen).."..."
		end
		
		local  icons={	"/esoui/art/guild/guildBanner_icon_aldmeri.dds",
						"/esoui/art/guild/guildBanner_icon_ebonheart.dds",
						"/esoui/art/guild/guildBanner_icon_daggerfall.dds"}
		
		if nAlliance>0 then
		
			sGuild="|t24:24:"..icons[nAlliance].."|t"..sGuild
		end
		
		
		
		
		status ="|c008800"..sGuild.."|r [|c00ff00"..gOnline.."/"..gTotal.."|r] [|c00ffff"..nOnline.."/"..nTotal.."|r]"
		
		guildtools.ui.status.label:SetText(status);
		
		

end

function guildtools.ui.status.updateInfo(text)
	guildtools.ui.status.info.data = { tooltipText = text }
end


function guildtools.ui.status.setVisibility()

	if guildtools.ui.status.label==nil then
			return
	end
		
	if guildtools.data.status.show then
	
		guildtools.ui.status.window:SetHidden(false)
		--guildtools.ui.status.icon:SetHidden(false)
		guildtools.ui.status.prevguild:SetHidden(false)
		guildtools.ui.status.nextguild:SetHidden(false)
		guildtools.ui.status.info:SetHidden(false)
		guildtools.ui.status.label:SetHidden(false)
		guildtools.ui.status.visible=true 
		
		
		
		
	else
		
		guildtools.ui.status.window:SetHidden(true)
		--guildtools.ui.status.icon:SetHidden(true)
		guildtools.ui.status.prevguild:SetHidden(true)
		guildtools.ui.status.nextguild:SetHidden(true)
		guildtools.ui.status.label:SetHidden(true)
		guildtools.ui.status.info:SetHidden(true)
		guildtools.ui.status.visible=false 
		
	end
	
	

end






function guildtools.ui.status.Window_OnUpdate()
	
	

end

function guildtools.ui.status.label_OnUpdate()

end

