local L = _G['Stacked'].L

-- L['Stack'] = 'Stack' -- keybind

-- --------------------------------------------------------
-- settings
-- L['General Options'] = 'General Options'
L['merge target'] = 'Merge stacks'
L['merge target description'] = 'When multiple locations contain the same item in incomplete stacks, those stacks may be merged together into one location.'
L['merge guildbank target'] = 'Merge stacks (guild bank)'
L['merge guildbank target description'] = L['merge target description']
L['none'] = 'None'
L['backpack'] = GetString(SI_INVENTORY_MODE_INVENTORY)
L['bank'] = GetString(SI_GUILDHISTORYCATEGORY2)
L['guildbank'] = 'Guild Bank'

L['tradeSucceeded'] = GetString(SI_TRADE_COMPLETE):gsub('%.$', '')
L['attachmentsRetrieved'] = 'Mail attachments retrieved'
L['bank opened'] = 'Bank opened'
L['guildbank opened'] = 'Guild Bank opened'

L['ignore items'] = 'Ignore items'
L['ignore items description'] = 'Items that are on your ignore list will never be touched by Stacked.'
L['ignore items info'] = 'Don\'t know which item an id represents? Use "/stacked list" to get clickable links of all excluded items.'
L['ignore items help'] = 'Add a new line with either the item ID or link (via menu option "|cFFFFFF'..GetString(SI_ITEM_ACTION_LINK_TO_CHAT)..'|r" and copy the link into this text box).'

L['ignore item'] = 'Ignore when stacking'
L['unignore item'] = 'Include when stacking'

-- L['Messages'] = 'Messages'
L['item moved'] = 'Item was moved'
L['item moved description'] = 'Enable chat output when an item has been moved.'
L['slots'] = 'Slot numbers'
L['slots description'] = 'Enable to add which slot was affected to movement messages.'
L['guild bank details'] = 'Guild Bank stacking details'
L['guild bank details description'] = 'Enable to show messages when items are moved for guild bank stacking.'

-- L['Automatic Stacking'] = 'Automatic Stacking'
L['automatic events'] = 'Automatically stack when any of these events happen:'
L['automatic containers'] = 'Allow automatic stacking only for these containers:'

-- --------------------------------------------------------
-- slash commands
L['/help'] = '<<1>> command help: <<2>>'
L['/stack'] = '"|cFFFFFF/stack|r" to start stacking manually'
L['/stackgb'] = '"|cFFFFFF/stackgb|r" to start stacking the guild bank manually'
L['/stacked list'] = '"|cFFFFFF/stacked list|r" to list all ignored items'
L['/stacked exclude'] = '"|cFFFFFF/stacked exclude|r |cFF80401234|r" to ignore the item with id 1234'
	.. '\n"|cFFFFFF/stacked exclude|r |cFF8040[Item Link]|r" to ignore the linked item'
L['/stacked include'] = '"|cFFFFFF/stacked include|r |cFF80401234|r" to un-ignore the item with id 1234'
	.. '\n"|cFFFFFF/stacked include|r |cFF8040[Item Link]|r" to un-ignore the linked item'

-- --------------------------------------------------------
-- container stacking
L['bag slot number'] = '<<1>> (Slot <<2>>)'
L['stacked item'] = 'Stacked <<2*1>> (<<and(4,5)>>) in <<C:3>>.'
L['failed stacking item'] = 'Stacking <<2*1>> in <<3>> failed.'
L['moved item'] = 'Moved <<2*1>> from <<3>> to <<4>>'
L['failed moving item'] = 'Failed to move <<2*1>> from <<3>> to <<4>>'
L['stacking completed'] = 'Stacking completed.'

-- --------------------------------------------------------
-- guild bank stacking
L['failed moving guildbank item'] = 'Moving item between backpack and guild bank failed.'
L['stacking guildbank item'] = 'Stacking <<2*1>>, currently using <<03*slot||slots>>.'
L['failed stacking guildbank item'] = 'Stacking <<1>> failed.'
L['withdraw item'] = 'Withdraw <<2*1>>'
L['deposit item'] = 'Deposit <<2*1>>'
L['guild bank state 0'] = 'Stacking guild bank completed. Freed <<01*slot||slots>>.'
L['guild bank state 2'] = 'Moving items from <<1>> to <<2>>.'
L['guild bank state 3'] = 'Started stacking of guild bank.'

-- error messages
L['not enough members'] = 'This guild does not have enough members to use the guild bank.'
L['insufficient permissions'] = 'You need to have both withdrawal and deposit permissions to restack the guild bank'
L['inventory full'] = 'You need at least 2 empty bag slots to restack the guild bank.'
L['not available'] = 'Guild bank data is not yet available.'
