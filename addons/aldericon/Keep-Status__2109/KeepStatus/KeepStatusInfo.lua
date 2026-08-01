--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
This addon is 90% copied and then modified from Sasky's addon CyrHUD (http://www.esoui.com/downloads/info559-CyrHUD.html)
I give all credit to them for the overall ui and design.
My modifications are just listing keeps that are your alliance that aren't under attack that have a resource taken or a resource under the max upgrade level.
]]

-- Initialized the addon names
KeepStatus = {}
KeepStatus.name = "KeepStatus"
KeepStatus.version = 9.0

KeepStatus.playerAlliance = nil
KeepStatus.defaultBGColor = ZO_ColorDef:New(0, 0, 0, .3)
KeepStatus.invisColor = ZO_ColorDef:New(0,0,0,0)
KeepStatus.playerInPvP = false
KeepStatus.width = 280
KeepStatus.iconWidthHeight = 30
KeepStatus.campaignId = 0

KeepStatus.defaults={
	xoff = -10,
	yoff = 60,
	timerOn = true
}
