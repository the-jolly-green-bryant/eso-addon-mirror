--[[
-------------------------------------------------------------------------------
-- Dyer, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local ADDON_NAME = "Dyer"

local dyesList = ZO_SortFilterList:Subclass()
local dyesManager = {}
local dyeStampsShown
local rightKeybindStripDescriptor
local dyesAvailableForRandomness

local db
local defaults = {
	s = {}, -- Saved Sets
	n = {}, -- No Random Dyes
	a = {
		[RESTYLE_MODE_EQUIPMENT] = {},
		[RESTYLE_MODE_COLLECTIBLE] = {},
	}, -- No Random Slots
}

local FAVORITE_MODE_DYESLOT = 1
local FAVORITE_MODE_SAVEDSET = 2
local FAVORITE_MODE_WARMOR = 3
local FAVORITE_MODE_WCOLLECTIBLE = 4

local knownDyeStamps = {
	[83519] = true,
	[83520] = true,
	[83521] = true,
	[83522] = true,
	[83523] = true,
	[83524] = true,
	[83525] = true,
	[83526] = true,
	[83527] = true,
	[83528] = true,
	[83529] = true,
	[83530] = true,
	[83531] = true,
	[83532] = true,
	[83533] = true,
	[83534] = true,
	[83535] = true,
	[83536] = true,
	[83537] = true,
	[83538] = true,
	[83539] = true,
	[83540] = true,
	[83541] = true,
	[83542] = true,
	[83543] = true,
	[83544] = true,
	[83545] = true,
	[83546] = true,
	[83547] = true,
	[83548] = true,
	[83549] = true,
	[83550] = true,
	[83551] = true,
	[83552] = true,
	[83553] = true,
	[83554] = true,
	[83555] = true,
	[83556] = true,
	[83557] = true,
	[83558] = true,
	[83559] = true,
	[83560] = true,
	[83561] = true,
	[83562] = true,
	[83563] = true,
	[83564] = true,
	[83565] = true,
	[83566] = true,
	[83567] = true,
	[83568] = true,
	[83569] = true,
	[83570] = true,
	[83571] = true,
	[83572] = true,
	[83573] = true,
	[83574] = true,
	[83575] = true,
	[83576] = true,
	[83577] = true,
	[83578] = true,
	[83579] = true,
	[83580] = true,
	[83581] = true,
	[83582] = true,
	[83583] = true,
	[83584] = true,
	[83585] = true,
	[83586] = true,
	[83587] = true,
	[83588] = true,
	[83589] = true,
	[83590] = true,
	[83591] = true,
	[83592] = true,
	[83593] = true,
	[83594] = true,
	[83595] = true,
	[83596] = true,
	[83597] = true,
	[83598] = true,
	[83599] = true,
	[83600] = true,
	[83601] = true,
	[83602] = true,
	[83603] = true,
	[83604] = true,
	[83605] = true,
	[83606] = true,
	[83607] = true,
	[83608] = true,
	[83609] = true,
	[83610] = true,
	[83611] = true,
	[83612] = true,
	[83613] = true,
	[83614] = true,
	[83615] = true,
	[83616] = true,
	[83617] = true,
	[83618] = true,
	[83619] = true,
	[83620] = true,
	[83621] = true,
	[83622] = true,
	[83623] = true,
	[83624] = true,
	[83625] = true,
	[83626] = true,
	[83627] = true,
	[83628] = true,
	[83629] = true,
	[83630] = true,
	[83631] = true,
	[83632] = true,
	[83633] = true,
	[83634] = true,
	[83635] = true,
	[83636] = true,
	[83637] = true,
	[83638] = true,
	[83639] = true,
	[83640] = true,
	[83641] = true,
	[83642] = true,
	[83643] = true,
	[83644] = true,
	[83645] = true,
	[83646] = true,
	[83647] = true,
	[83648] = true,
	[83649] = true,
	[83650] = true,
	[83651] = true,
	[83652] = true,
	[83653] = true,
	[83654] = true,
	[83655] = true,
	[83656] = true,
	[83657] = true,
	[83658] = true,
	[83659] = true,
	[83660] = true,
	[83661] = true,
	[83662] = true,
	[83663] = true,
	[83664] = true,
	[83665] = true,
	[83666] = true,
	[83667] = true,
	[83668] = true,
	[83669] = true,
	[83670] = true,
	[83671] = true,
	[83672] = true,
	[83673] = true,
	[83674] = true,
	[83675] = true,
	[83676] = true,
	[83677] = true,
	[83678] = true,
	[83679] = true,
	[83680] = true,
	[83681] = true,
	[83682] = true,
	[83683] = true,
	[83684] = true,
	[83685] = true,
	[83686] = true,
	[83687] = true,
	[83688] = true,
	[83689] = true,
	[83690] = true,
	[83691] = true,
	[83692] = true,
	[83693] = true,
	[83694] = true,
	[83695] = true,
	[83696] = true,
	[83697] = true,
	[83698] = true,
	[83699] = true,
	[83700] = true,
	[83701] = true,
	[83702] = true,
	[83703] = true,
	[83704] = true,
	[83705] = true,
	[83706] = true,
	[83707] = true,
	[83708] = true,
	[83709] = true,
	[83710] = true,
	[83711] = true,
	[83712] = true,
	[83713] = true,
	[83714] = true,
	[83715] = true,
	[83716] = true,
	[83717] = true,
	[83718] = true,
	[83719] = true,
	[83720] = true,
	[83721] = true,
	[83722] = true,
	[83723] = true,
	[83724] = true,
	[83725] = true,
	[83726] = true,
	[83727] = true,
	[83728] = true,
	[83729] = true,
	[83730] = true,
	[83731] = true,
	[83732] = true,
	[83733] = true,
	[83734] = true,
	[83735] = true,
	[83736] = true,
	[83737] = true,
	[83738] = true,
	[83739] = true,
	[83740] = true,
	[83741] = true,
	[83742] = true,
	[83743] = true,
	[83744] = true,
	[83745] = true,
	[83746] = true,
	[83747] = true,
	[83748] = true,
	[83749] = true,
	[83750] = true,
	[83751] = true,
	[83752] = true,
	[83753] = true,
	[83754] = true,
	[83755] = true,
	[83756] = true,
	[83757] = true,
	[83758] = true,
	[83759] = true,
	[83760] = true,
	[83761] = true,
	[83762] = true,
	[83763] = true,
	[83764] = true,
	[83765] = true,
	[83766] = true,
	[83767] = true,
	[83768] = true,
	[83769] = true,
	[83770] = true,
	[83771] = true,
	[83772] = true,
	[83773] = true,
	[83774] = true,
	[83775] = true,
	[83776] = true,
	[83777] = true,
	[83778] = true,
	[83779] = true,
	[83780] = true,
	[83781] = true,
	[83782] = true,
	[83783] = true,
	[83784] = true,
	[83785] = true,
	[83786] = true,
	[83787] = true,
	[83788] = true,
	[83789] = true,
	[83790] = true,
	[83791] = true,
	[83792] = true,
	[83793] = true,
	[83794] = true,
	[83795] = true,
	[83796] = true,
	[83797] = true,
	[83798] = true,
	[83799] = true,
	[83800] = true,
	[83801] = true,
	[83802] = true,
	[83803] = true,
	[83804] = true,
	[83805] = true,
	[83806] = true,
	[83807] = true,
	[83808] = true,
	[83809] = true,
	[83810] = true,
	[83811] = true,
	[83812] = true,
	[83813] = true,
	[83814] = true,
	[83815] = true,
	[83816] = true,
	[83817] = true,
	[83818] = true,
	[83819] = true,
	[83820] = true,
	[83821] = true,
	[83822] = true,
	[83823] = true,
	[83824] = true,
	[83825] = true,
	[83826] = true,
	[83827] = true,
	[83828] = true,
	[83829] = true,
	[83830] = true,
	[83831] = true,
	[83832] = true,
	[83833] = true,
	[83834] = true,
	[83835] = true,
	[83836] = true,
	[83837] = true,
	[83838] = true,
	[83839] = true,
	[83840] = true,
	[83841] = true,
	[83842] = true,
	[83843] = true,
	[83844] = true,
	[83845] = true,
	[83846] = true,
	[83847] = true,
	[83848] = true,
	[83849] = true,
	[83850] = true,
	[83851] = true,
	[83852] = true,
	[83853] = true,
	[83854] = true,
	[83855] = true,
	[83856] = true,
	[83857] = true,
	[83858] = true,
	[83859] = true,
	[83860] = true,
	[83861] = true,
	[83862] = true,
	[83863] = true,
	[83864] = true,
	[83865] = true,
	[83866] = true,
	[83867] = true,
	[83868] = true,
	[83869] = true,
	[83870] = true,
	[83871] = true,
	[83872] = true,
	[83873] = true,
	[83874] = true,
	[83875] = true,
	[83876] = true,
	[83877] = true,
	[83878] = true,
	[83879] = true,
	[83880] = true,
	[83881] = true,
	[83882] = true,
	[83883] = true,
	[83884] = true,
	[83885] = true,
	[83886] = true,
	[83887] = true,
	[83888] = true,
	[83889] = true,
	[83890] = true,
	[83891] = true,
	[83892] = true,
	[83893] = true,
	[83894] = true,
	[83895] = true,
	[83896] = true,
	[83897] = true,
	[83898] = true,
	[83899] = true,
	[83900] = true,
	[83901] = true,
	[83902] = true,
	[83903] = true,
	[83904] = true,
	[83905] = true,
	[83906] = true,
	[83907] = true,
	[83908] = true,
	[83909] = true,
	[83910] = true,
	[83911] = true,
	[83912] = true,
	[83913] = true,
	[83914] = true,
	[83915] = true,
	[83916] = true,
	[83917] = true,
	[83918] = true,
	[83919] = true,
	[83920] = true,
	[83921] = true,
	[83922] = true,
	[83923] = true,
	[83924] = true,
	[83925] = true,
	[83926] = true,
	[83927] = true,
	[83928] = true,
	[83929] = true,
	[83930] = true,
	[83931] = true,
	[83932] = true,
	[83933] = true,
	[83934] = true,
	[83935] = true,
	[83936] = true,
	[83937] = true,
	[83938] = true,
	[83939] = true,
	[83940] = true,
	[83941] = true,
	[83942] = true,
	[83943] = true,
	[83944] = true,
	[83945] = true,
	[83946] = true,
	[83947] = true,
	[83948] = true,
	[83949] = true,
	[83950] = true,
	[83951] = true,
	[83952] = true,
	[83953] = true,
	[83954] = true,
	[83955] = true,
	[83956] = true,
	[83957] = true,
	[83958] = true,
	[83959] = true,
	[83960] = true,
	[83961] = true,
	[83962] = true,
	[83963] = true,
	[83964] = true,
	[83965] = true,
	[83966] = true,
	[83967] = true,
	[83968] = true,
	[83969] = true,
	[83970] = true,
	[83971] = true,
	[83972] = true,
	[83973] = true,
	[83974] = true,
	[83975] = true,
	[83976] = true,
	[83977] = true,
	[83978] = true,
	[83979] = true,
	[83980] = true,
	[83981] = true,
	[83982] = true,
	[83983] = true,
	[83984] = true,
	[83985] = true,
	[83986] = true,
	[83987] = true,
	[83988] = true,
	[83989] = true,
	[83990] = true,
	[83991] = true,
	[83992] = true,
	[83993] = true,
	[83994] = true,
	[83995] = true,
	[83996] = true,
	[83997] = true,
	[83998] = true,
	[83999] = true,
	[84000] = true,
	[84001] = true,
	[84002] = true,
	[84003] = true,
	[84004] = true,
	[84005] = true,
	[84006] = true,
	[84007] = true,
	[84008] = true,
	[84009] = true,
	[84010] = true,
	[84011] = true,
	[84012] = true,
	[84013] = true,
	[84014] = true,
	[84015] = true,
	[84016] = true,
	[84017] = true,
	[84018] = true,
	[84019] = true,
	[84020] = true,
	[84021] = true,
	[84022] = true,
	[84023] = true,
	[84024] = true,
	[84025] = true,
	[84026] = true,
	[84027] = true,
	[84028] = true,
	[84029] = true,
	[84030] = true,
	[84031] = true,
	[84032] = true,
	[84033] = true,
	[84034] = true,
	[84035] = true,
	[84036] = true,
	[84037] = true,
	[84038] = true,
	[84039] = true,
	[84040] = true,
	[84041] = true,
	[84042] = true,
	[84043] = true,
	[84044] = true,
	[84045] = true,
	[84046] = true,
	[84047] = true,
	[84048] = true,
	[84049] = true,
	[84050] = true,
	[84051] = true,
	[84052] = true,
	[84053] = true,
	[84054] = true,
	[84055] = true,
	[84056] = true,
	[84057] = true,
	[84058] = true,
	[84059] = true,
	[84060] = true,
	[84061] = true,
	[84062] = true,
	[84063] = true,
	[84064] = true,
	[84065] = true,
	[84066] = true,
	[84067] = true,
	[84068] = true,
	[84069] = true,
	[84070] = true,
	[84071] = true,
	[84072] = true,
	[84073] = true,
	[84074] = true,
	[84075] = true,
	[84076] = true,
	[84077] = true,
	[84078] = true,
	[84079] = true,
	[84080] = true,
	[84081] = true,
	[84082] = true,
	[84083] = true,
	[84084] = true,
	[84085] = true,
	[84086] = true,
	[84087] = true,
	[84088] = true,
	[84089] = true,
	[84090] = true,
	[84091] = true,
	[84092] = true,
	[84093] = true,
	[84094] = true,
	[84095] = true,
	[84096] = true,
	[84097] = true,
	[84098] = true,
	[84099] = true,
	[84100] = true,
	[84101] = true,
	[84102] = true,
	[84103] = true,
	[84104] = true,
	[84105] = true,
	[84106] = true,
	[84107] = true,
	[84108] = true,
	[84109] = true,
	[84110] = true,
	[84111] = true,
	[84112] = true,
	[84113] = true,
	[84114] = true,
	[84115] = true,
	[84116] = true,
	[84117] = true,
	[84118] = true,
	[84119] = true,
	[84120] = true,
	[84121] = true,
	[84122] = true,
	[84123] = true,
	[84124] = true,
	[84125] = true,
	[84126] = true,
	[84127] = true,
	[84128] = true,
	[84129] = true,
	[84130] = true,
	[84131] = true,
	[84132] = true,
	[84133] = true,
	[84134] = true,
	[84135] = true,
	[84136] = true,
	[84137] = true,
	[84138] = true,
	[84139] = true,
	[84140] = true,
	[84141] = true,
	[84142] = true,
	[84143] = true,
	[84144] = true,
	[84145] = true,
	[84146] = true,
	[84147] = true,
	[84148] = true,
	[84149] = true,
	[84150] = true,
	[84151] = true,
	[84152] = true,
	[84153] = true,
	[84154] = true,
	[84155] = true,
	[84156] = true,
	[84157] = true,
	[84158] = true,
	[84159] = true,
	[84160] = true,
	[84161] = true,
	[84162] = true,
	[84163] = true,
	[84164] = true,
	[84165] = true,
	[84166] = true,
	[84167] = true,
	[84168] = true,
	[84169] = true,
	[84170] = true,
	[84171] = true,
	[84172] = true,
	[84173] = true,
	[84174] = true,
	[84175] = true,
	[84176] = true,
	[84177] = true,
	[84178] = true,
	[84179] = true,
	[84180] = true,
	[84181] = true,
	[84182] = true,
	[84183] = true,
	[84184] = true,
	[84185] = true,
	[84186] = true,
	[84187] = true,
	[84188] = true,
	[84189] = true,
	[84190] = true,
	[84191] = true,
	[84192] = true,
	[84193] = true,
	[84194] = true,
	[84195] = true,
	[84196] = true,
	[84197] = true,
	[84198] = true,
	[84199] = true,
	[84200] = true,
	[84201] = true,
	[84202] = true,
	[84203] = true,
	[84204] = true,
	[84205] = true,
	[84206] = true,
	[84207] = true,
	[84208] = true,
	[84209] = true,
	[84210] = true,
	[84211] = true,
	[84212] = true,
	[84213] = true,
	[84214] = true,
	[84215] = true,
	[84216] = true,
	[84217] = true,
	[84218] = true,
	[84219] = true,
	[84220] = true,
	[84221] = true,
	[84222] = true,
	[84223] = true,
	[84224] = true,
	[84225] = true,
	[84226] = true,
	[84227] = true,
	[84228] = true,
	[84229] = true,
	[84230] = true,
	[84231] = true,
	[84232] = true,
	[84233] = true,
	[84234] = true,
	[84235] = true,
	[84236] = true,
	[84237] = true,
	[84238] = true,
	[84239] = true,
	[84240] = true,
	[84241] = true,
	[84242] = true,
	[84243] = true,
	[84244] = true,
	[84245] = true,
	[84246] = true,
	[84247] = true,
	[84248] = true,
	[84249] = true,
	[84250] = true,
	[84251] = true,
	[84252] = true,
	[84253] = true,
	[84254] = true,
	[84255] = true,
	[84256] = true,
	[84257] = true,
	[84258] = true,
	[84259] = true,
	[84260] = true,
	[84261] = true,
	[84262] = true,
	[84263] = true,
	[84264] = true,
	[84265] = true,
	[84266] = true,
	[84267] = true,
	[84268] = true,
	[84269] = true,
	[84270] = true,
	[84271] = true,
	[84272] = true,
	[84273] = true,
	[84274] = true,
	[84275] = true,
	[84276] = true,
	[84277] = true,
	[84278] = true,
	[84279] = true,
	[84280] = true,
	[84281] = true,
	[84282] = true,
	[84283] = true,
	[84284] = true,
	[84285] = true,
	[84286] = true,
	[84287] = true,
	[84288] = true,
	[84289] = true,
	[84290] = true,
	[84291] = true,
	[84292] = true,
	[84293] = true,
	[84294] = true,
	[84295] = true,
	[84296] = true,
	[84297] = true,
	[84298] = true,
	[84299] = true,
	[84300] = true,
	[84301] = true,
	[84302] = true,
	[84303] = true,
	[84304] = true,
	[84305] = true,
	[84306] = true,
	[84307] = true,
	[84308] = true,
	[84309] = true,
	[84310] = true,
	[84311] = true,
	[84312] = true,
	[84313] = true,
	[84314] = true,
	[84315] = true,
	[84316] = true,
	[84317] = true,
	[84318] = true,
	[84319] = true,
	[84320] = true,
	[84321] = true,
	[84322] = true,
	[84323] = true,
	[84324] = true,
	[84325] = true,
	[84326] = true,
	[84327] = true,
	[84328] = true,
	[84329] = true,
	[84330] = true,
	[84331] = true,
	[84332] = true,
	[84333] = true,
	[84334] = true,
	[84335] = true,
	[84336] = true,
	[84337] = true,
	[84338] = true,
	[84339] = true,
	[84340] = true,
	[84341] = true,
	[84342] = true,
	[84343] = true,
	[84344] = true,
	[84345] = true,
	[84346] = true,
	[84347] = true,
	[84348] = true,
	[84349] = true,
	[84350] = true,
	[84351] = true,
	[84352] = true,
	[84353] = true,
	[84354] = true,
	[84355] = true,
	[84356] = true,
	[84357] = true,
	[84358] = true,
	[84359] = true,
	[84360] = true,
	[84361] = true,
	[84362] = true,
	[84363] = true,
	[84364] = true,
	[84365] = true,
	[84366] = true,
	[84367] = true,
	[84368] = true,
	[84369] = true,
	[84370] = true,
	[84371] = true,
	[84372] = true,
	[84373] = true,
	[84374] = true,
	[84375] = true,
	[84376] = true,
	[84377] = true,
	[84378] = true,
	[84379] = true,
	[84380] = true,
	[84381] = true,
	[84382] = true,
	[84383] = true,
	[84384] = true,
	[84385] = true,
	[84386] = true,
	[84387] = true,
	[84388] = true,
	[84389] = true,
	[84390] = true,
	[84391] = true,
	[84392] = true,
	[84393] = true,
	[84394] = true,
	[84395] = true,
	[84396] = true,
	[84397] = true,
	[84398] = true,
	[84399] = true,
	[84400] = true,
	[84401] = true,
	[84402] = true,
	[84403] = true,
	[84404] = true,
	[84405] = true,
	[84406] = true,
	[84407] = true,
	[84408] = true,
	[84409] = true,
	[84410] = true,
	[84411] = true,
	[84412] = true,
	[84413] = true,
	[84414] = true,
	[84415] = true,
	[84416] = true,
	[84417] = true,
	[84418] = true,
	[84419] = true,
	[84420] = true,
	[84421] = true,
	[84422] = true,
	[84423] = true,
	[84424] = true,
	[84425] = true,
	[84426] = true,
	[84427] = true,
	[84428] = true,
	[84429] = true,
	[84430] = true,
	[84431] = true,
	[84432] = true,
	[84433] = true,
	[84434] = true,
	[84435] = true,
	[84436] = true,
	[84437] = true,
	[84438] = true,
	[84439] = true,
	[84440] = true,
	[84441] = true,
	[84442] = true,
	[84443] = true,
	[84444] = true,
	[84445] = true,
	[84446] = true,
	[84447] = true,
	[84448] = true,
	[84449] = true,
	[84450] = true,
	[84451] = true,
	[84452] = true,
	[84453] = true,
	[84454] = true,
	[84455] = true,
	[84456] = true,
	[84457] = true,
	[84458] = true,
	[84459] = true,
	[84460] = true,
	[84461] = true,
	[84462] = true,
	[84463] = true,
	[84464] = true,
	[84465] = true,
	[84466] = true,
	[84467] = true,
	[84468] = true,
	[84469] = true,
	[84470] = true,
	[84471] = true,
	[84472] = true,
	[84473] = true,
	[84474] = true,
	[84475] = true,
	[84476] = true,
	[84477] = true,
	[84478] = true,
	[84479] = true,
	[84480] = true,
	[84481] = true,
	[84482] = true,
	[84483] = true,
	[84484] = true,
	[84485] = true,
	[84486] = true,
	[84487] = true,
	[84488] = true,
	[84489] = true,
	[84490] = true,
	[84491] = true,
	[84492] = true,
	[84493] = true,
	[84494] = true,
	[84495] = true,
	[84496] = true,
	[84497] = true,
	[84498] = true,
	[84499] = true,
	[84500] = true,
	[84501] = true,
	[84502] = true,
	[84503] = true,
	[84504] = true,
	[84505] = true,
	[84506] = true,
	[84507] = true,
	[84508] = true,
	[84509] = true,
	[84510] = true,
	[84511] = true,
	[84512] = true,
	[84513] = true,
	[84514] = true,
	[84515] = true,
	[84516] = true,
	[84517] = true,
	[84518] = true,
	[115713] = true,
	[115714] = true,
	[115715] = true,
	[115716] = true,
	[115717] = true,
	[115718] = true,
	[115719] = true,
	[115720] = true,
	[119595] = true,
	[119596] = true,
	[119597] = true,
	[119598] = true,
	[119599] = true,
	[119600] = true,
	[119601] = true,
	[119602] = true,
	[119603] = true,
	[119604] = true,
	[119605] = true,
	[119606] = true,
	[119607] = true,
	[119608] = true,
	[120428] = true,
	[120429] = true,
	[120430] = true,
	[120431] = true,
	[120432] = true,
	[120433] = true,
	[120434] = true,
	[120435] = true,
}

local function IsDyeIdKnown(dyeId)
	return select(2, GetDyeInfoById(dyeId))
end

local function GetDyeStampItemLink(itemId)
	return ("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
end

local function GetDyeStampInfo(itemId)
	
	local itemLink = GetDyeStampItemLink(itemId)
	local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
	local primaryDyeId, secondaryDyeId, accentDyeId = GetItemLinkDyeIds(itemLink)
	
	return name, primaryDyeId, secondaryDyeId, accentDyeId
	
end

local function GetDyeStampQualityColor(itemId)
	local itemLink = GetDyeStampItemLink(itemId)
	return GetItemQualityColor(GetItemLinkQuality(itemLink))
end

local function BuildDyesAvailableForRandomness()
	
	dyesAvailableForRandomness = {}
	
	for dyeIndex = 1, GetNumDyes() do
		local _, known, _, _, _, _, _, _, _, dyeId = GetDyeInfo(dyeIndex)
		if known and not db.n[dyeId] then
			table.insert(dyesAvailableForRandomness, dyeId)
		end
	end
	
end

local function OnDyeIdMouseUp(swatch, button, upInside)
	if upInside then
		if button == MOUSE_BUTTON_INDEX_LEFT then
			if not swatch.locked then
				ZO_DYEING_KEYBOARD:SwitchToDyeingWithDyeId(swatch.dyeId)
			end
		elseif button == MOUSE_BUTTON_INDEX_RIGHT then
			local achievementName = GetAchievementInfo(swatch.achievementId)
			if achievementName ~= "" then
				ClearMenu()
				AddMenuItem(GetString(SI_DYEING_SWATCH_VIEW_ACHIEVEMENT), function() ZO_DYEING_KEYBOARD:AttemptExit(swatch.achievementId) end)
				if db.n[swatch.dyeId] then
					AddMenuItem(GetString(DYER_ADD_FROM_RANDOM), function()
						db.n[swatch.dyeId] = nil
						swatch:SetColor(ZO_DYEING_FRAME_INDEX, 1, 1, 1, 1)
						BuildDyesAvailableForRandomness()
					end)
				else
					AddMenuItem(GetString(DYER_REMOVE_FROM_RANDOM), function()
						db.n[swatch.dyeId] = true
						swatch:SetColor(ZO_DYEING_FRAME_INDEX, 1, 0, 0, 1)
					end)
				end
				ShowMenu(swatch)
				BuildDyesAvailableForRandomness()
			end
		end
	end
end

function ZO_DYEING_KEYBOARD:LayoutDyes()

	local SWATCHES_LAYOUT_OPTIONS = 
	{
		padding = 6,
		leftMargin = 27,
		topMargin = 18,
		rightMargin = 0,
		bottomMargin = 0,
		selectionScale = ZO_DYEING_SWATCH_SELECTION_SCALE,
	}
	
	ZO_DYEING_KEYBOARD.dyeLayoutDirty = false
	
	local _, _, unlockedDyeIds, dyeIdToSwatch = ZO_Dyeing_LayoutSwatches(ZO_DYEING_KEYBOARD.savedVars.showLocked, ZO_DYEING_KEYBOARD.savedVars.sortStyle, ZO_DYEING_KEYBOARD.swatchPool, ZO_DYEING_KEYBOARD.headerPool, SWATCHES_LAYOUT_OPTIONS, ZO_DYEING_KEYBOARD.pane, true)
	
	ZO_DYEING_KEYBOARD.unlockedDyeIds = unlockedDyeIds
	ZO_DYEING_KEYBOARD.dyeIdToSwatch = dyeIdToSwatch
	
	for dyeId, swatch in pairs(ZO_DYEING_KEYBOARD.dyeIdToSwatch) do
		swatch:SetHandler("OnMouseUp", OnDyeIdMouseUp)
		if db.n[dyeId] then
			swatch:SetColor(ZO_DYEING_FRAME_INDEX, 1, 0, 0, 1)
		else
			swatch:SetColor(ZO_DYEING_FRAME_INDEX, 1, 1, 1, 1)
		end
	end
	
	local anyDyesToSwatch = next(dyeIdToSwatch) ~= nil
	ZO_DYEING_KEYBOARD.noDyesLabel:SetHidden(anyDyesToSwatch)
	if ZO_DYEING_KEYBOARD.selectedDyeId then
		ZO_DYEING_KEYBOARD:SetSelectedDyeId(ZO_DYEING_KEYBOARD.selectedDyeId, true)
	end
	
end

function dyesList:New(control)
	
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		name = {},
		primaryDyeId = {tiebreaker = "name", isNumeric = true},
		secondaryDyeId = {tiebreaker = "name", isNumeric = true},
		accentDyeId = {tiebreaker = "name", isNumeric = true},
	}
	
 	self.masterList = {}
	
	self.noDyesLabel = control:GetNamedChild("NoDyesLabel")
	
 	ZO_ScrollList_AddDataType(self.list, 1, "DyerRowTemplate", 52, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SorterKeys, self.currentSortOrder) end
	
	return self
	
end

function dyesList:SetupEntry(control, data)
	
	control.data = data
	
	control.name = GetControl(control, "Name")
	control.name:SetText(data.name)
	
	control.primary = GetControl(control, "Primary")
	control.secondary = GetControl(control, "Secondary")
	control.accent = GetControl(control, "Accent")
	
	local dyeName1, _, _, _, achievementId1, r1, g1, b1 = GetDyeInfoById(data.primaryDyeId)
	local dyeName2, _, _, _, achievementId2, r2, g2, b2 = GetDyeInfoById(data.secondaryDyeId)
	local dyeName3, _, _, _, achievementId3, r3, g3, b3 = GetDyeInfoById(data.accentDyeId)
	
	control.primary:SetColor(ZO_DYEING_SWATCH_INDEX, r1, g1, b1)
	control.secondary:SetColor(ZO_DYEING_SWATCH_INDEX, r2, g2, b2)
	control.accent:SetColor(ZO_DYEING_SWATCH_INDEX, r3, g3, b3)
	
	control.primary.dyeId = data.primaryDyeId
	control.secondary.dyeId = data.secondaryDyeId
	control.accent.dyeId = data.accentDyeId

	control.primary.dyeName = dyeName1
	control.secondary.dyeName = dyeName2
	control.accent.dyeName = dyeName3
	
	control.primary.isDyeKnown = data.primaryDyeIdKnown
	control.secondary.isDyeKnown = data.secondaryDyeIdKnown
	control.accent.isDyeKnown = data.accentDyeIdKnown

	control.primary.achievementId = achievementId1
	control.secondary.achievementId = achievementId2
	control.accent.achievementId = achievementId3
	
	control.primary:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, data.primaryDyeIdKnown or data.isCrownStoreDyeStamp)
	control.secondary:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, data.secondaryDyeIdKnown or data.isCrownStoreDyeStamp)
	control.accent:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, data.accentDyeIdKnown or data.isCrownStoreDyeStamp)
	
	local crownStore = GetControl(control, "CrownStore")
	crownStore:SetHidden(not data.isCrownStoreDyeStamp)
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end

