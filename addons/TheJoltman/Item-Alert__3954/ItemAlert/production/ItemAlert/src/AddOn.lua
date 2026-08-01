--------------------------------------------------------------------------------------------------------------------------------------------------------------------
ItemAlert = {}

ItemAlert.AddName = "ItemAlert"
ItemAlert.FancyName = "|c00e0ffI|r|c00befft|r|c009cffe|r|c007bffm|r|c00e0ff A|r|c00beffl|r|c009cffe|r|c007bffr|r|c007bfft"
ItemAlert.FancyNameBracketed = "["..ItemAlert.FancyName.."]"
ItemAlert.AddId = "ItemAlert"
ItemAlert.Version = 10102
ItemAlert.Author = "|c85e085@TheJoltman"
ItemAlert.PanelTitle = "ItemAlert"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
if LibDebugLogger then

	ItemAlert.Logger = LibDebugLogger("ItemAlert")
	ItemAlert.Logger:Debug("Initializing "..ItemAlert.AddName.."...")

else

	d("Error loading LibDebugLogger!")

end

if LibChatMessage then

	ItemAlertChat = LibChatMessage(ItemAlert.FancyName, ItemAlert.AddId)

else

	d("Error loading LibChatMessage!")

end

if LibAddonMenu2 then

	ItemAlertLam2 = LibAddonMenu2

else

	d("Error loading LibAddonMenu2!")

end

if LibCustomMenu then

	ItemAlertLcm = LibCustomMenu

else

	d("Error loading LibCustomMenu!")

end

if LibGPS3 then

	ItemAlertGps = LibGPS3

else

	d("Error loading LibGPS3!")

end

if LibFonts then

	ItemAlertLf = LibFonts

else

	d("Error loading LibFonts!")

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
ItemAlert.AccountData = {}
ItemAlert.CharacterData = {}
ItemAlert.Window = GetWindowManager()
ItemAlert.InfoText = ItemAlert.Window:CreateTopLevelWindow("ItemAlertDisplayBar")
ItemAlert.SortOrderEntries = {}
ItemAlert.Sounds = {}
ItemAlert.LootedNodePositions = {}
ItemAlert.LastWritComplete = os.clock()
ItemAlert.LastLootTime = os.clock()
ItemAlert.StartTime = os.clock()
ItemAlert.TrackedNodeNames = {
	"ancestor silk",
	"ash",
	"beech",
	"birch",
	"blessed thistle",
	"blue entoloma",
	"bugloss",
	"calcinium ore",
	"columbine",
	"copper seam",
	"corn flower",
	"cotton",
	"crimson nirnroot",
	"dragonthorn",
	"dwarven ore",
	"ebonthread",
	"ebony ore",
	"electrum seam",
	"emetic russula",
	"flax",
	"galatite ore",
	"herbalist's satchel",
	"hickory",
	"high iron ore",
	"imp stool",
	"iron ore",
	"ironweed",
	"jute",
	"kreshweed",
	"lady's smock",
	"luminous russula",
	"mahogany",
	"maple",
	"mountain flower",
	"namira's rot",
	"nightshade",
	"nightwood",
	"nirnroot",
	"oak",
	"orichalcum ore",
	"pewter seam",
	"platinum seam",
	"potable liquids",
	"pure water",
	"quicksilver ore",
	"rubedite ore",
	"ruby ash wood",
	"runestone",
	"scrap wood",
	"silver seam",
	"silverweed",
	"spidersilk",
	"stinkhorn",
	"torn cloth",
	"violet coprinus",
	"void bloom",
	"voidstone ore",
	"water hyacinth",
	"water skin",
	"white cap",
	"wormwood",
	"yew",
}