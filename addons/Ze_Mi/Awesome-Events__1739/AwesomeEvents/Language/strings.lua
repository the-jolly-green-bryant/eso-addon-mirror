--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: strings.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local strings = {
	--main
	SI_AWEVS_ALL_MODS_DISABLED="Enable an Awesome Events module",
	SI_AWEVS_DESCRIPTION="Stay in the loop with Awesome Events! Get notified about various in-game events while you play. Explore different modules and customization options to tweak your gaming experience. Don't forget to check out all the options on the settings page. Your feedback is important! If you have any suggestions, translation contributions, or bug reports, feel free to reach out. You can contact me via the addons page at https://esoui.com",

	--debug
	SI_AWEVS_DEBUG_NO_EVENT_CALLBACKS="No callbacks, event listener removed!",
	SI_AWEVS_DEBUG_ENABLED="|c82D482ENABLED",
	SI_AWEVS_DEBUG_DISABLED="|cD49682DISABLED",
	SI_AWEVS_DEBUG_MODULE_EVENT_INVALID="Invalid event object!\nExpected: event={eventCode=EVENT_...,callback=function() ... end}!\nBoth keys are mandatory!\nIs:",
	SI_AWEVS_DEBUG_MODULE_OPTION_INVALID="Invalid options object!\nExpected: option={type='',name='',tooltip='',default=...}!\nAt least those keys are mandatory!\nIs:",
	SI_AWEVS_DEBUG_MODULE_NOT_FOUND="Module not found!",
	SI_AWEVS_DEBUG_MODULE_NO_TIMER="This module doesn't listen to the EVENT_TIMER event or you are trying to call a Timer Function inside the Enable Function, sorry thats not possible. The timer cannot be used.",
	SI_AWEVS_DEBUG_COMMAND_USAGE="Usage: /aedebug mod_id (on\off)",

	--appearance
	SI_AWEVS_APPEARANCE="Appearance",
	SI_AWEVS_APPEARANCE_MOVABLE="Movable Window",
	SI_AWEVS_APPEARANCE_MOVABLE_HINT="UnLocks the window so it can be moved.",
	SI_AWEVS_APPEARANCE_TEXTALIGN="Text alignment",
	SI_AWEVS_APPEARANCE_TEXTALIGN_HINT="The alignment of all text within the add-on.",
	SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT="Left",
	SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER="Center",
	SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT="Right",
	SI_AWEVS_APPEARANCE_UISCALE="UI scale",
	SI_AWEVS_APPEARANCE_UISCALE_HINT="Set the scale of the UI.",
	SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA="Background Transparency",
	SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA_HINT="Set the degree of background transparency.",
	SI_AWEVS_APPEARANCE_COLOR_AVAILABLE="Color (availability)",
	SI_AWEVS_APPEARANCE_COLOR_AVAILABLE_HINT="Change the text color of availability messages.",
	SI_AWEVS_APPEARANCE_COLOR_HINT="Color (hint)",
	SI_AWEVS_APPEARANCE_COLOR_HINT_HINT="Change the text color of hints.",
	SI_AWEVS_APPEARANCE_COLOR_WARNING="Color (warning)",
	SI_AWEVS_APPEARANCE_COLOR_WARNING_HINT="Change the text color of warnings.",
	SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT="Hint: No module enabled",
	SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT_HINT="Show a message in the awesome events window if all modules are disabled.",

	--import
	SI_AWEVS_IMPORT="Import Settings",
	SI_AWEVS_IMPORT_DESCRIPTION="Overwrite your settings with those from another character",
	SI_AWEVS_IMPORT_CHARACTER_LABEL="Import from",
	SI_AWEVS_IMPORT_CHARACTER_SELECT=" - Select a charakter -",
	SI_AWEVS_IMPORT_BUTTON="Import",

	--module-all
	SI_AWEMOD_SHOW="Show",
	SI_AWEMOD_SHOW_HINT="Show or hide all notifications from this module",
	SI_AWEMOD_SPACING_POSITION="Spacing (Position)",
	SI_AWEMOD_SPACING_POSITION_HINT="Set the gap position between notifications of this module and the following notifications.",
	SI_AWEMOD_SPACING_BOTTOM="at bottom",
	SI_AWEMOD_SPACING_BOTH="at top and at bottom",
	SI_AWEMOD_SPACING_TOP="at top",
	SI_AWEMOD_SPACING="Spacing (Size)",
	SI_AWEMOD_SPACING_HINT="Set the gap between notifications of this module and the following notifications.",
	SI_AWEMOD_FONTSIZE="Fontsize",
	SI_AWEMOD_FONTSIZE_HINT="Set the fontsize of all notifications from this module.",

	--module-bufffood
	SI_AWEMOD_BUFFFOOD="Buff-Food",
	SI_AWEMOD_BUFFFOOD_HINT="Get a countdown when your bufffoods effect is nearly complete, or a notification if you don't have any food effect.",
	SI_AWEMOD_BUFFFOOD_TIMER_LABEL="Effect <<C:1>> ends in",
	SI_AWEMOD_BUFFFOOD_READY_LABEL="Take your buff-food!",
	SI_AWEMOD_BUFFFOOD_TIMER="Start buff-food timer (minutes)",
	SI_AWEMOD_BUFFFOOD_TIMER_HINT="Will show the countdown timer if your buff-food's effect ends within the number of minutes below.",
	SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT="Blink in combat",
	SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT_HINT="The warning will start blinking while you don't have any bufffood effect in combat.",
	SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT="Hide out of combat",
	SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT_HINT="If you don't have any active bufffood effect and you are not in combat for 5 minutes, the (Take your buff-food!) warning will be hidden till the next combat or your next lunch.",

	--module-clock
	SI_AWEMOD_CLOCK="Time and Date",
	SI_AWEMOD_CLOCK_HINT="Get a clock on your screen, optionally with the current date.",
	SI_AWEMOD_CLOCK_DATEFORMAT="Date format",
	SI_AWEMOD_CLOCK_DATEFORMAT_HINT="Choose your prefered date format.",
	SI_AWEMOD_CLOCK_DATEFORMAT_DAY="day",
	SI_AWEMOD_CLOCK_DATEFORMAT_MONTH="month",
	SI_AWEMOD_CLOCK_DATEFORMAT_YEAR="year",
	SI_AWEMOD_CLOCK_DATEFORMAT_DEFAULT="month/day/year",
	SI_AWEMOD_CLOCK_STYLE="Appearance",
	SI_AWEMOD_CLOCK_STYLE_HINT="Choose your preferred appearance.",
	SI_AWEMOD_CLOCK_STYLE_TIME="Time only",
	SI_AWEMOD_CLOCK_STYLE_DATETIME_SHORT="Date & Time (single line)",
	SI_AWEMOD_CLOCK_STYLE_DATETIME_LONG="Date & Time (double line)",
	SI_AWEMOD_CLOCK_FORMAT="Clock format - 24 hour",
	SI_AWEMOD_CLOCK_FORMAT_HINT="Display the clock in 24-hour/military format or in 12-hour with AM/PM.",

	--module-crafting
	SI_AWEMOD_CRAFTING="Crafting Research",
	SI_AWEMOD_CRAFTING_HINT="Get a countdown when your next research is nearly complete, or a notification if a research slot is available.",
	SI_AWEMOD_CRAFTING_AVAILABLE_LABEL="can research",
	SI_AWEMOD_CRAFTING_BLACKSMITHING="Show timer for Blacksmithing",
	SI_AWEMOD_CRAFTING_BLACKSMITHING_HINT="Display a countdown timer when your Blacksmithing research is nearly complete. Adjust the threshold below.",
	SI_AWEMOD_CRAFTING_CLOTHING="Show timer for Clothing",
	SI_AWEMOD_CRAFTING_CLOTHING_HINT="Display a countdown timer when your Clothing research is nearly complete. Adjust the threshold below.",
	SI_AWEMOD_CRAFTING_JEWELRY="Show timer for Jewelry Crafting",
	SI_AWEMOD_CRAFTING_JEWELRY_HINT="Display a countdown timer when your Jewelry Crafting research is nearly complete. Adjust the threshold below.",
	SI_AWEMOD_CRAFTING_WOODWORKING="Show timer for Woodworking",
	SI_AWEMOD_CRAFTING_WOODWORKING_HINT="Display a countdown timer when your Woodworking research is nearly complete. Adjust the threshold below.",
	SI_AWEMOD_CRAFTING_TIMER="Research warning timer (minutes)",
	SI_AWEMOD_CRAFTING_TIMER_HINT="Will show the countdown warning timer if any research completes within this many minutes.",

	--module-durability
	SI_AWEMOD_DURABILITY="Durability of equipped Armor",
	SI_AWEMOD_DURABILITY_LABEL="Durability",
	SI_AWEMOD_DURABILITY_HINT="Get a notification before the durability of your equipped armor gets to weak.",
	SI_AWEMOD_DURABILITY_INFO="Durability (|cFFFF60info|r) %",
	SI_AWEMOD_DURABILITY_INFO_HINT="If durability of one of your equipped items is this many or less, you will see a notification.",
	SI_AWEMOD_DURABILITY_WARNING="Durability (|cFF6060warning|r) %",
	SI_AWEMOD_DURABILITY_WARNING_HINT="If durability of one of your equipped items is this many or less, you will see a warning.",

	--module-fencing
	SI_AWEMOD_FENCING="Thieves Guild",
	SI_AWEMOD_FENCING_HINT="Get a notification if the number of available transactions at your thieves guild is lower then the following values, or a countdown timer until you get new transactions.",
	SI_AWEMOD_FENCING_SELLS_LABEL="Sells left",
	SI_AWEMOD_FENCING_LAUNDERS_LABEL="Launders left",
	SI_AWEMOD_FENCING_SELLS="Show warning for low sells",
	SI_AWEMOD_FENCING_SELLS_HINT="Display a notification when the number of sells remaining falls below the info and warning values set below.",
	SI_AWEMOD_FENCING_SELLS_INFO="Sells remaining (|cFFFF60info|r)",
	SI_AWEMOD_FENCING_SELLS_INFO_HINT="If the number of sells left is this many or less, you will see a notification.",
	SI_AWEMOD_FENCING_SELLS_WARNING="Sells remaining (|cFF6060warning|r)",
	SI_AWEMOD_FENCING_SELLS_WARNING_HINT="If the number of sells remaining is this many or less, you will see a warning.",
	SI_AWEMOD_FENCING_LAUNDERS="Show warning for low launders",
	SI_AWEMOD_FENCING_LAUNDERS_HINT="Display a notification when the number of launders remaining falls below the info and warning values set below.",
	SI_AWEMOD_FENCING_LAUNDERS_INFO="Launders remaining (|cFFFF60info|r)",
	SI_AWEMOD_FENCING_LAUNDERS_INFO_HINT="If the number of launders left is this many or less, you will see a notification.",
	SI_AWEMOD_FENCING_LAUNDERS_WARNING="Launders remaining (|cFF6060warning|r)",
	SI_AWEMOD_FENCING_LAUNDERS_WARNING_HINT="If the number of launders remaining is this many or less, you will see a warning.",

	--module-inventory
	SI_AWEMOD_INVENTORY="Inventory (Space & Money)",
	SI_AWEMOD_INVENTORY_HINT="Show details about your current inventor usage, the money you own and/or get a notification before you go out of backpack space.",
	SI_AWEMOD_INVENTORY_LOW="Show low space warning",
	SI_AWEMOD_INVENTORY_LOW_HINT="Get a notification before you go out of backpack space.",
	SI_AWEMOD_INVENTORY_LOW_INFO="Backpack space low (|cFFFF60info|r)",
	SI_AWEMOD_INVENTORY_LOW_INFO_HINT="If remaining backpack space is this many or less, you will see a notification",
	SI_AWEMOD_INVENTORY_LOW_WARNING="Backpack space low (|cFF6060warning|r)",
	SI_AWEMOD_INVENTORY_LOW_WARNING_HINT="If remaining backpack space is this many or less, you will see a warning.",
	SI_AWEMOD_INVENTORY_LOW_LABEL="Bag space|r: <<1>>",
	SI_AWEMOD_INVENTORY_DETAILS="Show inventory details",
	SI_AWEMOD_INVENTORY_DETAILS_HINT="Show details about your current bank und backpack usage.",
	SI_AWEMOD_INVENTORY_DETAILS_LABEL="<<1>>Backpack|r: <<2>>/<<3>> <<1>>|| Bank|r: <<4>>/<<5>>",
	SI_AWEMOD_INVENTORY_MONEY="Show money",
	SI_AWEMOD_INVENTORY_MONEY_HINT="Show the money you own (bank and backpack).",
	SI_AWEMOD_INVENTORY_MONEY_LABEL="Money|r: <<1>>k |t16:16:EsoUI/Art/currency/currency_gold.dds|t<<2[/ (+1k banked)/ (+$dk banked)]>>",
	SI_AWEMOD_INVENTORY_ADVCURRENCIES="Show special currencies",
	SI_AWEMOD_INVENTORY_ADVCURRENCIES_HINT="Show the amount of telvar stones or writ vouchers you own.",
	SI_AWEMOD_INVENTORY_TELVARSTONES_LABEL="Telvar|r: <<1>> |t16:16:EsoUI/Art/currency/currency_telvar.dds|t",
	SI_AWEMOD_INVENTORY_WRITVOUCHER_LABEL="Writs:|r <<1>> |t16:16:EsoUI/Art/currency/currency_writvoucher.dds|t",

	--module-mails
	SI_AWEMOD_MAILS="Mails",
	SI_AWEMOD_MAILS_HINT="Get a notification if you have unread mails.",
	SI_AWEMOD_MAILS_LABEL="Unread Mails",

	--module-mount
	SI_AWEMOD_MOUNT="Mount Training",
	SI_AWEMOD_MOUNT_HINT="Get a countdown when your mount's training is nearly complete, or a notification if the mount can be trained.",
	SI_AWEMOD_MOUNT_TIMER_LABEL="Train mount in",
	SI_AWEMOD_MOUNT_READY_LABEL="Mount can be trained",
	SI_AWEMOD_MOUNT_TIMER="Start training timer (minutes)",
	SI_AWEMOD_MOUNT_TIMER_HINT="Will show the countdown timer if mount can be trained within the number of minutes below.",

	--module-repairkits
	SI_AWEMOD_REPAIRKITS="Repair Kits",
	SI_AWEMOD_REPAIRKITS_HINT="See how many repair kits you have in your inventory.",
	SI_AWEMOD_REPAIRKITS_LABEL="Repair Kits|r: |t16:16:EsoUI/Art/icons/store_repairkit_002.dds|t <<1[None/1 kit/$d kits]>>",

	--module-shadowysupplier
	SI_AWEMOD_SHADOWYSUPPLIER="Shadowy Supplier (Passive Skill)",
	SI_AWEMOD_SHADOWYSUPPLIER_HINT="The shadowy supplier is a passive skill from the dark brotherhoods skill line. Get an information and timer about availability of Dark Brotherhood`s Shadowy Supplier (passive ability).",
	SI_AWEMOD_SHADOWYSUPPLIER_TIMER="Supplier cooldown timer (minutes)",
	SI_AWEMOD_SHADOWYSUPPLIER_TIMER_HINT="Will show the cooldown timer if Shadowy Supplier is available within the number of minutes below.",
    SI_AWEMOD_SHADOWYSUPPLIER_AVAILABLE_LABEL="Available",

	--module-skills
	SI_AWEMOD_SKILLS="Attribute- & Skillpoints",
	SI_AWEMOD_SKILLS_HINT="Get a notification if you have unspent attribute- or skillpoints.",
	SI_AWEMOD_SKILLS_ATTRIBUTES_LABEL="Attributes",
	SI_AWEMOD_SKILLS_CHAMPIONPOINTS_LABEL="CP",
	SI_AWEMOD_SKILLS_SKILLS_LABEL="Skills",

	--module-skyshards
	SI_AWEMOD_SKYSHARDS="Skyshards",
	SI_AWEMOD_SKYSHARDS_HINT="Get a notification about how many shards you have to collect to get a new skillpoint.",
	SI_AWEMOD_SKYSHARDS_REMAINING_LABEL="Shards missing",
	SI_AWEMOD_SKYSHARDS_REMAINING="Shards missing",
	SI_AWEMOD_SKYSHARDS_REMAINING_HINT="Display a notification when you miss less shards.",

	--module-soulgems
	SI_AWEMOD_SOULGEMS="Soul Gems",
	SI_AWEMOD_SOULGEMS_HINT="See how many empty or filled soul gems you have for your revival.",
	SI_AWEMOD_SOULGEMS_LABEL="Soul gems|r: <<1>> |t16:16:EsoUI/Art/icons/soulgem_006_filled.dds|t <<2[/(1 empty)/($d empty)]>>",

	--module-weaponcharge
	SI_AWEMOD_WEAPONCHARGE="Charge of equipped Weapons",
	SI_AWEMOD_WEAPONCHARGE_HINT="Get a notification before the charge of your equipped weapons goes to low.",
	SI_AWEMOD_WEAPONCHARGE_INFO="Weapon Charge (|cFFFF60info|r) %",
	SI_AWEMOD_WEAPONCHARGE_INFO_HINT="If the charge of your equipped weapon is less or equal to this value, you will see a notification.",
	SI_AWEMOD_WEAPONCHARGE_WARNING="Weapon Charge (|cFF6060warning|r) %",
	SI_AWEMOD_WEAPONCHARGE_WARNING_HINT="If the charge of your equipped weapon is less or equal to this value, you will see a warning.",
	SI_AWEMOD_WEAPONCHARGE_SET_LABEL="Set",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