function dyesList:BuildMasterList()
	
	self.masterList = {}
	
	for savedEntryIndex, data in ipairs(db.s) do
	
		local primaryDyeId, secondaryDyeId, accentDyeId, mode, primaryDyeIdKnown, secondaryDyeIdKnown, accentDyeIdKnown
		
		if not data.m or data.m == FAVORITE_MODE_DYESLOT then
			data.m = FAVORITE_MODE_DYESLOT
			mode = data.m
			primaryDyeId = data.p
			secondaryDyeId = data.s
			accentDyeId = data.a
		elseif NonContiguousCount(data.d) > 0 then
			
			mode = data.m
			
			local referenceSlot = EQUIP_SLOT_CHEST
			if mode == FAVORITE_MODE_WCOLLECTIBLE then
				referenceSlot = COLLECTIBLE_CATEGORY_TYPE_COSTUME
			end
			
			primaryDyeId = data.d[referenceSlot].p
			secondaryDyeId = data.d[referenceSlot].s
			accentDyeId = data.d[referenceSlot].a

		end
		
		primaryDyeIdKnown = IsDyeIdKnown(primaryDyeId)
		secondaryDyeIdKnown = IsDyeIdKnown(secondaryDyeId)
		accentDyeIdKnown = IsDyeIdKnown(accentDyeId)
		
		local primaryDyeName = GetDyeInfoById(primaryDyeId)
		local secondaryDyeName = GetDyeInfoById(secondaryDyeId)
		local accentDyeName = GetDyeInfoById(accentDyeId)
		
		if primaryDyeIdKnown and secondaryDyeIdKnown and accentDyeIdKnown then
			table.insert(self.masterList, {
				name = data.n,
				primaryDyeId = primaryDyeId,
				secondaryDyeId = secondaryDyeId,
				accentDyeId = accentDyeId,
				mode = mode,
				primaryDyeIdKnown = primaryDyeIdKnown,
				secondaryDyeIdKnown = secondaryDyeIdKnown,
				accentDyeIdKnown = accentDyeIdKnown,
				primaryDyeName = string.lower(primaryDyeName),
				secondaryDyeName = string.lower(secondaryDyeName),
				accentDyeName = string.lower(accentDyeName),
				savedEntryIndex = savedEntryIndex,
				slotDef = data.d
			})
		end
		
	end
	
	for itemId, enabled in pairs(knownDyeStamps) do
		
		if enabled then
		
			local name, primaryDyeId, secondaryDyeId, accentDyeId = GetDyeStampInfo(itemId)
			
			local primaryDyeName, _, _, _, achievementId1 = GetDyeInfoById(primaryDyeId)
			local secondaryDyeName, _, _, _, achievementId2 = GetDyeInfoById(secondaryDyeId)
			local accentDyeName, _, _, _, achievementId3 = GetDyeInfoById(accentDyeId)
			
			local isCrownStoreDyeStamp = achievementId1 == 0 or achievementId2 == 0 or achievementId3 == 0

			primaryDyeIdKnown = IsDyeIdKnown(primaryDyeId)
			secondaryDyeIdKnown = IsDyeIdKnown(secondaryDyeId)
			accentDyeIdKnown = IsDyeIdKnown(accentDyeId)
			
			if (primaryDyeIdKnown and secondaryDyeIdKnown and accentDyeIdKnown) or isCrownStoreDyeStamp then
				table.insert(self.masterList, {
					name = name,
					primaryDyeId = primaryDyeId,
					secondaryDyeId = secondaryDyeId,
					accentDyeId = accentDyeId,
					mode = FAVORITE_MODE_DYESLOT,
					primaryDyeIdKnown = primaryDyeIdKnown,
					secondaryDyeIdKnown = secondaryDyeIdKnown,
					accentDyeIdKnown = accentDyeIdKnown,
					primaryDyeName = string.lower(primaryDyeName),
					secondaryDyeName = string.lower(secondaryDyeName),
					accentDyeName = string.lower(accentDyeName),
					isCrownStoreDyeStamp = isCrownStoreDyeStamp,
				})
			end
		end
	end
	
