SWAPS_skillAlias = {

		["flame touch"]				= "destructive touch",	
		["frost touch"]				= "destructive touch",	
		["shock touch"]				= "destructive touch",	

		["flame clench"]				= "destructive clench",
		["frost clench"]				= "destructive clench",
		["shock clench"]				= "destructive clench",

		["flame reach"]				= "destructive reach",
		["frost reach"]				= "destructive reach",
		["shock reach"]				= "destructive reach",

	-- -------------------------------------------------------
	
		["wall of fire"]						= "wall of elements",
		["wall of frost"]						= "wall of elements",
		["wall of storms"]					= "wall of elements",

		["unstable wall of fire"]			= "unstable wall of elements",
		["unstable wall of frost"]			= "unstable wall of elements",
		["unstable wall of storms"]		= "unstable wall of elements",

		["blockade of fire"]					= "elemental blockade",
		["blockade of frost"]				= "elemental blockade",
		["blockade of storms"]				= "elemental blockade",

	-- --------------------------------------------------------
	
		["fire impulse"]				= "impulse",	
		["frost impulse"]				= "impulse",	
		["shock impulse"]				= "impulse",	

		["fire ring"] = "elemental ring",
		["frost ring"] = "elemental ring",
		["lightning ring"] = "elemental ring", 

		["flame pulsar"]				= "pulsar",
		["frost pulsar"]				= "pulsar",
		["storm pulsar"]				= "pulsar",
		
	-- --------------------------------------------------------

		["fire storm"]				= "elemental storm",
		["ice storm"]				= "elemental storm",
		["thunder storm"]			= "elemental storm",

		["fiery rage"]				= "elemental rage",
		["icy rage"]				= "elemental rage",
		["thunderous rage"]			= "elemental rage",
		
		["eye of flame"]			= "eye of the storm",
		["eye of frost"]			= "eye of the storm",
		["eye of lightning"]		= "eye of the storm",	
	
}

local lang = GetCVar("Language.2")

if lang == "fr" then

		SWAPS_skillAlias["toucher de flammes^m"]		= "toucher destructeur^m"
		SWAPS_skillAlias["toucher de givre^m"]			= "toucher destructeur^m"
		SWAPS_skillAlias["toucher de foudre^m"]		= "toucher destructeur^m"

		SWAPS_skillAlias["prise de flammes^f"]			= "prise destructrice^f"
		SWAPS_skillAlias["prise de givre^f"]			= "prise destructrice^f"
		SWAPS_skillAlias["prise de foudre^f"]			= "prise destructrice^f"

		SWAPS_skillAlias["allonge de feu^m"]			= "allonge destructrice^m"
		SWAPS_skillAlias["allonge de givre^m"]			= "allonge destructrice^m"
		SWAPS_skillAlias["allonge de foudre^m"]		= "allonge destructrice^m"

	-- ------------------------------------------------------------------------
	
		SWAPS_skillAlias["mur de feu^m"]							= "mur élémentaire^m"		
		SWAPS_skillAlias["mur de givre^m"]						= "mur élémentaire^m"		
		SWAPS_skillAlias["mur de tempêtes^m"]					= "mur élémentaire^m"		

		SWAPS_skillAlias["mur de feu instable^m"]				= "mur élémentaire instable^m"
		SWAPS_skillAlias["mur de givre instable^m"]			= "mur élémentaire instable^m"
		SWAPS_skillAlias["mur de tempêtes instable^m"]		= "mur élémentaire instable^m"

		SWAPS_skillAlias["barrage de feu^m"]					= "rempart élémentaire^m"		
		SWAPS_skillAlias["barrage de givre^m"]					= "rempart élémentaire^m"		
		SWAPS_skillAlias["barrage de tempêtes^m"]				= "rempart élémentaire^m"		
	
	-- -------------------------------------------------------------------------

		SWAPS_skillAlias["impulsion de feu^f"]			= "impulsion^m"	
		SWAPS_skillAlias["impulsion de froid^f"]		= "impulsion^m"	
		SWAPS_skillAlias["impulsion de foudre^f"]		= "impulsion^m"	

		SWAPS_skillAlias["cercle de feu^m"]				= "cercle élémentaire^m"
		SWAPS_skillAlias["cercle de givre^m"]			= "cercle élémentaire^m"
		SWAPS_skillAlias["cercle de foudre^m"]			= "cercle élémentaire^m"

		SWAPS_skillAlias["pulsar de flamme^m"]			= "pulsar^m"	
		SWAPS_skillAlias["pulsar de givre^m"]			= "pulsar^m"	
		SWAPS_skillAlias["pulsar des tempêtes^m"]		= "pulsar^m"	
	
		
elseif lang == "de" then

		SWAPS_skillAlias["flammenberührung^f"]		= "zerstörerische berührung^f"
		SWAPS_skillAlias["frostberührung^f"]		= "zerstörerische berührung^f"
		SWAPS_skillAlias["schockberührung^f"]		= "zerstörerische berührung^f"

		SWAPS_skillAlias["flammenhieb^m"]			= "zerstörerischer hieb^m"
		SWAPS_skillAlias["frosthieb^m"]				= "zerstörerischer hieb^m"
		SWAPS_skillAlias["schockhieb^m"]				= "zerstörerischer hieb^m"

		SWAPS_skillAlias["flammenfaust^m"]			= "zerstörerische faust^m"
		SWAPS_skillAlias["frostfaust^m"]				= "zerstörerische faust^m"
		SWAPS_skillAlias["schockfaust^m"]			= "zerstörerische faust^m"

	-- -------------------------------------------------------------------
	
		SWAPS_skillAlias["feuerwand^f"]					= "elementare wand^f"
		SWAPS_skillAlias["frostwand^f"]					= "elementare wand^f"
		SWAPS_skillAlias["sturmwand^f"]					= "elementare wand^f"

		SWAPS_skillAlias["instabile feuerwand^f"]		= "instabile elementare wand^f"
		SWAPS_skillAlias["instabile frostwand^f"]		= "instabile elementare wand^f"
		SWAPS_skillAlias["instabile sturmwand^f"]		= "instabile elementare wand^f"

		SWAPS_skillAlias["feuerblockade^f"]				= "elementare blockade^f"
		SWAPS_skillAlias["frostblockade^f"]				= "elementare blockade^f"
		SWAPS_skillAlias["sturmblockade^f"]				= "elementare blockade^f"
	
	-- --------------------------------------------------------------------
	
		SWAPS_skillAlias["feuerimpuls^m"]		= "impuls^m"
		SWAPS_skillAlias["frostimpuls^m"]		= "impuls^m"
		SWAPS_skillAlias["schockimpuls^m"]		= "impuls^m"

		SWAPS_skillAlias["feuerring^m"]			= "elementarer ring^m"
		SWAPS_skillAlias["frostring^m"]			= "elementarer ring^m"
		SWAPS_skillAlias["schockring^m"]			= "elementarer ring^m"

		SWAPS_skillAlias["flammenpulsar^m"]		= "pulsar^m"	
		SWAPS_skillAlias["frostpulsar^m"]		= "pulsar^m"	
		SWAPS_skillAlias["sturmpulsar^m"]		= "pulsar^m"	

	-- -----------------------------------------------------------------------
	
		SWAPS_skillAlias["geladener schlag"]				 = "überladung"
		SWAPS_skillAlias["geladener hieb"] 					= "überladung"
		SWAPS_skillAlias["kräftiger geladener hieb"] 	= "überladung"

end