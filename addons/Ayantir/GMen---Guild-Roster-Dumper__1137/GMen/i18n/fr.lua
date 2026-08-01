--[[
Author: Ayantir
Filename: fr.lua
Version: 0.1
]]--

GMen = GMen or {}
GMen.lang = {}

GMen.lang.guildToDump = "Guilde à Dump"
GMen.lang.guildToDumpTT = "Sélectionnez la guilde à dumper"
GMen.lang.sortBy1 = "Premier ordre de tri"
GMen.lang.sortBy2 = "Deuxième ordre de tri"
GMen.lang.sortByO1 = "Rang"
GMen.lang.sortByO2 = "Niveau"
GMen.lang.sortByO3 = "UserID"
GMen.lang.format = "Format d'une ligne"
GMen.lang.formatTT = "Utilisez les variables pour définir comment vous voulez afficher une ligne de votre Roster\nUsage:\n%userid% = @UserID\n%character% = Nom du personnage\n%class% = Classe\n%alliance% = Nom de l'alliance\n%level% = Niveau du personnage"
GMen.lang.showClass = "Afficher la classe"
GMen.lang.showClassTT = "Afficher la classe du membre"
GMen.lang.showLevel = "Afficher le niveau"
GMen.lang.showLevelTT = "Affiche le niveau ou le rang vétéran du membre"
GMen.lang.showAlliance = "Afficher l'alliance"
GMen.lang.showAllianceTT = "Afficher l'alliance du membre"
GMen.lang.shortenAlliance = "Raccourcir le nom de l'alliance"
GMen.lang.shortenAllianceTT = "Remplace le nom de l'alliance par [AD], [EP] ou [DC]"
GMen.lang.bbCode = "Ajouter des BB code"
GMen.lang.dumpGuild = "Dump"
GMen.lang.dumpDone = "Dump de la guilde effectué. Merci de faire un ReloadUI (commande |c007FFF/reloadui|r) puis éditer le fichier |c007FFFDocuments/Elder Scrolls Online/live(eu)/SavedVariables/GMen.lua|r en suivant les indications d'édition pour obtenir votre roster :)"
GMen.lang.rankName = "BB Code for Rank Name"
GMen.lang.rankNameTT = "BB Code for Rank Name"
GMen.lang.account = "BB Code for UserID"
GMen.lang.accountTT = "BB Code for UserID"
GMen.lang.character = "BB Code for Character Name"
GMen.lang.characterTT = "BB Code for Character Name"
GMen.lang.className = "BB Code for Class Name"
GMen.lang.classNameTT = "BB Code for Class Name"
GMen.lang.alliance = "BB Code for Alliance Name"
GMen.lang.allianceTT = "BB Code for Alliance Name"
GMen.lang.level = "BB Code for Level"
GMen.lang.levelTT = "BB Code for Level"
GMen.lang.veteranRank = "BB Code for Veteran Rank"
GMen.lang.veteranRankTT = "BB Code for Veteran Rank"
GMen.lang.description = "Comment ça marche ?"
GMen.lang.descriptionTX = "\r\nDans un premier temps, paramétrez vos options, ne supprimez pas le |cEC3B83%s|r, c'est la valeur.\r\nPuis appuyez sur le bouton |cEC3B83Dump|r. Si tout se déroule bien, le chat va s'afficher et vous indiquer de faire un ReloadUI (commande |cEC3B83/reloadui|r) et vous donner le nom de votre fichier où se trouve votre dump.\r\n\r\nLe plus simple est de lancer |cEC3B83Excel|r puis :\r\n\r\n- Ouvrir le fichier\r\n- A l'assistant importation, choisissez |cEC3B83Délimité|r puis Suivant.\r\n- Puis choisissez |cEC3B83Autre|r et en séparateur, inscrivez |cEC3B83\"|r (le double guillements, touche 3)\r\n- Puis |cEC3B83Suivant|r et |cEC3B83Terminer|r\r\n- Copiez la colonne B en totalité.\r\n- Fermez Excel SANS SAUVEGARDER.\r\n- Enfin collez votre texte sur votre site/forum\r\n\r\nN'oubliez pas de supprimer les quelques lignes de configuration de l'addon :)"
GMen.lang.bbCodeH = "BBCode"
GMen.lang.OptionsH = "Options"