end

function dyesList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

local function Sanitize(value)
	return value:gsub("[-*+?^$().[%]%%]", "%%%0")
end

function dyesList:FilterScrollList()
	
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	
	local editText = ZO_RESTYLE_KEYBOARD.contentSearchEditBox:GetText()
	local search = Sanitize(string.lower(editText))
	
	if search == "" or string.len(search) == 1 then
		for i = 1, #self.masterList do
			local data = self.masterList[i]
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		end
	else
		for i = 1, #self.masterList do
			local data = self.masterList[i]
			if string.find(string.lower(data.name), search) or string.find(data.primaryDyeName, search) or string.find(data.secondaryDyeName, search) or string.find(data.accentDyeName, search) then
				table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
			end
		end
	end
	
	local anyDyestampsToShow = next(scrollData) ~= nil
	self.noDyesLabel:SetHidden(anyDyestampsToShow)
		
end

local function UpdateDyeStampsLayout()
	dyesManager:RefreshFilters()
end

function Dyer_HoverRow(control)
	dyesList:Row_OnMouseEnter(control)
end

function Dyer_ExitRow(control)
	dyesList:Row_OnMouseExit(control)
end

function Dyer_HoverDye(control)

	InitializeTooltip(InformationTooltip, control, BOTTOM, -15, -15, TOP)
	
	SetTooltipText(InformationTooltip, zo_strformat(SI_DYEING_SWATCH_TOOLTIP_TITLE, control.dyeName))
	InformationTooltip:AddVerticalPadding(INFORMATION_TOOLTIP_VERTICAL_PADDING)
	
	local line1, line2 = ZO_Dyeing_GetAchivementText(control.isDyeKnown, control.achievementId)
	InformationTooltip:AddLine(line1, "", ZO_NORMAL_TEXT:UnpackRGB())
	if line2 then
		InformationTooltip:AddLine(line2, "", ZO_NORMAL_TEXT:UnpackRGB())
	end
	
