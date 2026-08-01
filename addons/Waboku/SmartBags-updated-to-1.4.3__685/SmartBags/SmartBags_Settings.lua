-- Name: SmartBags
-- Version: 1.3.5a
-- Author: Reikan
-- Settings functions

-------------------------------------------------------------------------------------------------------------------------
-- SETTINGS FUNCTIONS (GET / SET)
-------------------------------------------------------------------------------------------------------------------------
-- States color functions
-- Normal state color GET
function SmartBags.GetNormalStateColor()
	return SmartBags.settings.normalStateColor.r, SmartBags.settings.normalStateColor.g, SmartBags.settings.normalStateColor.b, SmartBags.settings.normalStateColor.a
end

-- Normal state color SET
function SmartBags.SetNormalStateColor(r, g, b, a)
	SmartBags.settings.normalStateColor.r = r
	SmartBags.settings.normalStateColor.g = g
	SmartBags.settings.normalStateColor.b = b
	SmartBags.settings.normalStateColor.a = a
	SmartBags.InfosUpdate()
end

-- Warning state percent value GET
function SmartBags.GetWarningStateValue()
	return SmartBags.settings.WarningValue
end

-- Warning state percent value SET
function SmartBags.SetWarningStateValue(_value)
	SmartBags.settings.WarningValue = _value
	SmartBags.InfosUpdate()
end

-- Warning state color GET
function SmartBags.GetWarningStateColor()
	return SmartBags.settings.warningStateColor.r, SmartBags.settings.warningStateColor.g, SmartBags.settings.warningStateColor.b, SmartBags.settings.warningStateColor.a
end

-- Warning state color SET
function SmartBags.SetWarningStateColor(r, g, b, a)
	SmartBags.settings.warningStateColor.r = r
	SmartBags.settings.warningStateColor.g = g
	SmartBags.settings.warningStateColor.b = b
	SmartBags.settings.warningStateColor.a = a
	SmartBags.InfosUpdate()
end

-- Full state color GET
function SmartBags.GetFullStateColor()
	return SmartBags.settings.fullStateColor.r, SmartBags.settings.fullStateColor.g, SmartBags.settings.fullStateColor.b, SmartBags.settings.fullStateColor.a
end

-- Full state color SET
function SmartBags.SetFullStateColor(r, g, b, a)
	SmartBags.settings.fullStateColor.r = r
	SmartBags.settings.fullStateColor.g = g
	SmartBags.settings.fullStateColor.b = b
	SmartBags.settings.fullStateColor.a = a
	SmartBags.InfosUpdate()
end

-- LootGoldLog Receive loot Color GET
function SmartBags.GetLootGoldLogReceiveLootColor()
	return SmartBags.settings.LootGoldLogReceiveLootColor.r, SmartBags.settings.LootGoldLogReceiveLootColor.g, SmartBags.settings.LootGoldLogReceiveLootColor.b, 1
end

-- LootGoldLog Receive gold Color GET
function SmartBags.GetLootGoldLogReceiveGoldColor()
	return SmartBags.settings.LootGoldLogReceiveGoldColor.r, SmartBags.settings.LootGoldLogReceiveGoldColor.g, SmartBags.settings.LootGoldLogReceiveGoldColor.b, 1
end

-- LootGoldLog Receive loot Color SET
function SmartBags.SetLootGoldLogReceiveLootColor(r, g, b, _)
	SmartBags.settings.LootGoldLogReceiveLootColor.r = r
	SmartBags.settings.LootGoldLogReceiveLootColor.g = g
	SmartBags.settings.LootGoldLogReceiveLootColor.b = b
end

-- LootGoldLog Receive gold Color SET
function SmartBags.SetLootGoldLogReceiveGoldColor(r, g, b, _)
	SmartBags.settings.LootGoldLogReceiveGoldColor.r = r
	SmartBags.settings.LootGoldLogReceiveGoldColor.g = g
	SmartBags.settings.LootGoldLogReceiveGoldColor.b = b
