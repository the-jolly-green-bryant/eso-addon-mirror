cl.ln = {
    com = {
        resetTxt = "Clock est maintenant réinitialisé.",
        resetUITxt = "Interface Horloge utilisateur est maintenant réinitialisé.",
        resetTimeTxt = "L'horloge est maintenant réinitialisé.",
        usOn = "Le temps est représenté en 12h avec am / pm.",
        usOff = "Le temps est représenté en 24 heures.",
        numOn = "Zeros sont ajoutés.",
        numOff = "chiffres simples sont présentés.",
        secOn = "Les secondes sont affichées.",
        secOff = "Les secondes sont cachés.",
        activeOn = "Clock - TST est allumé.",
        activeOff = "Clock - TST est éteint.",
        moonOn = "La lune est affichée.",
        moonOff = "La lune est cachée.",
        ldateOn = "date de Lore est affiché.",
        ldateOff = "date de Lore est caché.",
        fldateOn = "Date faux Lore est affiché.",
        fldateOff = "Date faux Lore est caché.",
        rtOn = "Real-Time est affiché.",
        rtOff = "Real-Time est caché.",
        dateOn = "La date est affichée.",
        dateOff = "La date est caché.",
        text = "Welcome to the |cFFD700Clock|r - TST by |c5175ea@Tyx|r [EU] help menu\n"
                .. "To show the current database of the times, write:\n"
                .. "\t\cl show\n"
                .. "To set the current time as Tamriel midnight/sunrise/noon/sunset use the appropriate command:\n"
                .. "\t\cl midnight\n\t\cl sunrise\n\t\cl noon\n\t\cl sunset\n"
                .. "To reset the current database, only the look or time to the default values, write:\n"
                .. "\t\cl reset\n\t\cl resetUI\t\cl resetTime\n"
                .. "You can toggle the displayed time formatt (12h/24h) by writing:\n"
                .. "\t\cl us\n"
                .. "To delete the zeros added before a single digit hour, write:\n"
                .. "\t\cl num\n"
                .. "You can toggle to display seconds with the command:\n"
                .. "\t\cl sec\n"
                .. "For showing the current moon phase, write:\n"
                .. "\t\cl moon\n"
                .. "To display the date (lore/fake lore/real), write:\n"
                .. "\t\cl ldate\n\t\cl fldate\t\cl date\n"
                .. "To stop/start the Clock from being moveable, write:\n"
                .. "\t\cl move\n"
                .. "To deactivate/activate the Clock use.\n"
                .. "\t\cl active\n\n"
                .. "To show the settings menu, write:\n"
                .. "\t\clsettings\n",
        moveOn = "Clock est maintenant mobile.",
        moveOff = "Clock est maintenant corrigé."
    },
    gui = {
        lang = "La langue",
        langTxt = "Sélectionnez une langue pour les paramètres et commandes d'horloge.\n Attention: cela va recharger l'interface utilisateur.",
        togOpt = "Activé / Désactivé",
        togOptTxt = "Changer la façon dont l'horloge ressemble.",
        sClock = "Afficher l'horloge",
        sTime = "Afficher l'heure",
        sMove = "Mobile",
        tMove = "Sélectionnez si l'horloge doit être mobile.",
        sAHide = "Masquage automatique",
        tAHide = "Sélectionnez si l'horloge doit être caché quand un menu est ouvert.",
        sFormat = "format 12h",
        sAMPM = "Afficher AM / PM",
        sNum = "Ajouter des zéros",
        tNum = "Ajouter des zéros avant un seul numéro = 01h24 -> 01h24",
        sSec = "Afficher les secondes",
        sMoon = "Afficher la Lune",
        tMoon = "Ajoute une petite icône avec la phase actuelle de la lune et les heures jusqu'à ce que la phase suivante commence.",
        sLDate = "Afficher lore date",
        tLDate = "Ajoute une ligne sous l'horloge avec le jour, le mois et l'année Tamriel.",
        sFLDate = "Montrer faux lore date",
        tFLDate = "Ajoute une ligne sous l'horloge avec le jour, le mois et l'année Tamriel.",
        sRT = "Voir en temps réel",
        tRT = "Ajoute une ligne sous l'horloge avec l'heure de votre système d'exploitation.",
        sDate = "Montrer réelle date",
        tDate = "Ajoute une ligne sous l'horloge avec le jour, le mois et l'année de votre système d'exploitation.",
        nsBg = "Afficher Contexte",
        tsBg = "Ajoute un arrière-plan derrière l'horloge.",
        look = "Regardez les options",
        lookTxt = "Diverses options pour changer la façon dont l'horloge ressemble.",
        nColPick = "Couleur",
        tColPick = "Changer la couleur de l'horloge.",
        nFont = "Police de caractère",
        tFont = "Modifier la police de l'Horloge.",
        nStyle = "style",
        tStyle = "Changer le style de l'horloge.",
        nSize = "Taille",
        tSize = "Modifier la taille de l'horloge.",
        nMoonStyle = "Style de lune",
        tMoonStyle = "Changez le style de l'étiquette de la lune.",
        nMoonSize = "Taille de la lune",
        tMoonSize = "Modifiez la taille du temps affiché à la phase suivante de la lune.",
        nMoonOffsetY = "Y-Décalage de la lune",
        tMoonOffsetY = "Déplacez la lune dans la direction verticale.",
        nSepLR = "Différents Looks",
        tSepLR = "Choisissez si vous voulez que votre date réelle ont un autre regard que votre date de lore.",
        nRColPick = "Couleur",
        tRColPick = "Changer la couleur de l'horloge.",
        nRFont = "Police de caractère",
        tRFont = "Modifier la police de l'Horloge.",
        nRStyle = "style",
        tRStyle = "Changer le style de l'horloge.",
        nRSize = "Taille",
        tRSize = "Modifier la taille de l'horloge.",
        nBg = "Contexte",
        tBg = "Choisissez un fond de l'horloge.",
        sHor = "Horizontal",
        tHor = "Vérifier les lore- et en temps réel à côté de l'autre.",
        descEditLookY = "Modifier le format de l'horloge = Utiliser '_' avant une variable!\n"
                .. "Année mois jour",
        descEditLookYTxt = "Année = Y = 582 (14) YY = 2F 582 (2014)\n"
                .. "Month: M = 4 MM = 04 MMM = First Seed (Avril)\n"
                .. "Day: D = 4 DD = 04 DDD = Fredas (vendredi)",
        descEditLookD = "Heure / Minute / Second",
        descEditLookDTxt = "Heure: h = 9 hh = 09\n"
                .. "Minute: m = 9 mm = 09\n"
                .." Deuxième: s = 9 ss = 09",
        descEditLookE = "Exemple",
        descEditLookETxt = "_DDD, Jour _D de _MMM _YY _hh: _mm: _ss\n"
                .. " Fredas, 4ème jour de First Seed 2F 582\n"
                .. " Vendredi 4ème jour d'Avril 2014",
        nELore = "Format Lore-temps",
        tELore = "Écrivez le format de l'heure pour le temps de tradition ici.",
        nEReal = "Format temps réel",
        tEReal = "Wirte le format de temps pour le temps réel ici.",
        day = "Sync [Day]",
        dayTxt = "Ajuster la longueur d'un jour à votre goût.",
        descDB = "Sync [Minuit / Sunrise / Noon / Sunset]",
        descDBTxt = "Synchronisez l'heure de l'horloge.\nPar exemple. sélectionnez midi quand le soleil est juste sous l'aiguille du Sud de la boussole.",
        nMid = "Minuit est maintenant!",
        tMid = "Sélectionnez cette option si la Lune est à son point le plus haut.",
        nRise = "Sunrise est maintenant!",
        tRise = "Déconseillé! Sunrise est pas vraiment clair. Travailler avec midi!",
        nNoon = "Noon est maintenant!",
        tNoon = "Sélectionnez cette option si le soleil est juste sous l'aiguille au sud de votre boussole.",
        nSet = "Sunset est maintenant!",
        tSet = "Déconseillé! Sunset est pas vraiment clair. Travailler avec midi!",
        descDS = "Sync [longueur du jour]",
        descDSTxt = "Synchroniser la photopériode de l'Horloge.",
        nDayH = "Heures",
        tDayH = "Combien de temps dure un jour dernier dans de vraies heures de temps dans le jeu.",
        nDayM = "Minutes",
        tDayM = "Combien de temps dure un jour dernier dans de vraies minutes de temps dans le jeu.",
        nDayS = "secondes",
        tDayS = "Combien de temps dure un jour dernier en secondes réelles de temps dans le jeu.",
        nAplyData = "Calculer",
        tAplyData = "Calcule l'heure actuelle dans Tamriel en fonction de la durée du jour sélectionnée et votre synchronisation (ou par défaut) l'heure de début.",
        moon = "Sync [Moon]",
        moonTxt = "Régler le début de cette phase de lune et la longueur de la première phase de l'humeur à votre goût.",
        nFull = "La pleine lune est maintenant!",
        tFull = "Sélectionnez ce au début de la phase de pleine lune.",
        nNew = "Nouvelle lune est maintenant!",
        tNew = "Sélectionnez ce au début de la nouvelle PHAST de lune.",
        descMS = "Sync [Moon]",
        descMSTxt = "Synchronisez la phase de lune de l'Horloge.\nNe que le tout début d'une phase.",
        descMoon = "Sync [longueur de phase]",
        descMoonTxt = "Vous avez seulement besoin de synchroniser l'horloge soit pour le début de la lune plein ou nouvelle et une seule fois.\n$ Une phase de pleine lune est de 30 jours ingame. Les Sliders follwing sont ici pour sélectionner le pourcentage d'une phase.",
        nNightF = "pourcentage de phase pleine lune",
        tNightF = "Sélectionnez la durée de la phase de pleine lune dernier.",
        nNightW = "Waning / Epilation phase de lune en jours",
        tNightW = "Sélectionnez la durée de la / Epilation phase de lune gibbeuse dernier.",
        nNightN = "Nouvelle phase de lune en jours",
        tNightN = "Sélectionnez la durée de la phase de la lune Nouvelle dernière.",
        nAplyMoon = "Calculer",
        tAplyMoon = "Calcule la phase actuelle de la lune sur la base des longueurs choisies et votre synchronisation (ou par défaut) l'heure de début.",
        reset = "Réinitialiser les options",
        resetTxt = "Divers option pour réinitialiser la totalité ou seulement une partie de l'horloge.",
        nResFull = "Tout recommencer",
        tResFull = "Remet tout pour les valeurs par défaut.",
        wResFull = "Cela remplacera toutes vos valeurs personnalisées avec ceux par défaut!\nRechargera l'interface utilisateur!",
        nResUI = "Réinitialiser l'interface utilisateur",
        tResUI = "Remet le look et le lieu de l'horloge aux valeurs par défaut.",
        wResUI = "Cela remplacera toutes vos personnalisations de l'interface utilisateur avec les valeurs par défaut!",
        nResTime = "Réinitialiser le temps",
        tResTime = "Remet vos synchronisations personnalisées et des longueurs de l'horloge aux valeurs par défaut.",
        wResTime = "Cela remplacera toutes vos personnalisations à l'heure avec les valeurs par défaut!\nRechargera l'interface utilisateur!",
        sJap = "Afficher midngiht comme 0",
        nDeprecated = "Outdated version ",
        tDeprecated = "This is an outdated version of Clock.\n"
                .. "Most likely it will still work for a very long time, but I will not update it anymore.\n"
                .. "However, I wrote a whole new version from scratch, which is nicer and eats less power.",
    },
    vi = {
        dbTS = {
            [1] = "minuit suivante (0 =00 TST) est à",
            [2] = "lever de soleil suivant (4 =00 TST) est à",
            [3] = "midi suivant (12 =00 TST) est à",
            [4] = "coucher de soleil suivant (20 =00 TST) est à",
            [5] = "Une journée est",
            [6] = "longue\n"
        },
        date = {
            first = "st",
            second = "Dakota du Nord",
            third = "rd",
            allNum = "e",
            lore = {
                week = {
                    [1] = "Morndas",
                    [2] = "Tirdas",
                    [3] = "Middas",
                    [4] = "Turdas",
                    [5] = "Fredas",
                    [6] = "Loredas",
                    [7] = "Sundas"
                },
                months = {
                    [1] = "Primétoile",
                    [2] = "Clairciel",
                    [3] = "Semailles",
                    [4] = "Ondepluie",
                    [5] = "Plantaison",
                    [6] = "Mi-L´an",
                    [7] = "Hautzénith",
                    [8] = "Vifâzur",
                    [9] = "Âtrefeu",
                    [10] = "Soufflegivre",
                    [11] = "Ombreciel",
                    [12] = "Soirétoile"
                },
                year = "2F"
            },
            real = {
                week = {
                    [1] = "Lundi",
                    [2] = "Mardi",
                    [3] = "Mercredi",
                    [4] = "Jeudi",
                    [5] = "Vendredi",
                    [6] = "samedi",
                    [7] = "dimanche"
                },
                months = {
                    [1] = "janvier",
                    [2] = "février",
                    [3] = "Mars",
                    [4] = "avril",
                    [5] = "Mai",
                    [6] = "juin",
                    [7] = "juillet",
                    [8] = "août",
                    [9] = "septembre",
                    [10] = "octobre",
                    [11] = "novembre",
                    [12] = "décembre"
                }
            }
        }
    }
}