end

function Dyer_ExitDye(control)
	ClearTooltip(InformationTooltip)
end

function Dyer_ClickDye(control, button, upInside)
	if upInside then
		if button == MOUSE_BUTTON_INDEX_LEFT then
			if control.isDyeKnown then
				ZO_DYEING_KEYBOARD:SwitchToDyeingWithDyeId(control.dyeId)
			end
		elseif button == MOUSE_BUTTON_INDEX_RIGHT then
			local achievementName = GetAchievementInfo(control.achievementId)
			if achievementName ~= "" then
				ClearMenu()
				AddMenuItem(GetString(SI_DYEING_SWATCH_VIEW_ACHIEVEMENT), function() ZO_RESTYLE_KEYBOARD:AttemptExit(control.achievementId) end)
				ShowMenu(control)
			end
		end
	end
end

local function SaveFavoriteDyeStampWhole(name, mode)

	local slots = ZO_Dyeing_GetSlotsForMode(ZO_RESTYLE_KEYBOARD.mode)
	
	local slotDef = {}
	for i, dyeableSlotData in ipairs(slots) do
		local restyleSlotType = dyeableSlotData:GetRestyleSlotType()
		local primaryDyeId, secondaryDyeId, accentDyeId = dyeableSlotData:GetPendingDyes()
		slotDef[restyleSlotType] = {p = primaryDyeId, s = secondaryDyeId, a = accentDyeId}
	end
	table.insert(db.s, {m = mode, n = zo_strformat("> <<1>> : <<2>>", GetString(DYER_SET_LABEL), name), d = slotDef}) -- ">" to help sorting for user
	
	dyesManager:RefreshData()
	