end

-- LootGoldLog Lost Color GET
function SmartBags.GetLootGoldLogLostColor()
	return SmartBags.settings.LootGoldLogLostColor.r, SmartBags.settings.LootGoldLogLostColor.g, SmartBags.settings.LootGoldLogLostColor.b, 1
end

-- LootGoldLog Lost Color SET
function SmartBags.SetLootGoldLogLostColor(r, g, b, _)
	SmartBags.settings.LootGoldLogLostColor.r = r
	SmartBags.settings.LootGoldLogLostColor.g = g
	SmartBags.settings.LootGoldLogLostColor.b = b
end

-- LootGoldLog Party Color GET
function SmartBags.GetLootGoldLogPartyColor()
	return SmartBags.settings.LootGoldLogPartyColor.r, SmartBags.settings.LootGoldLogPartyColor.g, SmartBags.settings.LootGoldLogPartyColor.b, 1
end

-- LootGoldLog Party Color SET
function SmartBags.SetLootGoldLogPartyColor(r, g, b, _)
	SmartBags.settings.LootGoldLogPartyColor.r = r
	SmartBags.settings.LootGoldLogPartyColor.g = g
	SmartBags.settings.LootGoldLogPartyColor.b = b
end

-- return hexa color for received loots
function SmartBags.GetLootGoldLogReceivedLootHexaColor()
	return SmartBags.HexaFromRGB(SmartBags.settings.LootGoldLogReceiveLootColor.r, SmartBags.settings.LootGoldLogReceiveLootColor.g, SmartBags.settings.LootGoldLogReceiveLootColor.b)
end

-- return hexa color for received gold
function SmartBags.GetLootGoldLogReceivedGoldHexaColor()
	return SmartBags.HexaFromRGB(SmartBags.settings.LootGoldLogReceiveGoldColor.r, SmartBags.settings.LootGoldLogReceiveGoldColor.g, SmartBags.settings.LootGoldLogReceiveGoldColor.b)
end

-- return hexa color for lost loot / gold
function SmartBags.GetLootGoldLogLostHexaColor()
	return SmartBags.HexaFromRGB(SmartBags.settings.LootGoldLogLostColor.r, SmartBags.settings.LootGoldLogLostColor.g, SmartBags.settings.LootGoldLogLostColor.b)
end

-- return hexa color for party loot
function SmartBags.GetLootGoldLogPartyHexaColor()
	return SmartBags.HexaFromRGB(SmartBags.settings.LootGoldLogPartyColor.r, SmartBags.settings.LootGoldLogPartyColor.g, SmartBags.settings.LootGoldLogPartyColor.b)
end

-- Lock / Unlock frame SET
function SmartBags.SetUILock(_bool)
	SmartBags.settings.Unlock = _bool
end

-- Show / Hide SmartBags during dialog SET
function SmartBags.SetShowInDialog(_bool)
	SmartBags.settings.ShowInDialog = _bool
end

-- Auto Swich Bank / Bag SET
function SmartBags.SetSwitchAuto(_bool)
	SmartBags.settings.AutoSwitch = _bool
end

-- LootGoldLog SET
function SmartBags.SetLootLog(_bool)
	SmartBags.settings.LootLog = _bool
end

-- LootGoldLog ShowGolds SET
function SmartBags.SetLootLogShowGolds(_bool)
	SmartBags.settings.ShowGolds = _bool
end

-- LootGoldLog Show total items SET
function SmartBags.SetLootLogShowTotalItems(_bool)
	SmartBags.settings.ShowTotalLoot = _bool
end

-- LootGoldLog Show party items SET
function SmartBags.SetLootLogShowPartyItems(_bool)
	SmartBags.settings.ShowPartyLoot = _bool
end

-- Language SET 
function SmartBags.SetLang(_lang)
	SmartBags.settings.LocalLang = _lang
	SmartBags.SetLangVariables()
	
	-- Reload the game UI
	ReloadUI()
end