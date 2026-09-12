
-- LibTarget : Vérification du bon changement de la table
LibTarget = LibTarget or {}
local LibTG = LibTarget

-- Référence à la lib réseau de TESO pour la communication de groupe
local LGB = LibGroupBroadcast  



-- ============================================================
-- ENCODAGE / DÉCODAGE DES DONNÉES
-- ============================================================

-- Encode une table de données en une chaîne binaire compacte pour l'envoi réseau.
-- Chaque entrée de uncodedData est un couple { valeur, tailleBits }
-- Supporte les tailles 8, 16 et 24 bits (little-endian) : octet faible en premier
-- Retourne une chaîne d'octets prête à être transmise.
local function EncodeByteTable(uncodedData)
	local StringTable = {}
	local oct = 1     -- Index courant dans StringTable (position d'écriture)

	for i = 1, #uncodedData do
		local num = uncodedData[i][1]  -- Valeur numérique à encoder
		if uncodedData[i][2] == 8 and type(num) == "number" then
			-- Encodage sur 1 octet (0-255)
			StringTable[oct] = string.char(num)
			oct = oct + 1
		elseif uncodedData[i][2] == 16 and type(num) == "number" then
			-- Encodage sur 2 octets (0-65535)
			StringTable[oct]     = string.char(num % 256)             -- Octet 1 de poids faible
			StringTable[oct + 1] = string.char(math.floor(num / 256)) -- Octet 2 de poids fort
			oct = oct + 2
		elseif uncodedData[i][2] == 24 and type(num) == "number" then
			-- Encodage sur 3 octets (0-16777215)
			StringTable[oct]     = string.char(num % 256)                          -- Octet 1 (poids faible)
			StringTable[oct + 1] = string.char(math.floor((num % 65536) / 256))    -- Octet 2 (milieu)
			StringTable[oct + 2] = string.char(math.floor(num / 65536))            -- Octet 3 (poids fort)
			oct = oct + 3
		end
	end
	return table.concat(StringTable)  -- Concatène tous les octets en une seule chaîne binaire
end


-- Décode une chaîne binaire reçue en une table Lua lisible.
-- codedData : chaîne binaire reçue via le réseau
-- Retourne une table { nomChamp = valeur, ... } + un timestamp de réception
local function DecodeStringTable(codedData, dataList)
	local DecodeTable = {}
	local pos = 1  -- Position de lecture courante dans la chaîne binaire

	-- Parcourt la structure de données définie dans LibTG.MobData
	-- pour savoir dans quel ordre et sur combien de bits lire chaque champ
	for i, v in ipairs(dataList) do
		local name   = v[3]   -- Nom du champ (ex: "Mob", "HP", "X"...)
		local nbBits = v[2]   -- Taille en bits du champ

		if nbBits == 8 then
			-- Lecture d'1 octet
			DecodeTable[name] = string.byte(codedData, pos)
			pos = pos + 1
		elseif nbBits == 16 then
			-- Lecture de 2 octets en little-endian : recomposition de la valeur 16 bits
			DecodeTable[name] = (string.byte(codedData, pos + 1) * 256 + string.byte(codedData, pos))
			pos = pos + 2
		elseif nbBits == 24 then
			-- Lecture de 3 octets en little-endian : recomposition de la valeur 24 bits
			DecodeTable[name] = (string.byte(codedData, pos + 2)) * 65536
			                  + (string.byte(codedData, pos + 1)) * 256
			                  + string.byte(codedData, pos)
			pos = pos + 3
		end
	end

	DecodeTable["LastR"] = GetFrameTimeSeconds()  -- Horodatage de la réception (en secondes depuis le lancement)
	return DecodeTable
end



-- ============================================================
-- RÉCEPTION DES DONNÉES
-- ============================================================

-- Appelée automatiquement par LGB quand un membre du groupe envoie ses données de ciblage.
-- unitTag : identifiant du joueur émetteur (ex: "group2")
-- data    : table contenant le champ "SwapingLibTG" (chaîne binaire encodée)
function LibTG:ReceiveData(unitTag, data, dataList)
	LibTG.LastSwapInfo[unitTag] = {}  -- Réinitialise les infos précédentes pour ce joueur
	LibTG.LastSwapInfo[unitTag] = DecodeStringTable(data.SwapingLibTG, dataList)  -- Décode et stocke

	local Swap = LibTG.LastSwapInfo[unitTag]
	local Mob  = Swap["Mob"]  -- Identifiant du mob actuellement ciblé par ce joueur
	
	if dataList == LibTG.PlayerData then
		LibTG.SwapingInfo[unitTag] = LibTG.LastSwapInfo[unitTag]
	end
	
	-- Si ce mob est dans la liste de suivi (SwapingInfo), on met à jour ses données pour ce joueur
	if LibTG.SwapingInfo[Mob] then
		LibTG.SwapingInfo[Mob][unitTag] = LibTG.SwapingInfo[Mob][unitTag] or {}
		for _, v in ipairs(LibTG.MobData) do
			-- Copie chaque champ décodé dans la table de suivi du mob
			LibTG.SwapingInfo[Mob][unitTag][v[3]] = Swap[v[3]]
		end
		LibTG.SwapingInfo[Mob][unitTag]["LastR"] = Swap["LastR"]
	end
end



-- ============================================================
-- ENVOI DES DONNÉES
-- ============================================================

-- Collecte et envoie les données de ciblage du joueur local à son groupe.
-- Déclenché périodiquement ou sur événement (selon LibTG.TargetUpdate).
-- Encode : HP max, HP courant, position (X/Z), angle de caméra, ID du mob ciblé.
function LibTG:SendingTargetData()
	if LibTG.TargetUpdate then
		-- Récupère les HP de la cible actuelle ("reticleover" = cible sous le réticule)
		local current, max = GetUnitPower("reticleover", POWERTYPE_HEALTH)
		LibTG.MobData[1][1] = max / 100      -- HP max (réduit pour tenir en 16 bits si besoin)
		LibTG.MobData[2][1] = current / 100  -- HP courant

		-- Récupère la position monde du joueur local
		local zoneId, x, y, z = GetUnitWorldPosition("player")
		LibTG.MobData[3][1] = x  -- Coordonnée X
		LibTG.MobData[4][1] = z  -- Coordonnée Z (l'axe vertical en TESO est Y, Z est la profondeur)

		-- Convertit le cap de caméra de radians en centièmes de degrés (précision accrue)
		local headingDeg = GetPlayerCameraHeading() * 180 / math.pi
		LibTG.MobData[5][1] = math.floor(headingDeg * 100 + 0.5)  -- Arrondi à 0.01° près

		-- Récupère l'ID du mob ciblé depuis la MobList
		LibTG.MobData[6][1] = LibTG.MobList[GetUnitName("reticleover")]

		if not LibTG.Protocol1 then return end  -- Sécurité : protocole LGB non initialisé
		LibTG.Protocol1:Send({ SwapingLibTG = EncodeByteTable(LibTG.MobData) })  -- Envoi encodé
	end
	
	local currentStamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
	local currentMagicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
	local ultimate = GetUnitPower("player", POWERTYPE_ULTIMATE)
	LibTG.PlayerData[1][1] = ultimate
	LibTG.PlayerData[2][1] = zo_roundToNearest((currentStamina / maxStamina) * 100, 1)
	LibTG.PlayerData[3][1] = zo_roundToNearest((currentMagicka / maxMagicka) * 100, 1)
	
	if not LibTG.Protocol2 then return end  -- Sécurité : protocole LGB non initialisé
	LibTG.Protocol2:Send({ SwapingLibTG = EncodeByteTable(LibTG.PlayerData) })  -- Envoi encodé
	
end




-- ============================================================
-- INITIALISATION DU PROTOCOLE LGB
-- ============================================================

-- Enregistre LibTarget auprès de LibGroupBroadcast et déclare le protocole de communication.
-- Doit être appelé une seule fois à l'initialisation de l'addon.
function LibTG:RegisterLGBHandler()
	if not LGB then return end  -- Sécurité : LGB non disponible (addon manquant ou chargé trop tard)

	-- Enregistrement du handler principal de l'addon auprès de LGB
	LibTG.LGBHandler = LGB:RegisterHandler(LibTG.Name)
	LibTG.LGBHandler:SetDisplayName(LibTG.DisplayName)
	LibTG.LGBHandler:SetDescription("LibTarget Swaping Info")

	-- Déclaration du protocole avec un ID unique et un nom interne
	LibTG.PROTOCOL_ID1 = 132
	LibTG.PROTOCOL_ID2 = 133
	local Protocol1 = LibTG.LGBHandler:DeclareProtocol(LibTG.PROTOCOL_ID1, "LibTargetProtocol1")
	local Protocol2 = LibTG.LGBHandler:DeclareProtocol(LibTG.PROTOCOL_ID2, "LibTargetProtocol2")

	-- Le protocole transporte un seul champ : la chaîne binaire encodée
	Protocol1:AddField(LGB.CreateStringField("SwapingLibTG"))
	Protocol2:AddField(LGB.CreateStringField("SwapingLibTG"))

	-- Callback appelé à chaque réception de données d'un membre du groupe
	Protocol1:OnData(function(unitTag, data) LibTG:ReceiveData(unitTag, data, LibTG.MobData) end)
	Protocol2:OnData(function(unitTag, data) LibTG:ReceiveData(unitTag, data, LibTG.PlayerData) end)

	-- Finalisation avec options :
	-- isRelevantInCombat    : le protocole reste actif en combat
	-- replaceQueuedMessages : un nouveau message remplace l'ancien s'il n'a pas encore été envoyé
	Protocol1:Finalize({
		isRelevantInCombat    = true,
		replaceQueuedMessages = true,
	})
	Protocol2:Finalize({
		isRelevantInCombat    = true,
		replaceQueuedMessages = true,
	})

	LibTG.Protocol1 = Protocol1  -- Stocke la référence pour utilisation dans SendingTargetData
	LibTG.Protocol2 = Protocol2  -- Stocke la référence pour utilisation dans SendingTargetData
end