end

local function SaveFavoriteDyeStampSolo(name, primaryDyeId, secondaryDyeId, accentDyeId)
	local FAVORITE_MODE_DYESLOT = 1 -- FAVORITE_MODE_SAVEDSET share same structure
	table.insert(db.s, {m = FAVORITE_MODE_DYESLOT, p = primaryDyeId, s = secondaryDyeId, a = accentDyeId, n = zo_strformat("> <<1>>", name)}) -- ">" to help sorting for user
	dyesManager:RefreshData()
end

local function RemoveFavoriteDyeStamp(index)
	table.remove(db.s, index)
	dyesManager:RefreshData()
end

local function RefreshDyes()
	dyesManager:RefreshData()
	BuildDyesAvailableForRandomness()
end

function Dyer_ClickDyeStamp(control, button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		
		if control.data.mode == FAVORITE_MODE_DYESLOT then
			if control.data.primaryDyeIdKnown and control.data.secondaryDyeIdKnown and control.data.accentDyeIdKnown then
				
				local primaryDyeId = control.data.primaryDyeId
				local secondaryDyeId = control.data.secondaryDyeId
				local accentDyeId = control.data.accentDyeId
				
				local slots = ZO_Dyeing_GetSlotsForMode(ZO_RESTYLE_KEYBOARD.mode)
				local activeDyeableSlot = ZO_Restyle_GetActiveOffhandEquipSlotType()
				
				for i, dyeableSlotData in ipairs(slots) do
					local restyleSlotType = dyeableSlotData:GetRestyleSlotType()
					if not dyeableSlotData:ShouldBeHidden() then
						
						local restyleMode = dyeableSlotData:GetRestyleMode()
						local restyleSetIndex = dyeableSlotData:GetRestyleSetIndex()
						
						local isPrimaryChannelDyeable, isSecondaryChannelDyeable, isAccentChannelDyeable = AreRestyleSlotDyeChannelsDyeable(restyleMode, restyleSetIndex, restyleSlotType)
						local finalPrimaryDyeId = isPrimaryChannelDyeable and primaryDyeId or INVALID_DYE_ID
						local finalSecondaryDyeId = isSecondaryChannelDyeable and secondaryDyeId or INVALID_DYE_ID
						local finalAccentDyeId = isAccentChannelDyeable and accentDyeId or INVALID_DYE_ID
						SetPendingSlotDyes(restyleMode, restyleSetIndex, restyleSlotType, finalPrimaryDyeId, finalSecondaryDyeId, finalAccentDyeId)
					end
				end

				PlaySound(SOUNDS.DYEING_RANDOMIZE_DYES)
				ZO_RESTYLE_KEYBOARD:OnPendingDyesChanged()
			end
		else
			if 1 + ZO_RESTYLE_KEYBOARD.mode == control.data.mode then
				
				local slots = ZO_Dyeing_GetSlotsForMode(ZO_RESTYLE_KEYBOARD.mode)
				
				for i, dyeableSlotData in ipairs(slots) do
					local restyleSlotType = dyeableSlotData:GetRestyleSlotType()
					
					local restyleMode = dyeableSlotData:GetRestyleMode()
					local restyleSetIndex = dyeableSlotData:GetRestyleSetIndex()
					
					local primaryDyeId = control.data.slotDef[restyleSlotType].p
					local secondaryDyeId = control.data.slotDef[restyleSlotType].s
					local accentDyeId = control.data.slotDef[restyleSlotType].a
					
					if not dyeableSlotData:ShouldBeHidden() then
						
						local isPrimaryChannelDyeable, isSecondaryChannelDyeable, isAccentChannelDyeable = AreRestyleSlotDyeChannelsDyeable(restyleMode, restyleSetIndex, restyleSlotType)
						local finalPrimaryDyeId = isPrimaryChannelDyeable and primaryDyeId or INVALID_DYE_ID
						local finalSecondaryDyeId = isSecondaryChannelDyeable and secondaryDyeId or INVALID_DYE_ID
						local finalAccentDyeId = isAccentChannelDyeable and accentDyeId or INVALID_DYE_ID
						
						SetPendingSlotDyes(restyleMode, restyleSetIndex, restyleSlotType, finalPrimaryDyeId, finalSecondaryDyeId, finalAccentDyeId)
						
					end
				end

				PlaySound(SOUNDS.DYEING_RANDOMIZE_DYES)
				ZO_RESTYLE_KEYBOARD:OnPendingDyesChanged()
			else
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, GetString(DYER_INVALID_MODE_FOR_SET))
			end
		end
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		if control.data.savedEntryIndex then
			ClearMenu()
			AddMenuItem(GetString(DYER_DELETE_DYESTAMP),
				function()
					RemoveFavoriteDyeStamp(control.data.savedEntryIndex)
				end)
			ShowMenu(control)
		end
	end
end

local function ToggleDyeStamps(forceHide, forceShow)

	if forceHide then
		dyeStampsShown = false
	elseif forceShow then
		DyerPane:SetHidden(false)
		ZO_DyeingTopLevel_KeyboardPane:SetHidden(true)
		dyeStampsShown = true
	else
		if ZO_DyeingTopLevel_KeyboardPane:IsHidden() then
			DyerPane:SetHidden(true)
			ZO_DyeingTopLevel_KeyboardPane:SetHidden(false)
			dyeStampsShown = false
		else
			DyerPane:SetHidden(false)
			ZO_DyeingTopLevel_KeyboardPane:SetHidden(true)
			dyeStampsShown = true
		end
	end
	
end

local function ShowDyeStampFavoriteWindow(mode, slotFrom, restyleSlotData)
	
	if mode == FAVORITE_MODE_DYESLOT then
		if (restyleSlotData:IsEquipment() and slotFrom ~= EQUIP_SLOT_NONE) or (restyleSlotData:IsCollectible() and (slotFrom == COLLECTIBLE_CATEGORY_TYPE_COSTUME or slotFrom == COLLECTIBLE_CATEGORY_TYPE_HAT)) then
			local primaryDyeId, secondaryDyeId, accentDyeId = restyleSlotData:GetPendingDyes()
			ToggleDyeStamps(false, true)
			ZO_Dialogs_ShowDialog("DYER_SAVE_DYESTAMP_SOLO", {mode = mode, primaryDyeId = primaryDyeId, secondaryDyeId = secondaryDyeId, accentDyeId = accentDyeId})
		end
	elseif mode == FAVORITE_MODE_SAVEDSET and slotFrom >= 1 and slotFrom <= 4  then
		local primaryDyeId, secondaryDyeId, accentDyeId = GetSavedDyeSetDyes(slotFrom)
		if primaryDyeId ~= INVALID_DYE_ID and secondaryDyeId ~= INVALID_DYE_ID and accentDyeId ~= INVALID_DYE_ID then
			ToggleDyeStamps(false, true)
			ZO_Dialogs_ShowDialog("DYER_SAVE_DYESTAMP_SOLO", {mode = mode, primaryDyeId = primaryDyeId, secondaryDyeId = secondaryDyeId, accentDyeId = accentDyeId})
		end
	elseif mode == FAVORITE_MODE_WARMOR then
		local primaryDyeId, secondaryDyeId, accentDyeId = restyleSlotData:GetPendingDyes()
		ToggleDyeStamps(false, true)
		ZO_Dialogs_ShowDialog("DYER_SAVE_DYESTAMP_WHOLE", {mode = mode, primaryDyeId = primaryDyeId, secondaryDyeId = secondaryDyeId, accentDyeId = accentDyeId})
	elseif mode == FAVORITE_MODE_WCOLLECTIBLE then
		local primaryDyeId, secondaryDyeId, accentDyeId = restyleSlotData:GetPendingDyes()
		ToggleDyeStamps(false, true)
		ZO_Dialogs_ShowDialog("DYER_SAVE_DYESTAMP_WHOLE", {mode = mode, primaryDyeId = primaryDyeId, secondaryDyeId = secondaryDyeId, accentDyeId = accentDyeId})
	end

end

function ZO_DyeingToolBase:OnRightClicked(restyleSlotData, dyeChannel)
	if select(dyeChannel, restyleSlotData:GetPendingDyes()) ~= nil then
		ClearMenu()
		AddMenuItem(GetString(SI_DYEING_CLEAR_MENU),
			function()
				restyleSlotData:SetPendingDyes(zo_replaceInVarArgs(dyeChannel, INVALID_DYE_ID, restyleSlotData:GetPendingDyes()))
				self.owner:OnPendingDyesChanged(restyleSlotData)
				PlaySound(SOUNDS.DYEING_TOOL_ERASE_USED)
			end)
		local primaryDyeId, secondaryDyeId, accentDyeId = restyleSlotData:GetPendingDyes()
		if primaryDyeId ~= INVALID_DYE_ID and secondaryDyeId ~= INVALID_DYE_ID and accentDyeId ~= INVALID_DYE_ID then
			AddMenuItem(GetString(DYER_ADD_SOLO_TO_DYESTAMPS), function() ShowDyeStampFavoriteWindow(FAVORITE_MODE_DYESLOT, restyleSlotData:GetRestyleSlotType(), restyleSlotData) end)
		end
		local mode = 1 + ZO_RESTYLE_KEYBOARD.mode -- 3/4
		AddMenuItem(GetString(DYER_ADD_WHOLE_TO_DYESTAMPS), function() ShowDyeStampFavoriteWindow(mode, nil, restyleSlotData) end)
		
		local randomizablePool = db.a[ZO_RESTYLE_KEYBOARD.mode]
		if randomizablePool[restyleSlotData:GetRestyleSlotType()] and randomizablePool[restyleSlotData:GetRestyleSlotType()][dyeChannel] then
			AddMenuItem(GetString(SI_ITEM_ACTION_UNMARK_AS_LOCKED), function()
				randomizablePool[restyleSlotData:GetRestyleSlotType()][dyeChannel] = nil
				ZO_RESTYLE_KEYBOARD.sheetsByMode[ZO_RESTYLE_KEYBOARD.mode].slots[restyleSlotData:GetRestyleSlotType()].dyeControls[dyeChannel].frameTexture:SetColor(1, 1, 1, 1)
			end)
		else
			AddMenuItem(GetString(SI_ITEM_ACTION_MARK_AS_LOCKED), function()
				if not randomizablePool[restyleSlotData:GetRestyleSlotType()] then randomizablePool[restyleSlotData:GetRestyleSlotType()] = {} end
				randomizablePool[restyleSlotData:GetRestyleSlotType()][dyeChannel] = true
				ZO_RESTYLE_KEYBOARD.sheetsByMode[ZO_RESTYLE_KEYBOARD.mode].slots[restyleSlotData:GetRestyleSlotType()].dyeControls[dyeChannel].frameTexture:SetColor(1, 0, 0, 1)
			end)
		end
		
		ShowMenu(self)
	end
end

function ZO_DyeingToolBase:OnSavedSetRightClicked(dyeSetIndex, dyeChannel)
	if select(dyeChannel, GetSavedDyeSetDyes(dyeSetIndex)) ~= nil then
		ClearMenu()
		AddMenuItem(GetString(SI_DYEING_CLEAR_MENU),
			function()
				SetSavedDyeSetDyes(dyeSetIndex, zo_replaceInVarArgs(dyeChannel, INVALID_DYE_ID, GetSavedDyeSetDyes(dyeSetIndex)))
				self.owner:OnSavedSetSlotChanged(dyeSetIndex)
				PlaySound(SOUNDS.DYEING_TOOL_ERASE_USED)
			end)
		local primaryDyeId, secondaryDyeId, accentDyeId = GetSavedDyeSetDyes(dyeSetIndex)
		if primaryDyeId ~= INVALID_DYE_ID and secondaryDyeId ~= INVALID_DYE_ID and accentDyeId ~= INVALID_DYE_ID then
			AddMenuItem(GetString(DYER_ADD_SOLO_TO_DYESTAMPS), function() ShowDyeStampFavoriteWindow(FAVORITE_MODE_SAVEDSET, dyeSetIndex) end)
		end
		ShowMenu(self)
	end
end

local function BuildSaveFavoriteDialog()

	local function AddDialogSetup(dialog, data)
	
		local name = GetControl(dialog, "EditBox")
		name:SetText("")
		
		local primary = GetControl(dialog, "Primary")
		local secondary = GetControl(dialog, "Secondary")
		local accent = GetControl(dialog, "Accent")
		
		local _, _, _, _, _, r1, g1, b1 = GetDyeInfoById(data.primaryDyeId)
		local _, _, _, _, _, r2, g2, b2 = GetDyeInfoById(data.secondaryDyeId)
		local _, _, _, _, _, r3, g3, b3 = GetDyeInfoById(data.accentDyeId)
		
		primary:SetColor(ZO_DYEING_SWATCH_INDEX, r1, g1, b1)
		secondary:SetColor(ZO_DYEING_SWATCH_INDEX, r2, g2, b2)
		accent:SetColor(ZO_DYEING_SWATCH_INDEX, r3, g3, b3)

		primary:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, true)
		secondary:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, true)
		accent:SetSurfaceHidden(ZO_DYEING_LOCK_INDEX, true)
		
	end
	
	local self = GetControl("DyerSaveFavoriteDialog")
	
	ZO_Dialogs_RegisterCustomDialog("DYER_SAVE_DYESTAMP_SOLO", 
	{
		customControl = self,
		setup = AddDialogSetup,
		title =
		{
			text = DYER_SAVE_FAVORITE_TITLE,
		},
		buttons =
		{
			[1] =
			{
				control = GetControl(self, "Accept"),
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					local name = ZO_Dialogs_GetEditBoxText(dialog)
					if(name and name ~= "") then
						SaveFavoriteDyeStampSolo(name, dialog.data.primaryDyeId, dialog.data.secondaryDyeId, dialog.data.accentDyeId)
					end
				end,
			},
			[2] =
			{
				control = GetControl(self, "Cancel"),
				text = SI_DIALOG_CANCEL,
			}
		}
	})
	
	ZO_Dialogs_RegisterCustomDialog("DYER_SAVE_DYESTAMP_WHOLE", 
	{
		customControl = self,
		setup = AddDialogSetup,
		title =
		{
			text = DYER_SAVE_FAVORITE_TITLE,
		},
		buttons =
		{
			[1] =
			{
				control = GetControl(self, "Accept"),
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					local name = ZO_Dialogs_GetEditBoxText(dialog)
					if(name and name ~= "") then
						SaveFavoriteDyeStampWhole(name, dialog.data.mode)
					end
				end,
			},
			[2] =
			{
				control = GetControl(self, "Cancel"),
				text = SI_DIALOG_CANCEL,
			}
		}
	})

end

local function BuildKeybindStrip()
	
	rightKeybindStripDescriptor = 
	{
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
		{
			name = GetString(DYER_TOGGLE_MODE),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = ToggleDyeStamps,
		},
	}
	
end

local function InitializeSlotsForRandomness()
	for modeIndex, modeData in pairs(ZO_RESTYLE_KEYBOARD.sheetsByMode) do
		for slotTypeIndex, slotTypeData in pairs(modeData.slots) do
			if not db.a[modeIndex][slotTypeIndex] then db.a[modeIndex][slotTypeIndex] = {} end
			for dyeChannelIndex, dyeChannelData in ipairs(slotTypeData.dyeControls) do
				if db.a[modeIndex][slotTypeIndex][dyeChannelIndex] then
					dyeChannelData.frameTexture:SetColor(1, 0, 0, 1)
				end
			end
		end
	end
end

local function BuildDyestampList()
	DyerPane:SetParent(ZO_DyeingTopLevel_Keyboard)
	dyesManager = dyesList:New(DyerPane)
	dyesManager:RefreshData()
	BuildDyesAvailableForRandomness()
	InitializeSlotsForRandomness()
end

function ZO_DYEING_KEYBOARD:GetRandomUnlockedDyeId()
    if #dyesAvailableForRandomness > 0 then
        return dyesAvailableForRandomness[zo_random(1, #dyesAvailableForRandomness)]
    end
end

local function AreDyeChannelsRandomizable(restyleMode, restyleSlotType)
	local randomizablePool = db.a[restyleMode]
	if randomizablePool[restyleSlotType] then
		return not randomizablePool[restyleSlotType][1], not randomizablePool[restyleSlotType][2], not randomizablePool[restyleSlotType][3]
	end
	return true, true, true
end

function ZO_Dyeing_UniformRandomize(restyleMode, getRandomUnlockedDyeIdFunction)
	
	local primaryDyeId = getRandomUnlockedDyeIdFunction()
	local secondaryDyeId = getRandomUnlockedDyeIdFunction()
	local accentDyeId = getRandomUnlockedDyeIdFunction()
	
	local slots = ZO_Dyeing_GetSlotsForMode(restyleMode)
	
	for i, dyeableSlotData in ipairs(slots) do
		if not dyeableSlotData:ShouldBeHidden() then
			local restyleSlotType = dyeableSlotData:GetRestyleSlotType()
				
			local isPrimaryChannelDyeable, isSecondaryChannelDyeable, isAccentChannelDyeable = dyeableSlotData:AreDyeChannelsDyeable()
			local isPrimaryChannelRandomizable, isSecondaryRandomizable, isAccentChannelRandomizable = AreDyeChannelsRandomizable(restyleMode, restyleSlotType)
			local actualPrimaryDyeId, actualSecondaryDyeId, actualAccentDyeId = dyeableSlotData:GetPendingDyes()
			local finalPrimaryDyeId, finalSecondaryDyeId, finalAccentDyeId
			
			if isPrimaryChannelDyeable then
				finalPrimaryDyeId = isPrimaryChannelRandomizable and primaryDyeId or actualPrimaryDyeId
			else
				finalPrimaryDyeId = INVALID_DYE_ID
			end

			if isSecondaryChannelDyeable then
				finalSecondaryDyeId = isSecondaryRandomizable and secondaryDyeId or actualSecondaryDyeId
			else
				finalSecondaryDyeId = INVALID_DYE_ID
			end

			if isAccentChannelDyeable then
				finalAccentDyeId = isAccentChannelRandomizable and accentDyeId or actualAccentDyeId
			else
				finalAccentDyeId = INVALID_DYE_ID
			end
			
			dyeableSlotData:SetPendingDyes(finalPrimaryDyeId, finalSecondaryDyeId, finalAccentDyeId)
			
		end
	end
	
	PlaySound(SOUNDS.DYEING_RANDOMIZE_DYES)
	return primaryDyeId, secondaryDyeId, accentDyeId
	
end

local function ConvertDBToRestyleSystem()

	if not db.convertedToRestyle then
		
		local DYEABLE_SLOT_BACKUP_OFF = 8
		local DYEABLE_SLOT_CHEST = 1
		local DYEABLE_SLOT_FEET = 5
		local DYEABLE_SLOT_HAND	= 6
		local DYEABLE_SLOT_HEAD = 0
		local DYEABLE_SLOT_LEGS = 4
		local DYEABLE_SLOT_OFF_HAND = 7
		local DYEABLE_SLOT_SHOULDERS = 2
		local DYEABLE_SLOT_WAIST = 3
		local DYEABLE_SLOT_HAT = 10
		local DYEABLE_SLOT_COSTUME = 9
		
		for entryIndex, entryData in ipairs(db.s) do
		
			if entryData.m == FAVORITE_MODE_WARMOR then
				
				local newData = {
					[EQUIP_SLOT_OFF_HAND] = entryData.d[DYEABLE_SLOT_OFF_HAND],
					[EQUIP_SLOT_BACKUP_OFF] = entryData.d[DYEABLE_SLOT_BACKUP_OFF],
					[EQUIP_SLOT_CHEST] = entryData.d[DYEABLE_SLOT_CHEST],
					[EQUIP_SLOT_FEET] = entryData.d[DYEABLE_SLOT_FEET],
					[EQUIP_SLOT_HAND] = entryData.d[DYEABLE_SLOT_HAND],
					[EQUIP_SLOT_HEAD] = entryData.d[DYEABLE_SLOT_HEAD],
					[EQUIP_SLOT_LEGS] = entryData.d[DYEABLE_SLOT_LEGS],
					[EQUIP_SLOT_SHOULDERS] = entryData.d[DYEABLE_SLOT_SHOULDERS],
					[EQUIP_SLOT_WAIST] = entryData.d[DYEABLE_SLOT_WAIST],
				}
				
				entryData.d = newData
				
			elseif entryData.m == FAVORITE_MODE_WCOLLECTIBLE then
			
				local newData = {
					[COLLECTIBLE_CATEGORY_TYPE_HAT] = entryData.d[DYEABLE_SLOT_HAT],
					[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = entryData.d[DYEABLE_SLOT_COSTUME],
				}
				
				entryData.d = newData
			
			end
			
		end
		
		db.convertedToRestyle = true
		
	end
			
end

local function OnAddonLoaded(_, addon)

	if addon == ADDON_NAME then
		
		db = ZO_SavedVars:NewAccountWide('DYER', 1, nil, defaults)
		
		ConvertDBToRestyleSystem()
		
		BuildSaveFavoriteDialog()
		BuildKeybindStrip()
		BuildDyestampList()
		
		CanUseCollectibleDyeing = function()
			return true
		end
		
		KEYBOARD_DYEING_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_SHOWING then
				KEYBIND_STRIP:AddKeybindButtonGroup(rightKeybindStripDescriptor)
			elseif newState == SCENE_HIDDEN then
				KEYBIND_STRIP:RemoveKeybindButtonGroup(rightKeybindStripDescriptor)
				ToggleDyeStamps(true)
			end
		end)
		
		ZO_DYEING_MANAGER:RegisterCallback("UpdateSearchResults", UpdateDyeStampsLayout)
		
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNLOCKED_DYES_UPDATED, RefreshDyes)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)