TTDungeon = TTDungeon or {}

-------------------------------------------------------------------------------
-- BASIS-VERLIESE (OHNE DLC) - DEUTSCH
-------------------------------------------------------------------------------
TTDungeon.BaseDungeonInfo_de = {
    
----------------------------------------------------------------------------
-- 1) Verbannungszellen I (zoneId=380)
----------------------------------------------------------------------------
[380] = {
    normalId = 4,
    vetId    = 20,
    zoneId   = 380,
    sets     = {265,197,110,295,170},
    questID  = 4107,
    HM       = 1554,
    SR       = 1552,
    ND       = 1553,
    TR       = nil,
    name     = "Verbannungszellen I",
    bosses = {
        {
            name = "Zellenhäscher",
            mechanics = {
                "Alle 15-20 Sekunden kanalisiert der Boss einen grünen Strahl, um die Gesundheit eines Spielers abzusaugen (kann nicht geblockt oder unterbrochen werden) (|c00FF00HEILEN|r) :contentReference[oaicite:0]{index=0}",
                "Feuert ein einfaches magisches Projektil auf einen Spieler für geringen Schaden (kann nicht vermieden werden) (|cFFFFFFKEINE AKTION|r) :contentReference[oaicite:1]{index=1}",
                "Beschwört einen beweglichen Frosttornado, der eine schädigende Eisspur hinterlässt (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:2]{index=2}",
            },
        },
        {
            name = "Schattenriss",
            mechanics = {
                "Schwingt seinen Schwanz in einem 360-Grad-AoE, verursacht hohen Schaden und eine kurze Betäubung (|cFF0000AUSWEICHEN oder BLOCKEN|r) :contentReference[oaicite:3]{index=3}",
                "Beschwört einen schattenhaften Klon mit wenig Leben, der die Gruppe angreift (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:4]{index=4}",
                "Springt auf einen entfernten Spieler, fesselt ihn und entzieht ihm Leben, um sich selbst zu heilen (|cFF7F00UNTERBRECHEN|r oder |c00FFFFBEFREIEN|r) :contentReference[oaicite:5]{index=5}",
            },
        },
        {
            name = "Angata die Clannbann-Handlerin",
            mechanics = {
                "Beginnt mit vielen Skelett-Adds (einschließlich Kryomanten), die sie umgeben (|cFFD700ADDS ZUERST TÖTEN|r) :contentReference[oaicite:6]{index=6}",
                "Schleudert einen einfachen Feuerball auf einen Spieler für moderaten Schaden (|cFFFFFFKEINE AKTION|r, wenn getankt) :contentReference[oaicite:7]{index=7}",
                "Kanalisiert eine Feuerwelle nach vorne, die hohen Schaden in einer Linie verursacht (|cFF7F00UNTERBRECHEN|r oder |cFF0000AUSWEICHEN|r) :contentReference[oaicite:8]{index=8}",
                "Beschwört zwei feurige Runenkreise auf dem Boden, die Schaden über Zeit verursachen (|cFFA500VERMEIDEN|r) :contentReference[oaicite:9]{index=9}",
                "Beschwört alle ~10s einen Clannbann zur Unterstützung (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:10]{index=10}",
            },
        },
        {
            name = "Skelettzerstörer",
            mechanics = {
                "Beginnt den Kampf mit vier Skampen-Adds, die sofort angreifen (|cFFD700ADDS ZUERST TÖTEN|r) :contentReference[oaicite:11]{index=11}",
                "Beschwört regelmäßig drei Skelette, die sich selbst zerstören, wenn sie nicht schnell getötet werden (|cFFD700SOFORT TÖTEN|r) :contentReference[oaicite:12]{index=12}",
                "Schlägt auf den Boden und erzeugt einen kleinen roten Kreis-AoE mit kontinuierlichem Schaden (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:13]{index=13}",
                "Holt zu einem Frontalangriff aus, angezeigt durch einen roten Telegrafen (|cFF0000BLOCKEN|r oder dahinter bleiben) :contentReference[oaicite:14]{index=14}",
            },
        },
        {
            name = "Hochedler Fürst Rilis",
            mechanics = {
                "Führt einen schweren Nahkampftreffer aus, der hohen Schaden verursacht und niederschlägt (|cFF0000BLOCKEN|r) :contentReference[oaicite:15]{index=15}",
                "Feuert ein magisches Projektil auf einen zufälligen Spieler, das hohen Schaden und Rückstoß verursacht (|cFF0000BLOCKEN|r oder |cFF0000AUSWEICHEN|r) :contentReference[oaicite:16]{index=16}",
                "Beschwört Pfützen aus blauem Geisterfeuer unter jedem Spieler, die schweren DoT verursachen (|cFFA500BEWEGEN|r) :contentReference[oaicite:17]{index=17}",
                "Erschafft regelmäßig zwei Kugeln, die auf ihn zuschweben und ihn bei Kontakt heilen (|cFF00FFZERSTÖREN|r) :contentReference[oaicite:18]{index=18}",
            },
        },
    },
},

    ----------------------------------------------------------------------------
    -- 2) Verbannungszellen II (zoneId=935)
    ----------------------------------------------------------------------------
    [935] = {
        normalId = 300,
        vetId    = 301,
        zoneId   = 935,
        sets     = {265,197,110,295,170},
        questID  = 4597,
        HM       = 451,
        SR       = 449,
        ND       = 1564,
        TR       = nil,
        name     = "Verbannungszellen II",
        bosses = {
            {
                name = "Hüter Areldur",
                mechanics = {
                    "Kommt mit zwei Flammenatronachen, die beim Tod explodieren (|cFFD700ADDS SCHNELL TÖTEN|r; nicht in ihrer Nähe stehen bei 0% – |cFF0000EXPLOSION VERMEIDEN|r) :contentReference[oaicite:0]{index=0}",
                    "Alle ~10 Sekunden hebt er den Stab, um einen mörserartigen Flammen-AoE abzufeuern, der einen kleinen brennenden Fleck hinterlässt (nicht blockbar) (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:1]{index=1}",
                    "Kanalisiert ein rotierendes 'Flammenrad', das sich nach außen ausbreitet; das Betreten verursacht tödlichen Schaden (nicht unterbrechbar) (|cFF0000BEWEGEN oder ROLLEN|r) :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Schlund des Infernalen",
                mechanics = {
                    "Entfesselt zufällig einen Flammenatem in einem breiten Kegel, der hohen Schaden verursacht (|cFF0000BLOCKEN|r oder |cFF0000AUSWEICHEN|r). Kann nicht unterbrochen werden. :contentReference[oaicite:3]{index=3}",
                    "Einäschernder Biss betäubt das aktuelle Ziel und verursacht einen DoT, der alle 2s permanente Feuerflecken hinterlässt (nicht reinigbar) (|c00FF00HEILEN|r & möglichst still bleiben) :contentReference[oaicite:4]{index=4}",
                    "Ein einfacher Hieb folgt dem Biss – blocken, um Schaden zu reduzieren, kann niederschlagen, wenn nicht geblockt (|cFF0000BLOCKEN|r) :contentReference[oaicite:5]{index=5}",
                    "Umgebungs-Feuerfalle nahe dem Eingang kann den Boss schwer schädigen, wenn man ihn darauf lockt (|cFFD700UMGEBUNG NUTZEN|r) :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Hüter Voranil",
                mechanics = {
                    "Beginnt mit zwei Daedra-Adds – zuerst auf sie konzentrieren, um Überwältigung zu verhindern (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:7]{index=7}",
                    "Schwerer Angriff, der geblockt werden muss, sonst kann er tödlich sein (|cFF0000BLOCKEN|r) :contentReference[oaicite:8]{index=8}",
                    "Führt einen Wirbelwind-AoE um sich herum aus – kann nicht unterbrochen werden (|cFF0000AUSWEICHEN|r oder zurückweichen) :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Hüterin Imiril",
                mechanics = {
                    "Alle ~25s teleportiert sie sich in eine blaue Kugel und beschwört Add-Wellen (Banekin, Zwielicht, Clannbann im Wechsel). (|cFFD700ADDS SCHNELL TÖTEN|r, bevor sie zurückkehrt) :contentReference[oaicite:10]{index=10}",
                    "Beim Wiedererscheinen löst sie eine große AoE-Explosion aus – kann nicht unterbrochen werden (|cFF0000BLOCKEN|r oder |cFF0000AUSWEICHEN|r) :contentReference[oaicite:11]{index=11}",
                    "Blaue Illusionen/Kugeln hüpfen durch die Arena und verursachen bei Kontakt Schaden (nicht blockbar) (|cFFA500VERMEIDEN|r) :contentReference[oaicite:12]{index=12}",
                    "Tank: Halte sie in der Mitte, um Chaos zu begrenzen; koordiniere schnellen AoE, um jede Add-Phase zu säubern. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Schwester Vera & Schwester Sihna",
                mechanics = {
                    "Beide sind Fernkampf-Harvester; erschaffen 'Feste' (Heilkugeln), die auf sie zufliegen – töte diese Kugeln schnell (|cFFD700KUGELN ZERSTÖREN|r) :contentReference[oaicite:14]{index=14}",
                    "Schildern sich gelegentlich gegenseitig mit einem starken Schadenschild (nicht reinigbar) – konzentriere dich auf die ungeschützte Schwester (|cFFD700ZIEL WECHSELN|r) :contentReference[oaicite:15]{index=15}",
                    "Sie kanalisieren einen frontalen AoE-Rückstoß; er kann unterbrochen werden (|cFF7F00UNTERBRECHEN|r) oder du musst dich entfernen, um schweren Schaden zu vermeiden :contentReference[oaicite:16]{index=16}",
                    "Tank: Nutze Sichtlinien (z.B. hinter Säulen), um sie für Gruppen-AoE-Schaden zusammenzuziehen. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Hochedler Fürst Rilis",
                mechanics = {
                    "Hauptsächlich Fernkampf, beschwört Daedroth und 'Fest'-Kugeln, die ihn heilen, wenn sie nicht zerstört werden (|cFFD700KUGELN SCHNELL TÖTEN|r) :contentReference[oaicite:18]{index=18}",
                    "Levitationsblase verflucht einen zufälligen Spieler rot/blau (nicht blockbar/unterbrechbar). Finde die passende Farbrune zur Reinigung (|c00FFFFFARBE ABGLEICHEN|r) :contentReference[oaicite:19]{index=19}",
                    "Wiederholte Blitzstabtreffer auf das Ziel, wenn verspottet; kann Nicht-Tanks in ~2 Treffern töten (|cFF0000BLOCKEN|r empfohlen) :contentReference[oaicite:20]{index=20}",
                    "Lässt große Flammen-AoEs dort fallen, wo Spieler stehen; diese bleiben bestehen und stapeln sich (|cFF0000BEWEGEN|r). Daedroth können Spieler auch fesseln – befreien oder blocken. :contentReference[oaicite:21]{index=21}",
                    "Herausforderer: Besiege Rilis, während noch drei Daedroth am Leben sind. Stoppe DPS bei niedriger Boss-HP, bis der dritte Daedroth erscheint (|cFFD700Herausforderer Bedingung|r) :contentReference[oaicite:22]{index=22}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 3) Pilzgrotte I (zoneId=283)
    ----------------------------------------------------------------------------
    [283] = {
        normalId = 2,
        vetId    = 299,
        zoneId   = 283,
        sets     = {266,162,33,61,297},
        questID  = 3993,
        HM       = 1561,
        SR       = 1559,
        ND       = 1560,
        TR       = nil,
        name     = "Pilzgrotte I",
        bosses = {
            {
                name = "Tazkad der Rudelführer",
                mechanics = {
                    "Kommt mit mehreren Goblins und Durzogs (|cFFD700ADDS ZUERST TÖTEN|r, wenn möglich) :contentReference[oaicite:0]{index=0}",
                    "Wirkt |cFF0000Agonie|r (ähnlich der Nachtklingen-Fähigkeit) auf den Tank, betäubt ihn kurz (kann |cFF7F00UNTERBROCHEN|r oder |c00FFFFBEFREIT|r werden) :contentReference[oaicite:1]{index=1}",
                    "Benutzt |cFF0000Blutwahn|r, einen schwachen DoT auf den Aggro-Halter (kann nicht vermieden werden). Heiler sollte darauf bei fragilen Zielen achten. :contentReference[oaicite:2]{index=2}",
                    "Schlagraserei: Ein Kegelangriff, der den Tank mehrmals trifft – blocken oder hinter dem Boss bleiben (|cFF0000BLOCKEN|r empfohlen, wenn anvisiert) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Kriegshäuptling Ozazai",
                mechanics = {
                    "Beginnt mit zwei Trübmoor-Kriegswachen, die eine DK-Standarte fallen lassen und Schildlauf verwenden (|cFFD700ADDS ZUERST TÖTEN|r). :contentReference[oaicite:4]{index=4}",
                    "Eröffnet mit |cFF0000Schockangriff|r, indem er auf ein Ziel springt und beim Aufprall AoE-Schaden verursacht (kann nicht unterbrochen werden). :contentReference[oaicite:5]{index=5}",
                    "Schwerer Angriff (|cFF0000Heumacher|r): muss geblockt werden, sonst schlägt er das Ziel nieder (|cFF0000BLOCKEN|r). :contentReference[oaicite:6]{index=6}",
                    "Wirkt regelmäßig |cFF0000Daedrischer Schlag|r (roter Strahl auf einen Spieler), erzeugt einen wachsenden roten AoE, der explodiert – von der Gruppe wegbewegen oder Gruppe weicht aus (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:7]{index=7}",
                    "Unter ~30% HP verwendet er |cFF0000Taumelndes Gebrüll|r, verursacht moderaten physischen AoE-Schaden. Fernkämpfer können außer Reichweite gehen; Nahkämpfer sollten blocken oder heraustreten (|cFF0000BLOCKEN oder BEWEGEN|r). :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Brutmutter",
                mechanics = {
                    "Kommt mit zwei Dreugh-Adds; konzentriere dich zuerst auf sie oder nutze AoE, um alle auf einmal zu erledigen (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:9]{index=9}",
                    "Zieht zufällig einen Spieler zum Boss (kann nicht geblockt werden) (|c00FFFFBEFREIEN|r, wenn betäubt). :contentReference[oaicite:10]{index=10}",
                    "Kanalisiert |cFF0000Schockendes Reißen|r, einen frontalen Kegelblitzangriff – Tank sollte Boss wegdrehen; Gruppe steht dahinter (|cFF0000BLOCKEN|r als Tank, oder |cFF0000VERMEIDEN|r). :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Klapper-Klaue",
                mechanics = {
                    "Eine riesige Schlammkrabbe, die alle ~10s ~8-10 kleinere Schlammkrabben beschwört (|cFFD700SCHNELL TÖTEN|r mit AoE). :contentReference[oaicite:12]{index=12}",
                    "Verwendet meist einfache schwere Angriffe; blocken oder ausweichen, wenn anvisiert. :contentReference[oaicite:13]{index=13}",
                    "Vermeide Herumlaufen, wenn Adds dich verfolgen – bleibe in Heilreichweite und lass AoE / Tank sie erledigen. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Kra’gh der Dreughkönig",
                mechanics = {
                    "Führt einen starken schweren Angriff (|cFF0000Ausfallschritt|r) aus, der geblockt werden muss, sonst wirst du weggeschleudert (|cFF0000BLOCKEN|r). :contentReference[oaicite:15]{index=15}",
                    "Benutzt |cFF0000Sturmfurie|r – eine schnelle Blitzkombination auf den Tank (kann nicht unterbrochen werden). Blocken empfohlen; tödlich für Nicht-Tanks. :contentReference[oaicite:16]{index=16}",
                    "Erschafft gelegentlich einige Schlammkrabben – leicht mit AoE zu töten, aber nicht weglaufen. :contentReference[oaicite:17]{index=17}",
                    "Kanalisiert ein großes |cFF0000Blitzfeld|r, das sich nach außen ausbreitet – explodiert bei maximaler Größe (kann Nicht-Tanks töten). (|cFF0000RAUSBEWEGEN|r) :contentReference[oaicite:18]{index=18}",
                    "Herausforderer erhöht nur Leben/Schaden ohne zusätzliche Mechaniken. Achte auf das Blitzfeld und halte Blocks aufrecht. :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 4) Pilzgrotte II (zoneId=934)
    ----------------------------------------------------------------------------
    [934] = {
        normalId = 18,
        vetId    = 312,
        zoneId   = 934,
        sets     = {266,162,33,61,297},
        questID  = 4303,
        HM       = 342,
        SR       = 340,
        ND       = 1563,
        TR       = nil,
        name     = "Pilzgrotte II",
        bosses = {
            {
                name = "Mephalas Giftzahn",
                mechanics = {
                    "Beginnt mit zwei Heiler-Adds – konzentriere dich zuerst auf sie, sonst heilen sie den Boss (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:0]{index=0}",
                    "Schwerer Angriff: Muss geblockt werden, sonst wird das Ziel niedergeschlagen (|cFF0000BLOCKEN|r) :contentReference[oaicite:1]{index=1}",
                    "Versprüht Gift in einem frontalen Kegel (|cFF7F00UNTERBRECHEN|r, wenn möglich, oder |cFF0000AUSWEICHEN|r) :contentReference[oaicite:2]{index=2}",
                    "Vergiftet die Füße eines zufälligen Spielers, hinterlässt einen DoT-Kreis, der bestehen bleibt – schnell herausbewegen & diese zusammenstapeln, um die Arena nicht zu bedecken (|cFF0000BEWEGEN|r) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Gamyne Bandu",
                mechanics = {
                    "Schwerer Angriff (|cFF0000Ripper|r), der hohen Schaden verursacht – blocken oder zurückgestoßen werden (|cFF0000BLOCKEN|r) :contentReference[oaicite:4]{index=4}",
                    "Kettet zufällig zwei Spieler mit einer dunklen Fessel aneinander – lauft in entgegengesetzte Richtungen, um sie zu brechen (|cFF0000VERTEILEN|r) :contentReference[oaicite:5]{index=5}",
                    "Beschwört vier Schatten, die einen einzelnen Spieler mit einem Dorn gefangen nehmen. Das Töten EINES beliebigen Schattens bricht die Kette & rettet ihn (|cFFD700EINEN SCHATTEN FOKUSSIEREN|r) :contentReference[oaicite:6]{index=6}",
                    "Teilt sich in vier Obsidianaspekte auf – töte sie alle, um ihre Rückkehr zu erzwingen. Sie kann nach dem Wiedererscheinen mit einem schweren Treffer eröffnen (|cFF0000BLOCKEN|r) :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Ciirenas die Schäferin",
                mechanics = {
                    "Drei Spinnen begleiten sie – töte sie NICHT, sonst erhält der Boss massive Schadensreduktion. :contentReference[oaicite:8]{index=8}",
                    "Markiert einen zufälligen Spieler mit Pheromonen, wodurch Spinnen ihn jagen – leite sie von der Gruppe weg (|cFFA500VERMEIDE es, sie zu töten|r) :contentReference[oaicite:9]{index=9}",
                    "Wirkt wiederholt Dunklen Blitz oder Schattenblitz, typischerweise auf zufällige Gruppenmitglieder (|cFF7F00UNTERBRECHEN|r, um eingehenden Schaden zu reduzieren) :contentReference[oaicite:10]{index=10}",
                    "Wenn sie nahe an eine Klippenkante oder Säule gedrängt wird, kann sie zurücksetzen – Tank sollte einen Fernkampf-Spott bereithalten, um sie festzuhalten. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Brut von Mephala",
                mechanics = {
                    "Beschwört ein Portal nahe der Höhlenwand – der nächste Spieler wird hineingezogen, um zusätzliche Spinnen zu bekämpfen. Sie verlassen es automatisch bei ~10% Boss-HP oder durch Töten der Spinnen. :contentReference[oaicite:12]{index=12}",
                    "Großer roter AoE breitet sich vom Boss aus – detoniert mit hohem Schaden und Niederschlag (|cFF0000BEWEGEN|r). :contentReference[oaicite:13]{index=13}",
                    "Erzeugt einen langsam bewegenden Strahl von Altären, der einen Spieler verfolgt – kann ausgewichen oder vom Tank absorbiert werden (|cFF0000AUSWEICHEN|r). :contentReference[oaicite:14]{index=14}",
                    "Zufälliger Schattenblitz stößt Spieler beim Aufprall zurück – Ausweichrolle oder blocken, wenn möglich (|cFF0000BLOCKEN|r empfohlen). :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Reggr Dunkelmorgen",
                mechanics = {
                    "Benutzt |cFF0000Kugel der Entkräftung|r, die Magicka von der Gruppe entzieht – warte mit Tränken, bis es endet. :contentReference[oaicite:16]{index=16}",
                    "Schwerer Angriff, der geblockt werden muss, sonst kann er einen Nicht-Tank sofort töten (|cFF0000BLOCKEN|r). :contentReference[oaicite:17]{index=17}",
                    "Raserei-AoE: Wirbelt Waffe in einem kleinen Kreis – heraustreten oder blocken (|cFF0000AUSWEICHEN|r oder |cFF0000BLOCKEN|r). :contentReference[oaicite:18]{index=18}",
                    "Zahlreiche Adds im Raum (Obsidiankrieger). Räume sie sicher oder snipe den Boss von oben. :contentReference[oaicite:19]{index=19}",
                },
            },
            {
                name = "Vila Theran",
                mechanics = {
                    "Wirkt Schattenblitz aus der Ferne – sie bewegt sich nicht, es sei denn, sie wird aus der Wirkreichweite gezwungen. (Tank kann sie durch Distanz neu positionieren) :contentReference[oaicite:20]{index=20}",
                    "Wachsende Verderbnis: Teleportiert zu mehreren Spielern und hinterlässt expandierende schwarze AoEs – Gruppe sammelt sich, bewegt sich dann als Einheit (|cFF0000BEWEGEN|r) :contentReference[oaicite:21]{index=21}",
                    "Kanalisiert einen hochschädigenden Schatten-AoE (Kanalisierter Schatten oder Laser). Heiler kann mildern oder Gruppe kann Schutzschild-Punkte nutzen, falls verfügbar. :contentReference[oaicite:22]{index=22}",
                    "Herausforderer erhöht typischerweise Schaden/Leben, aber keine neuen Mechaniken – achte auf hohen DoT und AoE-Überlappung. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 5) Spindeltiefen I (zoneId=144)
    ----------------------------------------------------------------------------
    [144] = {
        normalId = 3,
        vetId    = 315,
        zoneId   = 144,
        sets     = {163,267,296,55,35},
        questID  = 4054,
        HM       = 1570,
        SR       = 1568,
        ND       = 1569,
        TR       = nil,
        name     = "Spindeltiefen I",
        bosses = {
            {
                name = "Spindelbrut",
                mechanics = {
                    "Beschwört regelmäßig kleine Spinnen-Adds, die Gift spucken oder Netze legen (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:0]{index=0}",
                    "Verschlingt tote Spinnen, um sich zu heilen, wenn nicht unterbrochen – achte auf die Fressanimation (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:1]{index=1}",
                    "Einfaches Giftspucken & leichte Angriffe können geblockt oder gegengeheilt werden (|cFF0000BLOCKEN|r, wenn anvisiert) :contentReference[oaicite:2]{index=2}",
                    "Tank: Halte den Boss an Ort und Stelle, sammle Spinnen-Adds für AoE. DPS stehen hinter dem Boss. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Schwarmmutter",
                mechanics = {
                    "Beschwört zusätzliche Spinnen – halte sie verspottet oder töte sie schnell mit AoE (|cFFD700ADDS BESEITIGEN|r) :contentReference[oaicite:4]{index=4}",
                    "Schwerer Angriff: Richtet sich auf und schlägt auf das Ziel ein – muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r) :contentReference[oaicite:5]{index=5}",
                    "Springt gelegentlich auf einen entfernten Spieler und verursacht hohen Schaden beim Aufprall (|cFF0000AUSWEICHEN|r oder |cFF0000BLOCKEN|r, wenn anvisiert) :contentReference[oaicite:6]{index=6}",
                    "Tank: Halte den Boss weggedreht; Gruppe sollte sich nahe am Boss sammeln, um Sprünge zu begrenzen. :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Cerise die Witwenmacherin",
                mechanics = {
                    "Umgeben von mehreren korrumpierten Kriegergilden-Adds (|cFFD700ADDS ZUERST TÖTEN|r oder mit AoE erledigen) :contentReference[oaicite:8]{index=8}",
                    "Schwerer Angriff, der einen Nicht-Tank töten kann, wenn nicht geblockt (|cFF0000BLOCKEN|r) :contentReference[oaicite:9]{index=9}",
                    "Kanalisiert eine Festhalt-/Betäubungsfähigkeit – kann unterbrochen (|cFF7F00UNTERBRECHEN|r) oder befreit werden, wenn getroffen (|c00FFFFBEFREIEN|r) :contentReference[oaicite:10]{index=10}",
                    "Schnelle Schläge wie 'Schneller Stoß' auf den Tank – blocken, um eingehenden Schaden zu reduzieren (|cFF0000BLOCKEN|r empfohlen). :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Großer Rabbu",
                mechanics = {
                    "Begleitet von mehreren korrumpierten Kriegergilden-Adds – konzentriere dich zuerst auf sie, wenn nötig (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:12]{index=12}",
                    "Führt einen auffälligen |cFF0000Ansturm|r aus, angezeigt durch einen roten Streifen auf dem Boden – |cFF0000AUSWEICHEN|r oder blocken, um Niederschlag zu vermeiden :contentReference[oaicite:13]{index=13}",
                    "Kettet gelegentlich einen zufälligen Spieler an sich – sofort blocken, um große Treffer zu vermeiden (|cFF0000BLOCKEN|r) :contentReference[oaicite:14]{index=14}",
                    "Tank: Halte Rabbu weggedreht, sammle Adds in seiner Nähe für effizienten AoE. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Die Flüsterin",
                mechanics = {
                    "Eine riesige Spinnendaedra – ziehe & töte umgebende Adds, bevor du angreifst. :contentReference[oaicite:16]{index=16}",
                    "Netz ziehen: Zieht Spieler zu sich, oft gefolgt von einer Daedrischen Explosions-AoE – schnell herausbewegen (|cFF0000BEWEGEN|r) :contentReference[oaicite:17]{index=17}",
                    "Arachnophobie: Feuert ein tödliches Projektil auf einen zufälligen Spieler – muss ausgewichen werden, sonst kann es betäuben/töten (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:18]{index=18}",
                    "Aufspießen: Einfacher schwerer Nahkampftreffer auf den Tank – blockbar (|cFF0000BLOCKEN|r) :contentReference[oaicite:19]{index=19}",
                    "Herausforderer: Erhöht ihr Leben und ihren Schaden; gleiche Mechaniken, also AoEs & Projektile vermeiden. :contentReference[oaicite:20]{index=20}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 6) Spindeltiefen II (zoneId=936)
    ----------------------------------------------------------------------------
    [936] = {
        normalId = 316,
        vetId    = 19,
        zoneId   = 936,
        sets     = {163,267,296,55,35},
        questID  = 4555,
        HM       = 448,
        SR       = 446,
        ND       = 1572,
        TR       = nil,
        name     = "Spindeltiefen II",
        bosses = {
            {
                name = "Verrückter Mortine",
                mechanics = {
                    "Kommt mit vielen Blutalb-Adds – |cFFD700ADDS ZUERST TÖTEN|r oder für AoE gruppieren. Nicht herumlaufen. :contentReference[oaicite:0]{index=0}",
                    "Sturmlauf: Schnelle Nahkampftreffer auf den Tank über ~2s – durchgehend blocken oder hohen Schaden erleiden (|cFF0000BLOCKEN|r). :contentReference[oaicite:1]{index=1}",
                    "Sprungangriff: Boss springt im Nahbereich nach oben und schlägt hart auf – (|cFF0000BLOCKEN|r, wenn du Aggro hast). :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Blutbrut",
                mechanics = {
                    "Schwerer Angriff (Zerschmettern): Muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r). :contentReference[oaicite:3]{index=3}",
                    "Höhleneinsturz: Schlägt regelmäßig auf den Boden – der innere Bereich wird in 3 Ticks bombardiert, blocken/durchheilen, wenn du bleibst. :contentReference[oaicite:4]{index=4}",
                    "Brechende Felsen: Äußere Ränder füllen sich mit fallenden Steinen – weiche ihnen aus, sonst ist es sofortiger Tod (|cFF0000BEWEGEN|r von den Rändern weg). :contentReference[oaicite:5]{index=5}",
                    "Wutanfall nach ~2 Minuten: Spammt AoE + unaufhaltsamen Schaden (sehr tödlich). Bringe Boss vor dem Wutanfall auf ~10% runter. :contentReference[oaicite:6]{index=6}",
                    "Hinweis: Dieser Boss |cFFD700kann übersprungen werden|r, indem man am rechten Rand des Raumes entlangläuft, falls gewünscht. :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Praxin Douare",
                mechanics = {
                    "Wellen: 4 Add-Phasen (Spinnen, Schwarmmutter, Rabbu + Cerise, Flüsterin). Boss ist unverwundbar, bis Wellen besiegt sind oder Zeit vergeht. :contentReference[oaicite:8]{index=8}",
                    "Quälender Ring: Zufälliger Spieler erhält einen roten Ring – |cFF0000ÜBERSCHREITE NICHT die Ringgrenze|r, sonst ist es sofortiger Tod. Wer drin ist, bleibt drin, wer draußen ist, bleibt draußen. :contentReference[oaicite:9]{index=9}",
                    "Frontaler Dreizackstoß: Boss kanalisiert langsamen 3-Linien-AoE nach vorne – drehe ihn von der Gruppe weg (|cFF0000BLOCKEN|r oder zur Seite treten). :contentReference[oaicite:10]{index=10}",
                    "Entzug: Zufälligem Spieler werden Ressourcen entzogen, wenn nicht ausgewichen wird. Halte Tränke oder schwere Angriffe bereit. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Fleischatronachen-Trio",
                mechanics = {
                    "Drei Fleischatronachen gleichzeitig; jeder kann schwere Angriffe ausführen – |cFF0000BLOCKEN|r als Tank. :contentReference[oaicite:12]{index=12}",
                    "Das Töten eines heilt & erzürnt die anderen – versuche, ihren Schaden gleichmäßig zu verteilen und alle 3 etwa zur gleichen Zeit zu töten (|cFFD700GLEICHZEITIG TÖTEN|r). :contentReference[oaicite:13]{index=13}",
                    "Stehe hinter ihnen, wenn du DPS bist – jeder hat einen kegelförmigen Hieb. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Urvan Veleth",
                mechanics = {
                    "Beginnt mit vier Geister-Adds (Bogenschützen/Krieger), die DK-Standarten fallen lassen – |cFFD700ADDS SCHNELL TÖTEN|r, sonst wirst du überwältigt. :contentReference[oaicite:15]{index=15}",
                    "Schwerer Angriff (Schildschlag) nachdem Boss blockt – wenn der Tank während des Blocks des Bosses einen schweren Angriff versucht, wird der Tank betäubt. Achte darauf. (|cFF0000BLOCKEN|r). :contentReference[oaicite:16]{index=16}",
                    "Blutpfütze: Boss taucht in Blut unter und jagt den Tank, entzieht Leben (heilt ihn). Bewege dich langsam/blocke, um Heilung zu minimieren. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Vorenor Winterbourne",
                mechanics = {
                    "Keine konventionellen Adds – nur 3 'Opfer' im Raum. Wenn sie nicht getötet werden, kann Boss sie für geringe Heilung aussaugen. :contentReference[oaicite:18]{index=18}",
                    "Blutkreis: Zielt auf einen zufälligen Spieler – hinterlässt einen schädigenden roten AoE auf dem Boden. Schnell herausbewegen (|cFF0000BEWEGEN|r). :contentReference[oaicite:19]{index=19}",
                    "Teleportationsschlag: Boss hebt Hand & teleportiert sich nacheinander zu jedem Spieler – jeder sollte blocken oder hohen Schaden riskieren (|cFF0000BLOCKEN|r). :contentReference[oaicite:20]{index=20}",
                    "Herausforderer: Töte keine Opfer. Vorenor hat mehr HP/Schaden. Brenne ihn trotz seiner Heilung nieder. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 7) Dunkelschattenkavernen I (zoneId=63)
    ----------------------------------------------------------------------------
    [63] = {
        normalId = 5,
        vetId    = 309,
        zoneId   = 63,
        sets     = {166,268,301,300,96},
        questID  = 4145,
        HM       = 1586,
        SR       = 1584,
        ND       = 1585,
        TR       = nil,
        name     = "Dunkelschattenkavernen I",
        bosses = {
            {
                name = "Hauptschäfer Neloren",
                mechanics = {
                    "Wirkt hauptsächlich |cFF0000Feuer|r-basierte Projektile, die kleine Flächen-AoEs hinterlassen (|cFFFFFFKEINE AKTION|r, wenn getankt) :contentReference[oaicite:0]{index=0}",
                    "Heilt sich selbst oder Verbündete häufig mit mächtigen Wiederherstellungszaubern (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:1]{index=1}",
                    "Kanalisiert manchmal ein kurzzeitiges Heilgebet (sehr große Heilung, wenn nicht unterbrochen) :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Vorarbeiter Llothan",
                mechanics = {
                    "Bleibt auf Distanz, wechselt aber alle ~10s den Standort (|cFFA500ACHTE|r auf einen Schock-AoE, wenn er sich bewegt) :contentReference[oaicite:3]{index=3}",
                    "Wirft Giftfläschchen auf den Boden, die DoT-Zonen erzeugen (|cFF0000BEWEGEN|r schnell raus) :contentReference[oaicite:4]{index=4}",
                    "Beschwört kleine Kwama-Adds bei ~75/50/25% HP. Töte sie schnell oder nutze AoE (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:5]{index=5}",
                    "Gelegentliche Schockexplosion um ihn herum, wenn du zu nah bleibst – schlägt dich nieder, wenn du getroffen wirst. :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Der Stockfürst",
                mechanics = {
                    "Springt zufällig auf entfernte Spieler, wenn sie weglaufen – bleibe nah, um Sprünge zu vermeiden (|cFF0000NICHT WEGLAUFEN|r) :contentReference[oaicite:7]{index=7}",
                    "Überkopf- oder Kegelschlag – blocken oder ausweichen, wenn du Aggro hast (|cFF0000BLOCKEN|r empfohlen). :contentReference[oaicite:8]{index=8}",
                    "Beschwört 3 Kwama-Scrib-Adds, indem er sich in den Boden gräbt (kleiner AoE-Verlangsamung). Töte sie mit AoE. :contentReference[oaicite:9]{index=9}",
                    "Bodenschlag: Wiederholte AoE-Impulse. Schlage/unterbrich ihn, um es zu stoppen oder ertrage schwere Treffer (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:10]{index=10}",
                    "Hinweis: Dieser Boss kann |cFFD700übersprungen werden|r, indem man zum Netch-Bereich hinunterspringt, falls gewünscht. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Höhlenpatriarch",
                mechanics = {
                    "Großer Netch mit einem einfachen schweren Angriff – Tank sollte blocken oder Niederschlag riskieren (|cFF0000BLOCKEN|r). :contentReference[oaicite:12]{index=12}",
                    "Wirkt eine große Giftwolke, normalerweise unter sich – bewege den Boss oder trete heraus (|cFF0000BEWEGEN|r). :contentReference[oaicite:13]{index=13}",
                    "Ansonsten minimale Mechaniken – halte den Boss für sichereren DPS weggedreht. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Schneidende Sphäre",
                mechanics = {
                    "Hat Dwemer-Spinnen-Adds – ziehe sie heran oder töte sie zuerst (|cFFD700ADDS BESEITIGEN|r). :contentReference[oaicite:15]{index=15}",
                    "Schießt ein schweres Dampfprojektil aus der Ferne – muss geblockt werden, sonst kann es dich niederschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:16]{index=16}",
                    "Springt hoch und schlägt auf, verursacht AoE-Schaden beim Aufprall (|cFF0000AUSWEICHEN|r). :contentReference[oaicite:17]{index=17}",
                    "Dreht sich in Raserei und jagt das Aggro-Ziel – Tank sollte blocken und möglichst stillstehen. (|cFF0000BLOCKEN|r) :contentReference[oaicite:18]{index=18}",
                    "Hinweis: Dieser Boss ist optional; kann übersprungen werden, wenn nicht für Quest oder Errungenschaften benötigt. :contentReference[oaicite:19]{index=19}",
                },
            },
            {
                name = "Wächter von Rkugamz",
                mechanics = {
                    "Farbcodierte Phasen:\n    • |c00FF00Grün|r = Standard-/Schwerer Angriff, beschwört Dwemer-Spinnen, die grüne Heilfelder erzeugen (halte ihn davon fern oder töte Spinnen)\n    • |cFF0000Rot|r = Wirbeljagd – zufälliger Spieler anvisiert, Boss wirbelt im AoE. Kite in einem weiten Kreis (|cFF0000BEWEGEN|r, kein Spott möglich)\n    • |c00FFFFBlau|r = Blitzhagel von oben – bleibe in Bewegung, um fallenden Schockkugeln auszuweichen :contentReference[oaicite:20]{index=20}",
                    "Wenn grün, führt er einen starken Frontalangriff (Enthauptung) aus, der zurückstoßen kann – (|cFF0000BLOCKEN|r als Tank). :contentReference[oaicite:21]{index=21}",
                    "Bei ~25% HP beschwört er zusätzliche Dwemer-Spinnen mit grünen Kreisen – Berühren heilt ihn weiter. :contentReference[oaicite:22]{index=22}",
                    "Stehe hinter ihm, außer in der roten Wirbelphase. Wenn du in Rot gejagt wirst, koordiniere und halte ihn in deinem AoE, während du kitest. :contentReference[oaicite:23]{index=23}",
                    "Herausforderer: Höhere HP/Schaden, gleiche Mechaniken. :contentReference[oaicite:24]{index=24}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 8) Dunkelschattenkavernen II (zoneId=930)
    ----------------------------------------------------------------------------
    [930] = {
        normalId = 308,
        vetId    = 21,
        zoneId   = 930,
        sets     = {166,268,301,300,96},
        questID  = 4641,
        HM       = 467,
        SR       = 465,
        ND       = 1588,
        TR       = nil,
        name     = "Dunkelschattenkavernen II",
        bosses = {
            {
                name = "Der gefallene Vorarbeiter",
                mechanics = {
                    "Beginnt mit mehreren Grubenratten-Adds – |cFFD700ADDS ZUERST TÖTEN|r oder für AoE gruppieren. :contentReference[oaicite:0]{index=0}",
                    "Wirkt einfachen Feuerball auf Tank (moderater Schaden) (|cFFFFFFKEINE AKTION|r, wenn getankt). :contentReference[oaicite:1]{index=1}",
                    "Wirbelnde Flammen: Rotiert langsam einen 360-Grad-Flammenstrahl – |cFF0000AUSWEICHEN oder BEWEGEN|r um den Boss; kann Gruppen auslöschen, wenn getroffen. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Transmutierter Stockfürst",
                mechanics = {
                    "Zwei kleine Scrib-Adds bleiben beim Boss. Sie können eine Betäubung & Ressourcenentzug kanalisieren (|cFF7F00UNTERBRECHEN|r, wenn möglich). :contentReference[oaicite:3]{index=3}",
                    "Schwerer Schlag: Gelegentlicher Bodenschlag – blocken als Tank oder |cFF0000AUSWEICHEN|r als DPS/Heiler. :contentReference[oaicite:4]{index=4}",
                    "Wütender Schlag (niedrige HP): Erhält Schadenschild & schlägt wiederholt auf den Boden; Heilung aufrechterhalten & Schild mit DPS brechen. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Transmutierte Alits",
                mechanics = {
                    "Kampf mit 3 Alits gleichzeitig; jeder kann schwere Angriffe ausführen – |cFF0000BLOCKEN|r als Tank. :contentReference[oaicite:6]{index=6}",
                    "Wenn einer stirbt, kann er wiederbelebt werden, wenn die anderen nicht schnell getötet werden – Schaden gleichmäßig verteilen (|cFFD700GLEICHZEITIG TÖTEN|r). :contentReference[oaicite:7]{index=7}",
                    "Atemangriffe in einem frontalen Kegel – Tank dreht sie weg; Gruppe bleibt dahinter oder an den Flanken. :contentReference[oaicite:8]{index=8}",
                    "Optionaler Boss für Speedruns – kann übersprungen werden, falls gewünscht. :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Grobull der Transmutierte",
                mechanics = {
                    "Boss ist von einem Blitzschild umgeben, der Projektile reflektiert – vermeide direkte Treffer, bis der Schild fällt. :contentReference[oaicite:10]{index=10}",
                    "Beschwört kleine & große Netch-Adds, die getötet werden müssen, um den Niedergang des Bosses aufzuladen. Tank verspottet große. (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:11]{index=11}",
                    "Nachdem genug Adds gestorben sind, fällt Grobull für ~10s zu Boden und entfernt den Schild – brenne ihn schnell nieder (|cFFD700VOLLER DPS|r). :contentReference[oaicite:12]{index=12}",
                    "Er wiederholt Phasen mit mehr Add-Wellen, bis er besiegt ist. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Maschinengarnison",
                mechanics = {
                    "Massive Welle von Dwemer-Konstrukten (Sphären, Spinnen, Zenturios). Tank muss vorsichtig Gruppe für Gruppe ziehen. :contentReference[oaicite:14]{index=14}",
                    "Wenn zu schnell gezogen wird, können mehrere Zenturios die Gruppe überwältigen. (|cFF0000PULLS DOSIEREN|r) :contentReference[oaicite:15]{index=15}",
                    "Dwemer-Sphären wirken Fernkampf-Pfeile & Boden-AoEs – konzentriere dich auf sie oder ziehe sie heran. :contentReference[oaicite:16]{index=16}",
                    "Dwemer-Spinnen können andere mit Blitzen ermächtigen, wenn sie allein gelassen werden – töte sie schnell oder unterbrich sie. :contentReference[oaicite:17]{index=17}",
                    "Zenturios haben schwere Treffer – |cFF0000BLOCKEN|r, wenn anvisiert, oder lass Tank sie von der Gruppe fernhalten. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Der Maschinewächter",
                mechanics = {
                    "Wechselt zufällig 3 Phasen: |cFF0000Feuer|r, |c00FF00Gift|r, |c00FFFFBlitz|r. Jede erfordert unterschiedliche Abstände. Kann nicht dauerhaft verspottet werden, aber halte Spott für Debuff aufrecht. :contentReference[oaicite:19]{index=19}",
                    "|cFF0000Feuer|r: Boss rotiert Flammen im 360°-Winkel, lässt Feuer-AoEs fallen. Bleibe auf Distanz oder weiche seitlich aus. Hinterlässt kleine Mörser-Explosionen am Boden. :contentReference[oaicite:20]{index=20}",
                    "|c00FF00Gift|r: Gruppenweiter DoT tickt. Heilen oder abschirmen. Meide den Boss, wenn er Giftstrahlen wirbelt. Vier mittlere Hebel können Gift stoppen, deaktivieren aber den Schweren Modus. :contentReference[oaicite:21]{index=21}",
                    "|c00FFFFBlitz|r: Nähe zum Boss ist tödlich. Beschwört Dwemer-Sphären – |cFFD700SCHNELL TÖTEN|r, sonst sammeln sie sich an. :contentReference[oaicite:22]{index=22}",
                    "Herausforderer: Benutze die Hebel nicht, um Gift zu entfernen. Überlebe alle 3 Phasen mit schwereren Treffern. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 9) Eldengrund I (zoneId=126)
    ----------------------------------------------------------------------------
    [126] = {
        normalId = 7,
        vetId    = 23,
        zoneId   = 126,
        sets     = {269,167,298,155,28},
        questID  = 4336,
        HM       = 1578,
        SR       = 1576,
        ND       = 1577,
        TR       = nil,
        name     = "Eldengrund I",
        bosses = {
            {
                name = "Akash gra-Mal",
                mechanics = {
                    "Einfacher frontaler Spaltangriff (kegelförmig), stößt zurück, wenn nicht geblockt. Tank: halte sie weggedreht (|cFF0000BLOCKEN|r empfohlen) :contentReference[oaicite:0]{index=0}",
                    "Führt gelegentlich einen Überkopfschlag oder 'Wirbelwind' um sich aus – trete aus dem kleinen roten Kreis (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:1]{index=1}",
                    "Wenn Spieler weit weglaufen, springt sie auf sie, verursacht kurze Betäubung/Schaden (bleibe nah, um Sprung zu verhindern) (|cFF0000NICHT WEGLAUFEN|r) :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Uralter Spriggan",
                mechanics = {
                    "Kommt mit drei kleineren Spriggans, die sich gegenseitig heilen können (|cFFD700ADDS TÖTEN|r schnell oder Heilung unterbrechen) :contentReference[oaicite:3]{index=3}",
                    "Kanalisiert eine Selbstheilung oder Verbündetenheilung, die unterbrochen werden kann (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:4]{index=4}",
                    "Benutzt schwache Basisangriffe – Tank dreht den Boss weg, Gruppe kann dahinter stehen, Adds mit AoE töten. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Würgeranke",
                mechanics = {
                    "Zieht zufällig einen entfernten Spieler mit Ranken heran, verursacht minimalen Schaden (|cFF0000ZURÜCK IN POSITION BEWEGEN|r) :contentReference[oaicite:6]{index=6}",
                    "Beschwört kleine Würger im Raum, die Würgeranke heilen, wenn sie am Leben bleiben (|cFFD700WÜRGER TÖTEN|r) :contentReference[oaicite:7]{index=7}",
                    "Verbreitet einen großen AoE von der Mitte aus, verursacht schweren Schaden (~90% HP), wenn getroffen – |cFF0000AUSWEICHEN oder RAUS|r sofort :contentReference[oaicite:8]{index=8}",
                },
            },    
            {
                name = "Nenesh gro-Mal",
                mechanics = {
                    "Begleitet von mehreren Ork-Adds – beseitige sie zuerst oder ziehe sie für AoE zusammen (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:9]{index=9}",
                    "Kanalisiert einen Zweihand-Aufwärtshaken, der geblockt werden muss (oder er schlägt dich nieder) (|cFF0000BLOCKEN|r) :contentReference[oaicite:10]{index=10}",
                    "Wirkt schwachen 'Zorn des Magiers'-ähnlichen Blitz, der unterbrochen werden kann (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Blattkoche",
                mechanics = {
                    "Kommt mit einem einfachen Alit-Add – verspotte/töte es schnell, damit es den Kampf nicht stört. :contentReference[oaicite:12]{index=12}",
                    "Schwerer Angriffssprung: springt auf den Tank oder das Ziel, wenn nicht geblockt, verursacht Niederschlag (|cFF0000BLOCKEN|r) :contentReference[oaicite:13]{index=13}",
                    "Kegelbiss oder 'Atmungs'-Animation – tritt zur Seite oder blocke (|cFF0000AUSWEICHEN|r / |cFF0000BLOCKEN|r). :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Kanonenreeve Oraneth",
                mechanics = {
                    "Erzeugt eine kleine Frostaura um sich, verursacht geringen DoT bei Nähe (|cFF0000VERMEIDE es, vorne zu stehen|r) :contentReference[oaicite:15]{index=15}",
                    "Schleudert einen Giftbolzen auf einen zufälligen Spieler – Ausweichrolle zur Negierung oder blocken, wenn in Gefahr (|cFF0000AUSWEICHEN|r) :contentReference[oaicite:16]{index=16}",
                    "Wirkt kleine AoE-Verlangsamungen auf den Boden, zieht Spieler kurz heran – befreien (|c00FFFFBEFREIEN|r). Beschwört dann vier Skelette. (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:17]{index=17}",
                    "Kanalisiert einen großen, expandierenden AoE von der Mitte aus – kann tödlich sein, wenn nicht ausgewichen wird (|cFF0000BEWEGEN|r schnell raus). :contentReference[oaicite:18]{index=18}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 10) Eldengrund II (zoneId=931)
    ----------------------------------------------------------------------------
    [931] = {
        normalId = 303,
        vetId    = 302,
        zoneId   = 931,
        sets     = {269,167,298,155,28},
        questID  = 4675,
        HM       = 463,
        SR       = 461,
        ND       = 1580,
        TR       = nil,
        name     = "Eldengrund II",
        bosses   = {
            {
                name = "Dubroze der Verseucher",
                mechanics = {
                    "Beginnt mit mehreren Fernkampf-Magier-Adds – |cFFD700ADDS ZUERST TÖTEN|r, sonst überwältigen sie. Tank kann sie hereinziehen. :contentReference[oaicite:0]{index=0}",
                    "Klassische Daedroth-Mechaniken – vom Gruppe wegdrehen, Flammenatem blocken oder aus Betäubung befreien (|cFF0000BLOCKEN|r). :contentReference[oaicite:1]{index=1}",
                    "Heiler/DPS müssen frontalen Kegel & jeden Schwanzhieb oder Boden-AoE meiden. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Dunkelwurzel",
                mechanics = {
                    "Erschafft regelmäßig zwei Hoarvor-Adds: Blau (Magicka-Buff) & Grün (Ausdauer-Buff). Töte sie und stehe im passenden Kreis, um großen Ressourcenbonus zu erhalten. :contentReference[oaicite:3]{index=3}",
                    "Wirkt Strahlenden Strahl von oben auf einen zufälligen Spieler, verursacht hohen AoE-Flächenschaden – steht auseinander, damit nicht mehrere Spieler getroffen werden (|cFF0000VERTEILEN|r). :contentReference[oaicite:4]{index=4}",
                    "Tank: Halte sie still und Spott aufrecht; kein Drehen des Bosses nötig. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Azara die Furchteinflößende",
                mechanics = {
                    "Kommt mit Magier-Adds – unterbrich oder töte sie schnell (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:6]{index=6}",
                    "Schwerer Angriff, der geblockt werden sollte, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r). :contentReference[oaicite:7]{index=7}",
                    "Beschwört gedankenkontrollierende 'Schatten'-Adds, die Spieler in Furcht versetzen, wenn sie am Leben bleiben – |cFFD700PRIORISIERE das Töten der Schatten|r. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Trübglanz",
                mechanics = {
                    "Wirkt kleine rote AoEs auf den Boden – weiche ihnen anfangs aus (|cFF0000BEWEGEN raus|r). :contentReference[oaicite:9]{index=9}",
                    "Phasenwechsel: Dieselben roten Kreise werden weiß und bieten nun Schutz – |cFF0000STEHE DRINNEN|r, um großen Schaden zu vermeiden. :contentReference[oaicite:10]{index=10}",
                    "Tank: Halte den Boss weggedreht, um frontale AoE-Hiebe zu vermeiden. Alle anderen achten auf Farbwechsel. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Der Schattenwächter",
                mechanics = {
                    "Beginnt mit mehreren Adds – Tank kann sie für AoE sammeln. :contentReference[oaicite:12]{index=12}",
                    "Schwerer Angriff, der geblockt werden muss, sonst kann er dich niederschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:13]{index=13}",
                    "Platziert große Boden-AoEs – Gift oder Schatten; schnell heraustreten, kein wildes Herumrennen nötig. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Bogdan der Nachtflamme",
                mechanics = {
                    "Erschafft schwarze 'Schatten', die Spieler gedankenkontrollieren/ängstigen, und weiße 'Schatten', die ihn heilen – |cFFD700SCHNELL TÖTEN|r oder Heilung unterbrechen. :contentReference[oaicite:15]{index=15}",
                    "Schwerer Angriff Flammenatem auf Tank gerichtet – blocken oder befreien, wenn betäubt (|cFF0000BLOCKEN|r). :contentReference[oaicite:16]{index=16}",
                    "Lässt 'Flammenpfützen' auf Spieler fallen, die bestehen bleiben – verteilt euch, damit die Arena nicht voll wird. :contentReference[oaicite:17]{index=17}",
                    "Bei Schwellenwerten (75%, 50%, 25%) springt er in die Luft & führt massiven AoE-Stampfer aus, der alle Feuer/Schatten beseitigt – blocken zum Überleben (|cFF0000BLOCKEN|r). :contentReference[oaicite:18]{index=18}",
                    "Herausforderer: Boss- & Add-Schaden erhöht, häufigere Erscheinungen – gleiche Taktik, heilende Schatten töten. :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 11) Kanalisation von Wegesruh I (zoneId=146)
    ----------------------------------------------------------------------------
    [146] = {
        normalId = 6,
        vetId    = 306,
        zoneId   = 146,
        sets     = {165,270,29,194,299},
        questID  = 4246,
        HM       = 1594,
        SR       = 1592,
        ND       = 1593,
        TR       = nil,
        name     = "Kanalisation von Wegesruh I",
        bosses = {
            {
                name = "Schlickkriecher",
                mechanics = {
                    "Einfacher 'Biss' trifft den Aggro-Halter – halte einen soliden Spott aufrecht (|cFFFFFFKEINE AKTION|r, wenn getankt) :contentReference[oaicite:0]{index=0}",
                    "Schwanzschlag (schwerer Angriff Kegel), der zurückstößt, wenn nicht geblockt – (|cFF0000BLOCKEN|r) oder |cFF0000AUSWEICHEN|r raus :contentReference[oaicite:1]{index=1}",
                    "Tank: Drehe Schlickkriecher weg, stehe still für konsistenten AoE von der Gruppe. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Ermittler Garron",
                mechanics = {
                    "Kanalisiert eine grüne Nebelkugel, die einen zufälligen Spieler jagt – bewege dich in kleinen Kreisen, damit sie dich nicht erwischt (|cFFA500KUGEL KITEN|r) :contentReference[oaicite:3]{index=3}",
                    "Beschwört Ruhelose Seelen (Geister) in Intervallen. Sie wirken Fernkampf-Eiskugeln – |cFFD700TÖTEN oder UNTERBRECHEN|r sie schnell. :contentReference[oaicite:4]{index=4}",
                    "Feuert gelegentlich ein starkes magisches Projektil ab, das zurückstoßen kann (|cFF0000BLOCKEN|r oder |cFF0000AUSWEICHEN|r, wenn auf dich gezielt). :contentReference[oaicite:5]{index=5}",
                    "Tank: Positioniere schnell neu, wenn Boss teleportiert, ziehe Geister für AoE zusammen. :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Der Rattenflüsterer",
                mechanics = {
                    "Beschwört regelmäßig einen Schwarm Skeever – brenne sie schnell nieder (|cFFD700AOE ADDS|r). :contentReference[oaicite:7]{index=7}",
                    "Kanalisiert einen 'Magiebomben'- oder 'Schlag'-Effekt, der auf den Tank zielt – beides kann |cFF7F00UNTERBROCHEN|r oder vermieden werden. :contentReference[oaicite:8]{index=8}",
                    "Wirkt manchmal wirbelnden Frost auf das Ziel, der es bewegungsunfähig macht – ebenfalls unterbrechbar (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Uulgarg der Hungrige",
                mechanics = {
                    "AOE-Furcht: Schreit und versetzt alle in Furcht – |c00FFFFBEFREIEN|r schnell, sonst riskierst du große Folgetreffer. :contentReference[oaicite:10]{index=10}",
                    "Schwerer Angriff nach Furcht kann tödlich sein, wenn nicht geblockt (|cFF0000BLOCKEN|r). :contentReference[oaicite:11]{index=11}",
                    "Wirbelwind: Dreht Waffe herum und verursacht moderaten AoE-Schaden – heraustreten oder blocken. :contentReference[oaicite:12]{index=12}",
                    "Tank: Halte ihn zentriert, damit die Gruppe sich nach der Furcht leicht neu positionieren kann. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Varaine Pellingare",
                mechanics = {
                    "Schwerer Angriff, der geblockt werden muss, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:14]{index=14}",
                    "Schnell wachsender roter AoE um den Boss – schnell raus oder du wirst betäubt/niedergeschlagen (|cFF0000BEWEGEN|r). :contentReference[oaicite:15]{index=15}",
                    "Springt/dreht sich gelegentlich und feuert eine schmale Kegel-Schockwelle auf einen zufälligen Spieler – (|cFF0000AUSWEICHEN|r oder |cFF0000BLOCKEN|r, wenn schnell). :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Allene Pellingare",
                mechanics = {
                    "Massiver schwerer Angriff – tötet sofort, wenn nicht geblockt (|cFF0000BLOCKEN|r ist zwingend erforderlich). :contentReference[oaicite:17]{index=17}",
                    "Folgt dem schweren Angriff sofort mit einem Wirbel-AoE, der ebenfalls Block erfordert – sehr hoher Schaden (|cFF0000BLOCKEN|r). :contentReference[oaicite:18]{index=18}",
                    "Hinterhalt/Teleportationsschlag auf einen zufälligen Spieler – wieder blocken oder großen Schaden riskieren (|cFF0000BLOCKEN|r). :contentReference[oaicite:19]{index=19}",
                    "Beschwört Wellen von teuflischen Halluzinationsfledermäusen (~alle 25% HP) mit wenig HP – |cFFD700SCHNELL TÖTEN|r. Allene erscheint wieder mit einem vorbereiteten schweren Angriff. :contentReference[oaicite:20]{index=20}",
                    "Wutanfall bei ~25% nach der letzten Fledermauswelle, verursacht mehr Schaden. Kann Gruppe betäuben (Seelenfessel-Stil). Schnell befreien, um Wirbel-/Schwer-Kombination zu vermeiden. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 12) Kanalisation von Wegesruh II (zoneId=933)
    ----------------------------------------------------------------------------
    [933] = {
        normalId = 22,
        vetId    = 307,
        zoneId   = 933,
        sets     = {165,270,29,194,299},
        questID  = 4813,
        HM       = 681,
        SR       = 679,
        ND       = 1596,
        TR       = nil,
        name     = "Kanalisation von Wegesruh II",
        bosses = {
            {
                name = "Garron der Zurückgekehrte",
                mechanics = {
                    "Platziert häufig große AoEs auf dem Boden; tritt zur Seite oder blocke bei Bedarf (|cFF0000BEWEGEN|r). :contentReference[oaicite:0]{index=0}",
                    "Beschwört alle ~30s vier geisterhafte Kristalle – jeder erzeugt ein Geister-Add, das hochschädigende Frostkugeln wirken kann (|cFFD700TÖTEN oder UNTERBRECHEN|r Geister schnell). :contentReference[oaicite:1]{index=1}",
                    "Teleportiert sich zur Mitte und kanalisiert einen entziehenden Strahl auf alle Spieler, der massiven DoT verursacht. Heiler muss Gruppe oben halten – alle bewegen sich auf Garron zu, um Fokus wiederaufzunehmen. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Malubeth die Geißlerin",
                mechanics = {
                    "Wirkt rote Boden-AoEs – leicht zu sehen, halte dich daraus fern (|cFF0000BEWEGEN|r). :contentReference[oaicite:3]{index=3}",
                    "Hebt einen zufälligen Spieler in die Luft und verursacht tickenden Schaden. Sie wird unfassbar – zwei Spieler müssen die Seitenaltäre aktivieren, um Verbündeten zu befreien (|c00FFFFALTÄRE AKTIVIEREN|r). :contentReference[oaicite:4]{index=4}",
                    "Tank: Halte sie weggedreht; achte auf verirrte Projektile oder kleine AoEs. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Schädelmäher",
                mechanics = {
                    "Typischer Knochenkoloss mit Adds: Beschwört Skelette aus dem Boden – brenne sie im AoE nieder, bevor sie explodieren. :contentReference[oaicite:6]{index=6}",
                    "Kegelschlag frontaler AoE – Tank dreht vom Gruppe weg, blocken, wenn anvisiert (|cFF0000BLOCKEN|r). :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Der Vergessene",
                mechanics = {
                    "Großer Fleischatronach-ähnlicher Boss mit kleineren Adds herum. Tank sammelt zuerst Adds (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:8]{index=8}",
                    "Sendet eine Welle oder einen äußeren Hieb aus, der zerbrechliche Spieler töten kann, wenn nicht geblockt oder ausgewichen wird (|cFF0000BLOCKEN|r oder zur Seite treten). :contentReference[oaicite:9]{index=9}",
                    "Halte Boss zentriert, damit AoE neue Add-Erscheinungen bewältigen kann. :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Uulgarg der Auferstandene",
                mechanics = {
                    "Bewegt sich ähnlich wie Uulgarg in Kanalisation I, mit einem großen AoE-Wirbel – heraustreten oder blocken. :contentReference[oaicite:11]{index=11}",
                    "Schwerer Angriff, der töten kann, wenn nicht geblockt (|cFF0000BLOCKEN|r früh; Animation endet kurz vor Aufprall). :contentReference[oaicite:12]{index=12}",
                    "Furcht & Flammenspuren: Versetzt Gruppe regelmäßig in Furcht, zwingt sie nach außen und hinterlässt Flammen dort, wo sie sich befreien (|cFF0000BEFREIEN + BEWEGEN|r). :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Varaine & Allene Pellingare",
                mechanics = {
                    "Zwei-Boss-Kampf – Tank muss beide verspotten und für AoE zusammenziehen. :contentReference[oaicite:14]{index=14}",
                    "Allene: Springt manchmal weg oder macht kleinen AoE-Hieb; blocken oder ausweichen nach Bedarf. :contentReference[oaicite:15]{index=15}",
                    "Varaine: Gelegentlich schwerer Angriff oder schmaler Kegel – |cFF0000BLOCKEN|r oder zur Seite treten. Kann einen wirbelnden AoE auf sich selbst legen. :contentReference[oaicite:16]{index=16}",
                    "Sie verschwinden, um kleine Vampirfledermaus-Adds zu erzeugen – töte sie schnell, dann erscheinen Bosse wieder. :contentReference[oaicite:17]{index=17}",
                    "Schadensschild: Manchmal erhält ein Boss für ~20s einen Schild – konzentriere dich in dieser Zeit auf den anderen Boss. :contentReference[oaicite:18]{index=18}",
                    "Herausforderer: Beschwöre & töte 15 Zombies während des Kampfes (starte zuerst Pull, sammle dann Zombies). :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 13) Arx Corinium (zoneId=148)
    ----------------------------------------------------------------------------
    [148] = {
        normalId = 8,
        vetId    = 305,
        zoneId   = 148,
        sets     = {156,304,303,271},
        questID  = 4202,
        HM       = 1609,
        SR       = 1607,
        ND       = 1608,
        TR       = nil,
        name     = "Arx Corinium",
        bosses = {
            {
                name = "Reißzahnhun",
                mechanics = {
                    "Kommt mit mehreren Lamia-Adds – entweder kontrolliere sie oder töte sie schnell mit AoE (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:0]{index=0}",
                    "Große Giftspirale auf dem Boden – darin zu stehen heilt den Boss rapide und verursacht einen DoT (|cFF0000BEWEGEN raus|r) :contentReference[oaicite:1]{index=1}",
                    "Schwerer Angriff (Schwanzpeitsche) in einem frontalen Kegel – Tank dreht weg und |cFF0000BLOCKEN|r oder tritt zur Seite, um Rückstoß zu vermeiden :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Ganakton der Sturm",
                mechanics = {
                    "Blitzbasierter Wamasu-Boss – Tank hält Spott aufrecht; keine Adds :contentReference[oaicite:3]{index=3}",
                    "Breiter Kegel Blitzatem – ausweichen oder blocken, wenn anvisiert (|cFF0000AUSWEICHEN/BLOCKEN|r) :contentReference[oaicite:4]{index=4}",
                    "Schockpuls betäubt regelmäßig gesamte Gruppe – unvermeidbar, also Heiler Gesundheit aufrechterhalten :contentReference[oaicite:5]{index=5}",
                    "Fesselnder Blitz fesselt einen zufälligen Spieler – befreien oder blocken zur Minderung (|c00FFFFBEFREIEN|r) :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Sliklenia die Sängerin",
                mechanics = {
                    "Kommt mit einem Schlangenbegleiter – töte die Schlange NICHT; sie schützt dich vor ihrem Schrei :contentReference[oaicite:7]{index=7}",
                    "Schwerer Angriff: muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r) :contentReference[oaicite:8]{index=8}",
                    "Kakophonie: Sie rennt zu einem Punkt und schreit, verursacht schweren AoE-DoT. Ihre Schlange erzeugt eine Schutzblase – sammelt euch darin (|cFFD700IN BLASE VERSTECKEN|r) :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Matrone Ixniaa",
                mechanics = {
                    "Begleitet von Lamia-Adds – konzentriere dich zuerst auf sie, damit du nicht überwältigt wirst (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:10]{index=10}",
                    "Doppelblitzkreise: erzeugt zwei Kreise unter einem Spieler – innerer Kreis verursacht massiven Schaden und Betäubung (|cFF0000BEWEGEN raus|r) äußerer Kreis kleinerer DoT :contentReference[oaicite:11]{index=11}",
                    "Standard-Lamia-Schwerer Angriff – Tank achtet auf große Treffer, blockt bei Bedarf :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Uralter Lurcher",
                mechanics = {
                    "Hat Lamia-Adds – kontrolliere oder töte sie schnell, bevor du dich auf den Boss konzentrierst :contentReference[oaicite:13]{index=13}",
                    "Schwerer Angriff (Stoß) muss geblockt werden, sonst wirst du ins Taumeln gebracht (|cFF0000BLOCKEN|r) :contentReference[oaicite:14]{index=14}",
                    "Kanalisiert einen grünen Strahl auf zufälligen Spieler für hohen DoT – kann nicht unterbrochen werden, muss geheilt werden :contentReference[oaicite:15]{index=15}",
                    "Unter 50%: Wutanfall mit blitzgeladenem AoE. Unterbrich Bodenschlag, wenn möglich (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Sellistrix die Lamia-Königin",
                mechanics = {
                    "An Land hat sie einen starken Schadenschild; im Wasser entfernt sie den Schild, elektrisiert aber das Wasser. Wähle Methode sorgfältig :contentReference[oaicite:17]{index=17}",
                    "Durchdringender Schrei: verheerender frontaler Schrei mit Rückstoß – ignoriert manchmal Spott, achte darauf (|cFF0000BLOCKEN oder AUSWEICHEN|r) :contentReference[oaicite:18]{index=18}",
                    "Wirkt Blitze auf zufällige Inseln mit fallendem Schutt – Gruppe kann an Land mildern oder im elektrisierten Wasser mit großer Heilung stehen :contentReference[oaicite:19]{index=19}",
                    "Stürmt gelegentlich auf einen zufälligen Spieler los – einfach blocken oder ausweichen. :contentReference[oaicite:20]{index=20}",
                    "Herausforderer erhöht HP/Schaden, aber keine neuen Mechaniken (|cFFD700Herausforderer|r). :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 14) Stadt der Asche I (zoneId=176)
    ----------------------------------------------------------------------------
    [176] = {
        normalId = 10,
        vetId    = 310,
        zoneId   = 176,
        sets     = {160,272,158,159,169},
        questID  = 4778,
        HM       = 1602,
        SR       = 1600,
        ND       = 1601,
        TR       = nil,
        name     = "Stadt der Asche I",
        bosses = {
            {
                name = "Infernaler Wächter",
                mechanics = {
                    "Doppelschlag – Einfache physische Schläge; Tank: blocken zur Schadensminderung. (|cFF0000BLOCKEN|r) :contentReference[oaicite:0]{index=0}",
                    "Dorniger Rückhandschlag – Schwerer Schwung, verursacht Blutung, wenn nicht geblockt. (|cFF0000BLOCKEN|r empfohlen) :contentReference[oaicite:1]{index=1}",
                    "Bodenschlag – Erzeugt einen großen Kreis-AoE, der Spieler zurückstößt; ausweichen oder |cFF0000BLOCKEN|r. :contentReference[oaicite:2]{index=2}",
                    "Feurige Explosion – Schleudert mehrere Feuerbälle durch das Gebiet. Achte auf deine Füße; zur Seite treten ist entscheidend. :contentReference[oaicite:3]{index=3}",
                    "Tunnelnde Wurzeln – Trifft entfernte Ziele mit Wurzeln. Ausweichen oder zur Seite treten, um Wurzel & DoT zu vermeiden. :contentReference[oaicite:4]{index=4}",
                },
            },
            {
                name = "Golor der Banekin-Handler",
                mechanics = {
                    "Beginnt mit & beschwört Banekins/Skampen in Wellen – |cFFD700ADDS SCHNELL TÖTEN|r. :contentReference[oaicite:5]{index=5}",
                    "Zermalmender Schlag – Schwerer Nahkampfangriff. Muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r). :contentReference[oaicite:6]{index=6}",
                    "Spalten – 360°-Drehung verursacht physischen Schaden; heraustreten oder bei Bedarf blocken (|cFF0000BEWEGEN|r). :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Wächter des Schreins",
                mechanics = {
                    "Gezielter Aufwärtshaken – Schwerer Angriff, der Ziel von Plattform stößt, wenn nicht geblockt (|cFF0000BLOCKEN|r). :contentReference[oaicite:8]{index=8}",
                    "Loderndes Feuer – Erzeugt feurige Kreise um den Boss; Tank kann Boss neu positionieren oder außerhalb stehen. :contentReference[oaicite:9]{index=9}",
                    "Teleportationsschlag – Zielt auf entfernte Spieler; befreien/blocken, wenn du es kommen siehst (|cFF0000NICHT weglaufen|r). :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Dunkle Glut",
                mechanics = {
                    "Hauptsächlich ein größerer Flammenatronach. Generische Feuerballangriffe zum Blocken/Ausweichen. :contentReference[oaicite:11]{index=11}",
                    "Lavageysir – Platziert Boden-AoE unter jedem Spieler. Schnell zur Seite treten (|cFF0000BEWEGEN|r). :contentReference[oaicite:12]{index=12}",
                    "Verbrennung – Explodiert beim Tod mit einem finalen AoE. Warte vor dem Plündern, sonst wirst du getötet! :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Rothariel Flammenherz",
                mechanics = {
                    "Zermalmender Schlag – Schwerer Angriff, der dich zurückstößt, wenn nicht geblockt (|cFF0000BLOCKEN|r). :contentReference[oaicite:14]{index=14}",
                    "Berserker-Raserei – 360°-Drehung mit moderatem Schaden; heraustreten oder blocken (|cFF0000BEWEGEN|r). :contentReference[oaicite:15]{index=15}",
                    "Brennendes Feld – Lässt kleine Flammenpfützen fallen; achte auf deine Füße. :contentReference[oaicite:16]{index=16}",
                    "Klone beschwören – Teilt sich in 3 Klone. Töte sie schnell; AoE oder Flächenschaden hilft, sie schneller niederzubrennen. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Klingenmeister Erthas",
                mechanics = {
                    "Wirft kreuzförmige AoE-Flammenlinien auf den Boden – tritt zur Seite oder spring darüber. :contentReference[oaicite:18]{index=18}",
                    "Lodernder Pfeil – Ein lang anhaltender Flammen-DoT auf zufälligen Spieler. Lösche ihn, indem du ins Wasser trittst (|cFF0000IM WASSER REINIGEN|r). :contentReference[oaicite:19]{index=19}",
                    "Beschwört Flammenatronachen – Normalerweise 1 auf einmal, aber 3 bei ~25% HP. Brenne sie schnell nieder oder werde überwältigt. :contentReference[oaicite:20]{index=20}",
                    "Teleport – Bewegt sich oft an einen neuen Ort; schnell wieder angreifen. Ultimates NACH dem Teleport fallen lassen. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 15) Stadt der Asche II (zoneId=681)
    ----------------------------------------------------------------------------
    [681] = {
        normalId = 322,
        vetId    = 267,
        zoneId   = 681,
        sets     = {160,272,158,159,169},
        questID  = 5120,
        HM       = 1114,
        SR       = 1108,
        ND       = 1107,
        TR       = nil,
        name     = "Stadt der Asche II",
        bosses = {
            {
                name = "Xivilai Rukhan, Akezel & Marruz",
                mechanics = {
                    "Pyrokasmus – Rukhan kanalisiert einen GROSSEN AoE, den du nicht unterbrechen kannst. Tritt oder weiche SCHNELL aus, um Niederschlag & großen Feuerschaden zu vermeiden (|cFF0000BEWEGEN|r) :contentReference[oaicite:0]{index=0}",
                    "Feuerkette – Zieht ein entferntes Ziel heran, oft vor Pyrokasmus. (|cFF0000BLOCKEN oder AUSWEICHEN|r, wenn bedroht) :contentReference[oaicite:1]{index=1}",
                    "Flammenatronachen – Beschwört regelmäßig Atronachen mit moderater HP. Töte schnell, wenn Gruppen-DPS niedrig ist, oder ignoriere, wenn du den Boss niederbrennen kannst. :contentReference[oaicite:2]{index=2}",
                    "Schwerer Angriff (Aufwärtshaken) – Muss geblockt werden, sonst wirst du zurückgeschleudert. (|cFF0000BLOCKEN|r) :contentReference[oaicite:3]{index=3}",
                    "Akezel (Heiler) – Teleportiert & wirkt Heilungen auf andere, kann unterbrochen oder fokussiert werden, wenn nötig. :contentReference[oaicite:4]{index=4}",
                    "Marruz (Bogenschütze) – Feuert Flammenfallen & teleportiert herum. Tritt aus bodenbasierten Flammen heraus. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Urata die Legion",
                mechanics = {
                    "Feuerkreise – Mehrere kleine Flammen-Boden-AoEs erscheinen unter Spielern. Schnell herausbewegen (|cFF0000BEWEGEN|r). :contentReference[oaicite:6]{index=6}",
                    "Beschwört 2 Dremora-Adds: Wenn nicht schnell getötet, können sie verschmelzen & Urata heilen. (|cFFD700ADDS TÖTEN|r sofort) :contentReference[oaicite:7]{index=7}",
                    "Einfache Nahkampftreffer & mittlere Feuerangriffe: Tank sollte sie von der Gruppe wegdrehen. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Horvantud der Feuerschlund",
                mechanics = {
                    "Feueratem – Großer Kegelangriff nach vorne. Stehe NICHT vorne, es sei denn du tankst – blocken als Tank. (|cFF0000BLOCKEN|r) :contentReference[oaicite:9]{index=9}",
                    "Stampfen (Bodenbeben) – Schlägt auf den Boden, beschwört rote Kreise. Heraustreten oder großen Schaden nehmen. (|cFF0000BEWEGEN|r) :contentReference[oaicite:10]{index=10}",
                    "Wellen von Dremora – Bei Gesundheitsschwellen (75%, 50%, 25%) erscheinen mehrere Dremora. Wenn Gruppen-DPS nicht hoch ist, töte sie oder riskiere Überwältigung. :contentReference[oaicite:11]{index=11}",
                    "Einfache Daedroth-Nahkampf-/Klauenhiebe – Tank dreht Boss von Gruppe weg, achte auf moderate Treffer. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Aschentitan",
                mechanics = {
                    "Schwerer Angriff – Kegeltelegraph vorne, Tank muss blocken oder wird weit zurückgestoßen. (|cFF0000BLOCKEN|r) :contentReference[oaicite:13]{index=13}",
                    "Flammenwand – Boss schlägt auf Boden, sendet Feuerbögen nach außen. Seitlich ausweichen. (|cFF0000BEWEGEN|r) :contentReference[oaicite:14]{index=14}",
                    "Feuerregen – Lässt Meteore oder kreisförmige AoEs auf jeden Spieler regnen. Tritt zur Seite – kann nicht ganz entkommen, aber bewege dich häufig. :contentReference[oaicite:15]{index=15}",
                    "Luftatronachen-Beschwörungen – Bei ~65% & ~35% Boss-Gesundheit beschwört er einen Luftatronachen (insgesamt 2). Tank muss sie kiten & Boss ebenfalls verspottet halten. :contentReference[oaicite:16]{index=16}",
                    "Schlag + Feuerwelle – stößt Spieler regelmäßig weg, kanalisiert dann Wellen aus Feuer oder Lava. Fernkampf empfohlen für DPS/Heiler. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Xivilai Boltaic & Xivilai Fulminator",
                mechanics = {
                    "Blitzangriff – Frontaler Kanal verursacht schweren Schockschaden. Kann unterbrochen oder zur Seite ausgewichen werden (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:18]{index=18}",
                    "Schockaura – Boss duckt sich, explodiert dann mit Schock-AoE. Herausbewegen oder unterbrechen. :contentReference[oaicite:19]{index=19}",
                    "Schwerer Angriff – Muss geblockt werden, sonst erleidest du riesigen Schaden. (|cFF0000BLOCKEN|r) :contentReference[oaicite:20]{index=20}",
                    "Sturmatronachen – Beschwört bis zu 4 gleichzeitig. Sie können überwältigen, wenn nicht schnell getötet. :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Valkyn Skoria",
                mechanics = {
                    "5 Plattformen (3 im HM) – Jede Plattform bricht irgendwann. Meide die Lava. Muss schnell DPS machen oder Plattformen gehen aus. :contentReference[oaicite:22]{index=22}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du in Lava gestoßen. (|cFF0000BLOCKEN|r) :contentReference[oaicite:23]{index=23}",
                    "Feuerball – Zielt auf einen zufälligen Spieler. Ausweichrolle oder blocken, um Rückstoß zu vermeiden. (|cFF0000AUSWEICHEN|r oder |cFF0000BLOCKEN|r) :contentReference[oaicite:24]{index=24}",
                    "Versteinern – Verwandelt zufällig einen Spieler in Stein. Schnell befreien oder ausweichen, wenn du den Cast siehst. :contentReference[oaicite:25]{index=25}",
                    "Flammenrad – Wiederholte kreisförmige Flammenlinien strahlen nach außen. Tritt dazwischen. (|cFF0000VORSICHTIG BEWEGEN|r) :contentReference[oaicite:26]{index=26}",
                    "Plattform zerschmettern – Er sticht in den Boden und zerstört diese Plattform. Bewege dich zur nächsten. :contentReference[oaicite:27]{index=27}",
                    "Atronachen & Schadensschild – Jeder Plattformwechsel erzeugt Flammenatronachen & eine geschützte Skoria. Brenne den Schild, töte Atronachen, dann wieder DPS auf ihn. :contentReference[oaicite:28]{index=28}",
                    "Herausforderer: Nur 3 Plattformen. Minimale Fehler erlaubt – time Schaden & Bewegungen gut. :contentReference[oaicite:29]{index=29}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 16) Krypta der Herzen I (zoneId=130)
    ----------------------------------------------------------------------------
    [130] = {
        normalId = 9,
        vetId    = 261,
        zoneId   = 130,
        sets     = {273,122,134,302,168},
        questID  = 4379,
        HM       = 1615,
        SR       = 1613,
        ND       = 1614,
        TR       = nil,
        name     = "Krypta der Herzen I",
        bosses = {
            {
                name = "Der Magier-Meister",
                mechanics = {
                    "Kommt mit vier Skelett-Magier-Adds – töte oder unterbrich sie schnell (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:0]{index=0}",
                    "Schwingt mit einem schweren Nahkampfhieb – muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r) :contentReference[oaicite:1]{index=1}",
                    "Wirkt einen donutförmigen AoE auf den Boden – Mitte und äußerer Ring sind sicher, Ränder verursachen Schaden (|cFF0000BEWEGEN|r) :contentReference[oaicite:2]{index=2}",
                    "Lässt eine 'Negieren'-ähnliche Blase fallen, die Magicka-Nutzung stört – heraustreten oder auf Ausdauer & |cFF0000BLOCKEN|r verlassen :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Erzmeister Siniel",
                mechanics = {
                    "Versetzt alle Spieler regelmäßig für ~2s in Furcht (|c00FFFFBEFREIEN|r) :contentReference[oaicite:4]{index=4}",
                    "Beschwört Wellen von untoten Skeletten (sehr wenig HP) – töte mit AoE (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:5]{index=5}",
                    "Kanalisiert einen dunklen Kreis-AoE auf dem Boden – stehe NICHT darin (|cFF0000BEWEGEN|r) :contentReference[oaicite:6]{index=6}",
                    "Bei niedriger Gesundheit kann er einen Schadenschild wirken – brenne ihn schnell durch :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Leviathan des Todes",
                mechanics = {
                    "Beginnt Kampf unbeleuchtet, erhält Flammenbuff mitten im Kampf (~50% HP). Feuerform erhöht Schaden stark (|cFF0000ERHÖHTE Vorsicht|r). :contentReference[oaicite:8]{index=8}",
                    "Expandierender roter Kreis von der Mitte – sofort raus, sonst kann er töten (|cFF0000BEWEGEN|r). Tödlich, wenn du in Phase zwei nah dran bist. :contentReference[oaicite:9]{index=9}",
                    "Stürmt in gerader Linie – leicht zur Seite auszuweichen. In Flammenphase hinterlässt er eine Feuerspur. :contentReference[oaicite:10]{index=10}",
                    "Tank: Halte Boss davon ab, wild herumzurennen – positioniere nahe Mauern, wenn möglich, um Anstürme zu kontrollieren. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Uulkar Knochenhand",
                mechanics = {
                    "Beschwört rote Kreise oder Runen, die als Stacheln ausbrechen und Spieler kurz betäuben (|cFF0000BEWEGEN|r oder |c00FFFFBEFREIEN|r). :contentReference[oaicite:12]{index=12}",
                    "Schwerer Angriff Überkopfschlag – absolutes Muss-Blocken, sonst erwarte einen One-Shot (|cFF0000BLOCKEN|r) :contentReference[oaicite:13]{index=13}",
                    "Schwingt in kleinen AoEs – Tank hält ihn still, DPS meiden wirbelnde Telegrafen. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Dogas der Berserker",
                mechanics = {
                    "Beginnt Kampf mit mehreren Skelett-Adds – kontrolliere oder töte sie zuerst. :contentReference[oaicite:15]{index=15}",
                    "Wirkt eine große AoE-Betäubung, die HP entzieht (ähnlich Seelenfessel) – |c00FFFFBEFREIEN|r oder Unaufhaltsam verwenden :contentReference[oaicite:16]{index=16}",
                    "Führt einen schweren Nahkampf- oder Überkopfschlag aus – blocken, wenn anvisiert (|cFF0000BLOCKEN|r). :contentReference[oaicite:17]{index=17}",
                    "Verteilt euch, um gruppenweite Betäubung zu vermeiden oder fokussiert ihn schnell – Er kann mehreren Spielern Leben stehlen. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Ilambris-Athor & Ilambris-Zaven",
                mechanics = {
                    "Zwillingsbosse: Zaven (Feuermagier) bleibt meist mittig; Athor (Blitz) wandert. :contentReference[oaicite:19]{index=19}",
                    "Zaven: Kanalisiert große Flammenbögen & erzeugt einen großen expandierenden AoE – rauslaufen oder niedergeschlagen werden (|cFF0000BEWEGEN|r). :contentReference[oaicite:20]{index=20}",
                    "Athor: Führt große Nahkampftreffer aus – blocke schweren Überkopfschlag, sonst wirst du geschleudert (|cFF0000BLOCKEN|r). Er platziert Blitzrunen auf dem Boden – meiden. :contentReference[oaicite:21]{index=21}",
                    "Tötungsreihenfolge oft Feuer zuerst -> Blitz erzürnt mit Blitzregen. Oder gleiche ihre HP für gleichzeitigen Tod an, um Wutanfallzeit zu reduzieren. :contentReference[oaicite:22]{index=22}",
                    "Wenn einer stirbt, erhält der andere einen verbesserten AoE und Schaden. Bleibe ruhig, blocke weiter oder weiche großen Treffern aus, schnell beenden. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 17) Krypta der Herzen II (zoneId=932)
    ----------------------------------------------------------------------------
    [932] = {
        normalId = 317,
        vetId    = 318,
        zoneId   = 932,
        sets     = {273,122,134,302,168},
        questID  = 5113,
        HM       = 1084,
        SR       = 941,
        ND       = 942,
        TR       = nil,
        name     = "Krypta der Herzen II",
        bosses = {
            {
                name = "Ibelgast",
                mechanics = {
                    "Kommt mit mehreren Nekromanten-/Heiler-Adds – konzentriere dich auf sie (|cFFD700ADDS TÖTEN|r) oder unterbrich, um langen Kampf zu verhindern :contentReference[oaicite:0]{index=0}",
                    "Platziert zufällig einen großen roten AoE-Kreis unter einem Spieler – schnell heraustreten (|cFF0000BEWEGEN|r) :contentReference[oaicite:1]{index=1}",
                    "Schwerer Angriff Überkopfschlag – muss geblockt werden, sonst erwarte Rückstoß (|cFF0000BLOCKEN|r) :contentReference[oaicite:2]{index=2}",
                    "Bei niedriger Gesundheit beschwört er einen Fleischatronachen mit moderater HP – Tank hält Aggro, töte ihn schnell (|cFFD700ADD TÖTEN|r) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Ruzozuzalpamaz",
                mechanics = {
                    "Wirkt Blitz auf Tank – niedriger DoT, aber Tank hält Spott aufrecht. :contentReference[oaicite:4]{index=4}",
                    "Beschwört Spinnenschwärme während des Kampfes – nicht panisch werden oder rennen. Tank sammelt sie, nutze AoE. :contentReference[oaicite:5]{index=5}",
                    "Kanalisiert einen jagenden AoE, der auf einen Spieler zielt – kite in weitem Kreis weg von der Gruppe (|cFF0000BEWEGEN raus|r). :contentReference[oaicite:6]{index=6}",
                    "Kokoniert einen zufälligen Spieler in einem Netz – andere müssen Synergie auf ihn verwenden, um zu befreien (|cFFD700VERBÜNDETEN BEFREIEN|r). :contentReference[oaicite:7]{index=7}",
                    "Schwerer Angriff Überkopfschlag – blocken, um Rückstoß zu vermeiden (|cFF0000BLOCKEN|r). :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Kammerwächter",
                mechanics = {
                    "Schwerer Angriff Überkopfschlag – blocken oder riesigen Schaden erleiden (|cFF0000BLOCKEN|r). :contentReference[oaicite:9]{index=9}",
                    "Versetzt regelmäßig alle Spieler in Furcht – sofort |c00FFFFBEFREIEN|r, um Weglaufen zu stoppen. :contentReference[oaicite:10]{index=10}",
                    "Beschwört Skelett-Adds über Zeit – töte schnell mit AoE, sonst überwältigen sie dich (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:11]{index=11}",
                    "Tank: Halte Boss mittig im Raum, befreie dich schnell von Furcht, um zu verhindern, dass Boss aus Gruppen-AoE wandert. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Ilambris-Amalgam",
                mechanics = {
                    "Kampf beginnt mit 2 kleineren Ilambris (blau & rot). Das Töten eines lässt den eigentlichen Knochenkoloss-Boss aus dem Haufen erscheinen. :contentReference[oaicite:13]{index=13}",
                    "Beschwört Skelett-Adds in Wellen – Tank gruppiert sie, töte mit AoE (|cFFD700ADDS BESEITIGEN|r). :contentReference[oaicite:14]{index=14}",
                    "Stampft Boden mit einem weiten AoE – heraustreten oder blocken. (|cFF0000BLOCKEN oder BEWEGEN|r). :contentReference[oaicite:15]{index=15}",
                    "Bei niedriger HP Wutanfall mit konstantem Feuerregen – bleibe mobil, achte auf Füße und beende Boss schnell. :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Mezeluth",
                mechanics = {
                    "Verwurzelt – sie bewegt sich NICHT. Gruppe muss sich ihr auf der Plattform nähern. :contentReference[oaicite:17]{index=17}",
                    "Kanalisiert einen feurigen Boden-AoE – unterbrich sie, um Gefahren zu reduzieren (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:18]{index=18}",
                    "Saugt Spieler regelmäßig an und platziert überlappende rote Kreise unter den Füßen jedes Spielers – |cFFD700VERTEILEN|r, damit sie nicht stapeln und Gruppe auslöschen. :contentReference[oaicite:19]{index=19}",
                    "Ausweichrolle oder bewege dich zurück in dein 'Viertel', um überlappende AoEs zu vermeiden. Jeder muss einen einzigartigen sicheren Platz finden. :contentReference[oaicite:20]{index=20}",
                },
            },
            {
                name = "Nerien'eth",
                mechanics = {
                    "Fliegen/Schädel: zufälliger Spieler wird mit einem großen Schädelprojektil anvisiert – |cFF0000AUSWEICHEN oder BLOCKEN|r oder riesigen Schaden/Niederschlag riskieren. :contentReference[oaicite:21]{index=21}",
                    "Teleportiert auf einen zufälligen Spieler – löst einen riesigen Ring-AoE aus. Wenn anvisiert, Distanz gewinnen oder blocken (|cFF0000BEWEGEN oder BLOCKEN|r). :contentReference[oaicite:22]{index=22}",
                    "Beschwört Geister an 3 Brunnen – sie zu töten senkt Schwierigkeit; sie zu ignorieren löst Schweren Modus aus, wenn 4 bei 35% HP übrig sind. :contentReference[oaicite:23]{index=23}",
                    "35%-Phase: Greift Schwert, Gruppe ist betäubt. Entzieht einem zufälligen Spieler Leben – andere müssen Schild schnell zerstören, um ihn zu befreien (|cFFD700DPS SCHILD|r). :contentReference[oaicite:24]{index=24}",
                    "Nach Schwertphase macht Boss schwerere Nahkampfangriffe mit zufälligen Anstürmen – blocken oder zur Seite treten. :contentReference[oaicite:25]{index=25}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 18) Burg Grauenfrost (zoneId=449)
    ----------------------------------------------------------------------------
    [449] = {
        normalId = 11,
        vetId    = 319,
        zoneId   = 449,
        sets     = {274,307,53,103},
        questID  = 4346,
        HM       = 1628,
        SR       = 1626,
        ND       = 1627,
        TR       = nil,
        name     = "Burg Grauenfrost",
        bosses = {
            {
                name = "Zähneknirscher der Frostgebundene",
                mechanics = {
                    "Ansturm – Boss stürmt auf den Tank zu, verursacht moderaten Schaden. (|cFF0000BLOCKEN|r). :contentReference[oaicite:0]{index=0}",
                    "Eiswind – Anhaltender Frost-AoE um den Boss, verursacht Verlangsamung und DoT. Heiler kann gegenheilen oder kurz heraustreten. :contentReference[oaicite:1]{index=1}",
                    "Leichte Angriffe – Häufige leichte Treffer auf den Aggro-Halter. Nicht herumlaufen; bei Bedarf blocken. :contentReference[oaicite:2]{index=2}",
                    "Position halten – Boss stillzuhalten ist am besten. Übermäßige Bewegung erschwert Heilung/AoE. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Wächter der Flamme",
                mechanics = {
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:4]{index=4}",
                    "Ansturm – Zielt auf entfernte Spieler. Position halten, blocken, wenn angestürmt. :contentReference[oaicite:5]{index=5}",
                    "Atem – Frontaler Kegelflammenangriff auf Tank (|cFF0000BLOCKEN|r). Andere vermeiden es, vorne zu stehen. :contentReference[oaicite:6]{index=6}",
                    "Blitzschlag – Zufälliger AoE unter einem Spieler. Schnell herausbewegen, dann zurückkehren, um weitere Anstürme zu vermeiden. :contentReference[oaicite:7]{index=7}",
                    "Bewegung minimieren – Reduziert zufällige Anstürme und Chaos. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Droddas Schreckensfürst",
                mechanics = {
                    "Schwerer Angriff – Überkopfschlag; blocken oder niedergeschlagen werden (|cFF0000BLOCKEN|r). :contentReference[oaicite:9]{index=9}",
                    "Spaltender Wirbel – Kleiner AoE-Wirbel um den Boss. Tank kann absorbieren; andere treten heraus. :contentReference[oaicite:10]{index=10}",
                    "Explodierende Banekins – Beschwört regelmäßig Banekins, die nahe Spielern detonieren. (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:11]{index=11}",
                    "Schalter nach Kampf – Aktiviere Mechanismus im Raum, um Zugbrücke zu senken. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Droddas Lehrling",
                mechanics = {
                    "Anfängliche Adds – Tank sammelt sie auf dem Boss für AoE. :contentReference[oaicite:13]{index=13}",
                    "Schwerer Angriff – Muss geblockt werden (|cFF0000BLOCKEN|r) oder riskiere Niederschlag. :contentReference[oaicite:14]{index=14}",
                    "Eisexplosion – Expandierender AoE unter dem Boss. (|cFF0000BEWEGEN|r) oder erleide schweren Schaden/Niederschlag. :contentReference[oaicite:15]{index=15}",
                    "Entzug (Strahl) – Hebt einen zufälligen Spieler an, heilt Boss. (|c00FFFFBEFREIEN|r) schnell. :contentReference[oaicite:16]{index=16}",
                    "Unterbrechbare Explosion – Boss kanalisiert einen Zauber, der unterbrochen werden kann (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Eisherz",
                mechanics = {
                    "Kegelangriff – Frostkegel auf Tank gerichtet; (|cFF0000BLOCKEN|r) oder zur Seite treten. Andere bleiben hinter dem Boss. :contentReference[oaicite:18]{index=18}",
                    "Eisexplosion – Großer AoE expandiert von Bossmitte. Herausbewegen oder niedergeschlagen werden. :contentReference[oaicite:19]{index=19}",
                    "Schlag – Rote Kreise unter jedem Spieler; erzeugt Draugr-Adds. Tank sammelt sie, vermeide Weglaufen. :contentReference[oaicite:20]{index=20}",
                    "Positionierung – Tank dreht Boss weg, Gruppe dahinter. Ruhig bleiben, es sei denn Bewegung ist erzwungen. :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Uralter Lurcher", -- Note: Same name as in Arx Corinium, description seems to match Arx Corinium's Lurcher too. Check if intended.
                mechanics = {
                    "Giftstrahl – Zielt zufällig auf einen Spieler mit schwerem DoT. Heiler oder blocken/ausweichen. :contentReference[oaicite:22]{index=22}",
                    "Rote Kreise – Schnell heraustreten. Überlappende Kreise verursachen hohen Schaden. :contentReference[oaicite:23]{index=23}",
                    "Wutanfall (~50%) – Erhält Blitzbuff, intensiviert Schaden. Schnell niederbrennen. :contentReference[oaicite:24]{index=24}",
                    "Zusätzliche Adds – Töte oder kontrolliere sie zuerst, wenn möglich. :contentReference[oaicite:25]{index=25}",
                },
            },
            {
                name = "Drodda von Eiskap",
                mechanics = {
                    "Nicht verspottbar – Sie wählt Ziele für Frostblitze. Jeder muss bereit sein zu blocken/heilen. :contentReference[oaicite:26]{index=26}",
                    "Teleport + Eisexplosion – Beim Teleport bildet sich ein großer AoE unter ihr. (|cFF0000BEWEGEN|r) oder One-Shot. :contentReference[oaicite:27]{index=27}",
                    "Eisgeister (~50%) – Zwei Geister erscheinen, können niederschlagen. Tank kann sammeln, Gruppe AoE. :contentReference[oaicite:28]{index=28}",
                    "Eisatronachen (~25%) – Zwei erscheinen mit Frontalangriffen. Stapel sie für AoE. :contentReference[oaicite:29]{index=29}",
                    "Entzug (Strahl) – Zufälliger Spieler wird angehoben, heilt Drodda rapide. (|c00FFFFBEFREIEN|r), um Wipe zu verhindern. :contentReference[oaicite:30]{index=30}",
                    "Formation halten – Vermeide Stapeln, damit du siehst, wer anvisiert wird. Nicht panisch rennen. :contentReference[oaicite:31]{index=31}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 19) Orkaninsel (zoneId=131)
    ----------------------------------------------------------------------------
    [131] = {
        normalId = 13,
        vetId    = 311,
        zoneId   = 131,
        sets     = {188,193,186,275},
        questID  = 4538,
        HM       = 1622,
        SR       = 1620,
        ND       = 1621,
        TR       = nil,
        name     = "Orkaninsel",
        bosses = {
            {
                name = "Sonolia die Matriarchin",
                mechanics = {
                    "Add-Welle – Begleitet von Lamien/Meeresvipern. Entweder töte sie zuerst oder staple sie auf dem Boss (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:0]{index=0}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:1]{index=1}",
                    "Schrei (Resonanz) – Kegel-AoE, der Ziel desorientiert. (|cFF0000BLOCKEN|r oder zur Seite treten). Wenn desorientiert, |c00FFFFBEFREIEN|r. :contentReference[oaicite:2]{index=2}",
                    "Positionierung – Tank dreht sie weg, Gruppe steht dahinter, um Schrei zu vermeiden. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Valaran Sturmrufer",
                mechanics = {
                    "Blitzsturm – Großer AoE im Bereich; bewege dich zur Seite, um längeren Schaden zu vermeiden (|cFF0000BEWEGEN|r). :contentReference[oaicite:4]{index=4}",
                    "Kettenblitz – Leichter Schock für die Gruppe; bufft auch Resistenz des Bosses. Geringe Bedrohung, wenn durchgeheilt. :contentReference[oaicite:5]{index=5}",
                    "Zermalmender Schlag (Schwerer Angriff) – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:6]{index=6}",
                    "Blitzavatar – Beschwört eine Reflexion mit wenig HP. Tank verspottet sie; AoE erledigt sie schnell. :contentReference[oaicite:7]{index=7}",
                    "Zufällige Betäubung – Boss kann einen Spieler betäuben (|c00FFFFBEFREIEN|r). Lass deine Gesundheit nicht zu tief fallen. :contentReference[oaicite:8]{index=8}",
                    "Blitzfeld – Breiter wellenartiger AoE fegt durch den Raum. Tritt zur Seite und lass ihn passieren, bevor du zurückkehrst. :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Yalorasse die Sprecherin",
                mechanics = {
                    "Mehrere Adds – Bogenschützen/Heiler-Gegner schließen sich ihr an. (|cFFD700ADDS ZUERST TÖTEN|r) oder staple sie auf dem Boss. :contentReference[oaicite:10]{index=10}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du zurückgestoßen (|cFF0000BLOCKEN|r). :contentReference[oaicite:11]{index=11}",
                    "Wirbelwind – Kleiner Nahkampf-Wirbel-AoE. Tank kann absorbieren; DPS/Heiler weichen zurück oder blocken. :contentReference[oaicite:12]{index=12}",
                    "Blitzschlag – Wirkt regelmäßig einen kleinen Boden-AoE, schnell herausbewegen. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Sturmfaust",
                mechanics = {
                    "Bodenfaust – Eine große Faust taucht auf, betäubt/schleudert jeden Hoch, der getroffen wird. Meiden oder |c00FFFFBEFREIEN|r. :contentReference[oaicite:14]{index=14}",
                    "Schergen – Beschwört kleinere Kopien. Tank muss sie greifen; sie sterben schnell durch AoE. :contentReference[oaicite:15]{index=15}",
                    "Stampfen – Schnell expandierender roter Kreis; wenn drinnen, wirst du mit schwerem Schaden in die Luft geschleudert (|cFF0000BEWEGEN|r). :contentReference[oaicite:16]{index=16}",
                    "Wutanfall (~25%) – Boss kanalisiert kontinuierliche Blitzimpulse. Heiler hält Gruppe am Leben, brennt Boss schnell nieder. :contentReference[oaicite:17]{index=17}",
                    "Positionierung – Kämpfe ihn in der Mitte, minimales Laufen. Zu viel Bewegung verursacht Chaos. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Kommodore Ohmanil",
                mechanics = {
                    "Viele Adds – Können überwältigen, wenn am Leben gelassen. (|cFFD700ADDS TÖTEN|r) oder staple sie auf Boss für AoE. :contentReference[oaicite:19]{index=19}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:20]{index=20}",
                    "Levitation – Zufälliger Spieler wird in einer lila Kugel aufgehängt. Verbündete können Boss unterbrechen oder Opfer (|c00FFFFBEFREIEN|r). :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Sturmreeve Neidir",
                mechanics = {
                    "Funkenschlag – Großer expandierender AoE unter dem Boss. (|cFF0000BEWEGEN raus|r) oder One-Shot. :contentReference[oaicite:22]{index=22}",
                    "Ansturm – Zielt auf jeden, der zu weit weg ist, oft tödlich. Bleibe nah, um es zu vermeiden. :contentReference[oaicite:23]{index=23}",
                    "Mini-Tornados – Treiben durch die Arena, verursachen Taumeln bei Kontakt. Meiden oder riskiere, in AoE gestoßen zu werden. :contentReference[oaicite:24]{index=24}",
                    "Blitzschlag – Sie hebt ihre Hand, trifft einen zufälligen Spieler mit schwerem Schaden (|cFF0000BLOCKEN|r empfohlen). :contentReference[oaicite:25]{index=25}",
                    "Leichte Angriffe – Ignoriert zufällig Spott, feuert mehrere Treffer auf jemanden. Heiler achtet auf plötzliche HP-Einbrüche. :contentReference[oaicite:26]{index=26}",
                    "Herausforderer – Erhöhte HP/Schaden, schnellere Tornados. Gleiche Mechaniken, bestrafender, wenn nicht gut gehandhabt. :contentReference[oaicite:27]{index=27}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 20) Volenfell (zoneId=22)
    ----------------------------------------------------------------------------
    [22] = {
        normalId = 12,
        vetId    = 304,
        zoneId   = 22,
        sets     = {276,77,102,305},
        questID  = 4432,
        HM       = 1634,
        SR       = 1632,
        ND       = 1633,
        TR       = nil,
        name     = "Volenfell",
        bosses = {
            {
                name = "Wüstenlöwe",
                mechanics = {
                    "Löwinnen-Adds – Vier Löwinnen-Adds erscheinen; Tank staple sie für AoE (|cFFD700ADDS TÖTEN|r). :contentReference[oaicite:0]{index=0}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:1]{index=1}",
                    "Gebrüll – Versetzt Gruppe in Furcht; |c00FFFFBEFREIEN|r schnell oder riskiere einen Folgeangriff. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Quintus Verres",
                mechanics = {
                    "Phase 1 (Krieger) – Nutzt Zweihandwaffe mit schweren Überkopfschlägen; blocken oder niedergeschlagen werden (|cFF0000BLOCKEN|r). Führt gelegentlich einen Wirbelwind-AoE aus – heraustreten. :contentReference[oaicite:3]{index=3}",
                    "Phase 2 (Magier) – Wechselt zu Flammenstab, lässt Feuerkreise fallen. Vermeide es, darin zu stehen. Achte auf zufällige Flammenblitze. :contentReference[oaicite:4]{index=4}",
                    "Phase 3 (Gargoyle) – Beschwört einen monströsen Gargoyle mit Frontalkegel & schwerem Schlag. Wenn du versteinert wirst, |c00FFFFBEFREIEN|r. Bewege dich aus großem Schlag-AoE. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Kochbiss",
                mechanics = {
                    "Adds – Mehrere schwache Adds begleiten den Boss; (|cFFD700ADDS TÖTEN|r) zuerst, um Kampf zu vereinfachen. :contentReference[oaicite:6]{index=6}",
                    "Feuerschlag – Ein großer, sich ausbreitender AoE, der pro Tick schweren Schaden verursacht. Tank kann absorbieren, DPS/Heiler müssen schnell raus. :contentReference[oaicite:7]{index=7}",
                    "Teleport – Boss kann teleportieren und mit nächstem Angriff folgen. Sei bereit zu blocken oder dich zu bewegen. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Bebenskala",
                mechanics = {
                    "Schwanzpeitsche – Boss brüllt, peitscht dann Schwanz in einem Kegel. (|cFF0000BLOCKEN|r oder zur Seite treten). :contentReference[oaicite:9]{index=9}",
                    "Eingraben – Verschwindet unterirdisch und bricht unter einem zufälligen Spieler hervor. (|cFF0000BEWEGEN|r), um Hochschleudern zu vermeiden. :contentReference[oaicite:10]{index=10}",
                    "Positionen beibehalten – Tank vorne, DPS/Heiler dahinter. Zu viel Laufen verursacht Verwirrung. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Instabiles Konstrukt",
                mechanics = {
                    "Blitzschuss – Ein kleiner kreisförmiger Telegraf. (|cFF0000BEWEGEN|r oder blocken), um Schaden zu vermeiden. :contentReference[oaicite:12]{index=12}",
                    "Wirbel – Dreht sich an Ort und Stelle, verursacht AoE-physischen Schaden. Bleibe 3–5m entfernt oder blocke. :contentReference[oaicite:13]{index=13}",
                    "Schlag – Boss rollt sich zusammen, springt und schlägt auf. Kleiner AoE unter Füßen – ausweichen oder heraustreten. :contentReference[oaicite:14]{index=14}",
                    "Bombe – Großer AoE unter einem zufälligen Spieler. Tritt von Verbündeten weg, um Gruppenschaden zu vermeiden. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Wächterrat",
                mechanics = {
                    "Drei Wächter (Stärke, Funke, Seele) – Teilen alle HP. Schaden an einem betrifft auch andere. :contentReference[oaicite:16]{index=16}",
                    "Stärke (Rot) – Nicht verspottbarer Wirbel jagt einen Spieler für hohen physischen Schaden. Kite weg; ziehe nicht durch Gruppe. :contentReference[oaicite:17]{index=17}",
                    "Funke (Blau) – Bleibt meist an Ort und Stelle, lässt Blitzkugeln von oben regnen. Meide oder bewege dich jedes Mal leicht. :contentReference[oaicite:18]{index=18}",
                    "Seele (Gelb) – Kegel-Schwerer Angriff (Enthaupten). Blocken oder ausweichen. Teilt manchmal Schaden oder 'heilt' durch Schadensumverteilung unter Wächtern. :contentReference[oaicite:19]{index=19}",
                    "Koordination – Einige Teams töten Seele zuerst, um Heilung zu begrenzen. Andere stapeln sie für ausgewogenen DPS. Achte einfach auf AoEs und laufe nicht wild herum. :contentReference[oaicite:20]{index=20}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 21) Schwarzherz-Unterschlupf (zoneId=38)
    ----------------------------------------------------------------------------
    [38] = {
        normalId = 15,
        vetId    = 321,
        zoneId   = 38,
        sets     = {308,277,157,309},
        questID  = 4589,
        HM       = 1652,
        SR       = 1650,
        ND       = 1651,
        TR       = nil,
        name     = "Schwarzherz-Unterschlupf",
        bosses = {
            {
                name = "Eisenferse",
                mechanics = {
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:0]{index=0}",
                    "Wirbelwind – Dreht Waffe in einem kleinen AoE. DPS/Heiler treten kurz heraus. :contentReference[oaicite:1]{index=1}",
                    "Drehtritt – Schleudert einen zufälligen Spieler zurück. Halte deinen Rücken zu einer Wand oder riskiere, von der Plattform getreten zu werden. :contentReference[oaicite:2]{index=2}",
                    "Adds – Sammle äußere Adds im Raum für AoE. Vermeide Kämpfe nahe Kanten. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Atarus",
                mechanics = {
                    "Säurespucke – Kegel-AoE vorne. Tank blockt oder tritt zur Seite; andere meiden den Kegel. :contentReference[oaicite:4]{index=4}",
                    "Ansturm – Boss stürmt in langer gerader Linie; roter Streifen-Telegraf. (|cFF0000BEWEGEN|r). :contentReference[oaicite:5]{index=5}",
                    "Stampfen – Kreisförmiger AoE-Niederschlag. Heraustreten, dann wieder angreifen. :contentReference[oaicite:6]{index=6}",
                    "Wutanfall (~30%) – Wird größer, stellt Gesundheit auf ~50% wieder her. Gleiche Mechaniken, mehr Schaden. :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Erster Maat Wellenschneider",
                mechanics = {
                    "Harpyien (Adds) – Fernkämpfer. Tank kann sie hereinziehen. Töte sie mit AoE. :contentReference[oaicite:8]{index=8}",
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:9]{index=9}",
                    "Wirbelwind – Kleiner Stahltornado-AoE. Kurz zurücktreten, dann zurückkehren. :contentReference[oaicite:10]{index=10}",
                    "Schattenhagel – Schnell kanalisierte Projektile treffen alle Spieler hart. (|cFF7F00UNTERBRECHEN|r) oder Wipe riskieren. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Nestmutter",
                mechanics = {
                    "Feuertornado – Ein schwer treffender Wirbel auf den Tank gerichtet. DPS/Heiler meiden Frontbereich des Bosses. :contentReference[oaicite:12]{index=12}",
                    "Zufälliger Teleport – Sie bewegt sich ständig. Formiere dich jedes Mal neu um sie. :contentReference[oaicite:13]{index=13}",
                    "Flammenatem – Großer frontaler Kegel. (|cFF0000BLOCKEN|r oder ausweichen, wenn getankt). Andere bleiben hinter dem Boss. :contentReference[oaicite:14]{index=14}",
                    "Feuerregen – Sie schreit, dann landen Feuerbälle dort, wo Spieler standen. Position halten, bis sie fallen, dann wegtreten. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Hohles Herz",
                mechanics = {
                    "Eisprojektile – Auf Tank gefeuert, hinterlassen DoT-Flecken. Hinter Boss stehen, um zu vermeiden. :contentReference[oaicite:16]{index=16}",
                    "Minimale Bedrohung – Sehr wenig HP. Bleibe aus ihrer Frontlinie, brenne sie schnell nieder. :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Kapitän Schwarzherz",
                mechanics = {
                    "Skelett-Adds – Erscheinen häufig, einschließlich Bogenschützen. Tank zieht sie für AoE heran. :contentReference[oaicite:18]{index=18}",
                    "Wirbel – 360°-Hieb verursacht moderaten physischen Schaden. Heraustreten oder blocken. :contentReference[oaicite:19]{index=19}",
                    "Skelettfluch – Zufälliger Spieler wird niedergeschlagen und für ~30s in ein Skelett verwandelt, verliert normale Fähigkeiten. Nutze leichte/schwere Angriffe. :contentReference[oaicite:20]{index=20}",
                    "Tank als Skelett – Wenn Tank verflucht ist, gibt es keinen Spott. Gruppe muss blocken oder Boss fokussieren, bis Tank zurückkehrt. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 22) Gesegnete Feuerprobe (zoneId=64)
    ----------------------------------------------------------------------------
    [64] = {
        normalId = 14,
        vetId    = 320,
        zoneId   = 64,
        sets     = {72,310,46,278},
        questID  = 4469,
        HM       = 1646,
        SR       = 1644,
        ND       = 1645,
        TR       = nil,
        name     = "Gesegnete Feuerprobe",
        bosses = {
            {
                name = "Grunzer der Schlaue",
                mechanics = {
                    "AOE-Furcht – Brüllt regelmäßig, versetzt alle in Furcht. (|c00FFFFBEFREIEN|r) schnell. :contentReference[oaicite:0]{index=0}",
                    "Massiver frontaler Schlag – Großer Kegelangriff, der dich von der Plattform schleudern kann. Tritt oder rolle zur Seite. :contentReference[oaicite:1]{index=1}",
                    "Positionierung – Tank hält Boss weggedreht; Gruppe steht dahinter, um schwere Treffer zu vermeiden. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Das Rudel",
                mechanics = {
                    "Wellen – Kämpfe zuerst gegen mehrere Wellen schwächerer Gegner. Bleibe zentral, Tank zieht Fernkämpfer heran. :contentReference[oaicite:3]{index=3}",
                    "Vier Bosse – Snagg (Zweihand-Ork mit Wirbelwind), Nusana (Feuermagierin Linienangriff), Dynus (Feuer-/Eismagier), Kayd (Schurke). :contentReference[oaicite:4]{index=4}",
                    "Werwolfverwandlung (~30%) – Jeder Boss verwandelt sich in Werwolfform, erhält Sprung/schweren/Sturmlauf. :contentReference[oaicite:5]{index=5}",
                    "Fokussiere Heiler/Schurke – Dynus (Heiler) & Kayd (Schurke) zuerst zu töten hilft oft. Tank versucht, alle zusammenzuhalten. :contentReference[oaicite:6]{index=6}",
                },
            },
            {
                name = "Teranya die Gesichtlose",
                mechanics = {
                    "Anfängliche Durzogs – Zwei wütende Durzogs erscheinen mit ihr. Tank verspottet sie, damit Gruppe alle zusammen mit AoE treffen kann. :contentReference[oaicite:7]{index=7}",
                    "Schwerer Angriff – Muss geblockt werden (|cFF0000BLOCKEN|r), sonst wirst du niedergeschlagen. :contentReference[oaicite:8]{index=8}",
                    "Wirbelwind – Kleiner Wirbel-AoE. Kurz zurücktreten, dann wieder angreifen. :contentReference[oaicite:9]{index=9}",
                    "Explodierende Banekins – Rennen auf Spieler zu und detonieren. AoE kann Weiche treffen, wenn unkontrolliert. Meiden oder blocken, wenn sie dich erreichen. :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Der Bestienmeister",
                mechanics = {
                    "Welle 1 (Einäscherungskäfer) – Vier flammende Käfer mit pulsierendem Feuer-AoE & Bodenflammen. Töte schnell mit AoE; stehe nicht im Feuer. :contentReference[oaicite:11]{index=11}",
                    "Welle 2 (Stachler) – Riesiger Skorpion, der Gift unter einem Spieler fallen lässt. (|cFF0000BEWEGEN|r) aus dem grünen Giftkreis. :contentReference[oaicite:12]{index=12}",
                    "Welle 3 (Trollkönig) – Großer Troll. Bleibe nah oder er springt. Achte auf Bodenschlag-AoE. Blocken oder zur Seite treten, wenn er schweren Angriff telegrafiert. :contentReference[oaicite:13]{index=13}",
                    "Allgemein – Tank dreht jede Welle weg; Gruppe rennt nicht herum. Fokussiere jede Bedrohung mit kontrollierter Bewegung. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Hauptmann Thoran",
                mechanics = {
                    "Feuerrunen – Auf Boden geworfen, verursachen hohen Schaden, wenn betreten. :contentReference[oaicite:15]{index=15}",
                    "Lila Wolken – Zufällige Stellen in der Arena mit schwerem DoT. Meide sie. :contentReference[oaicite:16]{index=16}",
                    "Lava-Atronach (niedrige HP) – Beschworen bei ~25%. Gibt Thoran einen Schadenschild. Töte den Atronachen, um Schild zu entfernen (er explodiert). :contentReference[oaicite:17]{index=17}",
                    "Adds – Verschiedene Mobs im Bereich. Beseitige sie oder staple sie auf Boss für AoE. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Die Lavakönigin",
                mechanics = {
                    "Lava-Atronachen – Sie wird unverwundbar, während sie sie anstrahlen. Töte sie zuerst, um Schild zu brechen. :contentReference[oaicite:19]{index=19}",
                    "Schwerer Angriff – Ein verzögerter Schwung verursacht massiven Rückstoß. (|cFF0000BLOCKEN|r sofort bei Ausholen). :contentReference[oaicite:20]{index=20}",
                    "Eruptionen – Zufällige kleine rote Kreise, die schweren Schaden verursachen. Achte auf deine Füße. :contentReference[oaicite:21]{index=21}",
                    "Feuerrad – Sie sticht ihr Schwert nieder, sendet Flammenlinien wie Speichen nach außen. Schnell zurückweichen, Linien zur Seite ausweichen, dann zurückkehren. :contentReference[oaicite:22]{index=22}",
                    "Fernkampf-Flammenschüsse – Zielt oft auf entfernte Spieler. Halte Schild oder blocke, wenn du den Cast siehst. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 23) Selenes Netz (zoneId=31)
    ----------------------------------------------------------------------------
    [31] = {
        normalId = 16,
        vetId    = 313,
        zoneId   = 31,
        sets     = {279,123,71,19},
        questID  = 4733,
        HM       = 1640,
        SR       = 1638,
        ND       = 1639,
        TR       = nil,
        name     = "Selenes Netz",
        bosses = {
            {
                name = "Baumthane Kerninn",
                mechanics = {
                    "Anfängliche Adds – Viele Feinde begleiten Kerninn. Tank sammelt sie in der Mitte für AoE. :contentReference[oaicite:0]{index=0}",
                    "Spalten – Führt gelegentlich einen kleinen AoE-Spaltangriff aus; heraustreten oder blocken, wenn du der Tank bist. :contentReference[oaicite:1]{index=1}",
                    "Raben (Heranziehen) – Kerninn hebt Arme, zieht Gruppe nach innen, verursacht moderaten AoE (Raben). (|c00FFFFBEFREIEN|r, wenn betäubt). :contentReference[oaicite:2]{index=2}",
                    "Organisiert bleiben – Nach dem Heranziehen schnell Positionen wieder einnehmen, um Chaos zu vermeiden. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Langklaue",
                mechanics = {
                    "Vorkampf-Katzen – Vier benannte Panther müssen getötet oder zumindest angegriffen werden, damit Langklaue herunterkommt. :contentReference[oaicite:4]{index=4}",
                    "Zusätzliche Senche – Während des Kampfes erscheinen Panthergeister unendlich oft neu. Tank hält sie; am besten nicht töten, sonst erscheinen sie wieder. :contentReference[oaicite:5]{index=5}",
                    "Hagel – Fallender Pfeil-AoE. Tritt zur Seite, um schweren Schaden zu vermeiden. :contentReference[oaicite:6]{index=6}",
                    "Giftwolken – Erscheinen unter oder um ihn herum, verursachen hohen DoT. Herausbewegen. :contentReference[oaicite:7]{index=7}",
                    "Agilität – Boss springt herum. Schnell neu positionieren; halte ihn verspottet. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Königin Aklayah",
                mechanics = {
                    "Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). :contentReference[oaicite:9]{index=9}",
                    "Negativer AoE – Haftet am Aggro-Halter (normalerweise Tank). Andere Spieler halten Abstand; Tank sollte nicht herumlaufen. :contentReference[oaicite:10]{index=10}",
                    "Hoarvore – Kleine Insekten erscheinen wiederholt, leicht mit leichtem AoE zu töten. Nicht zerstreuen. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Faulbalg",
                mechanics = {
                    "Stampfen – Frontaler AoE mit Niederschlag. (|cFF0000BLOCKEN|r als Tank, oder wegtreten) :contentReference[oaicite:12]{index=12}",
                    "Würger – Erscheinen nach Stampfern um die Arena. Harmlos, wenn ignoriert. :contentReference[oaicite:13]{index=13}",
                    "Ansturm – Riesiger linearer roter Telegraf. Er stürmt vorwärts, Niederschlag bei Treffer. Zur Seite treten oder blocken. :contentReference[oaicite:14]{index=14}",
                    "Gebrüll – Versetzt alle in Reichweite in Furcht, ~2–3s. (|c00FFFFBEFREIEN|r), um zufällige Niederschläge zu vermeiden. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Mennir Vielbein",
                mechanics = {
                    "Spinnenschwarm – Konstante kleine Spinnen-Adds mit wenig HP. Töte sie schnell mit AoE. :contentReference[oaicite:16]{index=16}",
                    "Schock-AoE – Sie kanalisiert schädigenden Blitz. (|cFF7F00UNTERBRECHEN|r) wann immer möglich, um große Treffer zu verhindern. :contentReference[oaicite:17]{index=17}",
                    "Fluch/Debuff – Sie zielt manchmal auf einen Spieler für einen DoT oder Betäubung – wieder unterbrechbar. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Selene",
                mechanics = {
                    "Phase 1 (Spinnenform) – Tank hält sie weggedreht; sie trifft mit schweren Spinnenangriffen. Bei ~50% fällt Gruppe in unteren Bereich. :contentReference[oaicite:19]{index=19}",
                    "Phase 2 (Humanoide) – Erhält neue Mechaniken, beschwört Adds (Heiler/Bogenschützen). Tank zieht sie heran oder hält sie verspottet. :contentReference[oaicite:20]{index=20}",
                    "Heranziehende Netze – Ähnlich Kerninns Rabenzug, aber intensiver. Schnell aus dem mittleren AoE bewegen. :contentReference[oaicite:21]{index=21}",
                    "Faulbalg-Geist – Ein großer spektraler Bär taucht auf. Bleibt vor Selene, verursacht massiven Kegelschaden. Tank darf Boss nicht drehen, sonst riskiert Gruppe One-Shot. :contentReference[oaicite:22]{index=22}",
                    "Panther-Geist – Zielt auf entfernte Spieler. Wenn er auf dich zukommt, |cFF0000BLOCKEN|r, sonst nimmst du großen Schaden. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 24) Kammern des Wahnsinns (zoneId=11)
    ----------------------------------------------------------------------------
    [11] = {
        normalId = 17,
        vetId    = 314,
        zoneId   = 11,
        sets     = {280,91,124,311},
        questID  = 4822,
        HM       = 1658,
        SR       = 1656,
        ND       = 1657,
        TR       = nil,
        name     = "Kammern des Wahnsinns",
        bosses = {
            {
                name = "Der Verfluchte",
                mechanics = {
                    "Skelett-Adds – Mehrere einfache Untote begleiten ihn; töte sie, bevor du dich auf den Boss konzentrierst. :contentReference[oaicite:0]{index=0}",
                    "Gefrorener Strom – Ähnlich wie Geister, ein Eis-AoE-Kanal; kann unterbrochen werden (|cFF7F00UNTERBRECHEN|r). :contentReference[oaicite:1]{index=1}",
                    "Lebensentzug – Reflektiert Gruppenschaden auf das Strahlziel. Stoppe Angriffe, während Strahl aktiv ist, um Verbündeten nicht zu töten. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Ulguna Seelenräuberin",
                mechanics = {
                    "Frontale Flammenwelle – Kegel-AoE, der zurückstößt. Tank hält sie von Gruppe weggedreht. :contentReference[oaicite:3]{index=3}",
                    "Levitation/Ersticken – Zufälliger Spieler wird angehoben & hilflos für ~10s; 4 Heilkugeln schweben zum Boss. Töte Kugeln schnell, um Verbündeten zu befreien. :contentReference[oaicite:4]{index=4}",
                    "Spott aufrechterhalten – Sie kann schnell weiche Ziele angreifen, wenn Tank Aggro verliert. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Totenkopf",
                mechanics = {
                    "Anfängliche Adds – Fernkämpfer füllen den Raum. Tank gruppiert sie mittig für AoE. :contentReference[oaicite:6]{index=6}",
                    "Frontaler Schlag – Muss geblockt werden, wenn getankt. Stößt zurück, wenn Block misslingt. :contentReference[oaicite:7]{index=7}",
                    "Skelett-Erscheinungen – Drei auf einmal von Bossfüßen; töte schnell, um explosive Selbstzerstörung zu verhindern. :contentReference[oaicite:8]{index=8}",
                    "Ansturm – Boss rennt in gerader Linie und lässt AoE-Minen fallen. Drehe ihn zu einer Wand, um Lauf zu verkürzen. :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Grothdarr",
                mechanics = {
                    "Schwerer Schlag – Großer Überkopfhieb. (|cFF0000BLOCKEN|r) empfohlen, wenn du Aggro hast. :contentReference[oaicite:10]{index=10}",
                    "Überhitzen/Frontaler AoE – Boss lädt auf & schießt nach vorne. Tank dreht von Gruppe weg. :contentReference[oaicite:11]{index=11}",
                    "Lavaspuren – Zwei Lavaschlangen wandern durch die Arena. Achte auf Füße & bleibe hinter Boss. :contentReference[oaicite:12]{index=12}",
                },
            },
            {
                name = "Achaeraizur",
                mechanics = {
                    "Viele Adds – Zahlreiche Dremora im Bereich. Wenn möglich, vermeide es, alle auf einmal zu aggroen. :contentReference[oaicite:13]{index=13}",
                    "Daedroth-Feueratem – Kegelflamme auf Tank gerichtet. (|cFF0000BLOCKEN oder BEWEGEN|r). :contentReference[oaicite:14]{index=14}",
                    "Feuerspuck-AoEs – Projektile, die niederschlagen, wenn nicht geblockt. Befreien, schnell aus Flamme raus. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Der Uralte",
                mechanics = {
                    "Wächterstrahl – Grüner Dreifachlaser. Hoher Schaden & Niederschlag. Tank dreht Boss weg, damit DPS/Heiler nicht getroffen werden. :contentReference[oaicite:16]{index=16}",
                    "Wirbel – Typischer Wächterwirbel mit AoE-Schaden. Achte auf HP oder trete kurz heraus. :contentReference[oaicite:17]{index=17}",
                    "Wutanfall (niedrige HP) – Schaden intensiviert sich. Schnell beenden mit hohem DPS & solider Heilung. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Iskra das Omen",
                mechanics = {
                    "Flammenwand – Zielt auf einen zufälligen Spieler & atmet Feuer in einer Linie. Tritt zur Seite, wenn es auf dich zielt. :contentReference[oaicite:19]{index=19}",
                    "Sprungschlag – Boss springt hoch oder auf ein entferntes Ziel, schlägt mit großem AoE auf. (|cFF0000BEWEGEN|r) schnell raus. :contentReference[oaicite:20]{index=20}",
                    "Bleibe nah – Wenn du zu weit weg bist, springt er weite Strecken, verschwendet Gruppenzeit. Halte ihn nahe der Mitte. :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Der Wahnsinnige Architekt",
                mechanics = {
                    "Add-Wellen – Beschwört untote Diener. Tank sammelt sie nah, AoE nach Bedarf. :contentReference[oaicite:22]{index=22}",
                    "Grinsender Blitz – Hoher Einzelziel-Fernkampfangriff. Tank hält Spott oder riskiert One-Shot für Weiche. :contentReference[oaicite:23]{index=23}",
                    "Bodenrunen – Lila Telegrafen, die verlangsamen & schaden. Sanft zur Seite treten, nicht Amok laufen. :contentReference[oaicite:24]{index=24}",
                    "Geisterboden – Fackeln leuchten auf, er kanalisiert pinken wirbelnden Boden. (|cFF0000BEWEGEN raus|r) vom Podest weg oder sterben. :contentReference[oaicite:25]{index=25}",
                    "Telekinese (Schutz) – Gegenteiliges Szenario. Bewege dich in seine Schutzkugel oder äußere Gefahren töten dich. :contentReference[oaicite:26]{index=26}",
                    "Herausforderer – Schriftrolle der glorreichen Schlacht erhöht seine HP & Schaden. Zusätzliche Belohnung bei Erfolg. :contentReference[oaicite:27]{index=27}",
                },
            },
        },
    },

} -- Ende von TTDungeon.BaseDungeonInfo_de


-------------------------------------------------------------------------------
-- DLC-VERLIESE - DEUTSCH
-------------------------------------------------------------------------------
TTDungeon.DLCDungeonInfo_de = {

    ----------------------------------------------------------------------------
    -- 1) Weißgoldturm (zoneId=688)
    ----------------------------------------------------------------------------
    [688] = {
        normalId = 288,
        vetId    = 287,
        zoneId   = 688,
        sets     = {184,185,198,183},
        questID  = 5342,
        HM       = 1279,
        SR       = 1275,
        ND       = 1276,
        TR       = nil,
        name     = "Weißgoldturm",
        bosses = {
            {
                name = "Die Adjudikatorin",
                mechanics = {
                    "Einkerkern (Käfige) – Zufälliger Spieler wird in einen brennenden Käfig am Rand geworfen. Muss Schloss knacken oder von Verbündetem befreit werden. :contentReference[oaicite:0]{index=0}",
                    "Zombies – Erscheinen während des Kampfes; töte sie prompt, damit sie nicht überwältigen. :contentReference[oaicite:1]{index=1}",
                    "Flammenwellen – Schmaler Kegelangriff wiederholt sich dreimal. Verursacht schweren Rückstoß/Schaden. Verteilt euch, um zu sehen, auf wen sie zielt, dann bewegt euch zu den Seiten des Bosses. :contentReference[oaicite:2]{index=2}",
                    "Feuertürme – Linke/rechte Säulen werfen Boden-AoEs. Vermeide es, darin zu stehen (|cFF0000BEWEGEN|r). :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Elitegarde (Micella, Otho, Cordius)",
                mechanics = {
                    "3-Boss-Kampf – Jeder hat einzigartige Fähigkeiten; Tank sammelt alle 3, aber Tötungsreihenfolge hilft. :contentReference[oaicite:4]{index=4}",
                    "Micella Carlinus (Tank-Rolle) – Nutzt DK-Fähigkeiten; lässt Banner fallen, betäubt. Fokussiere sie zuerst, um Buffs/Debuffs schnell zu entfernen. :contentReference[oaicite:5]{index=5}",
                    "Cordius Pontifio (DPS-Rolle) – Mix aus Nachtklinge + DK. Teleportationsschlag, Drachenritter-Standarte, Wirbel-AoE. Normalerweise zweites Tötungsziel. :contentReference[oaicite:6]{index=6}",
                    "Otho Numida (Heiler-Rolle) – Leichte Stabangriffe, HoT-Zauber, kann ein 'Feuerrad' (Speichen) wirken. Halte ihn unterbrochen oder töte ihn zuletzt, wenn gut kontrolliert. :contentReference[oaicite:7]{index=7}",
                    "Achte auf überlappende Banner & AoEs. Verteilt euch oder blockt, wenn anvisiert. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Die Planare Hemmerin",
                mechanics = {
                    "Zackenmechanik – Boss kann nur 'verspottet' werden, indem man den Zacken in der Mitte aufhebt. Person mit Zacken erhält stapelnden Feuer-DoT. :contentReference[oaicite:9]{index=9}",
                    "Portale – Zwei Spieler sehen Graustufenbildschirme. Nur sie können diese Risse zerstören; töte sie schnell, sonst erscheinen Adds. :contentReference[oaicite:10]{index=10}",
                    "Sturzflug-Variante:\n    • Rote Phase – Sie bewegt sich langsam, keine Schmelzaura. Tank kann halten oder nähern.\n    • Blaue Phase – Sie ist in blaue Flammen gehüllt, tödliche Nahkampf-Verlangsamungsaura. Kite sie herum oder 'Schwein in der Mitte' mit Zackenweitergabe. :contentReference[oaicite:11]{index=11}",
                    "Flammenkreise – Erscheinen unter Spielern (besonders in roter Phase). Einfach zur Seite treten. :contentReference[oaicite:12]{index=12}",
                    "Koordination – Wechselt, wer den Zacken hat, um tödliche DoT-Stapel zu vermeiden. Halte Boss in blauer Phase in Bewegung, damit sie dich nicht sofort tötet. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Molag Kena",
                mechanics = {
                    "Blitzaspekte x4 (Start + 60%, 30%) – Kena ist geschützt, töte 4 Aspekte um die Arena. Sie explodieren beim Tod; stehe nicht im AoE. :contentReference[oaicite:14]{index=14}",
                    "Rückstoßwellen – Während Schildphase springt & schlägt sie mit Blitzbögen, stößt Spieler zum tödlichen Feuerring. Ausweichen oder in Lücken blocken. :contentReference[oaicite:15]{index=15}",
                    "Blitzwände – Rotierende Linien kreuzen die Arena. Mit ihnen bewegen oder |cFF0000BLOCKEN|r/durchrollen. Im Schweren Modus bewegen sie sich schneller. :contentReference[oaicite:16]{index=16}",
                    "Sturmatronach – Erscheint gelegentlich, zielt auf zufälligen Spieler. Explodiert, wenn er ihn berührt. Sofort töten oder wegkiten. :contentReference[oaicite:17]{index=17}",
                    "Windkegel – Kena beschwört einen großen frontalen Rückstoß. Tank dreht sie von Gruppe weg, blocken, um Position nicht zu verlieren. :contentReference[oaicite:18]{index=18}",
                    "Exekutionsphase (~25%) – Alle Mechaniken kombinieren sich. Zwei Blitzwände gleichzeitig, 2 Sturmatronachen, keine Schildphasen mehr. Schnell beenden. :contentReference[oaicite:19]{index=19}",
                    "Schriftrolle für Schweren Modus – Erhöht ihren Schaden/HP, beschleunigt Blitzwände. Zusätzliche Belohnungen bei Erfolg. :contentReference[oaicite:20]{index=20}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 2) Gefängnis der Kaiserstadt (zoneId=678)
    ----------------------------------------------------------------------------
    [678] = {
        normalId = 289,
        vetId    = 268,
        zoneId   = 678,
        sets     = {195,196,190,164},
        questID  = 5136,
        HM       = 1303,
        SR       = 1128,
        ND       = 1129,
        TR       = nil,
        name     = "Gefängnis der Kaiserstadt",
        bosses = {
            {
                name = "Oberunhold",
                mechanics = {
                    "Sturmlauf (Kegel-AoE) – Schnell treffender Vorwärtskegel. Tank muss blocken und Boss nicht drehen. Jeder andere Getroffene stirbt wahrscheinlich. :contentReference[oaicite:0]{index=0}",
                    "Sprungschlag – Springt auf den Tank (oder Aggro-Ziel). (|cFF0000BLOCKEN|r oder niedergeschlagen werden). :contentReference[oaicite:1]{index=1}",
                    "Kreis der Verderbnis (Unterbrechbar) – Rote Funkenanimation. Wenn nicht unterbrochen, bildet sich ein großer AoE unter dir, der betäubt und schädigt. :contentReference[oaicite:2]{index=2}",
                    "Adds – Erscheinen stetig aus Käfigen/Portal. Müssen schnell getötet werden, sonst wird Gruppe überwältigt. :contentReference[oaicite:3]{index=3}",
                    "Harvester bei ~50% – Boss beschwört einen Harvester aus einem Portal. Priorisiere ihn; er nutzt tödliche AoEs. :contentReference[oaicite:4]{index=4}",
                },
            },
            {
                name = "Ibomez der Fleischformer",
                mechanics = {
                    "Schwerer Angriff (Aufwärtshaken) – Muss geblockt werden, sonst schleudert er Ziel hoch (|cFF0000BLOCKEN|r). Normalerweise auf Tank, wenn Spott gehalten wird. :contentReference[oaicite:5]{index=5}",
                    "Kegelgiftwelle – Tank dreht Boss von Gruppe weg; vermeide es, vorne zu stehen. :contentReference[oaicite:6]{index=6}",
                    "Zermürben (Betäubung) – Boss fesselt einen zufälligen Spieler, lädt tödlichen Schlag auf. (|cFF7F00SCHNELL UNTERBRECHEN|r, um ihn zu retten). :contentReference[oaicite:7]{index=7}",
                    "Schlickpfützen-Ritual (75/50/25%) – Er rennt zur Pfütze in der Mitte, lässt viele Insassen aus Seitentüren erscheinen. Nutze 'Fleischbomben' auf sie, bevor sie die Pfütze erreichen. Sonst bilden sie mehrere Fleischatronachen. :contentReference[oaicite:8]{index=8}",
                    "Fleischatronachen – Müssen fokussiert werden, wenn gebildet. Sie werden irgendwann wütend und verursachen massiven Schaden. :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Grablichtwächter",
                mechanics = {
                    "5 Nekromanten – Um die Insel positioniert. Sie beschwören Skelette, wenn nicht unterbrochen/getötet. Fokussiere sie, sonst erzeugen sie Adds. :contentReference[oaicite:10]{index=10}",
                    "Rückstoßwirbel – Boss duckt sich, löst großen AoE aus, der Spieler wegstößt (möglicherweise ins Giftwasser). (|cFF0000BLOCKEN|r oder heraustreten). :contentReference[oaicite:11]{index=11}",
                    "Laserstrahlen – Dreifache grüne Linien auf Tankfront gezielt. Entweder blocken oder seitlich bewegen. :contentReference[oaicite:12]{index=12}",
                    "Giftbomben – Projektile aus dem umgebenden toxischen Wasser. Wenn sie auf dich landen, |cFF0000BLOCKEN|r, um Betäubung zu vermeiden. :contentReference[oaicite:13]{index=13}",
                    "Gift meiden – Herunterfallen oder ins Wasser gestoßen werden verursacht tödlichen Gift-DoT. :contentReference[oaicite:14]{index=14}",
                },
            },
            {
                name = "Fleischabsomination",
                mechanics = {
                    "Hoarvore – Erscheinen ständig. Ihre Gift-AoEs sind tödlich, wenn gestapelt. Töte sie sofort. :contentReference[oaicite:15]{index=15}",
                    "Hoarvor-Splat (~alle 25%) – Boss bewegt sich zur Mitte, beschwört 4 Kamikaze-Hoarvore, die beim Aufprall explodieren. Verteilt euch, blockt oder weicht ihnen aus. :contentReference[oaicite:16]{index=16}",
                    "Giftkreise – Jeder Spieler erhält einen kleinen Kreis. Ein unglücklicher Spieler wird in einem Ring eingeschlossen – bleibe darin. Andere können Ringkante nicht überqueren oder sterben. Zombies erscheinen währenddessen. :contentReference[oaicite:17]{index=17}",
                    "Schwere Angriffe – Selbst mit Block können sie Tank herumstoßen. Drehe Boss zu Wand oder Zaun, um übermäßiges Neupositionieren zu vermeiden. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Rat des Lordwächters",
                mechanics = {
                    "4 Dremora (Nekromant, Ritter, Berserker, Heiler) – Jeder hat einzigartige Synergie. Töte sie in bester Reihenfolge, damit letzte Geister beherrschbar sind. :contentReference[oaicite:19]{index=19}",
                    "Nekromant – Beschwört ein Totem, das Schaden an ihnen drastisch reduziert. Muss Totem töten oder zerstören, um es zu brechen. Normalerweise erstes Tötungsziel. :contentReference[oaicite:20]{index=20}",
                    "Ritter – Hat einen Ansturm-AoE, kann in Geisterform nicht geblockt werden. Tritt zur Seite. :contentReference[oaicite:21]{index=21}",
                    "Berserker – Zweihandwaffen, nutzt Stahltornado. Blocken oder weggehen. Als Geist musst du ausweichen, da nicht blockbar. :contentReference[oaicite:22]{index=22}",
                    "Heiler – Einfache Heilungen. Leicht unterbrechbar, solange lebendig, unaufhaltsam in Geisterform. Oft zuletzt töten, damit andere kontrolliert bleiben. :contentReference[oaicite:23]{index=23}",
                    "Geisterwiederbelebung – Sobald ein Boss getötet wird, belebt er sich als nicht spottbarer Geist wieder. Er nutzt weiterhin einige Fähigkeiten. Du kannst sie nicht schädigen oder unterbrechen. :contentReference[oaicite:24]{index=24}",
                },
            },
            {
                name = "Lordwächter Dämmer",
                mechanics = {
                    "Teleport & Schlag – Er verschwindet, betäubt den Tank, dann Überkopfschlag. Tank: befreien + blocken, sonst wirst du zerschmettert. :contentReference[oaicite:25]{index=25}",
                    "Schattenkugeln – Blaue Sphären entziehen HP & verlangsamen, wenn du nah stehst. Verteilt euch. :contentReference[oaicite:26]{index=26}",
                    "Meteor (Klein) – Zufälliger Meteor zielt auf einen Spieler. |cFF0000BLOCKEN|r, um Betäubung/Schaden zu vermeiden. :contentReference[oaicite:27]{index=27}",
                    "Maschinengewehr – Schnelle Salven auf einen gewählten Spieler. Dieser Spieler steht hinter Tank, der Schüsse blockt. :contentReference[oaicite:28]{index=28}",
                    "Portale – Erscheinen paarweise. Hineintreten bringt dich zur Decke. Synergie drücken, um sicher zu landen. Du hast nur 2 Nutzungen pro Portal. :contentReference[oaicite:29]{index=29}",
                    "Dunkellichtschlag – Lordwächter fliegt hoch. Jeder auf dem Boden wird sofort getötet. Zwei Spieler müssen schnell in jedes Portal, dann Synergie. :contentReference[oaicite:30]{index=30}",
                    "Schatten (65% & 35%) – Er verschwindet, 4 Schattenklone erscheinen. Nur 1 ist gleichzeitig fest. Tank verspottet alle. DPS tötet den festen Schatten. Meteore fallen auch häufiger. :contentReference[oaicite:31]{index=31}",
                    "Kampf endet, sobald finale 0% erreicht sind. Überlebe mehrere Dunkellicht- & Schattenphasen. :contentReference[oaicite:32]{index=32}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 3) Ruinen von Mazzatun (zoneId=843)
    ----------------------------------------------------------------------------
    [843] = {
        normalId = 293,
        vetId    = 294,
        zoneId   = 843,
        sets     = {256,258,259,260},
        questID  = 5403,
        HM       = 1506,
        SR       = 1507,
        ND       = 1508,
        TR       = nil,
        name     = "Ruinen von Mazzatun",
        bosses   = {
            {
                name = "Zatzu",
                mechanics = {
                    "Aufwärtshaken Schwerer Angriff – Muss geblockt werden, sonst wirst du niedergeschlagen (|cFF0000BLOCKEN|r). Typischerweise auf Tank gerichtet. :contentReference[oaicite:0]{index=0}",
                    "Teleportschlag – Springt nach oben und schlägt auf Aggro-Ziel auf, großer AoE-Flächenschaden. Ausweichen oder bei Landung blocken. Steine zerstreuen sich nach außen – blocken oder ausweichen. :contentReference[oaicite:1]{index=1}",
                    "Steinhagel – Boss kanalisiert einen Wirbel über Kopf, schleudert Steine zufällig (ähnlich Aetherarchiv zweiter Boss). Blocken oder Niederschlag riskieren. :contentReference[oaicite:2]{index=2}",
                    "Position halten – Ständiges Herumlaufen provoziert zusätzlichen AoE von Schlägen. Tank hält ihn still, DPS treten nur bei Bedarf zur Seite. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Mächtiger Chudan",
                mechanics = {
                    "Spucksalve – Ein mehrfach treffender schwerer 'Spuck'-Angriff auf Tank gerichtet. (|cFF0000BLOCKEN|r empfohlen) Jeder Treffer platziert auch Boden-AoE. Drehe Boss NICHT. :contentReference[oaicite:4]{index=4}",
                    "Haj-Mota Adds – Zwei erscheinen regelmäßig. Töte sie oder werde überrannt. Tank sammelt & AoE. :contentReference[oaicite:5]{index=5}",
                    "Bogenschützen – Erscheinen ebenfalls um die Arena; ziehe sie heran oder töte schnell. :contentReference[oaicite:6]{index=6}",
                    "Geschützter Argonier – Geschützt durch eine Blitzblase. Nur durch Chudans Ansturm brechbar. :contentReference[oaicite:7]{index=7}",
                    "Ansturmmechanik – Ein roter AoE folgt einem zufälligen Spieler. Lock ihn zum geschützten Argonier. Kurz vor Aufprall, Ausweichrolle, damit Chudan Schild zerschmettert. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Xal-Nur der Sklaventreiber",
                mechanics = {
                    "Gebrüll – Ein weitreichender AoE, der zurückstößt oder unterbricht. Tank absorbiert, andere stehen außer Reichweite. :contentReference[oaicite:9]{index=9}",
                    "Ansturm – Boss stürmt auf einen entfernten Spieler zu (schwerer Angriff). Wenn Gruppe nach Beginn der Bewegung unterbrechen kann, tu es. Ansonsten blocken, wenn anvisiert. :contentReference[oaicite:10]{index=10}",
                    "Bogenschützen & Trolle – Beschworene Adds in Intervallen. Trolle müssen verspottet/getötet werden. Bogenschützen können mit Wamasu-Trick freigelassen oder manuell getötet werden. :contentReference[oaicite:11]{index=11}",
                    "Eingraben/Stampfen – Ähnlich vMA Behemoth. Er stampft, schleudert Steine über Boden. Seitlich treten oder blocken. :contentReference[oaicite:12]{index=12}",
                    "Spucke “Gewürz” & Geysire (Phase) – Bei bestimmten HP-Schwellen wird Xal-Nur immun. Er spuckt Schleim. Spieler mit Schleim müssen ihn zum aktiven Geysir bringen. Bewegung verlangsamt, achte auf Schlammkrabben & Bossanstürme. :contentReference[oaicite:13]{index=13}",
                    "Wamasu freilassen – Ein Trollbändiger erscheint jede Immunphase. Töte einen Bändiger, um einen Wamasu zu befreien, der hilft, Bogenschützen zu töten. :contentReference[oaicite:14]{index=14}",
                    "Wiederholung – Dieser Zyklus passiert ~3 Mal. Konzentriere dich auf Trolle, handle Schleim schnell ab, halte Boss mittig für einfacheres Management. :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Baumhüterin Na-Kesh",
                mechanics = {
                    "Totems – Sie erzeugt häufig entziehende Totems. Müssen sofort zerstört werden, sonst gehen Gruppenressourcen auf null. :contentReference[oaicite:16]{index=16}",
                    "Add-Wellen – Argonische Bogenschützen, Steinformer, etc. töte sie, sonst wird Raum überwältigt. Tank muss sie sammeln & halten. :contentReference[oaicite:17]{index=17}",
                    "Geisterphasen @70% & 50% – Sie zieht sich in einen Käfig zurück, beschwört entweder Chudans oder Xal-Nurs Geist. Du kannst ihn schnell töten oder Ultimate aufbauen. :contentReference[oaicite:18]{index=18}",
                    "Flüche @70%, 50%, 30% – Ein Spieler erhält Disco-Farbbildschirm, verliert normale Fähigkeiten. Verbündete sehen, welche Statue leuchtet. Bewegt euch zusammen dorthin, damit verfluchter Spieler sie brechen kann. :contentReference[oaicite:19]{index=19}",
                    "Exekutionsphase (~30%) – Sie erhält wirbelnde Wurzel-AoEs, verursachen hohen DoT. Nicht panisch rennen. Halte Mechaniken straff. :contentReference[oaicite:20]{index=20}",
                    "Fokus – Töte immer Totems. Kontrolliere Adds. Reinige Flüche. Jede Stufe kann sich überlappen. Fassung ist entscheidend. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 4) Wiege der Schatten (zoneId=848)
    ----------------------------------------------------------------------------
    [848] = {
        normalId = 295,
        vetId    = 296,
        zoneId   = 848,
        sets     = {257,261,262,263},
        questID  = 5702,
        HM       = 1524,
        SR       = 1525,
        ND       = 1526,
        TR       = nil,
        name     = "Wiege der Schatten",
        bosses = {
            {
                name = "Sithera",
                mechanics = {
                    "Im Dunkeln erleidet Boss nur ~10% Schaden – halte sie im Lichtkreis eines entzündeten Kohlebeckens für vollen Schaden (|cFF0000IMMER im Licht kämpfen|r) :contentReference[oaicite:0]{index=0}",
                    "Zufälliges Giftspucken auf den Aggro-Halter (|cFF0000BLOCKEN|r als Tank, oder schnell zur Seite treten) :contentReference[oaicite:1]{index=1}",
                    "Erzeugt kleinere Spinnen-Adds – schneller AoE hilft. Sie verursachen auch minimales Gift, können aber überwältigen, wenn ignoriert. :contentReference[oaicite:2]{index=2}",
                    "Kohlebecken-Phasen: Bei ~50% erlischt aktuelles Kohlebecken – bewege dich zum nächsten. (|cFFD700KOHLEBECKEN NEU ENTZÜNDEN|r) und bringe Sithera herüber. :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Khephidaen der Spinnenkith",
                mechanics = {
                    "Schwerer Angriff Überkopf – tödlich, wenn nicht geblockt (|cFF0000BLOCKEN|r). Achte auch auf kleine Telegrafen um Boss. :contentReference[oaicite:4]{index=4}",
                    "Große AoE-'Explosions'-Expansionen – tritt heraus, bevor es explodiert, oder blocke als Tank. :contentReference[oaicite:5]{index=5}",
                    "Boss teleportiert zu Kohlebecken & löscht sie. Dunkelheit erzeugt schattenhafte Adds – schnell neu entzünden. :contentReference[oaicite:6]{index=6}",
                    "Achte auf einen wirbelnden Cast – Unterbrechen verhindert großen Schaden. (|cFF7F00UNTERBRECHEN|r empfohlen). :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Votarin von Velidreth",
                mechanics = {
                    "Eine riesige Spinne mit mehreren Gift-AoEs – einige können Weiche töten. (|cFF0000KREISE VERMEIDEN|r) :contentReference[oaicite:8]{index=8}",
                    "Kleine Spinnen treten häufig bei. Töte sie schnell, damit sie sich nicht ansammeln. :contentReference[oaicite:9]{index=9}",
                    "Boss kann versuchen, sich selbst zu heilen, indem er tote Spinnenleichen verschlingt – |cFF7F00UNTERBRECHEN|r, wenn du sie fressen siehst. :contentReference[oaicite:10]{index=10}",
                    "Gelegentliche weite AoE-Explosion bei maximaler Reichweite (|cFF0000BEWEGEN|r). Stehe nicht darin oder garantierter One-Shot. :contentReference[oaicite:11]{index=11}",
                },
            },
            {
                name = "Dranos Velador",
                mechanics = {
                    "Boss steht mittig; Statue sendet rote Energiewellen über Boden – bewegen oder darüber springen. :contentReference[oaicite:12]{index=12}",
                    "Immunitätsphase: Dranos teleportiert, erzeugt 3 'Schatten'. Töten lässt rote Kugeln fallen – alle 3 aufheben beendet Bossimmunität, betäubt Dranos kurz für DPS-Fenster. :contentReference[oaicite:13]{index=13}",
                    "Fesselmechanik: Zwei kleine Adds fesseln (betäuben) ein zufälliges Ziel; Boss lädt schweren Angriff für One-Shot auf. Verbündete müssen fesselnde Adds SCHNELL töten oder unterbrechen. Gefesseltes Opfer muss direkt nach Befreiung blocken. :contentReference[oaicite:14]{index=14}",
                    "Teleportationsschlag-AoEs: Er springt zu jedem Spieler, hinterlässt roten Kreis unter ihnen. Verteilt euch, blockt jeden Schlag, tretet dann aus Kreisen. :contentReference[oaicite:15]{index=15}",
                    "Mörserschüsse: Er schleudert Flammenkugeln, die in großem AoE landen. Tritt zur Seite – anhaltender Effekt kann dich niederschlagen. :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Velidreth",
                mechanics = {
                    "Ressourcenentziehende Kugeln: Vielfarbige Kugeln treiben umher – |cFF0000VERMEIDEN|r, sonst entziehen sie Leben/Ausdauer/Magicka. :contentReference[oaicite:17]{index=17}",
                    "Verschlingen-Ultimate: Sie kanalisiert zufällig auf einen Spieler, verbraucht dessen aufgebautes Ultimate. Nutze Ults prompt. :contentReference[oaicite:18]{index=18}",
                    "Fleischatronachen (@~81% & 51%) – Töte sie. Jeder lässt Synergiekugeln fallen, die 2 Spieler aufheben müssen, um Lichter für Katakomben zu halten. :contentReference[oaicite:19]{index=19}",
                    "Katakomben (@66% & 33%) – Paarweise verbannt, jede Gruppe hat 1 Licht. Navigiere durch Mini-Labyrinth, meide Fallen & Adds. Trenne dich nicht, sonst stirbt unbeleuchteter Spieler. Kehre zum Bossbereich zurück, wenn du Ausgang findest. :contentReference[oaicite:20]{index=20}",
                    "Deckenangriff: “Keinen Muskel rühren!” – Wenn doch, One-Shot-Aufspießung. Warte auf Farbwechsel & Rumpeln, dann Ausweichrolle im letzten Moment. :contentReference[oaicite:21]{index=21}",
                    "Endphase ~30% – Keine Katakomben mehr, aber Kugeln, Verschlingen & Überkopfsprünge bleiben. Schnell niederbrennen. :contentReference[oaicite:22]{index=22}",
                    "Wiederbelebungstrick: Sie unterbricht Wiederbelebungsversuche mit schnellem Cast. Tank/DPS können Schein-Wiederbelebung machen, sie dann unterbrechen, dann Wiederbelebung sicher beenden. :contentReference[oaicite:23]{index=23}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 5) Blutquellschmiede (zoneId=973)
    ----------------------------------------------------------------------------
    [973] = {
        normalId = 324,
        vetId    = 325,
        zoneId   = 973,
        sets     = {340,341,338,339},
        questID  = 5889,
        HM       = 1696,
        SR       = 1694,
        ND       = 1695,
        TR       = nil,
        name     = "Blutquellschmiede",
        bosses   = {
            {
                name = "Mathgamain",
                mechanics = {
                    "Boss hat einen kegelförmigen schweren Angriff – muss geblockt werden, sonst One-Shot. (|cFF0000BLOCKEN|r) :contentReference[oaicite:0]{index=0}",
                    "Adds erscheinen in Wellen bei ~75%, 50% und 25%. Tank sammelt sie; DPS tötet sie schnell. :contentReference[oaicite:1]{index=1}",
                    "Mögliche Würger können erscheinen – fokussiere sie schnell, um schweren Gift-DoT zu vermeiden. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Caillaoife",
                mechanics = {
                    "Bei ~75/50/25% HP wird Boss immun, bildet eine ‘Wald’-Barriere. Adds erscheinen (Bären, Würger, etc.) – töte sie, um Schild zu entfernen. :contentReference[oaicite:3]{index=3}",
                    "Boss kanalisiert einen großen frontalen AoE-Felsenschlag – Tank muss von Gruppe wegdrehen. (|cFF0000BLOCKEN|r oder ausweichen) :contentReference[oaicite:4]{index=4}",
                    "Regelmäßig wird ein zufälliger Spieler mit einer Eiswirbel-Aura ausgewählt – Boss feuert Eisangriffe auf ihn. Bewege dich vorsichtig, Heilung aufrechterhalten. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Steinern Herz",
                mechanics = {
                    "“Space Invaders” – Boss kanalisiert viele kleine feurige Projektile, die über Boden wandern. Wackle links/rechts, um ihnen auszuweichen. :contentReference[oaicite:6]{index=6}",
                    "Beschwört Steinatronachen – wenn nicht schnell getötet, werden sie wütend und platzieren rote AoEs unter Spielern. (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:7]{index=7}",
                    "Verbreitet zufällige persistente Flammenkreise – weiche ihnen aus, sie stapeln sich schnell. :contentReference[oaicite:8]{index=8}",
                    "Bei ~25% HP verwurzelt Spieler gelegentlich – Ausweichrolle zum Befreien oder schweren Burst-Schaden erleiden. :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Galchobhar",
                mechanics = {
                    "Schwerer Angriff formt einen Mini-Vulkan – Tank muss darauf stehen und blocken, sonst wird Gruppe von tödlichen Feuerbällen getroffen. :contentReference[oaicite:10]{index=10}",
                    "Feuershalk erscheint – wenn er dich mit Feuerball anvisiert, springe auf den äußeren geschmolzenen Fels, um ihn aufzulösen. :contentReference[oaicite:11]{index=11}",
                    "Bei ~50% beschwört Boss Steinatronachen; töte sie schnell, sonst erzeugen sie mehrere Boden-AoEs. :contentReference[oaicite:12]{index=12}",
                    "Boss wirft Waffe mitten im Kampf – jeder muss auf eine separate Plattform um die Arena springen, um einer riesigen Bodenexplosion zu entgehen. Teile keine Pads, sonst sinken sie schneller. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Gherig Bullenblut (Trio)",
                mechanics = {
                    "3 Bosse: Gherig (Haupt), Feuerhaut-Add (kettet 2 Spieler, muss unterbrochen werden), und ein Heiler-Add. :contentReference[oaicite:14]{index=14}",
                    "Tötungsreihenfolge typischerweise: Feuerhaut-Minotaurus (One-Shot-Kettenmechanik) > Heiler-Add > Gherig. :contentReference[oaicite:15]{index=15}",
                    "Tank sammelt alle 3, hält sie davon ab, AoEs auf Gruppe zu wirbeln. Achte auf Boden-AoE nach Kettenbruch. :contentReference[oaicite:16]{index=16}",
                },
            },
            {
                name = "Erdblut-Amalgam",
                mechanics = {
                    "Boss schleudert Lavapools, die wachsen & Feuerkugeln auf Spieler speien – halte dich von ihnen fern. :contentReference[oaicite:17]{index=17}",
                    "Wird regelmäßig immun & lässt Steine von oben regnen – weiche den fallenden Steinen aus. (|cFF0000BEWEGEN|r) :contentReference[oaicite:18]{index=18}",
                    "Bei ~80% & ~50% teilt sich Boss in 2, dann insgesamt 3 Kopien. Jede hat gleiche Mechaniken – mehrere schwere Angriffe & mehr Lavapools. :contentReference[oaicite:19]{index=19}",
                    "Beste Taktik: Phasen schnell vorantreiben & kleinere Kopien zuerst töten, um überlappende Lavapools zu reduzieren. :contentReference[oaicite:20]{index=20}",
                    "Herausforderer: Kohlebecken deaktiviert, Boss trifft härter/hat mehr HP. Keine Betäubungen oder Lavareinigungen aus Umgebung. :contentReference[oaicite:21]{index=21}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 6) Falkenring (zoneId=974)
    ----------------------------------------------------------------------------
    [974] = {
        normalId = 368,
        vetId    = 369,
        zoneId   = 974,
        sets     = {336,337,342,335},
        questID  = 5891,
        HM       = 1704,
        SR       = 1702,
        ND       = 1703,
        TR       = nil,
        name     = "Falkenring",
        bosses   = {
            {
                name = "Morrigh Bullenblut",
                mechanics = {
                    "Hat einen Minotaurus-Verbündeten – fokussiere zuerst den Minotaurus, dann brenne sie nieder. :contentReference[oaicite:0]{index=0}",
                    "Bei ~50% HP hebt sie eine Schutzkugel. Jeder muss darin stehen, um schwerem Flächenbombardement zu entgehen. :contentReference[oaicite:1]{index=1}",
                    "Sie legt kleine Boden-AoEs – schnell heraustreten. Kein panisches Rennen nötig. :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Belagerungsmammut",
                mechanics = {
                    "Tank: halte das Mammut von der Gruppe weggedreht – schwere Frontalangriffe. :contentReference[oaicite:3]{index=3}",
                    "Projektilfeuer: Bogenschützen schleudern flammende AoEs aufs Schlachtfeld – bleibe in Bewegung, um auszuweichen. :contentReference[oaicite:4]{index=4}",
                    "Stampfen – Unter ~50% HP bäumt sich Mammut auf. Jeder muss BLOCKEN oder wird getötet. :contentReference[oaicite:5]{index=5}",
                },
            },
            {
                name = "Cernunnon",
                mechanics = {
                    "Drei Bosse (Magier, Bogenschütze, Nahkämpfer) erscheinen nacheinander. Jeder muss getötet werden, dann wird seine Seele zu einem Altar getragen. (|cFF0000BEWEGEN|r beim Tragen, sonst wirst du von Feinden festgehalten). :contentReference[oaicite:6]{index=6}",
                    "Wenn du ihre Seelen nicht zum Altar bringst, beleben sie sich wieder. Wiederholt sich, bis alle Seelen platziert sind. :contentReference[oaicite:7]{index=7}",
                    "Hauptboss taucht nach Platzieren von 3 Seelen auf. Beschwört Skelett-Adds; töte sie schnell. :contentReference[oaicite:8]{index=8}",
                    "Während Kampf mit Hauptboss erhält jeder Spieler einen Überkopf-AoE-Kometen – verteilt euch und |cFF0000BLOCKEN|r, um tödlichen Schaden zu vermeiden. :contentReference[oaicite:9]{index=9}",
                    "Eine wirbelnde Grenze fängt dich ein – Heraustreten tötet dich. Meide wirbelnde Geister (Furchteffekt). :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Todesfürst Bjarfrud Skjoralmor",
                mechanics = {
                    "Konstante Wellen von Untoten – töte sie nah am Boss, damit ihre Leichen sich sammeln. :contentReference[oaicite:11]{index=11}",
                    "Reinigen! – Jeder tote Add hinterlässt einen ‘verdorbenen Körper’, der mit naher Urnensynergie gereinigt werden muss. Wenn zu viele bleiben, kann eine große Explosion Gruppe auslöschen. :contentReference[oaicite:12]{index=12}",
                    "Boss kanalisiert einen direkten frontalen Atem – Tank hält ihn von Gruppe weggedreht. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Domihaus der Blutgehörnte",
                mechanics = {
                    "Behält stationäre Mittelposition bei – Tank muss Spott halten, sonst trifft er zufällige Spieler mit Hadoken, tötet sie. :contentReference[oaicite:14]{index=14}",
                    "Schrei bei 70/50/30/10/5% HP – One-Shot, wenn nicht hinter einer Säule. Säulen brechen nach jedem Schrei, Gruppe muss koordinieren. :contentReference[oaicite:15]{index=15}",
                    "Heranziehen & Feuerspuren – Er zieht Spieler heran, dann lässt jeder mehrere Feuer-AoEs hinter sich fallen – |cFF0000NICHT stapeln|r und rückwärts (oder seitwärts) gehen, um Überlappung zu vermeiden. :contentReference[oaicite:16]{index=16}",
                    "Steinphase – Beschwört 4 Flammenatronachen, wird unzielbar – töte sie schnell. :contentReference[oaicite:17]{index=17}",
                    "Bodenschlag – Feuerbälle kreuzen Raum von Bossmitte. Verstecke dich hinter gewählter Säule, um tödliche Treffer zu vermeiden. :contentReference[oaicite:18]{index=18}",
                    "Exekution (~25% HP) – Erhält Schild, spammt Add-Beschwörungen. Brenne sie mit AoE nieder oder sie überwältigen dich. :contentReference[oaicite:19]{index=19}",
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 7) Gipfel der Schuppenruferin (zoneId=1010)
    ----------------------------------------------------------------------------
    [1010] = {
        normalId = 418,
        vetId    = 419,
        zoneId   = 1010,
        sets     = {348,350,346,347},
        questID  = 6065,
        HM       = 1981,
        SR       = 1979,
        ND       = 1980,
        TR       = 1983,
        name     = "Gipfel der Schuppenruferin",
        bosses = {
            {
                name = "Orzun der Übelriechende & Rinaerus der Ranzige",
                mechanics = {
                    "Trenne die beiden Bosse, damit ihre Kreise nicht überlappen oder sie wütend werden – Tank hält den Nahkampf-Oger (Orzun) vom Fernkampf-Oger (Rinaerus) fern. :contentReference[oaicite:0]{index=0}",
                    "Rinaerus kanalisiert, um Skeever zu beschwören – |cFF7F00UNTERBRECHEN|r ihn oder töte Skeever schnell. :contentReference[oaicite:1]{index=1}",
                    "Schneesturm (von Rinaerus) platziert bewegliche Eisstacheln auf Boden – Berühren betäubt dich. Am Ende wirkt Orzun Schneebodenbeben, das dich tötet, es sei denn du bist 'gefroren' durch Stehen im Stachelkreis (|cFF0000ABSICHTLICH hineinbewegen|r!). :contentReference[oaicite:2]{index=2}",
                    "Rinaerus kann einen großen Eisangriff kanalisieren: verstecke dich hinter Eissäulen bei Bedarf, sonst kann er dich töten (|cFF0000SICHTLINIE blockieren|r). :contentReference[oaicite:3]{index=3}",
                    "Töte sie nahezu gleichzeitig – einen zu früh zu töten erzürnt den anderen. :contentReference[oaicite:4]{index=4}",
                },
            },
            {
                name = "Doylemish Eisenherz",
                mechanics = {
                    "Schwerer Angriff / Blutung auf Tank – muss starke Heilung oder Blocks aufrechterhalten. :contentReference[oaicite:5]{index=5}",
                    "In Intervallen erscheinen schwebende rote Sphären, zielen auf Spieler. Wenn getroffen, verwandeln sie dich in Stein – Verbündeter muss dich befreien oder Boss kanalisiert tödlichen Strahl (kann unterbrochen werden). :contentReference[oaicite:6]{index=6}",
                    "Eisgeist-Adds erscheinen – töte sie schnell mit AoE. :contentReference[oaicite:7]{index=7}",
                    "Verteilt euch, um Sphären besser zu handhaben; laufe nicht weit weg, wenn versteinert, sonst bist du außer Synergiereichweite. :contentReference[oaicite:8]{index=8}",
                },
            },
            {
                name = "Matriarchin Aldis",
                mechanics = {
                    "Arena hat Eiswasser, das tödlichen Schaden verursacht – |cFF0000BLEIBE auf sicheren Plattformen|r. :contentReference[oaicite:9]{index=9}",
                    "Sie stampft Boden in weitem AoE – |cFF0000BEWEGEN raus oder BLOCKEN|r. :contentReference[oaicite:10]{index=10}",
                    "Verdorbene Leimeniden erscheinen alle 10% HP – töte sie schnell, um Giftgeysire & große AoE-Probleme zu vermeiden. :contentReference[oaicite:11]{index=11}",
                    "Ein rotierendes 'Loch' erscheint unter Bossfüßen mit wirbelnden Eisstacheln – Tank steht darauf, um Schaden zu 'stopfen', sonst wird Gruppe hart getroffen. :contentReference[oaicite:12]{index=12}",
                    "Gelegentlicher Furchtschrei – |c00FFFFBEFREIEN|r schnell oder riskiere, ins Eiswasser gestoßen zu werden. :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Seuchenmischer Mortieu",
                mechanics = {
                    "Toxischer Aufbau – Gruppe sammelt Seuchenstapel an, verursacht ansteigenden DoT & Debuffs. :contentReference[oaicite:14]{index=14}",
                    "Töte spezifizierte Adds (Imp, Würger, Käfer) pro Jorvulds Ruf – er wirft einen Trank, sobald sie tot sind, reinigt deine Seuche. :contentReference[oaicite:15]{index=15}",
                    "Tank: Muss auf Giftgittern stehen, die grüne Strahlen aussenden – BLOCKEN, sonst erleidet Gruppe massiven Giftschaden. :contentReference[oaicite:16]{index=16}",
                    "Mortieu nutzt Bogen-ähnliche Schüsse – |cFF0000AUSWEICHEN oder BLOCKEN|r. Auch “Ziel anvisieren” Scharfschuss kann unterbrochen werden. :contentReference[oaicite:17]{index=17}",
                    "Wenn gereinigt, erhält Gruppe großen Schadensbuff – brenne Boss & achte auf beschworenen Wachen-Add. :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Zaan die Schuppenruferin",
                mechanics = {
                    "Adds am Anfang (Eisatronach & Verdorbene Leimenide) – vermeide Stehen in ihren Todes-AoEs (Eisstacheln & Geysir). Du brauchst sie für finale Synergie, um kommende Giftwelle zu überleben. :contentReference[oaicite:19]{index=19}",
                    "Alle 20% HP: Zwei oder drei große Eis-Adds erscheinen – töte schnell oder Gruppe wird zu Tode gefroren. Dann erscheinen 3 Statuen – nach deren Tötung überflutet gesamter Boden mit Gift. Jeder muss in separater Mechanik stehen (Eis, Geysir, Laser oder Schild), um zu überleben. :contentReference[oaicite:20]{index=20}",
                    "Giftatem von Drachenstatuen – zufällige Kegel-One-Shots von den Rändern. Gruppe steht in fester Formation & tritt seitlich aus. :contentReference[oaicite:21]{index=21}",
                    "Feueratem auf zufälligen Spieler – kleinteiliges Wellenmuster, einfach ruhig seitlich aus jeder Welle treten. :contentReference[oaicite:22]{index=22}",
                    "Feuerstrahl – Sie packt ein Ziel in der Luft – andere können Strahl blocken, um Schaden zu teilen. Wenn allein gelassen, stirbt Opfer schnell. :contentReference[oaicite:23]{index=23}",
                    "Schildphasen – Zaan nimmt ihren Schild wieder auf, beschwört frühere Adds. Wiederhole alle 20%. Herausforderer fügt zusätzliche Schritte für Synergie und Timing hinzu. :contentReference[oaicite:24]{index=24}",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 8) Krallenhort (zoneId=1009)
    -------------------------------------------------------------------------------
    [1009] = {
        normalId = 420,
        vetId    = 421,
        zoneId   = 1009,
        sets     = {344,345,349,343},
        questID  = 6064,
        HM       = 1965,
        SR       = 1963,
        ND       = 1964,
        TR       = 2102,
        name     = "Krallenhort",
        bosses = {
            {
                name = "Lizabeth Charnis",
                mechanics = {
                    "Kampf verläuft in WELLENPHASEN, während Lizabeth Untote beschwört (|cFFD700Adds|r).",
                    "Jede Welle enthält Knochenkolosse, Skelette und geisterhafte Geister (|cFFD700Schnell beseitigen|r).",
                    "Achte auf große fliegende Schädel, die durch den Raum wirbeln (|cFF0000AUSWEICHEN/BLOCKEN|r).",
                    "Ziemlich zentral zu bleiben hilft, Wellen-Erscheinungen zu managen.",
                },
            },
            {
                name = "Kadavermenagerie",
                mechanics = {
                    "Begegnung hat |cFFD7003 Hauptbosse|r (Bär, Guar, Senche-Tiger) + 3 explodierende Wölfe.",
                    "|cFF0000Senche-Tiger|r: Unterbrich Sprung & Fesseln oder er tötet gefesselten Spieler!",
                    "|cFF0000Guar|r: Fernkampf-Giftspucken, leicht zu töten, aber erscheint später wieder.",
                    "|cFF0000Wölfe|r: Jagen Spieler und explodieren; Tank kann blocken oder Gruppe kann sie schnell töten.",
                    "|cFF0000Bär|r: Frontaler schwerer Angriff & ein Schadensschild. Belebt sich wieder, wenn nicht schnell erledigt.",
                },
            },
            {
                name = "Caluurion",
                mechanics = {
                    "Lich-Boss in der Mitte, wirkt expandierende AoEs & Bodenspritzer (|cFF0000BEWEGEN|r).",
                    "Beschwört Totems (Gift, Schock oder Adds). |cFFD700Zerstöre|r sie, sonst wird Boss später immun.",
                    "Skelett-Diener erscheinen aus Totems; mache schnellen AoE, um Wurzel/Betäubungsspam zu vermeiden.",
                    "Bei ~25% HP löst Ignorieren eines Totems Bossimmunität aus. Also handle Totems durchgehend ab!",
                },
            },
            {
                name = "Ulfnor und Sabina Cedus",
                mechanics = {
                    "|cFFD700Duo-Kampf|r: Ulfnor (schwere Feuerangriffe), Sabinas Geist (kettet zufälligen Spieler).",
                    "Sabinas Kette muss |cFF7F00SCHNELL UNTERBROCHEN|r werden, sonst tötet Ulfnor das gefesselte Ziel!",
                    "Er sendet auch Kegel- oder springende Flammenbögen – |cFF0000AUSWEICHEN/BLOCKEN|r oder Brand-DoT reinigen.",
                    "Bei niedriger HP stößt Ulfnor den Tank durch den Raum. Töte ihn schnell, bevor er ihn aufspießt!",
                },
            },
            {
                name = "Thurvokun & Orryn der Schwarze",
                mechanics = {
                    "|cFF7F00Orryn|r teleportiert herum und kanalisiert schnellen Schädelhagel – |cFF7F00SOFORT UNTERBRECHEN|r, sonst schmilzt Gruppe!",
                    "|cFF0000Giftpfützen|r: Thurvokun lässt sie auf Tank fallen – platziere sie vorsichtig um die Mitte. Laufe nicht wild herum.",
                    "Jeder schwere Angriff erzeugt 2 Shalks unter Tank – |cFFD700Töte oder wurzle|r sie schnell, damit Tank nicht überwältigt wird.",
                    "|cFFD700Kristalle (85/75/65/55%)|r: Jeder erzeugt einen Knochenkoloss & Adds – zerstöre Kristall & töte Koloss, um Wiederholungen zu stoppen.",
                    "|cFFA500Geisterphase (~45%)|r: Orryn beschwört unaufhaltsame Geisterlinien. Ein goldener Verbündeter erzeugt eine Wand – |cFF0000VERSTECKE dich dahinter|r oder stirb bei Kontakt!",
                    "|cFF0000Endphase (50%->0%)|r: Orryn belebt Thurvokun wieder. Geisterlinien kehren ohne Hilfe zurück – finde die |cFF0000Lücke|r und bewege dich schnell hindurch. Koloss-Add-Erscheinungen kommen weiterhin in 10%-Intervallen! Wenn er Wand erklimmt & brüllt, befreie dich von Furcht & greife goldene Kreise vor dem Giftatem!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 9) Mondjägerfeste (zoneId=1052)
    -------------------------------------------------------------------------------
    [1052] = {
        normalId = 426,
        vetId    = 427,
        zoneId   = 1052,
        sets     = {404,398,402,403},
        questID  = 6186,
        HM       = 2154,
        SR       = 2155,
        ND       = 2156,
        TR       = 2159,
        name     = "Mondjägerfeste",
        bosses   = {
            {
                name = "Kerkermeister Melitus",
                mechanics = {
                    "Großer AoE wächst & explodiert in mehrere schnelle rote Kreise – bleibe |cFF0000VERTEILT|r und |cFF0000BEWEGE|r dich, um ihnen auszuweichen.",
                    "Blutfontänen erscheinen unter jedem Spieler – |cFF0000NICHT STAPELN|r, halte Abstand, um Überlappung zu vermeiden.",
                    "Werwolf-Adds (~80%, ~51%, ~31%) – (|cFFD700ADDS TÖTEN|r). Ihre springenden schweren Angriffe können töten, wenn nicht ausgewichen.",
                    "Unterbrechen oder Sterben: Boss lädt großen Überkopfschlag auf – (|cFF7F00SCHNELL UNTERBRECHEN|r), sonst tötet er Tank sofort.",
                },
            },
            {
                name = "Heckenlabyrinth-Wächter",
                mechanics = {
                    "Wurzel: Boss wurzelt alle – (|c00FFFFBEFREIEN|r oder |cFF0000AUSWEICHEN|r), bevor großer Schaden trifft.",
                    "Schwerer Angriff & Spalten – (|cFF0000BLOCKEN|r als Tank) oder zur Seite ausweichen. Halte Boss in Mitte, weg von Würgern.",
                    "Würger an Rändern können Spieler fesseln – zwei DPS durchstreifen paarweise, um Spriggans & Würger im Labyrinth zu töten.",
                    "Spriggans heilen Boss – (|cFFD700TÖTE sie|r), damit Wächter-HP sinken kann.",
                },
            },
            {
                name = "Mylenne Mondruferin",
                mechanics = {
                    "Sprung fesselt einen Spieler – (|cFF7F00SCHNELL UNTERBRECHEN|r), sonst stirbt gefesseltes Ziel.",
                    "Schwerer Angriff auf Tank – (|cFF0000BLOCKEN|r). Wenn auf DPS/Heiler gezielt, |cFF0000AUSWEICHEN|r oder One-Shot.",
                    "Wölfe erscheinen in Wellen – (|cFFD700TÖTE|r sie), bevor Fokus wieder auf Boss geht.",
                    "Wächter wirken Blitz-AoEs – verteilt euch, bleibt in Bewegung. Stapelt nicht, sonst überlappt ihr Schaden.",
                },
            },
            {
                name = "Archivar Ernarde",
                mechanics = {
                    "Add-Wellen (~76%, ~56%, ~36%) – Werwölfe können töten. (|cFFD700FOKUSSIERE Adds|r) schnell in einer Ecke.",
                    "Blitz-AoE unter einem zufälligen Spieler – bewege dich von Gruppe weg, bis er explodiert.",
                    "Schildblase fängt einen Spieler – (|cFFD700DPS ZERSTÖRT|r) Schild, sonst stirbt dieser Spieler.",
                    "Runenroulette: Boss wählt ein Symbol über Kopf. Jeder Spieler muss in passendem Runenkreis stehen oder wird getötet.",
                },
            },
            {
                name = "Vykosa die Aufgestiegene",
                mechanics = {
                    "Zwei Wolfsbegleiter teilen Kette – verspotte & töte roten Wolf zuerst, dann grauen. Weiche ihren Sprüngen aus oder stirb.",
                    "Boss schwerer Angriff – (|cFF0000BLOCKEN|r). Tank erleidet starke Blutungen – Heiler nutzt starke Heilungen.",
                    "Furchttotem – mittlerer AoE. (|c00FFFFBEFREIEN|r), wenn gefürchtet. Meide es, darin zu stehen.",
                    "Mehrere Wellen von Werwölfen & Wächtern bei festen HP – (|cFFD700ADDS TÖTEN|r). Wächter wirken Blitzfelder – verteilt euch.",
                    "Archivar-Geist @30%: Runenroulette kehrt zurück – jeder Spieler muss wieder passende Rune finden.",
                    "Bei ~20% beide Wölfe entfesselt – töte sie erneut, beende dann Boss vorsichtig.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 10) Marsch der Aufopferung (zoneId=1055)
    -------------------------------------------------------------------------------
    [1055] = {
        normalId = 428,
        vetId    = 429,
        zoneId   = 1055,
        sets     = {400,397,401,399},
        questID  = 6188,
        HM       = 2164,
        SR       = 2165,
        ND       = 2166,
        TR       = 2168,
        name     = "Marsch der Aufopferung",
        bosses   = {
            {
                name = "Die Wyrd-Schwestern",
                mechanics = {
                    "Drei Schwestern: Ursus (S&B), Rangifer (Heiler), Strigidae (Bogenschütze). |cFFD700Tötungsreihenfolge|r oft Ursus → Rangifer → Strigidae.",
                    "Ursus: schwerer Angriff kann Nicht-Tanks töten – (|cFF0000BLOCKEN|r als Tank) oder ausweichen, wenn auf dich gezielt. Sie kann auch ein entferntes Ziel 'Anstürmen' (|cFF0000BLOCKEN oder AUSWEICHEN|r).",
                    "Rangifer: versucht andere zu heilen – (|cFF7F00UNTERBRECHEN|r sie). Halte Boss von Gruppe weggedreht und staple sie mit Ursus, wenn möglich.",
                    "Strigidae: hat eine blaue Stille-Aura. Darin stehen blockiert Magicka-Fähigkeiten/Ultimates. Sie nutzt |cFF0000Pfeilsprühen|r & Teleportationsschlag – schnell herausbewegen.",
                },
            },
            {
                name = "Aghaedh von der Sonnenwende",
                mechanics = {
                    "Würger um die Arena schießen auf Spieler – können getötet oder gegengeheilt werden. Heilung muss stetig sein, wenn ignoriert.",
                    "Lurcher erscheinen bei ~70%, 55%, 25% HP – (|cFFD700Fokussiere Lurcher|r). Wenn sie sterben, lässt jeder Synergiekugeln fallen. Hebe sie auf oder riskiere später tödlichen AoE.",
                    "Boss kanalisiert große Explosion, wenn du Synergiebuff nicht hast – One-Shot. Stelle sicher, dass du Lurcher-Synergie aufhebst!",
                    "Tank: halte Boss weggedreht und sammle Adds. DPS brennt Lurcher schnell nieder und achtet auf Füße für zufällige AoEs.",
                },
            },
            {
                name = "Dagrund der Stämmige",
                mechanics = {
                    "Nutzt |cFF0000Elementarbögen|r (Feuer, Eis, Blitz) bei bestimmten HP – weiche diesen breiten/springenden Projektilen aus oder blocke, sonst massiver Schaden.",
                    "Schwerer Angriff auf Tank – (|cFF0000BLOCKEN|r). Auf Nicht-Tanks gezielt, muss ausgewichen werden oder tödlich.",
                    "Sprungangriff: springt, landet, schießt vier schnelle AoEs auf jeden Spieler – |cFF0000AUSWEICHROLLE|r oder getötet werden.",
                    "Bogenschützen erscheinen alle ~10% HP – (|cFFD700ADDS ZUERST TÖTEN|r). Sie lassen Elementar-AoEs unter Spielern fallen. Nicht überwältigt werden; fokussiere sie schnell.",
                },
            },
            {
                name = "Tarcyr",
                mechanics = {
                    "Adds, die Spieler mit Kanalisierung fesseln – (|cFFD700UNTERBRECHEN & fokussieren|r sie). Wenn nicht befreit, wird gefesselter Spieler getötet.",
                    "Feuerspur: Tarcyr sprintet, hinterlässt Flammen auf Boden. Tank spottet neu & hält Boss danach von Gruppe fern.",
                    "Stampede: sendet Geisterhirsche zu jedem Spieler – (|cFF0000BLOCKEN|r oder ausweichen), sonst wirst du niedergeschlagen.",
                    "Blitzstampfen: Tarcyr stampft wiederholt Blitzimpulse – (|cFF7F00UNTERBRECHEN|r), sonst kann Gruppe wipen.",
                    "Jagdphase (@80%, 55%, 20%): jeder muss schleichen/verstecken, um erzwungenes Hochschleudern zu vermeiden. 3 Synergieaktivierungen vom wandernden Irrlicht, um Phase zu beenden. Tarnung 3 Mal brechen tötet dich.",
                },
            },
            {
                name = "Balorgh",
                mechanics = {
                    "Wechselt Wasser (Schock), Blumen auf Inseln und Überkopfstampfen mit Feuerbällen. Achte, welches Element aktiv ist – meide oder blocke entsprechend.",
                    "Schwerer Angriff & Atem: immer von Gruppe weggedreht. Tank muss |cFF0000BLOCKEN|r oder riskiert One-Shot. Team bleibt hinter Boss.",
                    "Feuerbälle nach Stampfen: Boss schreit “Verbrennt …” oder “Fühlt meine Flammen”, feuert dann 4 zielsuchende Feuerbälle – |cFF0000AUSWEICHROLLE|r oder du erhältst tödlichen DoT.",
                    "Jagdphase (~80%, 60%, 40%, 20%): Boss teilt sich in 4 Schatten. Locke jeden Schatten in eine NPC-Falle. Meide Wasser, wenn elektrisiert, oder Inseln, wenn sie von explosiven Blumen bedeckt sind.",
                    "Wölfe erscheinen jede Jagdphase – (|cFFD700Töte sie schnell|r). Finale ~20% Push enthält 2 Wölfe + Boss gleichzeitig; bleibe ruhig & handle Adds ab, bevor Balorgh beendet wird.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 11) Frostgewölbe (zoneId=1080)
    -------------------------------------------------------------------------------
    [1080] = {
        normalId = 433,
        vetId    = 434,
        zoneId   = 1080,
        sets     = {432,429,430,431},
        questID  = 6249,
        HM       = 2262,
        SR       = 2263,
        ND       = 2264,
        TR       = 2267,
        name     = "Frostgewölbe",
        bosses   = {
            {
                name = "Eispirscher",
                mechanics = {
                    "Boss blickt Tank an: kegelförmige AoE-Angriffe – |cFF0000BLOCKEN|r als Tank, drehe Boss nicht auf Gruppe.",
                    "Aufwärtshaken fesselt zufälligen Spieler – (|cFF7F00BOSS SCHNELL UNTERBRECHEN|r), sonst wird gefesseltes Ziel zu Tode geprügelt.",
                    "Beschwört Wellen von Eisgeistern & Spinnen bei ~90%/75%/50%/30% – (|cFFD700ADDS SOFORT TÖTEN|r). Geister machen schwere Treffer/Betäubungen.",
                    "Troll hebt Felsbrocken auf & schleudert ihn auf Spieler – |cFF0000AUSWEICHROLLE|r oder blocken, um Niederschlag zu mildern. Laufe nicht weg, sonst springt Boss auf dich.",
                },
            },
            {
                name = "Kriegsfürst Tzogvin",
                mechanics = {
                    "Angekettet: Zwei Spieler verbinden sich – bewegt euch auseinander, um Verbindung zu brechen, sonst explodieren beide (|cFF0000VERTEILEN|r).",
                    "Schwerer Angriff/Zermalmender Schlag auf Zufälligen – (|cFF0000BLOCKEN oder AUSWEICHEN|r). Tanks können es nehmen, DPS/Heiler müssen ausweichen oder werden getötet.",
                    "Flammenphase @~70%: Tzogvin springt hoch, landet mit Rückstoß. Jeder Spieler erhält roten Kreis mit DoT – |cFF0000NICHT überlappen|r, sonst tödlich. Fokussiere Schaden auf seinen Schutzschild, um Phase abzubrechen.",
                    "Wirbelwinde @~30%: Tornados kreisen am Raumrand, einer kann Spieler jagen – kite vorsichtig; Boss kanalisiert manchmal Blizzard. |cFF0000STÄNDIG BEWEGEN|r, um große AoEs zu vermeiden.",
                    "Adds: Goblin-Bogenschützen können erscheinen. (|cFFD700Unterbrechen oder töten|r sie schnell). Tank zieht sie herein, wenn möglich.",
                },
            },
            {
                name = "Gewölbeschützer",
                mechanics = {
                    "Versteckt sich in Schutzkugel bei Schwellen (~75%, ~40%, ~20%). Laserstrahlen kreuzen Raum – |cFF0000BLEIBE hinter Bosskugel|r, um Laser zu blocken, sonst wirst du getötet.",
                    "Boss hat typische Dwemer-Zenturio-Moves: kegelförmiger Dampfatem (Tank blockt) und Blitzhagel (zur Seite treten).",
                    "Dwemer-Sphären & Spinnen erscheinen häufig – (|cFFD700ADDS TÖTEN|r). Spinnen können Sphären 'aufladen', machen sie tödlicher. Halte sie unter Kontrolle, sonst wirst du überwältigt.",
                    "Blaue rollende Kugeln wandern ebenfalls – meide sie, sonst betäuben/explodieren sie.",
                },
            },
            {
                name = "Rizzuk Knochenfrost (mit Lawine)",
                mechanics = {
                    "Kampf hat 2 Bosse: Rizzuk (Fokus zum Töten) & Lawine (riesiger Frostatronach). Tank muss Lawines schwere Treffer von Gruppe fernhalten.",
                    "Rizzuk teleportiert & kanalisiert tödlichen Froststrahl – (|cFF7F00SCHNELL UNTERBRECHEN|r), sonst stirbt Gruppe.",
                    "Gefrorener Schlag: Rizzuk bewegt sich zur Mitte, jeder Spieler erhält roten Kreis, der nach kurzer Betäubung explodiert – (|cFF0000VERTEILEN|r), sonst überlappt ihr & sterbt.",
                    "Lawine führt Boden-AoE-Phasen durch – Tank muss in/nahe der teilweisen ‘sicheren Zone’ stehen oder schwere Schneeböen blocken. Laufe nicht weg, sonst erleidest du massiven DoT.",
                    "Eiskugeln / Tornados an Rändern: meide große blaue wirbelnde AoEs. Bei niedriger HP erzeugt Rizzuk mehr Eisgefahren – |cFF0000AUSWEICHEN|r ihnen.",
                },
            },
            {
                name = "Der Steinwächter",
                mechanics = {
                    "Phase 1: Zerstöre beide Arme, bevor Boss Schaden nimmt. Jeder Arm erzeugt bei Tod einen Dwemer-Zenturio – (|cFFD700FOKUSSIEREN & schnell töten|r). Rollende Kugeln wandern über Boden – meide oder werde betäubt.",
                    "Wirbelnder Flammenangriff: sobald Arme weg sind, wirbelt Steinwächter Flammenstrahlen – Gruppe muss ständig rotieren, um sofort tödliche Feuerkegel zu vermeiden.",
                    "Rattenlabyrinth (Skeevaton-Phase) bei ~55% (und wieder ~30%): jeder Spieler nutzt Portal & verwandelt sich in Skeevaton. Lade Ultimate an zentralem Knoten, teilt euch auf, um 4 Schockförderbänder zu deaktivieren. Meide Fallen, töte/kontrolliere Dwemer-Erscheinungen.",
                    "Phase 2 & 3: gleiche Arm-Tötungsroutine wiederholt sich, aber mehr Gefahren: wirbelnde Klingen-Adds, zufällige Meteore, schwererer Dampf-DoT (Vet) & möglicherweise Stoßangriff.",
                    "Boss hat Nahkampf-Blitzaura – |cFF0000NICHT an Boss kuscheln|r. Tank: achte auf hochschädigenden Strahl & zufälligen schweren Schlag.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 12) Tiefen von Malatar (zoneId=1081)
    -------------------------------------------------------------------------------
    [1081] = {
        normalId = 435,
        vetId    = 436,
        zoneId   = 1081,
        sets     = {436,433,434,435},
        questID  = 6251,
        HM       = 2272,
        SR       = 2273,
        ND       = 2274,
        TR       = 2276,
        name     = "Tiefen von Malatar",
        bosses   = {
            {
                name = "Gefräßiger Schlund",
                mechanics = {
                    "Boss blickt Tank mit frontalem Kegel-Giftspucken an – |cFF0000BLOCKEN|r oder zur Seite treten als Tank, meiden als DPS/Heiler.",
                    "Wenn Gift-AoEs landen, sofort heraustreten. Überlappen ist tödlich für Tank.",
                    "Boss verschwindet bei festen HP-Triggern (80%, 50%, 25%). Team muss ZUSAMMENBLEIBEN, um ihn zu finden, sonst stirbt gefesselter Spieler. Adds & AoE-Kreise erscheinen – töte Adds & |cFF7F00UNTERBRICH|r Boss, sobald gefunden!",
                    "Bleibe ruhig & gruppiere dich; allein suchen garantiert schnellen Tod.",
                },
            },
            {
                name = "Die Weinende Frau",
                mechanics = {
                    "Kegel-AoEs bilden sich um Boss – große Eisfelder außen oder innen. Achte, welche Region jedes Mal ‘sicher’ ist (|cFF0000BEWEGEN|r).",
                    "Ausbreitendes Eis: kleine, schnelle AoEs oder Eisstacheln jagen dich – |cFF0000VERMEIDEN|r, hineinzutreten, sonst wirst du gewurzelt/immobilisiert.",
                    "Faule Geysire: unter jedem Spieler, laden auf & brechen nach oben aus, wenn du darin bleibst (|cFFA500FÜSSE IN BEWEGUNG HALTEN|r).",
                    "Gefährliche Adds erscheinen (bes. Wächter bei 75/55/35%). |cFFD700TÖTE Wächter|r zuerst – schwere Angriffe können ungeblockt töten.",
                },
            },
            {
                name = "Dunkle Kugel",
                mechanics = {
                    "Zentrale dunkle Kugel erzeugt ständig |cFFD700Auroraner-Adds|r. Sie tragen farbcodierte Angriffe (|cFFFF00Strahlend|r, |cFF0000Lodernd|r, |c00FFFFSzintillierend|r, |cFF7F00Phosphoreszierend|r).",
                    "Fokussiere Farbkreis eines Adds: tötet seinen Buff oder Synergie zum Kreis. Dann Schaden an Hauptkugel in Mitte. Wiederholen.",
                    "|cFFD700TÖTE Kugeln|r, die an Raumrändern erscheinen – diese stärken Auroraner, machen sie tödlich. Zerstöre sie schnell!",
                    "Tank muss mehrere Erscheinungen managen – Gruppe sollte sich auf Beseitigung aller Adds konzentrieren, bevor zentrale Kugel wieder angegriffen wird.",
                },
            },
            {
                name = "König Narilmor",
                mechanics = {
                    "Teilt sich in 4 Kopien. Nur |cFFD700eine ist echt|r. Entweder AoE sie in einer Ecke nieder oder ziele einzeln auf sie.",
                    "Jede Kopie kann zufällige farbcodierte Fähigkeiten haben (Eis, Blitz, Meteor, etc.). Alle können große Treffer kanalisieren – |cFF7F00häufig UNTERBRECHEN|r oder schweren Schaden erleiden.",
                    "Heile NPC Tharayya nahe Ecke gegen Geist – wenn sie stirbt, erhalten Illusionen riesige Schilde & werden fast unbesiegbar!",
                    "Behalte Situationsbewusstsein für farbbasierte AoEs von jedem Klon – (|cFF0000BEWEGEN|r aus Meteoren, Eisfeldern, etc.).",
                },
            },
            {
                name = "Symphonie der Klingen",
                mechanics = {
                    "Basisangriffe: schwerer Hieb (|cFF0000BLOCKEN|r), wirbelnde Klingen (|cFF0000AUSWEICHEN|r).",
                    "Geisterwand: Linien von Auroranern kreuzen Arena – töte 1 oder 2, um Lücke zu schaffen, sonst wirst du bei Berührung getötet. Achte auf Boss-AoE beim Bewegen.",
                    "Regelmäßig erscheinen 4 Auroraner an Rändern – wenn sie Boss erreichen, erhält er farbbasierte Angriffe: |cFF0000Meteore|r, |cFFFF00Strahlender Strahl|r, |c00FFFFBlitz|r, oder |c7F7FFFEissäulen|r. Töte 1–2, um Schwierigkeit zu reduzieren.",
                    "Kugeln aus Dunkle Kugel Kampf erscheinen auch. |cFFD700Zerstöre Kugeln|r zuerst oder erleide tödliche AoE-Kombos. Dann wieder Boss fokussieren.",
                    "Endphase (~11%): Teleportiert dich in neues Reich; Boss-HP springt auf ~50% im HM (~25% normal). Wände erscheinen aus mehreren Richtungen. Meide sie, während du mit allen 4 Elementarangriffen umgehst – |cFF0000VERTEILEN|r, töte Kugeln, keine Panik. Überlebe, bis Boss tot ist!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 13) Mondgrab-Tempelstadt (zoneId=1122)
    -------------------------------------------------------------------------------
    [1122] = {
        normalId = 494,
        vetId    = 495,
        zoneId   = 1122,
        sets     = {458,452,453,454},
        questID  = 6349,
        HM       = 2417,
        SR       = 2418,
        ND       = 2419,
        TR       = 2422,
        name     = "Mondgrab-Tempelstadt",
        bosses = {
            {
                name = "Auferstandene Ruinen",
                mechanics = {
                    "Felswurf & Immunität: Boss rollt sich gold leuchtend zusammen, wirft Felsbrocken, die dich niederschlagen. |cFF0000BLOCKEN|r, wenn beworfen. Zwei Synergieplatten können Hemo-Heloten-Kugeln erzeugen – |cFF7F00SCHWERER ANGRIFF|r auf Kugeln, um Immunität zu brechen.",
                    "Bodenschlag: Ein wiederholter AoE-Schaden um den Boss – Heiler achtet auf Gruppen-Gesundheit. Meide Zentrum für weniger Schaden.",
                    "Durchquerung des Raumes: Nach Schildbruch stürmt Boss geradeaus – |cFF0000WEG AUSWEICHEN|r oder One-Shot.",
                    "Adds: Hohfang-Vampire & andere treten mitten im Kampf bei – (|cFFD700Adds schnell töten|r, um Überlappung zu vermeiden).",
                },
            },
            {
                name = "Dro’zakar",
                mechanics = {
                    "Blutschild: Dro’zakar wird immun & pulsiert AoE unter jedem Spieler. Fokussiere Schild & verteilt euch, sonst können gestapelte AoEs Gruppe auslöschen. |cFFD700SCHILD schnell DPSen|r!",
                    "Blutpfütze: Boss versinkt in Pfütze, jagt Tank – |cFF0000BLOCKEN|r, da es HP entzieht & sich selbst heilt. Bewegung minimieren begrenzt Heilung.",
                    "Siphon-Kugeln: Opfer-Heloten beschwören rote Hemo-Heloten-Kugeln in Ecken – Boss versucht, sie für massive Stärkung zu entleeren. |cFF7F00SCHWERER ANGRIFF auf Kugeln|r zum Zerstören.",
                    "Adds: Kontinuierliche Erscheinungen. Tank sammelt sie für AoE. Dro’zakar kann auch Tank mit Kegel-Hieb treffen – von Gruppe wegdrehen.",
                },
            },
            {
                name = "Kujo Kethba",
                mechanics = {
                    "Eruptionsphase: Boss zerschmettert Boden, wird immun. Lava-Geysire erscheinen – muss |cFFA500Rutschsteine|r darauf schieben, um geschmolzenen Fels zu stoppen. Reflektion tötet Gruppe, wenn hier versucht wird zu dpsen!",
                    "Schwerer Angriff: Boss Überkopf-Klauenschlag – (|cFF0000BLOCKEN|r) oder niedergeschlagen werden. Schlägt auch Flügel für doppelten Kegel-Feuerwelle – Front meiden.",
                    "Adds: Viele erscheinen jede Eruption – Tank sammelt, töte sie schnell, um Chaos zu verhindern.",
                    "Nach ~20s endet Eruption – |cFF0000ANGRIFF AUF BOSS STOPPEN|r während Reflektion & fokussiere Steine, um Geysire zu versiegeln. Dann DPS fortsetzen.",
                },
            },
            {
                name = "Nisaazda & Grundwulf",
                mechanics = {
                    "Nisaazda Teleports: Fernkampf-Blutmagierin nutzt Kanäle, die |cFF7F00UNTERBROCHEN|r werden MÜSSEN. Beschwört großen Blutwirbel – bewege Bosse raus oder sie erhalten riesigen Schadensbuff!",
                    "Gargoyle-Beschwörung: Sie versucht großen Cast, der Hemo-Helot zum Unterbrechen benötigt – schwerer Angriff einer roten Kugel auf sie. Misslingen erzeugt großen Gargoyle-Add!",
                    "Grundwulf: Einfache schwere Schwünge & linearer Schrei (|cFF0000Fus Ro Dah|r). Ausweichen oder blocken oder zurückgestoßen werden. Normalerweise im Nahkampf getankt, während er nahe Nisaazda gezogen wird, um beide zu AoEn.",
                    "Geisterhafte Adds: Immun, bis von Hemo-Heloten-Spritzer getroffen. Achte auf Synergienutzung, wenn mehrere Geister + Gargoyle aktiv sind – gut koordinieren.",
                },
            },
            {
                name = "Grundwulf (Drachenritual)",
                mechanics = {
                    "Blockmechanik: Drache versucht, auf Grundwulf zu feuern. Er versteckt sich hinter einem |cFFA500Rutschstein|r. |cFF7F00SCHWERER ANGRIFF|r auf Stein, um ihn wegzustoßen, damit Flammen ihn treffen! Misslingen verbreitet Feuer in Arena.",
                    "Fus Ro Dah: Eine breite Linie. Nachdem sie passiert ist, hinterlässt sie Kreise, die Geister erzeugen – |cFFD700Kugel unterbrechen oder Synergie|r, wenn du sie via Hemo-Helot verwundbar machen willst. Sonst sind sie unbesiegbar.",
                    "Blutstacheln: Roter Stachel fesselt zufälligen Spieler & wendet Heilungsabsorption an. Muss im Kreis des Stachels stehen, bis er verschwindet – Gerinnungs-Add erscheint. Bei niedriger Boss-HP können mehrere Stacheln gleichzeitig erscheinen!",
                    "Unheilmaul-Adds: Große Pantherbestien bei bestimmten HP oder Zeitintervallen – schnell verspotten. AoE sie nieder, bevor neue Wellen überlappen.",
                    "Herausforderer Extras: Boss HP ~15M, Erhält riesigen Fledermaus-Add, der zufälligen Spieler jagt – Sofort-Tod bei Berührung, kann nur durch Hemo-Heloten-Spritzer getötet werden. Stein bestraft bei falscher Bewegung, & häufigere Feuerwand vom Drachen. Überlebe alles, während Geister + Fledermaus + Stacheln systematisch kontrolliert werden!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 14) Hort von Maarselok (zoneId=1123)
    -------------------------------------------------------------------------------
    [1123] = {
        normalId = 496,
        vetId    = 497,
        zoneId   = 1123,
        sets     = {456,457,459,455},
        questID  = 6351,
        HM       = 2427,
        SR       = 2428,
        ND       = 2429,
        TR       = 2431,
        name     = "Hort von Maarselok",
        bosses = {
            {
                name = "Selenes Klauen & Selenes Fänge",
                mechanics = {
                    "|cFFA500Selenes Klauen (Bär)|r: Tank muss von Gruppe wegdrehen. Schwere Angriffe müssen |cFF0000GEBLOCKT|r werden, sonst kann es niederschlagen/töten. Meide Bodenschlag, der Stacheln unter jedem Spieler erzeugt.",
                    "|cFFA500Selenes Fänge (Spinne)|r: Erscheint nach Tod des Bären. Wieder muss Tank schnell verspotten, sonst kann es Nicht-Tanks töten. Beschwört gelegentlich kleinere Spinnen, töte sie, bevor sie dich überrennen.",
                    "|cFF00FFSelene|r: Teleportiert & kanalisiert Giftschläge, die |cFF7F00UNTERBRECHUNG|r erfordern. Sie wirft auch Giftkegel auf zufälligen Spieler – ausweichen oder initialen Treffer blocken. Verteilt AoEs unter jedem Spieler: heraustreten oder blocken+befreien, wenn getroffen.",
                },
            },
            {
                name = "Azurseuchen-Lurcher",
                mechanics = {
                    "Dreifache Begegnung: Du musst Gesundheit des Lurchers 3 Mal leeren, um Maarselok (oben) zu schaden. Jede Leerung löst Add-Phase aus & Lurcher ‘lädt wieder auf’ bis ~70%.",
                    "|cFF0000Schwerer Angriff|r: Muss geblockt werden, sonst riskiert man One-Shot. Lurcher macht auch kegelförmige Bodenangriffe – Tank dreht von Gruppe weg.",
                    "Ressourcenentziehende AoEs: Boss schlägt Arme, erzeugt kleine blaue Kreise im Bereich. Hineintreten entzieht Ausdauer & verursacht moderaten Schaden. Herausbewegen!",
                    "Maarselok Feuer: Gelegentliche große Linie/Atem von oben – leicht zu meiden, aber lass Lurcher nicht darin stehen, sonst wird er wütend. Achte auf Add-Wellen (Spriggans, Imps, Wölfe) zwischen Übergängen.",
                },
            },
            {
                name = "Azurseuchen-Kankroid",
                mechanics = {
                    "Kankroid in Mitte ist anfangs immun. Fokussiere |cFFA500Verseucher-Lurcher|r am Rand. Töte ihn, hebe Synergiesamen auf, bringe ihn zu Kankroid, um Schild zu brechen – nutze dieses Burst-Fenster, um Kankroid zu dpsen!",
                    "|cFF0000Stampfen|r: Lurcher schlägt Boden, hinterlässt großen untelegrafierten Kreis, der tödlichen DoT verursacht. Tank zieht Lurcher davon weg. Stehe nicht in diesen Kreisen!",
                    "Würger erscheinen nach erster verwundbarer Phase – (|cFFD700TÖTE sie SOFORT|r), sonst wirst du überwältigt. Kankroid-Schild reformiert sich nach ~20s, wiederhole Mechaniken, bis er tot ist.",
                },
            },
            {
                name = "Maarselok (Vor dem Endkampf)",
                mechanics = {
                    "Bei 3 Wellen von Spinnenlingen von Selene, jede Welle genug Spinnen, um Maarselok niederzuschlagen (80%->65%->50%). Im Grunde kämpfst du gegen riesige Add-Wellen, während du Selenes Spinnenlinge vor Würgern & Hoarvoren schützt.",
                    "|cFFD700Würger|r: Erscheinen in großer Zahl nahe Wänden – fokussiere sie mit AoEs, sonst töten sie Spinnenlinge & verlängern Kampf unendlich!",
                    "|cFF0000Hoarvore|r: Kriechen langsam zu Selene, explodieren, wenn sie sie erreichen, betäuben sie & stoppen Spinnenlinge. Spieler kann nahe stehen, um sie harmlos detonieren zu lassen.",
                    "Adds: Lurcher, Bären, Bogenschützen, etc. halten Tank beschäftigt. Sobald genug Spinnen oben ankommen, landet Boss für ~20s. Brenne ihn jedes Mal nieder. Wiederholt sich bis 50% HP, dann flieht er.",
                },
            },
            {
                name = "Maarselok (Endkampf)",
                mechanics = {
                    "Kampf beginnt bei 50% HP (~12.5M). Herausforderer setzt ihn auf ~17.5M HP zurück. Viele weite AoEs & spezielle Mechaniken.",
                    "|cFF0000Fus Ro Dah|r: Großer Rückstoßschrei auf Tank gerichtet (blocken!) oder wer auch immer Aggro hat. Flügelschläge & schwerer Kegelatem können auch verheerend sein. Meide Flügel, achte auf Atemschwenk, oder weiche Treffern mit Rolle aus.",
                    "Meteorschauer: Zufällige Flammenkugeln treffen Arena. Dann |cFF0000STÜRMT|r Boss von einer Seite zur anderen, typischerweise auf Tankposition gezielt. Alle anderen treten zur Seite. Tank sollte Ansturm blocken.",
                    "|cFFA500Samenmechanik (nicht-HM)|r: Zufälliger Spieler wird verflucht. Er synergiert auf leuchtendem Pad zur Reinigung. Misslingen erzeugt Lurcher.",
                    "|cFFA500Herausforderer|r: Selene ist feindlich, erfordert Unterbrechung ihrer Giftsalven. Sie kann angegriffen werden, um Schild zu brechen, dann Gruppensynergie mit Samen. 2 oder 3 sehen gleiches Pad, 1 sieht Fälschung. ‘Außenseiter’ muss sich Mehrheitspad anschließen oder stirbt. Tank oder 3 vs 1 Szenario. Lurcher erscheint bei Misslingen. Todeswurzeln müssen zerstört werden, bevor Wiederbelebung erfolgen kann.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 15) Eiskap (zoneId=1152)
    -------------------------------------------------------------------------------
    [1152] = {
        normalId = 503,
        vetId    = 504,
        zoneId   = 1152,
        sets     = {472,473,478,471},
        questID  = 6414,
        HM       = 2541,
        SR       = 2542,
        ND       = 2543,
        TR       = 2546,
        name     = "Eiskap",
        bosses = {
            {
                name = "Kjarg der Stoßzahnkratzer",
                mechanics = {
                    "Basisangriffe: Einfache Frontalschwünge. Tank hält ihn von Gruppe weggedreht.",
                    "|cFF0000Wutanfall|r: Boss leuchtet rot, verursacht massiven Schaden. Tank sollte ihn kiten, um Treffer zu vermeiden – versuche nicht, frontal zu tanken!",
                    "Hammerschlag: schwerer Überkopfschlag mit Eisstacheln vorne – |cFF0000BLOCKEN/ausweichen|r oder sterben.",
                    "Eistornado: folgt langsam zufälligem Spieler. Kite ihn weg, überlappe nicht auf Tank oder Gruppe.",
                    "Eisatronachen erscheinen am Rand: |cFFD700Fokussieren & töten|r sie. Wenn zu lange am Leben gelassen, wurzeln & bombardieren sie Gruppe mit Eisblitzen.",
                },
            },
            {
                name = "Schwester Skelga",
                mechanics = {
                    "Bewegt sich herum, wirkt Eisangriffe. Tank hält sie verspottet & weggedreht.",
                    "Dunkle Fessel auf Tank kann nicht gereinigt werden – einfach durchheilen (Reinigen löst Schaden aus).",
                    "Feueraura: platziert unter 1 zufälligen Spieler – NICHT überlappen, sonst tötet es Gruppe. Wenn offensiv nutzen willst, stehe nahe Boss, achte aber auf HP.",
                    "Würger: geschützt durch Eis, bis von Feueraura ‘geschmolzen’. Dann schnell töten – diese schießen hochschädigende Eisblitze.",
                    "Kegel/AoE-Angriffe: typischerweise klein, meide durch Stehen hinter ihr. Sie nutzt auch geringeren AoE unter Füßen.",
                },
            },
            {
                name = "Vearogh der Schlurfer",
                mechanics = {
                    "Ein großer Fleischatronach, bedeckt von Hexenmagie. Tank steht vorne, Gruppe dahinter.",
                    "Schwerer Angriff & Frontalschwünge – |cFF0000BLOCKEN|r oder One-Shot. Feuerwellen wandern auch über Arena – meide/weiche ihnen aus.",
                    "Beschwörungskreise erzeugen Geister, Skelette oder Zombies – (|cFFD700SCHNELL TÖTEN|r), sonst wird Gruppe überrannt. Einige Skelette entziehen Spielerressourcen mit Fessel.",
                    "Später im Kampf: rotierende Flammböen wirbeln in Arena – versuche, ihnen seitlich auszuweichen oder gegenzuheilen, wenn Gruppe stark genug ist.",
                },
            },
            {
                name = "Sturmgeborener Wiedergänger",
                mechanics = {
                    "Viele Blitz- & Eis-AoEs erscheinen unter Spielern – bleibe in Bewegung, staple nicht. Wenn du darin stehst, stirbst du wahrscheinlich, besonders im Schweren Modus.",
                    "Schwerer Angriff (lange Aufladung) kann Tank sofort töten, wenn ungeblockt, oder DPS, wenn nicht ausgewichen. Achte auf Bossanimation.",
                    "Sprungschlag: Boss springt in Luft & landet, verursacht riesigen Schaden in kleinem Bereich – |cFF0000BLOCKEN oder BEWEGEN|r.",
                    "Sturmatronachen erscheinen ~55% & ~40% – (|cFFD700Fokussiere diese|r), sonst stärken sie Boss. Wenig HP, aber großer Gruppenschaden, wenn ignoriert.",
                    "Bei ~35–40% kanalisiert Boss großen Eissturm in Mitte – gruppieren, Heilung/Defensive zünden oder Boss schnell niederbrennen.",
                },
            },
            {
                name = "Mutter Ciannait (Eiskap-Zirkel)",
                mechanics = {
                    "4 Hexen + finale 20% Bossphase. Jede Hexe wird nacheinander verwundbar, dann zufällig nach erster Rotation. Jede hat Sub-Mechaniken aus früheren Kämpfen!",
                    "|cFF7F00Hexe 1: Gohlla|r erzeugt den Riesen (Kjarg). Wenn wütend, muss Tank kiten. |cFFD700TÖTE Riesen zuerst|r.",
                    "|cFF7F00Hexe 2: Hiti|r erzeugt gefrorene Würger, die Feueraura zum Schmelzen benötigen – wie bei Schwester Skelga. Dann töte sie.",
                    "|cFF7F00Hexe 3: Bani|r erzeugt Geister, Zombies, Skelette wie im Vearogh-Kampf. Eliminiere sie schnell.",
                    "|cFF7F00Hexe 4: Maefyn|r erzeugt Eiskap-Krieger mit Sturm-AoEs wie beim ‘4. Boss’. Muss Krieger zuerst töten.",
                    "Währenddessen hat Gruppe wirbelnden Wind (Bärentornado), brennende Aura, Blitzfeld, etc. von früheren Bossen. Meiden oder managen!",
                    "Nach 4 Hexen kanalisiert |cFF0000Mutter Ciannait|r finale Phase mit massivem AoE in Mitte. Brenne sie schnell nieder, sonst steigert sie DoT-Impulse. Überlebe mit großen Heilungen bei niedrigem DPS!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 16) Unheiliges Grab (zoneId=1153)
    -------------------------------------------------------------------------------
    [1153] = {
        normalId = 505,
        vetId    = 506,
        zoneId   = 1153,
        sets     = {476,479,474,475},
        questID  = 6416,
        HM       = 2551,
        SR       = 2552,
        ND       = 2553,
        TR       = 2555,
        name     = "Unheiliges Grab",
        bosses = {
            {
                name = "Nabor der Vergessene (Geheimboss #1)",
                mechanics = {
                    "Boss steht auf zentraler Plattform; falle nicht von Rändern!",
                    "Großer BOOM: Boss kanalisiert, unsichere Plattformen leuchten. Hake dich an sicheren Punkt oder werde von Explosion getötet.",
                    "Bogenschützen erscheinen um Arena – |cFF7F00UNTERBRECHEN|r, sonst 'Zielen sie an' und stoßen dich runter. Sie können schnell getötet oder kontrolliert werden.",
                    "Wiederhole jedes Mal, wenn Boss kanalisiert. Achte auf Füße und hake dich vorsichtig ein!",
                },
            },
            {
                name = "Hakgrym der Heuler",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r: Tank muss BLOCKEN oder wird getötet. Andere müssen Ausweichrolle machen, wenn auf sie gezielt.",
                    "Lichkristalle: AoE-Stacheln aus Boden – bewege dich raus, bevor sie explodieren.",
                    "Wehklagendes Totem: Erscheint am Rand, schießt Projektile – (|cFFD700Schnell töten|r).",
                    "Fleischabsomination (~60% & 30%): Fokussiere sie; achte auf ihren großen AoE-Schlag und persistenten Bodeneffekt.",
                    "|cFFA500Werwolfverwandlung|r bei 0%: Erhält 50% HP zurück, macht Linienanstürme mit Skelett-Erscheinungen – töte Adds und kite weiter oder blocke Boss-Schläge.",
                },
            },
            {
                name = "Hüter des Brennofens",
                mechanics = {
                    "Schwertbögen & Spalten – halte Boss weggedreht. Tank blockt schwere Angriffe oder macht Ausweichrolle.",
                    "Adds erscheinen schnell, wenn DPS hoch ist – nutze AoEs oder fokussiere sie, damit du nicht überwältigt wirst.",
                    "|cFF0000Flammen steigen in Schächten auf!|r: Boss schützt sich & großes Feuer tötet Gruppe, wenn nicht gelöst. 3 Gruppenmitglieder haken sich zu 3 Aussichtspunkten hoch. Synergie enthüllt korrektes Bodensymbol, um Boss darauf zu führen. Sobald Boss Schwert auf korrektes Symbol sticht, weichen Flammen zurück.",
                    "Bogenschützen über Kopf können Gruppe mit Pfeilen eindecken – optional zu töten, wenn sie Ärger machen.",
                },
            },
            {
                name = "Ewige Ägis",
                mechanics = {
                    "Kegel- oder Linienangriffe mit Klingenwürfen – ausweichen oder blocken. Sie können zurückstoßen oder starken Schaden verursachen.",
                    "Blauer „Hurrikan“-AoE um Boss – sichere Zone in Mitte. Oder bleibe weit draußen, bis er endet. Heiler achtet auf Gruppen-HP, wenn sie außerhalb des Hurrikans stehen.",
                    "Bei Gesundheitsschwellen (90%,70%,50%,30%) beschwört Boss 4 Reflexionen, die große AoEs um sich wirbeln. Meiden oder schnell blocken – ODER unter Boss stapeln mit großen Heilungen/Minderung, um sie zusammen zu verbrennen.",
                    "Vorsichtige Überlappung mit Boss-Wirbel-AoE – bleibe dahinter oder im 'sicheren Ring', wenn du Stack-Burn machst.",
                },
            },
            {
                name = "Ondagore der Wahnsinnige",
                mechanics = {
                    "Boss ziemlich geringer Schaden, aber erzeugt großen Knochenkoloss & Geist-Adds – (|cFFD700Fokussiere Koloss|r). Er hat tödlichen schweren Angriff, wenn nicht geblockt/ausgewichen.",
                    "|cFF0000Inneres Gift|r (~80% & ~35%): Boss kanalisiert Gift in Mitte – |cFFD700Hake dich raus|r, um Geister im äußeren Ring zu töten. Dann kehrt er Gift nach außen, sodass du zurückkommen kannst.",
                    "|cFF7F00Explosionsphase (~50% & ~15%)|r: Verstecke dich hinter Säulen oder stirb durch unaufhaltsame Explosionen. Töte währenddessen 4 Heiler, die ihn stärken, um Phase zu beenden – Gruppe muss bei jeder Explosionswelle vorsichtig sein. Boss kehrt schließlich zu normal zurück.",
                    "Skelett-Adds bleiben – erledige sie zwischen Phasen, um Chaos zu reduzieren!",
                },
            },
            {
                name = "Voria die Herzdચोर (Geheimboss #2)",
                mechanics = {
                    "Muss 'Vergessene Stärke'-Buff von Nabors Urne haben, um versteckte Haken zu ihr zu sehen.",
                    "Voria teleportiert bei ~75% & ~40% weg. Hake dich schnell hinterher, brich ihren Schild, dann |cFF7F00UNTERBRICH|r, sonst entkommt sie & du verlierst Kampf.",
                    "Voria kann kurzzeitig Knochengoliath werden. Halte DPS auf ihr. Achte auf einfache AoE-Schläge, aber sie ist nicht sehr bedrohlich, wenn Tank Aggro hat.",
                    "|cFFD700Bei Erfolg, nimm 'Vorias Autorität' aus ihrer Urne, um nächste versiegelte Tür zu öffnen.|r",
                },
            },
            {
                name = "Vorias Meisterwerk (Geheimboss #3)",
                mechanics = {
                    "Betritt 'Vorias Sanktum'-Tür nach Sieg über Voria. Hake dich durch sumpfige Arena – Wasser ist tödliches Gift oder hoher DoT.",
                    "Boss bleibt mittig, stampft gelegentlich große AoEs, die bestehen bleiben. Stapel sie wenn möglich, um Platz zu sparen. Stehe nicht darin!",
                    "Skelett-Adds: Ein Zweihand-Skelett erscheint nach jedem Stampfen – Tank oder töte es schnell, sonst wirst du überwältigt. Es kann riesige schwere Treffer machen.",
                    "Schleimgegner erscheinen. Du kannst sie normal töten, aber wenn sie groß sind (Millionen HP), nutze Haken, um sie zu 'teilen', bis klein genug zum schnellen Töten.",
                    "Balanciere AoE + Bewegung, töte Adds, achte auf Stampfer, du wirst Erfolg haben. Plündere letzte Urne für 'Abscheuliches Bollwerk'-Buff.",
                },
            },
            {
                name = "Kjalnar Grabskaald (Endboss)",
                mechanics = {
                    "|cFF0000Massiver Angriff|r: Sehr mächtiger schwerer Angriff – Tank MUSS blocken oder stirbt. Er hat auch geisterhafte Hand-Betäubung auf Tank oder zufällige Spieler.",
                    "Grabstaub: Kjalnar schleudert mehrere Bögen vom Boden – Magieschaden unaufhaltsam, wenn nicht geblockt. Hohe Resistenzen oder Block empfohlen.",
                    "Käfige (Herausforderer): Beschwört Knochenkäfige unter jedem Spieler – |cFF0000SCHNELL RAUS|r, bevor große Explosion dich tötet.",
                    "Knochenminen: Verteilt Hörner auf Boden als Landminen – meide Drauftreten, sonst großer Schaden.",
                    "Beschwörungsfelder: Er erzeugt Skelette aus jeder Ecke. Wenn sie Mitte oder Sigil erreichen, stärken sie Boss oder explodieren. Töte oder kontrolliere sie sofort. Ein großer Zweihand-Skelett versucht auch, sich wiederzuheilen, wenn es eine mittlere Rune trifft – muss schnell getötet werden, sonst erhält er volle HP zurück.",
                    "|cFF0000Bei 50% HP|r: Beschwört Riesenuntoten vom Rand: schleudert Feuer-AoEs & Frostatem. Du kannst ihn nicht töten – blocke oder schütze dich durch Atem. Brenne Kjalnar weiter nieder, um Kampf zu beenden!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 17) Steingarten (zoneId=1197)
    -------------------------------------------------------------------------------
    [1197] = {
        normalId = 507,
        vetId    = 508,
        zoneId   = 1197,
        sets     = {516,517,518,534},
        questID  = 6505,
        HM       = 2755,
        SR       = 2697,
        ND       = 2698,
        TR       = 2701,
        name     = "Steingarten",
        bosses = {
            {
                name = "Exarch Kraglen",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Muss GEBLOCKT werden, sonst kann er einen Tank töten; DPS/Heiler müssen AUSWEICHROLLE machen, wenn auf sie gezielt.",
                    "|cFF7F00Hieb (Frontal)|r – Schnelle Abfolge frontaler Hiebe; Tank hält ihn von Gruppe weggedreht und blockt nach Bedarf.",
                    "|cFF0000Furcht + Unterbrechung|r – Er stößt alle zurück, kanalisiert dann großen AoE. BEFREIEN und schnell UNTERBRECHEN, um tödlichen Schaden zu verhindern.",
                    "|cFF0000Stampf-AoE|r – Nach Unterbrechung stampft er Boden mit weitem Kreis. Heraustreten und dann zurückbewegen.",
                    "|cFFFF00Ansturmmechanik|r – Wenn Gruppe zu weit weg steht, stürmt Boss auf sie zu, verursacht riesigen Schaden. Bleibe nach Stampfer nahe bei ihm, um es zu vermeiden."
                },
            },
            {
                name = "Stein-Behemoth",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Boss holt langsam zu Schlag aus. TANK muss BLOCKEN; andere AUSWEICHEN, wenn anvisiert.",
                    "|cFF00FFBlitzphase|r – Jeder erhält expandierende AoEs unter Füßen. Verteilen oder BLOCKEN, um Schaden zu reduzieren.",
                    "|cFF0000Feuerphase|r – Schleudert Feuerbälle, kanalisiert dann riesigen Feuerring über Boden – RAUSBEWEGEN oder sterben.",
                    "|c00FFFFEisphase|r – Gruppe wird verlangsamt. AUSWEICHROLLE oder BEFREIEN. Du lässt kleine Eiskreise fallen – platziere sie vorsichtig. Boss betäubt wieder – stehe nicht in übriggebliebenem Eis.",
                    "|cFF7F00Mini-Behemoths|r – Bis zu drei kleine Hüllen erscheinen, entziehen Ressourcen. TÖTE sie, sonst stapeln sie sich, besonders bei niedriger Gesundheit."
                },
            },
            {
                name = "Arkasis der Wahnsinnige Alchemist",
                mechanics = {
                    "|cFF0000PHASE 1 – Feuer (100%→60%)|r: Drei Feuer-AoEs unter Tank alle ~10s – tritt bei jedem Pop weg. Adds erscheinen bei 90/80/70…% – |cFFD700Schnell töten|r, um Magmahülle zu verhindern.",
                    "|cFFA500WERWOLFPHASE 1 (60%)|r: Alle verwandeln sich. Vier Steinhüllen erscheinen – VERSPOTTEN & #3 UNTERBRECHEN. Nutze #4 STAMPFEN für Blitzminen & #2 SPRUNG nach Bedarf. Kugeln schnell töten.",
                    "|cFF0000PHASE 2 – Gift (60%→20%)|r: Wirft jetzt Giftflaschen, die wirbeln. BLOCKEN oder AUSWEICHEN. Adds wieder alle 10%. Minimal bewegen, um überlappende AoEs zu vermeiden, wenn zu nah.",
                    "|cFFA500WERWOLFPHASE 2 (20%)|r: Gleiche Mechaniken, aber einige Hüllen markieren dich (Bildschirm grau). Wechsle mit anderer Hülle oder One-Shot. #2 Sprung zum Partner, neu provozieren. Auch Hoarvore/Kugeln töten, wenn sie erscheinen.",
                    "|cFF00FFPHASE 3 – Blitz (20%→0%)|r: Im Schweren Modus kann Boss HP zurückgewinnen (~50%). Gruppe erhält große Blitz-AoEs, die sie jagen – lauft zusammen, um gefesselte Spieler via Synergie zu befreien. Töte Unheilmaul/Adds zuerst. Wiederholen bis tot!",
                    "|cFF0000Herausforderer|r: Boss ~18M HP, erzeugt riesige Fledermaus in Werwolfphasen – Sofort-Tod bei Berührung. Muss Hämoglobin-Synergie nutzen, um Fledermaus-Schild zu entfernen. Gefährlichere Bomben/Flaschen, kürzere Phasen. Überlebe mit koordinierten Tötungen!"
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 18) Kastell Dorn (zoneId=1201)
    -------------------------------------------------------------------------------
    [1201] = {
        normalId = 509,
        vetId    = 510,
        zoneId   = 1201,
        sets     = {535,513,514,515},
        questID  = 6507,
        HM       = 2706,
        SR       = 2707,
        ND       = 2708,
        TR       = 2710,
        name     = "Kastell Dorn",
        bosses = {
            {
                name = "Schreckenswyrmin Tindulra",
                mechanics = {
                    "|cFF0000Feueratem|r – Kegel-AoE auf Tank, blocken oder zur Seite treten. Alle anderen bleiben hinter Boss.",
                    "|cFFA500Feuerpfützen|r – Auf Boden gespuckt, stehe nicht darin. Sie explodieren, wenn Boss stampft!",
                    "|cFF7F00Fesseln/Sprung|r – Sie springt auf zufälligen Spieler und betäubt ihn. |cFF7F00BOSS UNTERBRECHEN|r, sonst stirbt gefesseltes Opfer!",
                    "|cFF0000Adds beschwören|r – Todshundbrutlinge erscheinen nach ~75%. Töte sie schnell oder riskiere Überwältigung."
                },
            },
            {
                name = "Blutzwilling",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Großer Hieb oder Teleportschlag. Tank blockt; wenn auf DPS gezielt, Ausweichrolle.",
                    "|cFFA500Blutkanalisierer|r – Vier kleine Adds stärken Boss. Töte sie, um Buff zu entfernen.",
                    "|cFF0000Blutpfützenphase|r – Boss schwebt mittig mit tödlichem AoE darunter. Herausbewegen. Wiederbelebter Vampir erscheint – fokussiere ihn! Achte auch auf Geistillusionen, die dich in Pfütze stoßen können.",
                },
            },
            {
                name = "Vaduroth",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Blocken oder sterben. Großer Sensenschwung auf Tank oder unglückliches Ziel.",
                    "|cFF7F00Sensenwurf|r – Bei 75/50/25% wirft Boss Sense raus. Alle werden herangezogen. Jeder erhält AoE – verteilt euch oder Wipe!",
                    "|cFFA500Wiederbelebter Vampir|r – Erscheint nach jedem Sensenwurf. Muss SOFORT getötet werden, sonst trifft er zu hart.",
                    "|cFFA500Virulente Eingeweide|r – Beschworener lila Klecks-Add. Fernkampfprojektil; töten oder es wird nervig.",
                    "|cFF0000Mini-Fledermausschwarm|r – Schwebt herum. Nicht erwischen lassen; verursacht hohen DoT bei Berührung.",
                },
            },
            {
                name = "Talfyg",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Verheerender Doppelhieb. Tank muss blocken oder Ausweichrolle machen. Andere können es nicht überleben.",
                    "|cFFA500Bodenschlag|r – Platziert großen Blut-AoE auf Boden. Heraustreten; verursacht massiven Schaden über Zeit.",
                    "|cFFD700Gargoyles|r – Sie erwachen in Wellen. Töte sie schnell oder riskiere große Probleme (Feuer oder Eis). Überbrenne Boss nicht, indem du diese ignorierst.",
                    "|cFF0000Tödlicher Strahl|r – Bei niedriger HP hebt Boss Hand & feuert Strahl. Bewegen oder blocken. Wiederholt sich bis Boss tot. Verteilen!",
                },
            },
            {
                name = "Fürstin Dorn",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Muss GEBLOCKT werden oder du stirbst. Sie kann auch verschwinden & zufälliges Ziel anstürmen.",
                    "|cFF7F00Bomben|r – Beschwört mehrere Bomben in Linien oder zufälligen Stellen. Wegtreten oder du explodierst.",
                    "|cFFA500Fledermausschwarm (Stationär)|r – Füllt Raum mit Fledermäusen, lässt grüne sichere Zone. Muss schnell hinein oder sterben. Sie setzt normale Angriffe hier fort!",
                    "|cFF0000Fledermausschwarm (Beweglich)|r – Bei 60% & 20%. Sichere Zone bewegt sich herum, folge ihr. Adds erscheinen: töte Wächter & Skampen, die Synergie fallen lassen. Wirf 4 Verderbnisse auf Boss, um Phase zu beenden.",
                    "|cFF0000Teleportschlag|r – Sie verschwindet & erscheint auf zufälligem Spieler mit tödlichem Schlag. BLOCKEN oder AUSWEICHEN oder sterben.",
                    "|cFF7F00Exekution (Herausforderer)|r – Nach 20% Schwarm bleibt er. Kämpfe Boss im beweglichen Kreis, plus Bomben, schwere Angriffe & Anstürme. Keine finale Änderung, wenn nicht Herausforderer, aber mehr HP/Schaden. Überlebe bis Tötung!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 19) Schwarzdrachenvilla (zoneId=1228)
    -------------------------------------------------------------------------------
    [1228] = {
        normalId = 591,
        vetId    = 592,
        zoneId   = 1228,
        sets     = {569,570,571,577},
        questID  = 6576,
        HM       = 2833,
        SR       = 2834,
        ND       = 2835,
        TR       = 2838,
        name     = "Schwarzdrachenvilla",
        bosses = {
            {
                name = "Avatar des Eifers",
                mechanics = {
                    "|cFF0000Gedankenschlag|r – Bäumt sich auf und kanalisiert frontalen Froststrahl. Tank: drehe Boss weg, damit Gruppe nicht getroffen wird.",
                    "|cFF7F00Spektrale Indriks|r – Beschwört 3 geisterhafte Indriks, die betäuben, wenn nicht geblockt/ausgewichen.",
                    "|cFFA500Teleport|r – Bewegt sich durch Raum; Tank verspottet schnell neu, um ihn weggedreht zu halten.",
                    "|cFF0000Gefrierender Wirbel|r – Platziert kleinen AoE auf zufälligem Spieler. Verteilen, um Überlappung zu vermeiden.",
                },
            },
            {
                name = "Avatar der Kraft",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Holt mit Kristall über Kopf aus; muss geblockt werden, sonst kann er Nicht-Tank töten.",
                    "|cFF7F00Geysire|r – Drei kleine AoEs bilden sich unter Spielern; wegbewegen, bevor sie ausbrechen.",
                    "|cFFFFFFEinfacher Kampf|r – Halte Boss weggedreht, achte auf Adds, falls welche aus früheren Ereignissen erscheinen.",
                },
            },
            {
                name = "Avatar der Standhaftigkeit",
                mechanics = {
                    "|cFF0000Schwere/Leichte Angriffe|r – Blocke Überkopfschlag oder riskiere hohen Schaden.",
                    "|c00FFFFEiskanal|r – Ein gefährlicher, ununterbrechbarer Strahl. Heiler muss gegenheilen oder Gruppe abschirmen.",
                    "|cFF0000Seltenes Bodeneis|r – Gelegentliche Eisflecken erscheinen unter Spielern; einfach herausbewegen.",
                },
            },
            {
                name = "Kinras Eisenauge",
                mechanics = {
                    "|cFF0000Dreifachfeuer|r – Boss blickt Tank an und schleudert 3 Bodenflammen hintereinander. Tank hält ihn von Gruppe fern.",
                    "|cFF0000Schwerer Angriff|r – Keulenschwung oder großer Feuerball (unbewaffnet). Tank muss BLOCKEN oder DPS/Heiler AUSWEICHROLLE.",
                    "|cFFD700Feuriges Totem|r – Erzeugt Totem, das Feuerbälle auf Gruppe wirft. (|cFFD700TÖTEN|r schnell oder provozieren.)",
                    "|cFF7F00Gebrüll/Salamander|r – Salamander erscheinen mit Flammenaura, die Boss bufft. Unterbrich Gebrüll, sonst stärken sie ihn.",
                    "|cFFA500Phasenwechsel|r – Wirft Waffe weg, wechselt zu unbewaffnet. Neue Angriffe: Felsstacheln, feurige Risse. Bleibe in Bewegung.",
                    "|cFF0000Vulkanischer Schlag (HM)|r – Erzeugt Mini-Vulkan. Tank steht darauf BLOCKEND, um Gruppe zu schützen.",
                    "|cFF7F00Ketten (HM)|r – Boss fesselt 2 Spieler mit wachsenden AoEs. |cFF7F00BOSS UNTERBRECHEN|r & schnell rausbewegen nach Befreiung!",
                    "|c00FFFFEisavatar-Synergie|r – Nutze sie, um Salamander einzufrieren oder Boss zu debuffen. Time Weißglut-Synergie für Betäubungen/Heilungen.",
                },
            },
            {
                name = "Hauptmann Geminus",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Aufgeladener Sprungstich oder Schuss; blocken oder ausweichen oder sterben.",
                    "|cFFA500Blitzminen|r – Verstreut in Arena; Ausweichrolle durch oder Drauftreten vermeiden.",
                    "|cFF7F00Schatten von Geminus|r – Bis zu vier Bogenschützen erscheinen, kanalisieren massiven AoE auf Spieler. |cFF7F00SOFORT UNTERBRECHEN|r!",
                    "|cFF0000Unverwundbarkeitsphase|r – Bei ~70% & 30% geht Boss zur Mitte, spammt Feuerlinien. Luftatronach erscheint – töte ihn, brich Schild!",
                    "|cFF0000Teleportsprung|r – Springt zu Spieler und schlägt Boden in großem AoE. Verteilen & ausweichen oder blocken!",
                    "|cFFD700Feuerhunde|r – Erscheinen nach erstem Schild. Tank verspottet sie, DPS fokussiert sie (2+ können überwältigen).",
                    "|cFF0000Doppelspalten & Blutung|r – Große Frontalschwünge auf Tank. Drehe Boss nicht herum, sonst wird Gruppe getötet.",
                    "|c00FFFFEisplatte|r – Nutze Synergie, um Schatten oder Boss einzufrieren. Weißglut kann Schlüsselangriffe wie Sprung unterbrechen.",
                },
            },
            {
                name = "Pyroturg Encratis",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Wirbeltritt oder Schwertschlag. Muss geblockt werden, sonst wirst du umgeworfen.",
                    "|cFFA500Flammender Wirbel|r – Boss kanalisiert feurigen Ring zu seinen Füßen – raus oder sterben! Beschwört Flammengeister.",
                    "|cFF7F00Salamanderflamme|r – Flammenatem verwandelt sich in Salamander, die zufällige Spieler jagen & explodieren.",
                    "|cFF0000Feuersturm|r – Raumweite Flammen außer Bossmitte. Beschwört Feuer-Behemoth – tanke ihn weg & töte schnell!",
                    "|cFF0000Phase 2 (60%→~75%)|r – Boss flieht in zweite Arena, erhält flammendes Schwert & teleportiert häufiger. Achte auf neue AoEs.",
                    "|cFF0000Herzfeuerspeer|r – Wirft Schwert auf Tank oder zufälliges Ziel, explodiert dahinter in Kegel. BLOCKEN, sonst massiver Schaden.",
                    "|cFFD700Nutze Geysire|r – Zweite Arena: springe runter, um Inferno zu meiden, oder nutze Geysir, um sichere Zone um Boss wieder zu betreten.",
                    "|cFF0000Salamandergrube|r – Mittlere Grube erzeugt wiederholt Salamander – ignoriere oder töte, wenn sie dich unten belästigen.",
                    "|cFF0000Sturmlauf/Spalten|r – Frontale Kombos, die DPS/Heiler sofort töten können. Tank hält Boss weggedreht.",
                    "|c00FFFFEis-Synergie|r – Bricht Feuersturm oder Wirbel ab, wenn gut getimed. Betäubt Boss & belebt Verbündete wieder. Riesiger Vorteil im HM.",
                },
            },
            {
                name = "Wächter Aksalaz",
                mechanics = {
                    "|cFFD700Benötigt alle Geheimnisse + je 30 Fragmente (5 Versuche)|r – Seid vorbereitet, keine schlampigen Wipes.",
                    "|cFF0000Schwerer Angriff|r – Riesiger Axtschwung, blocken oder sofort sterben.",
                    "|cFF7F00Bodeneiszapfen|r – Axtschlag löst 3 jagende Eisstacheln pro Spieler aus. Bleibe in Bewegung.",
                    "|cFFA500Frostnova|r – Mittiger Cast mit wirbelnden äußeren Tornados. Verstecke dich an sicheren Stellen oder One-Shot.",
                    "|cFFD700Avatare beschworen|r – Bei 85/60/35% HP erscheinen Avatare des Eifers/Kraft/Standhaftigkeit. Volle Mechaniken, töte sie nacheinander.",
                    "|cFF7F00Frostbrut-Adds|r – Wenig HP, können dich aber umschwärmen. Fokussiere sie, wenn zu viele sich stapeln.",
                    "|cFF0000Exekution ~25%|r – Arena schrumpft mit konstantem Eissturm. Projektile aus Gittern füllen Lücken, achte auf Füße.",
                    "|cFF0000Herausforderer|r – Erhält Eismeteor & Frostbiss-DoTs bei bestimmten Moves. Verteile Meteortreffer. Hohe Heilung benötigt.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 20) Der Kessel (zoneId=1229)
    -------------------------------------------------------------------------------
    [1229] = {
        normalId = 593,
        vetId    = 594,
        zoneId   = 1229,
        sets     = {572,573,574,578},
        questID  = 6578,
        HM       = 2843,
        SR       = 2844,
        ND       = 2845,
        TR       = 2847,
        name     = "Der Kessel",
        bosses = {
            {
                name = "Ochsenblut der Verkommene",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Holt mit beiden Armen zu Schlag aus; Tank muss BLOCKEN oder DPS/Heiler AUSWEICHROLLE.",
                    "|cFF7F00Toxische Blähung|r – Dreht sich um und lässt 3 Giftgaswolken frei, die sich langsam nach außen in Dreieck ausbreiten.",
                    "|cFFA500Klecks beschwören|r – Erzeugt rote (Blut) und grüne (Galle) Kleckse. Rote schießen, grüne kriechen zum Boss. Töte sie, sonst wird Boss wütend oder heilt sich.",
                    "|cFF0000Giftkäfig|r – Fängt zufälligen Spieler in Käfig. Andere Mitglieder müssen ihn schnell DPSen oder Opfer stirbt.",
                    "|cFF7F00Ansturm|r – Wenn durch rote Kleckse wütend, stürmt Boss auf zufälligen Spieler zu, verursacht massiven Schaden, wenn nicht geblockt/ausgewichen.",
                    "|cFF0000Explodierende Ketten|r – Ketten unter jedem Spieler explodieren dreimal hintereinander. Bleibe in Bewegung, um große Treffer zu vermeiden.",
                },
            },
            {
                name = "Aufseherin Viccia",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Ein Aufwärtsschlag oder Stabhieb; BLOCKEN oder sterben. Wenn auf Nicht-Tank gezielt, AUSWEICHROLLE!",
                    "|cFFA500Blitzminen|r – Mehrere Schockminen erscheinen. Sie betäuben bei Kontakt; du kannst durchrollen oder Drathas einige negieren lassen.",
                    "|cFF7F00Kanalisierter Blitz|r – Zielt auf zufälligen Spieler mit tödlichem Strahl; muss |cFF7F00SCHNELL UNTERBROCHEN|r werden.",
                    "|cFF0000Großer AoE-Kreis|r – Boss kanalisiert großen Bodenschlagkreis. Herausbewegen & Tank positioniert Boss leicht neu.",
                    "|cFFD700Add-Wellen|r – Erscheinen bei ~75%, ~50%, ~25%. Dremora-Bogenschützen, -Magier. Töte sie oder werde überwältigt.",
                    "|cFF0000Kettenzug|r – Zieht zufällig entfernten Spieler heran. Wenn Blitzmine im Weg ist, kannst du durchgezogen werden. Achte auf Positionen.",
                },
            },
            {
                name = "Geschmolzener Wächter",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Schlägt Boden, hinterlässt Lavapfützen-AoE. Tank blockt & tritt nach Aufprall zur Seite.",
                    "|cFFA500Flammenhagel|r – Lässt Feuerbälle um Arena regnen, hinterlässt kleine Brandflecken. Bleibe in Bewegung.",
                    "|cFF7F00Kanalisierter Schlag|r – Boss kanalisiert schweren gruppenweiten DoT. Muss |cFF7F00UNTERBROCHEN|r werden, sonst erleidet Gruppe extremen Schaden.",
                    "|cFF0000Teleport|r – Boss verschwindet unter Lava & erscheint an anderem Rand wieder, erzeugt zwei geschmolzene Unhold-Adds. Töte diese Adds immer zuerst.",
                    "|cFF0000Nova-Schlag|r – Große Explosion mit großem Radius. Raus oder blocken/ausweichen im letzten Moment.",
                    "|cFFD700Stapelnder Feuerdebuff|r – Jeder Feuerballtreffer fügt stapelnden Debuff hinzu, der erlittenen Feuerschaden erhöht. Meide oder blocke diese Projektile.",
                },
            },
            {
                name = "Rettet Lyranth (Daedrische Begegnung)",
                mechanics = {
                    "|cFF7F00Zerstöre Energiemodule|r – Nutze Synergie mit Öl, um Module mit Lyranths Barriere zu verbinden. Lyranth entzündet sie. Jedes zerstörte Modul erzeugt Welle von Daedra.",
                    "|cFFD700Mehrere Wellen|r – Knochenkoloss, Daedroth, Titan, Ogrims, Bogenschützen. Handle zuerst Prioritäts-Adds ab: Xyvkin-Bogenschützen & große Daedra.",
                    "|cFF0000Xyvkin-Bogenschützen|r – Sehr tödliche Einzelzieltreffer. Tank muss sie schnell verspotten & DPS tötet sie zuerst.",
                    "|cFFA500Sturmatronachen|r – Explodieren beim Tod. Bleibe fern, wenn sie sich selbst zerstören.",
                    "|cFF0000Alle Module unten|r – Finale Welle enthält Flammentitan. Überlebe alles, um Lyranth zu befreien & diesen Abschnitt abzuschließen.",
                },
            },
            {
                name = "Baron Zaudrus",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Massiver Hammerschlag. Tank muss BLOCKEN oder wird getötet. Beschwört geschmolzene Säulen beim Aufprall.",
                    "|cFFA500Geschmolzene Säulen|r – Umwelthindernisse. Wenn |cFF7F00Ascheschacht|r-Strahl sie zerstört, erscheinen Daedroth-Adds. Wenn |c00FFFFKaltflammen-Synergie|r sie zerstört, erscheinen stattdessen freundliche Atronachen!",
                    "|cFF7F00Galvanischer Schlag|r – Breiter frontaler Kegel. Jeder Getroffene erhält Blitz-DoT-Kreis – |cFF0000NICHT stapeln|r, sonst großer Gruppenschaden.",
                    "|cFF0000Ascheschacht|r – Flammenwände umkreisen Arena. Meiden oder sofort getötet werden. Kann auch Säulen brechen, beschwört Daedroths, wenn nicht vorsichtig.",
                    "|cFFA500Feuergeysire|r – Zufällige Flammenkreise auf Boden, bleibe in Bewegung. Stalaktiten können auch von Decke fallen.",
                    "|cFFD700Kaltflammen-Infusion|r – Lyranth-Synergiebuff zum Töten von Säulen oder schnellem Niederbrennen von Boss/Adds. Beschwört verbündete Atronachen, wenn Säulen dadurch zerstört werden.",
                    "|cFF0000Herausforderer|r – Boss HP/Schaden stark erhöht. Zusätzliche Hammerwurf-Lavaflecken & häufigere Add-Erscheinungen. Vermeide gestapelte AoEs!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 21) Rotblütenbastion (zoneId=1267)
    -------------------------------------------------------------------------------
    [1267] = {
        normalId = 595,
        vetId    = 596,
        zoneId   = 1267,
        sets     = {608,605,606,607},
        questID  = 6683,
        HM       = 3018,
        SR       = 3019,
        ND       = 3020,
        TR       = 3023,
        name     = "Rotblütenbastion",
        bosses = {
            {
                name = "Geist der Krähen (Geheimboss #1)",
                mechanics = {
                    "|cFFD700Add-Wellen|r – Bevor Boss erscheint, zwei Wellen von ~3–6 Daedra. Tank sammelt sie; DPS tötet schnell.",
                    "|cFF0000Krähensturm|r – Zielt auf zufälligen Spieler mit krähenverseuchtem AoE. Kite weg von Gruppe oder riskiere schweren Schaden.",
                    "|cFF7F00Dunkle Blitze|r – Feuert Blitze unter jeden Spieler. Sie poppen schnell, also tritt zur Seite oder blocke, um Schaden zu reduzieren.",
                },
            },
            {
                name = "Rogerain der Schlaue",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Holt mit Stab aus, entfesselt wirbelnde oder elektrische Angriffe. Tank blockt oder DPS/Heiler Ausweichrolle.",
                    "|cFFA500Unaussprechliche Leere|r – Großer Bodenkreis am Standort eines Spielers. Schnell rausbewegen oder tödlichen Schaden erleiden.",
                    "|cFF0000Bauchplatscher|r – Innerhalb der Leere strahlen 8 kleinere AoEs aus. Bleibe seitlich ausweichend, um Betäubungen/Schaden zu vermeiden.",
                    "|cFF7F00Chaostor|r – Erzeugt Portal, das kleine Daedra beschwört (Spinnen, Hüpfer, Wächter). Töte Portal zuerst, um Adds zu stoppen.",
                    "|cFF0000Ziegenifizierung|r – Zufälliger Spieler wird Ziege, kann |cFFD700Süßrollen|r essen (für Buffs & Gruppenheilung) oder Chaostor für hohen Schaden anstürmen. Nutze deine Form weise!",
                    "|cFFA500Giftspritzer|r – Lässt kleine AoEs oder größere auf Spieler fallen. Verteilen & blocken, wenn du sie gleich explodieren lässt.",
                    "|cFFD700Frösche & Daedrische Adds|r – Regelmäßig beschworen; töte sie, um Chaos zu vermeiden. Lass sie nicht ansammeln.",
                    "|cFF0000Herausforderer|r – Gleiche Mechaniken, Boss hat höhere HP/Schaden. Kontrolliere Adds & koordiniere Ziegensynergie für Erfolg.",
                },
            },
            {
                name = "Spinnendaedra (Geheimboss #2)",
                mechanics = {
                    "|cFFD700Add-Wellen|r – Zwei Sätze von ~3–6 Mobs, bevor Boss erscheint. Tank hält sie, DPS fokussiert Adds schnell.",
                    "|cFF0000Schwerer Angriff|r – Direkter Schlag auf Tank, Block empfohlen. Nicht-Tanks müssen ausweichen oder sterben.",
                    "|cFF7F00Blitzschüsse|r – Zwei Spieler erhalten Blitzbögen über Kopf. Entweder blocken oder bewegen, um Aufprall zu vermeiden.",
                    "|cFFA500Spucken|r – Boss spuckt auf zufälliges Ziel. Wenn auf dich gezielt, Ausweichrolle oder rechtzeitig zur Seite treten.",
                },
            },
            {
                name = "Artefaktträger: Eliam Merick, Ihudir, Liramindrel",
                mechanics = {
                    "|cFF0000Schwere Angriffe|r – Basistreffer für Tank zum Blocken. Nicht-Tanks Ausweichrolle oder sterben, wenn Spott verloren geht.",
                    "|cFF7F00Sparta-Tritt|r – Boss versucht, Tank mit Folge-AoE zu treten. Selbst wenn geblockt, wirst du leicht zurückgestoßen. Sei bereit für nächsten Zug!",
                    "|cFF0000Blitzfelder|r – Große Schock-AoEs erscheinen auf Boden. Nicht stapeln und schnell herausbewegen.",
                    "|cFFA500Ansturm|r – Boss stürmt auf Tank zu. BLOCKEN oder rollen; DPS/Heiler werden wahrscheinlich getötet, wenn getroffen.",
                    "|cFFD700Miniboss-Adds|r – Bei ~80% erscheint Bogenschütze, bei ~50% der Zweihandkämpfer. Unterbrich ihn, sonst macht er Feinde wütend. Töte sie jedes Mal, sonst erschweren sie Kampf.",
                    "|cFF0000Bei 30%|r – Beide Adds kehren zusammen zurück. Normaler Vet: du kannst sie wieder töten oder Boss niederbrennen. |cFF0000Herausforderer|r: Sie werden bei Exekution unkillbar. Tank muss sie managen; DPS fokussiert Boss (keine Teil-Tötungen).",
                },
            },
            {
                name = "Gramvoller Zwielicht (Geheimboss #3)",
                mechanics = {
                    "|cFFD700Add-Wellen|r – Zwei Vorkampf-Wellen von ~3–6 Daedra. Gleicher Ansatz: Tank sammelt, DPS brennt sie schnell nieder.",
                    "|cFF0000Schwerer Angriff|r – Großer Schlag auf Tank, blocken oder tödlichen Schaden riskieren. Andere müssen ausweichen, wenn anvisiert.",
                    "|cFF7F00Maschinengewehrblitze|r – Schnelle Kugeln auf Spieler gerichtet (ähnlich Lord Wächter im GKK). Tank steht in Linie, um sie sicher zu blocken, wenn auf DPS/Heiler gezielt.",
                    "|cFF0000Meteore|r – Jeder Spieler erhält Meteor über Kopf. Verteilen & blocken oder Aufprall ausweichen. Nicht überlappen, sonst stirbt Gruppe schnell.",
                },
            },
            {
                name = "Prior Thierric Sarazen",
                mechanics = {
                    "|cFF0000Sparta-Tritt|r – Tritt Tank mit kleinem Boden-AoE. Selbst wenn geblockt, stößt dich leicht zurück. Sei bereit für sofortigen Folgezug.",
                    "|cFF7F00Schwerer Angriff/Spalten|r – Großer Frontalschwung. Tank muss blocken; DPS/Heiler hinter Boss oder werden zerstört.",
                    "|cFF0000Bodenstacheln|r – Boss kanalisiert: jeder Spieler sieht 4 kleine AoEs unter Füßen. Vorsichtig bewegen, damit sie nicht überlappen. Meiden oder jeden Pop blocken.",
                    "|cFF7F00Teleportstachel|r – Boss warpt weg, zufälliger Spieler wird markiert. Muss |cFF7F00SCHNELL UNTERBROCHEN|r werden, sonst wird dieser Spieler von Stachel von unten getötet (~300k+).",
                    "|cFFD700Add-Wellen|r – Stetiger Fluss von Daedra & Nord: töte sie zuerst! Sie können heilen oder betäuben. Kein DPS-Check am Boss, also Adds beseitigen oder überwältigt werden.",
                    "|cFFA500Heilkreise|r – Er lässt große Runenkreise fallen, die ihn heilen & dich verletzen. Lass Boss nicht darin stehen, und stehe selbst nicht darin.",
                    "|cFF0000Betäubungswände|r – Wände aus AoEs gleiten in Sätzen von ~3–4 über Arena. Finde Lücke und bewege dich durch, sonst wirst du gestoßen/betäubt + großer Schaden.",
                    "|cFF7F00Klingensturm (niedrige HP)|r – Beschwört langsame Wirbelwinde. Achte einfach auf Füße und meide sie.",
                    "|cFF0000Herausforderer|r – Mehr HP/Schaden. Teleportstachel erhält Schild, zwingt dich, in Blase zu rennen, um zu unterbrechen. Zusätzliche Betäubungskugeln aus Mechaniken früherer Bosse. Bleibe ruhig, töte Adds und blocke alles!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 22) Schreckenkeller (zoneId=1268)
    -------------------------------------------------------------------------------
    [1268] = {
        normalId = 597,
        vetId    = 598,
        zoneId   = 1268,
        sets     = {604,609,602,603},
        questID  = 6685,
        HM       = 3028,
        SR       = 3029,
        ND       = 3030,
        TR       = 3032,
        name     = "Schreckenkeller",
        bosses = {
            {
                name = "Purgator (Geheimboss #1)",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Boss lädt Hammer über Kopf auf; Tank BLOCKEN oder andere Rollen ausweichen oder sterben.",
                    "|cFFD700Flammenatronachen|r – Erscheinen wiederholt. Sie lassen Feuer-AoEs auf Boden fallen. Töten oder vom Gruppe wegtanken, wenn Schaden hoch ist.",
                    "|cFF7F00Meteore|r – Jeder Spieler erhält Meteor auf sich – verteilen & blocken/ausweichen. NICHT stapeln oder sofortiger Wipe.",
                },
            },
            {
                name = "Skorion-Brutherr",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Großer Überkopfschlag. Tank muss blocken oder wird niedergeschlagen/getötet.",
                    "|cFFA500Agonymiumsteine|r – Müssen zerstört werden, sonst absorbiert Boss sie, heilt oder bufft sich. Stapel Adds nahe Steinen, um sie zusammen zu cleaven.",
                    "|cFF7F00Totem / Säule|r – Teleportiert, um Säule auszusaugen. Töte sie schnell, um gruppenweiten Schaden zu stoppen. Achte auf Xivkyn oder andere Add-Erscheinungen.",
                    "|cFF0000Kegel-AoE (Aufruhr)|r – Drehe Boss von Gruppe weg. Wenn du getroffen wirst, ist hoher Schaden wahrscheinlich tödlich.",
                    "|cFFD700Mehrere Adds|r – Xivkyn-Berserker/Magier & andere erscheinen in Wellen. Priorisiere sie, bevor Boss weiter fokussiert wird.",
                    "|cFF0000Heranziehen + Explosion|r – Wenn Boss Stein verbraucht, zieht er Gruppe heran und verlangsamt sie. Weiche vor großer Explosion aus.",
                    "|cFF0000Fluch & DoTs|r – Achte auf Gesundheitsbalken; Heiler hält große Heilungen aufrecht. Boss kann nicht gereinigt werden. Überlebe mit Synergie.",
                    "|cFF0000Herausforderer|r – Zusätzliche Knochenkoloss & Daedroth Erscheinungen; fokussiere sie zuerst, sonst wippen sie Team. Säulenpriorität bleibt gleich.",
                },
            },
            {
                name = "Totengräber (Geheimboss #2)",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Überkopf-Stabschlag; muss geblockt werden, sonst wird Tank plattgemacht.",
                    "|cFFA500Add-Erscheinungen|r – Skelettbogenschützen & andere Untote erscheinen durchgehend. Töte sie, wenn sie sich gefährlich stapeln.",
                    "|cFF7F00Lichkristalle|r – Viele explosive Kristallbomben auf Boden – meiden oder sie verursachen großen DoT. Sie verschwinden nach kurzer Zeit.",
                    "|cFF0000Großer AOE-Burst|r – Totengräber kanalisiert ausbreitenden Kreis. Schnell heraustreten oder blocken, wenn du in Schwierigkeiten bist.",
                },
            },
            {
                name = "Cyronin Artellian",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Stab-Ausholen. Tank blockt oder DPS/Heiler müssen ausweichen oder sterben sofort.",
                    "|cFF7F00Blitzwinde|r – Boss wirbelt Stab, sendet wirbelnde Schocklinien aus. Bewegen oder blocken, um Treffer zu mildern.",
                    "|cFFD700Sturmatronachen|r – Beschworene Adds. Müssen getötet oder unterbrochen gehalten werden. Boss kann sie wiederbeleben, wenn Kampf sich zieht.",
                    "|cFFA500Blitzwyrm|r – Verlangsamt Spieler, kanalisiert Arretierenden Blitz. Wenn auf dich gezielt, mache extra Schaden darauf oder töte schnell.",
                    "|cFF0000Schädelprojektile|r – Boss kanalisiert rote Geisterschädel. Ausweichrolle oder blocken, wenn auf dich gezielt, sonst tödlich.",
                    "|cFF0000Rote Wellen (Schreckensflut)|r – Große fegende Wellen von Rändern. Finde Lücken oder werde getötet. Im Schweren Modus töten sie sofort!",
                    "|cFF7F00HM: Extra Debuffs|r – Zwei Spieler erhalten Donnerlinien, die Schock-AoEs hinterlassen. Verteilen, um sie sicher zu platzieren.",
                },
            },
            {
                name = "Gramwächter (Geheimboss #3)",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Muss von Tank geblockt werden. Andere ausweichen, wenn du versehentlich Aggro ziehst.",
                    "|cFF7F00Wirbelattacke|r – Boss wirbelt Sense 360°, tödlich, wenn du darin stehst. Tank muss Spott halten & langsam zurückweichen oder seitlich treten während Wirbel.",
                    "|cFFA500Add-Erscheinungen|r – Zwielicht oder geringere Adds erscheinen. Wenn zu viele ansammeln, wird Boss immun; töte einige, um Immunität zu entfernen.",
                    "|cFFFF00Wind-Auren|r – Ein oder zwei wirbelnde Windkugeln jagen zufällige Spieler – kite weg von Gruppe oder riskiere großen AoE-Schaden.",
                },
            },
            {
                name = "Magma-Inkarnation",
                mechanics = {
                    "|cFF0000Schwerer Angriff (Raserei)|r – Mehrere Schläge. Tank blockt zum Überleben. Sehr tödlich bei Misslingen.",
                    "|cFFA500Kanalisierungskreis|r – Inkarnation sticht Schwerter nieder, bildet großen orangenen Kreis. Tank muss darin stehen & BLOCKEN, um Gruppe vor pulsierendem Schaden zu schützen.",
                    "|cFF7F003-Strahl-Mechanik|r – Drei Spieler erhalten Strahlen. Nach 3s erhält jeder großen Feuer-DoT. Verteilen, damit sie nicht stapeln, sonst doppelter Schaden!",
                    "|cFF0000GROSSER BOOM|r – Raumweiter AoE. Blocken/ausweichen oder rauslaufen. Tank kann es mit Block absorbieren. DPS/Heiler können sicher wegtreten.",
                    "|cFFD700Skampen|r – Erscheinen in Wellen von ~4. Müssen schnell getötet werden, sonst stapeln sie tödlichen Feuerschaden. Tank sammelt; DPS brennt sie SOFORT nieder.",
                    "|cFF0000Portalphasen|r – Bei ~60% & 30% schützt sich Boss & wird immun. Betritt Portal, um Totem in Mini-Arena mit einzigartigen Gefahren zu zerstören. Erfolg verhindert Boss-Wutanfall-Buffs!",
                    "|cFFA500Nach-Portal-Winde|r – Zusätzliche wirbelnde oder wandernde Flammenwände erscheinen. Achte auf einzige Lücke, wenn sie Arena umkreisen. Keine Panik!",
                    "|cFF0000Herausforderer|r – Jedes Mal, wenn du Portal verlässt, erscheint großer Spinnen-Add mit ~2.5M HP. Tank muss verspotten & Gruppe tötet ihn zuerst. Auch Strahllinien lassen Flammen-AoEs auf Boden fallen. Platziere sie vorsichtig!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 23) Korallenhorst (zoneId=1301)
    -------------------------------------------------------------------------------
    [1301] = {
        normalId = 599,
        vetId    = 600,
        zoneId   = 1301,
        sets     = {632,619,620,621},
        questID  = 6740,
        HM       = 3153,
        SR       = 3107,
        ND       = 3108,
        TR       = 3111,
        name     = "Korallenhorst",
        bosses = {
            {
                name = "Schwertwächter",
                mechanics = {
                    "|cFF0000Spaltender Schock|r – Boss holt zu Spaltangriff aus, trifft Tank. Gruppenmitglieder erhalten jeweils Blitz-AoE-Kreis – verteilen, um überlappenden Schaden zu vermeiden.",
                    "|cFF7F00Schwere Schwünge/Stampfen|r – Mehrere schwere Angriffe & Schläge. Tank BLOCKT sie, minimale Bewegung nötig bei stabiler Formation.",
                },
            },
            {
                name = "Maligalig",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Doppelarmstich. Tank muss BLOCKEN oder wird niedergeschlagen/getötet. DPS/Heiler müssen ausweichen, wenn anvisiert.",
                    "|cFF7F00Sturm Zelle|r – Negativer AoE auf Spieler. Bewege ihn in 'Donut'-Sturm, der um Arena wirbelt, um ihn aufzulösen. Misslingen = tödlich!",
                    "|cFFA500Yaghra-Larve|r – Explodierende Käfer jagen markierte Spieler; Ausweichrolle oder töte sie schnell vor Detonation.",
                    "|cFFD700Wogende Wasser (70% & 35%)|r – Raum überflutet, spült alle herum. Nutze Synergie, um auf Mini-Inseln zu springen & 'Wellen' + Adds zu töten. Tank zuerst, dann Gruppe folgt. Töte Wellen jeder Plattform, um Kampf fortzusetzen.",
                    "|cFF0000Herausforderer Zusatz|r – 'Aufbauende Statik' in Wasserphasen. Längere Plattformzeit = schwererer DoT. Springe ins Wasser, um Statikstapel zu löschen, aber Wasser schädigt auch. Manage Heilungen & wiederholte Sprünge, um jede Plattform sicher zu meistern.",
                },
            },
            {
                name = "Stabwächter",
                mechanics = {
                    "|cFF0000Schwere Angriffe|r – Kanalisierte Stabtreffer. Tank blockt oder weicht als DPS aus, wenn anvisiert. Hinterlässt manchmal geringen DoT.",
                    "|cFFA500Große Boden-AoEs|r – Platziert regelmäßig große Fallen auf Boden – leicht vermeidbar durch mobil bleiben oder nahe Boss stapeln.",
                    "|cFF0000Meteor-Teleport|r – Boss teleportiert in Ecken, entfernt alte Fallen, platziert aber neue. Position entsprechend ändern.",
                },
            },
            {
                name = "S’zarzo das Bollwerk",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Schildschlag. Tank blockt, um Niederschlag zu vermeiden. Nicht-Tank muss ausweichen oder erleidet tödlichen Schaden.",
                    "|cFFA500Banner|r – DK-ähnliche Standarte platziert. Bewege Boss raus, lass ihn nicht im Banner stehen, sonst erhält er Schaden.",
                    "|cFF7F00Add-Wellen|r – ~4 Bogenschützen oder Krieger erscheinen. Ziehe sie heran, töte sie schnell, bevor zu Boss zurückgekehrt wird.",
                    "|cFF0000Popcorn-AoEs|r – S’zarzo kanalisiert mehrere schnelle AoE-Pops unter jedem Spieler (3 Mal). Laufe nicht herum; blocke einfach alle 3 Treffer oder tritt vorsichtig zur Seite.",
                },
            },
            {
                name = "Sarydil",
                mechanics = {
                    "|cFF0000Angriff/Brandmal|r – Schneller Teleportschlag + schwerer Folgeangriff. Tank hält Spott, blockt oder DPS/Heiler müssen Ausweichrolle machen, wenn anvisiert.",
                    "|cFFA500Sprintminen|r – Boss springt durch Raum, hinterlässt Minen. Achte auf Füße & wechsle zu neuem Ort. Tritt nicht darauf!",
                    "|cFF7F00Wurfdolche|r – Nach Sprinten kanalisiert Dolchhagel. |cFF7F00SOFORT UNTERBRECHEN|r oder tödlich für Gruppe.",
                    "|cFF0000GROSSER BOOM|r – Expandierender AoE nach Rückwärtssalto. Entweder blocken oder im letzten Moment ausweichen. Übrige platzierte Minen explodieren dann auch!",
                    "|cFFD700Markiert (Fallen)|r – Zufälliger Spieler lässt mehrere Bodenfallen für einige Sekunden fallen. Laufe zu leerem Raum, um sie sicher weg von Gruppe zu platzieren.",
                    "|cFF7F00Add-Phasen (70%/40%)|r – Boss verschwindet, erzeugt ~4 Adds (Bogenschützen, Beschwörer, etc.). Letzte Welle fügt 'Bollwerk'-Miniboss hinzu. Töte sie oder werde überwältigt. Dann erscheint Sarydil wieder.",
                    "|cFF0000Schatten/Illusionen|r – Sie dupliziert sich an Rändern. Finde & unterbrich die echte, sonst erleidest du verheerende Treffer, wenn nicht schnell gestoppt.",
                    "|cFF0000Herausforderer|r – Zusätzliche Aufgestiegene Sturmwirker erscheinen, müssen |cFF7F00ständig UNTERBROCHEN|r werden, wenn nicht getötet. Markierte Mechanik betrifft alle Spieler jede Add-Phase. Schnell beseitigen, um Minenchaos zu begrenzen. Überleben oder wipen!",
                },
            },
            {
                name = "Schildwächter",
                mechanics = {
                    "|cFF0000Schwere Angriffe|r – Starke Schildschläge. Tank blockt, um große Treffer zu vermeiden. Andere dürfen keine Aggro nehmen oder werden zerquetscht.",
                    "|cFFA500Schildphase (~65%, 25%)|r – Wächter duckt sich, wird unverwundbar. 3 Adds kanalisieren Energie in Schild – töte sie, um ihn zu brechen. Wiederholen, falls es wieder auftritt. Dann Kampf normal fortsetzen.",
                },
            },
            {
                name = "Varallion",
                mechanics = {
                    "|cFF0000Schwerer Angriff (Auslöschen)|r – Nicht extrem stark, aber Block zur Sicherheit empfohlen. Wenn DPS/Heiler anvisiert, blocken/ausweichen zur Sicherheit.",
                    "|cFF7F00Meereskugel + Wellen|r – Häufige riesige Wasserwellen kreuzen Arena – meide sie. Markierte Spieler sehen schwebende Kugel auf sich zukommen. Blocke aus nächster Nähe oder töte aus Distanz. Explodiert, wenn unbehandelt.",
                    "|cFFA500Fallenfelder|r – Lila Kreise auf Boden. Wegbewegen & in Ecken ablegen. Darin stehen ist über Zeit tödlich.",
                    "|cFFD700Mehrere Greifen|r – Bei ~90%, ~80%, ~50% erscheinen kleinere Greifen (in zufälliger Reihenfolge) mit einzigartigen Mechaniken:\n • Blutungs-Greif: Einfache schwere Blutungen.\n • Wind-Greif: Beschwört 2 Tornados.\n • Blitz-Greif: Großes statisches Feld jagt zufälligen Spieler.\nTöte sie, sonst geht dir schnell sicherer Platz aus!",
                    "|cFF0000Herausforderer|r – Bei 30% kommt riesiger 4. Greif (Kargaeda) hinzu, plus mehr Wellenkombos, die T-Form bilden. Gruppe muss Boss provoziert halten, Kargaeda töten oder bleibt stecken. Währenddessen nehmen Fesselmechaniken (zwei Spieler verbunden) mehr Schaden bei großer Entfernung. Überlappe Endphasen mit massiven Tornadowänden. Überlebe, koordiniere, kein DPS-Check – Geduld ist Schlüssel!",
                },
            },
            {
                name = "Z’Baza (Finaler Geheimboss)",
                mechanics = {
                    "|cFF0000Tentakel|r – Erscheinen um Arena, senden Hiebe & beschwören kleinere AoEs. Töten reduziert Raumgefahren.",
                    "|cFF7F00Gedankenschlag|r – Wenn Boss Spieler vorne sieht, schlägt er sie mit starken Illusionen. Tank dreht Boss WEG; Gruppe steht dahinter.",
                    "|cFFA500Kugel Explosionen|r – Kugeln jagen markierte Spieler. Töten oder abfangen durch Blocken/Ausweichen der Explosion bei sicherer HP. Poppe sie nicht in Gruppe.",
                    "|cFF0000Teleport + Portal|r – Z’Baza springt manchmal weit weg; ein Synergie-Wasserloch kann dich schnell zu ihrem Standort bringen – nützlich für Tank-Neu verspotten.",
                    "|cFFD700Geschützte Phase (~55%, ~25%)|r – Boss ist immun, während Tentakel oder kleineres Add kanalisiert. Du bist in Blase gefangen & nimmst Schaden. Töte kanalisierendes Add schnell, um Boss wieder schaden zu können.",
                    "|cFF0000Herausforderer|r – Mehr HP/Schaden, schnellere Kugel-Erscheinungen, größere AoEs von Tentakeln, aber Ansatz ist identisch. Kämpfe methodisch, töte Tentakel, halte Boss weggedreht, achte auf Füße, und du wirst Erfolg haben!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 24) Gram des Schiffbauers (zoneId=1302)
    -------------------------------------------------------------------------------
    [1302] = {
        normalId = 601,
        vetId    = 602,
        zoneId   = 1302,
        sets     = {624,633,622,623},
        questID  = 6742,
        HM       = 3154,
        SR       = 3117,
        ND       = 3118,
        TR       = 3120,
        name     = "Gram des Schiffbauers",
        bosses = {
            {
                name = "Verlorene Maid (Geheimboss #1)",
                mechanics = {
                    "|cFF0000Schrei-AoE|r – Frontaler eisbasierter Schrei (|cFF0000BLOCKEN|r oder zur Seite treten). Vermeide es, vorne zu sein.",
                    "|cFFA500Eissäulen|r – Mehrere kleine Säulen, die verlangsamen & DoT verursachen. |cFFD700TÖTEN|r oder umkreisen.",
                    "|cFF7F00Schattenaufspaltung (~54%)|r – Boss wird immun, erzeugt 3 Illusionen. Zerstöre sie schnell, sonst bleibt Boss unantastbar.",
                },
            },
            {
                name = "Vorarbeiter Bradiggan",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Extrem hoher Schaden – (|cFF0000BLOCKEN oder AUSWEICHEN|r). Misslingen = One-Shot.",
                    "|cFF7F00GROSSER BOOM|r – AoE breitet sich von Mitte aus; du kannst ihn nicht absorbieren, sonst Kettenexplosion. Schnell heraustreten.",
                    "|cFFA500Ansturm + Geister|r – Nach jedem Ansturm erscheinen 4 nicht spottbare Geister & fesseln Spieler. |cFFD700TÖTE sie schnell|r, um Debuffs zu entfernen.",
                    "|cFFD700Fleischkoloss|r bei ~60% / ~30% – Boss geht; töte Koloss, sonst Chaos. Boss kehrt nach Koloss-Tod zurück.",
                    "|cFF0000Herausforderer Bomben|r – Bei ~30% erscheinen zwei Bomben auf zwei Spielern; jeder muss mit genau einem Verbündeten teilen, nicht mehr!",
                },
            },
            {
                name = "Verhüllter Axtmann (Geheimboss #2)",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Tödlicher Überkopfschwung; idealerweise |cFF0000AUSWEICHEN|r oder blocken als Tank.",
                    "|cFF7F00Explodierende Hunde|r – Markieren zufälligen Spieler & explodieren. Time Ausweichen oder Blocken zum Überleben.",
                    "|cFFA500Geisterphase|r – Boss verschwindet; 4 rote Geister zum |cFF7F00UNTERBRECHEN|r. Sie hinterlassen AoEs, die kurz danach detonieren. Dann erscheint Boss wieder.",
                    "|cFFD700Kleine Adds|r – Einige Skelettverbündete erscheinen. Töte sie oder riskiere, dass sich schwere Treffer stapeln.",
                },
            },
            {
                name = "Nazaray",
                mechanics = {
                    "|cFF0000Schwerer Angriff/Keule|r – Muss geblockt oder ausgewichen werden. Tödlicher Treffer, wenn nicht gemildert.",
                    "|cFF7F00Heuschreckenregen|r – Fallende AoEs von oben. Bleibe |cFF0000IN BEWEGUNG|r oder blocke, wenn festgehalten.",
                    "|cFFA500Giftflecken|r – Auf Boden, können verlangsamen. Meiden, sonst erleidest du schweren DoT.",
                    "|cFFD700Riesenwespen|r – Häufig beschworen. Töte schnell, um Chaos zu reduzieren. Unter 30% erscheinen wirbelnde Giftwinde.",
                    "|cFF0000Herausforderer Ungezähmte Verwandte|r – Beschwört 3 große Adds, die explodierende AoEs kanalisieren. |cFFD700FOKUSSIERE einen|r, um sichere Zone zu schaffen; andere explodieren weg von Gruppe.",
                },
            },
            {
                name = "Sturmverfluchter Seemann (Geheimboss #3)",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Mächtiger Hieb. Tank oder Ziel blockt/rollt. Beschwört Blitzbögen auf zufällige Spieler.",
                    "|cFF7F00Überlader-Aura|r – Gewählter Spieler erhält Kettenblitz. Nicht herumlaufen; stehen & gegenheilen/blocken.",
                    "|cFFA500Multi-Teleport|r – Boss springt herum. Blocke einfach jede Landung oder werde niedergeschlagen.",
                },
            },
            {
                name = "Kapitän Numirril",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r – Muss geblockt werden. Hat auch frontalen Spaltangriff & zufällige Sprint-Anstürme – meiden oder blocken.",
                    "|cFF7F00Wellen (~80% & ~40%)|r – Kreuzen Arena paarweise; |cFF0000BEWEGEN|r oder niedergeschlagen & DoT erleiden.",
                    "|cFFA500Beschwört Ertrunkene|r – Leichen oder Kolosse. Sie überfluten Bereich mit üblen Pfützen. Töte sie, um sichere Plätze offen zu halten.",
                    "|cFFD700Fleischabsomination|r ~85% & 40% – Boss geht, töte oder kite 'Malcolm'. Dann kehrt Boss zurück. Im HM erscheinen 2 unter 40%. Gruppensynergie ist entscheidend!",
                    "|cFF0000Kein DPS-Check|r – Überlebe Mechaniken, verspotte Adds & Boss immer neu. Geduld sichert Sieg.",
                },
            },
        },
    },
    
    -------------------------------------------------------------------------------
    -- 25) Erdwurz-Enklave (zoneId=1360)
    -------------------------------------------------------------------------------
    [1360] = {
        normalId = 608,
        vetId    = 609,
        zoneId   = 1360,
        sets     = {660,661,662,666},
        questID  = 6835,
        HM       = 3377,
        SR       = 3378,
        ND       = 3379,
        TR       = 3381,
        name     = "Erdwurz-Enklave",
        bosses = {
            {
                name = "Geschuppte Wurzeln (Geheimboss #1)",
                mechanics = {
                    "Schwerer Angriff – Muss vom Tank geblockt oder von DPS/Heiler ausgewichen werden, wenn anvisiert (|cFF0000BLOCKEN|r) :contentReference[oaicite:0]{index=0}",
                    "Meteore – Jeder Spieler wird anvisiert; verteilen und entweder blocken oder ausweichen, um Überlappung zu vermeiden (|cFF0000BLOCKEN oder AUSWEICHEN|r) :contentReference[oaicite:1]{index=1}",
                    "Feuerwölfe – Erscheinen wiederholt und springen Spieler an; töte sie schnell (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:2]{index=2}",
                    "Brennender Boden – Der Boss schleudert Feuer auf den Aggro-Halter und hinterlässt Flammenflecken auf dem Boden (|cFFA500RAUSBEWEGEN|r) :contentReference[oaicite:3]{index=3}",
                },
            },
            {
                name = "Verderbnis des Steins",
                mechanics = {
                    "Erdbeben – Erscheinen unter jedem Spieler; bewegen, damit sie nicht stapeln (|cFFA500VERTEILEN|r) :contentReference[oaicite:4]{index=4}",
                    "Stampfen – Der Boss kanalisiert einen großen AoE von der Mitte aus, der niederschlägt, wenn nicht ausgewichen wird (|cFF0000BEWEGEN|r) :contentReference[oaicite:5]{index=5}",
                    "Versteckphasen (~75%, 50%, 25%) – Renne hinter eine Steinsäule oder stirb durch den Schlag des Bosses (|cFF0000ONE-SHOT|r) :contentReference[oaicite:6]{index=6}",
                    "Stein-Atronachen – Beschworen nach jeder Versteckphase; töte oder unterbrich sie schnell (|cFFD700ADDS FOKUSSIEREN|r) :contentReference[oaicite:7]{index=7}",
                    "Übermäßiges Ausweichen – Exzessives Ausweichen erzürnt den Boss und erhöht den Schaden (|cFF0000AUSWEICHEN BEGRENZEN|r) :contentReference[oaicite:8]{index=8}",
                    "Herausforderer – Mehr Gesundheit/Schaden, mehr Atronachen. Überspringe keine Adds, sonst wirst du überwältigt (|cFFD700TÖTE sie|r) :contentReference[oaicite:9]{index=9}",
                },
            },
            {
                name = "Lutea (Geheimboss #2)",
                mechanics = {
                    "Wässriger Ring (Donut) – Fängt die Gruppe in einem Ring; stehe in der Mitte, um tödlichen Schaden zu vermeiden (|cFF0000MITTE BLEIBEN|r) :contentReference[oaicite:10]{index=10}",
                    "Wasserspritzer – Boss schleudert Wasser frontal in einer Linie; blocken oder zur Seite treten als Tank (|cFF0000BLOCKEN|r) :contentReference[oaicite:11]{index=11}",
                    "Geysir (Unterbrechbar) – Großer Kanal verursacht hohen Schaden; schnell unterbrechen oder blocken (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:12]{index=12}",
                    "Teleport – Sie springt durch den Raum und setzt Fallenplatzierungen zurück. Folge und verspotte schnell neu :contentReference[oaicite:13]{index=13}",
                },
            },
            {
                name = "Verderbnis der Wurzel",
                mechanics = {
                    "Grüne AoEs – Schnell bewegende Ströme über den Boden; staple nicht mit anderen (|cFFA500MOBIL BLEIBEN|r) :contentReference[oaicite:14]{index=14}",
                    "Faune & Spriggans – Beschworen in Wellen, plus Wurzelbäume, die sie schützen. Zerstöre die Bäume, um Faune herauszuzwingen (|cFFD700ADDS TÖTEN|r) :contentReference[oaicite:15]{index=15}",
                    "Verteiler (Illusionen) – Boss teilt sich in mehrere Kopien; töte sie alle, sonst bleibt Boss immun (|cFFD700ILLUSIONEN FOKUSSIEREN|r) :contentReference[oaicite:16]{index=16}",
                    "Herausforderer – Größere Wellen, zusätzliche Bäume, dreifache Erscheinungen. Kein direkter Enrage, kann aber überwältigen, wenn ignoriert (|cFF0000ADDS ZUERST KONTROLLIEREN|r) :contentReference[oaicite:17]{index=17}",
                },
            },
            {
                name = "Jodoro (Geheimboss #3)",
                mechanics = {
                    "Gedankenschlag – Frontaler Kanal. Muss unterbrochen werden, sonst verwüstet er die Gruppe (|cFF7F00UNTERBRECHEN|r) :contentReference[oaicite:18]{index=18}",
                    "Spektraler Indrik – Ein kleinerer Geist stürmt auf die Gruppe zu. Zielt normalerweise auf den Tank. Ausweichen oder blocken nach Bedarf :contentReference[oaicite:19]{index=19}",
                    "Laserlinien – Rote Bögen unter jedem Spieler, verursachen schweren Schaden bei Überlappung. Verteilen (|cFF0000STAPELN VERMEIDEN|r) :contentReference[oaicite:20]{index=20}",
                    "Teleport + Kanal – Boss verschwindet, erscheint weit weg wieder. Spott aufrechterhalten, schnell unterbrechen, wenn er wieder mit Gedankenschlag beginnt :contentReference[oaicite:21]{index=21}",
                },
            },
            {
                name = "Erzi Druide Devyric",
                mechanics = {
                    "Erdbeben – Wie Beben der Verderbnis des Steins, verteilen, damit sie nicht überlappen (|cFFA500VERTEILEN|r) :contentReference[oaicite:22]{index=22}",
                    "Totems – Erscheinen in Ecken, explodieren mit AoE & finalem Projektil. Wegtreten, dann blocken oder ausweichen (|cFF0000FINALEN TREFFER BLOCKEN|r) :contentReference[oaicite:23]{index=23}",
                    "Blitzsäule – Beschworen mit ~370k HP. Muss getötet werden, sonst bombardiert sie Gruppe mit Blitzen (|cFFD700PRIORITÄTS-ADD|r) :contentReference[oaicite:24]{index=24}",
                    "Flammenwölfe – Markierter Spieler wird gejagt. Time Block oder Ausweichen, um Sprung zu überleben (|cFF0000BLOCKEN oder ROLLEN|r) :contentReference[oaicite:25]{index=25}",
                    "Bärenform (~70% / 20%) – Boss verwandelt sich, regeneriert HP. Erhält riesigen Blitzatem & zufälligen Ansturm. Lass ihn Totems zerschmettern, um sie zu beseitigen. Kehrt möglicherweise später zurück oder bleibt. (|cFF0000ATEM KITEN oder BLOCKEN|r) :contentReference[oaicite:26]{index=26}",
                    "Exekutionsphase – Mehrere Blitzregen. Jeder muss blocken oder riskiert sofortigen Tod. (Heiler hält große HoTs aufrecht) :contentReference[oaicite:27]{index=27}",
                    "Herausforderer – Mehr Totems, schwerere Treffer, zusätzliche Wolfserscheinungen. Synergie bei Blitzsäulentötungen aufrechterhalten & sorgfältig koordinieren. Kein direkter DPS-Check, nur überleben & Mechaniken handhaben :contentReference[oaicite:28]{index=28}",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 26) Kentertiefen (zoneId=1361)
    -------------------------------------------------------------------------------
    [1361] = {
        normalId = 610,
        vetId    = 611,
        zoneId   = 1361,
        sets     = {664,665,667,663},
        questID  = 6837,
        HM       = 3396,
        SR       = 3397,
        ND       = 3398,
        TR       = 3400,
        name     = "Kentertiefen",
        bosses = {
            {
                name = "Mzugru (Geheimboss #1)",
                mechanics = {
                    "Blitzschläge – Der Boss feuert Bögen nach oben, verursacht Blitz-AoEs auf dem Boden. Wegtreten (|cFF0000BEWEGEN|r) :contentReference[oaicite:0]{index=0}",
                    "Schildphase – Boss heilt hinter Barriere. Zerstöre die Pylone, um Immunität zu entfernen (|cFFD700PYLONE TÖTEN|r) :contentReference[oaicite:1]{index=1}",
                    "Wirbelangriff – Boss rotiert an Ort und Stelle, verursacht schweren Nahkampf-AoE. Tank kann blocken; andere halten Abstand (|cFF0000BLOCKEN oder ZURÜCKWEICHEN|r) :contentReference[oaicite:2]{index=2}",
                },
            },
            {
                name = "Der euphotische Torwächter",
                mechanics = {
                    "Ansturm & Ausrasten – Boss sprintet im Zickzack, lässt AoEs fallen. Jage ihn nicht; lass ihn zu dir zurückkehren (|cFFA500STEHEN BLEIBEN|r) :contentReference[oaicite:3]{index=3}",
                    "Gräben & Adds – Kleine Löcher erzeugen Pangrits. Spieler mit Giftsynergie müssen sie stopfen, sonst erscheinen mehr Adds (|cFF0000SYNERGIE NUTZEN|r) :contentReference[oaicite:4]{index=4}",
                    "Teleport-Boom – Teleportiert weg, hinterlässt expandierenden AoE. Schnell zurücktreten (|cFF0000RAUSBEWEGEN|r) :contentReference[oaicite:5]{index=5}",
                    "Zwillingsillusion – Boss erzeugt Spiegelbild mit wenig HP. Wenn nicht schnell getötet, explodiert es. Achte auch auf schwere Angriffe (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:6]{index=6}",
                    "Herausforderer – Schnellere AoEs, mehr Schaden und häufigere Add-Erscheinungen. Überlebe mit sorgfältiger Synergienutzung :contentReference[oaicite:7]{index=7}",
                },
            },
            {
                name = "Xzyviian, Verteidigungskrabbler (Geheimboss #2)",
                mechanics = {
                    "Schwerer Angriff – Tank muss blocken oder DPS/Heiler muss ausweichen. Tödlich, wenn nicht gemildert (|cFF0000BLOCKEN|r) :contentReference[oaicite:8]{index=8}",
                    "Feuerbomben – Zufällige Bodenkreise, die brennen. Nicht stapeln oder verweilen (|cFF0000BEWEGEN|r) :contentReference[oaicite:9]{index=9}",
                    "Sprung-AoE – Boss springt gelegentlich, schlägt auf Boden auf. Zurücktreten oder blocken (|cFF0000LANDUNG VERMEIDEN|r) :contentReference[oaicite:10]{index=10}",
                },
            },
            {
                name = "Varzunon",
                mechanics = {
                    "Skelett-Adds – Beschwört Skelette nonstop. Tank sammelt sie; DPS muss schnell töten (|cFFD700PRIORITÄTS-ADDS|r) :contentReference[oaicite:11]{index=11}",
                    "Fressen an Opfern – Leuchtende Skelette kriechen zum Boss, lassen ihn wachsen. Töte sie, um Enrage zu verhindern (|cFFD700SCHNELL TÖTEN|r) :contentReference[oaicite:12]{index=12}",
                    "Stampfen – Expandierender AoE-Niederschlag. Achte auf größeren Radius, wenn Boss groß ist (|cFF0000BEWEGEN|r) :contentReference[oaicite:13]{index=13}",
                    "Meteore – Mehrere Einzelzieltreffer von oben. Heiler sei bereit mit Gruppenheilungen (|cFF0000HP HOCHHALTEN|r) :contentReference[oaicite:14]{index=14}",
                    "Herausforderer – Zusätzliche Überkopf-AoEs und stärkere Adds. Manage Boss-Wachstum oder halte Heilung stark :contentReference[oaicite:15]{index=15}",
                },
            },
            {
                name = "Chralzak, Sphäre 9402-A (Geheimboss #3)",
                mechanics = {
                    "Wirbelangriff – Ein wirbelnder Angriff im Nahbereich. Tank kann blocken, andere treten heraus (|cFF0000WIRBEL VERMEIDEN|r) :contentReference[oaicite:16]{index=16}",
                    "Bombenwürfe – Feuert große Schockbomben auf zufällige Spieler. Achte auf Aufprallkreise (|cFF0000BEWEGEN|r) :contentReference[oaicite:17]{index=17}",
                    "Immunitätsschild – Erhält regelmäßig Unverwundbarkeit. Zerstöre den aktiven Pylon oder Leiter, um ihn zu brechen (|cFFD700LEITER TÖTEN|r) :contentReference[oaicite:18]{index=18}",
                },
            },
            {
                name = "Zelvraak der Atemlose",
                mechanics = {
                    "Meereskugel – Eine große Blase sinkt langsam herab. Greife sie an, um sie zurückzudrängen. Wenn sie Boden berührt, wiped Gruppe (|cFF0000HÖCHSTE PRIORITÄT|r) :contentReference[oaicite:19]{index=19}",
                    "Furcht – Boss kanalisiert schwarzen Rauch. Drehe dich physisch weg oder werde gefürchtet (kein Befreien) (|cFF0000WEGSCHAUEN|r) :contentReference[oaicite:20]{index=20}",
                    "Schatten (~75% & 25%) – Vier Illusionen erscheinen, jede muss unterbrochen werden, sonst schlagen sie Gruppe (|cFF7F00UNTERBRECHEN & TÖTEN|r) :contentReference[oaicite:21]{index=21}",
                    "Zerrissene Seele – Markiert einen Spieler, zieht seine Seele heraus. Laufe zu deinem Geist, um zu überleben. (|cFF0000SAMMLE deine Seele|r) :contentReference[oaicite:22]{index=22}",
                    "Reichswechsel @50% – Jeder wird solo portiert. Töte weiße Geister für Heilung, meide schwarze Geister oder töte sie. Rückkehr erzeugt Fleischabsomination oder kleineren Atronachen (abhängig von deinen Kills) (|cFFD700ADD FOKUSSIEREN|r) :contentReference[oaicite:23]{index=23}",
                    "Kegelangriff – Boss plus alle Illusionen oder Spaltungen replizieren denselben frontalen Kegel. Tank hält sie alle weggedreht (|cFF0000BOSS NICHT DREHEN|r) :contentReference[oaicite:24]{index=24}",
                    "Herausforderer – Intensivere Seelenzerrissen-Mechaniken, 2 Spieler gleichzeitig, Wiederbelebung erzeugt Skelett-Adds, und Boss kann Flammen über Kopf entzünden, die gruppenweiten Schaden verursachen. Verpasse keine einzige Meereskugel, sonst sterbt ihr alle! :contentReference[oaicite:25]{index=25}",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 27) Bal Sunnar (zoneId=1389)
    -------------------------------------------------------------------------------
    [1389] = {
        normalId = 613,
        vetId    = 614,
        zoneId   = 1389,
        sets     = {680,681,682,683},
        questID  = 6896,
        HM       = 3470,
        SR       = 3471,
        ND       = 3472,
        TR       = 3474,
        name     = "Bal Sunnar",
        bosses = {
            {
                name = "Geheimnis #1 - Totem-Rätsel",
                mechanics = {
                    "Zufälliges Rätsel mit zentralem Totem (vier Blöcke) und drei kleineren Totems an Rändern.",
                    "Nutze die vier Hebel, um jeden Block am zentralen Totem zu drehen. Blöcke 1 & 2 passen zum rechten Totem, 2 & 3 zum mittleren, 3 & 4 zum linken.",
                    "Wenn gelöst, öffnen sich Käfige und du erhältst 'Stärke der Ahnen'-Buff (+300 Waffen-/Magieschaden).",
                },
            },
            {
                name = "Kovan Giryon (Boss #1)",
                mechanics = {
                    "Teleport-Mechanik – Der Boss teleportiert durch den Raum und bildet breite rechteckige AoEs, die ihn kreuzen. Tritt zur Seite oder blocke. (|cFF0000BEWEGEN|r)",
                    "Schattenphase (~65%, 45%, 20%) – Boss wird immun, beschwört Adds. Tank sammelt sie, DPS tötet schnell. Dann normaler Kampf geht weiter. (|cFFD700ADDS TÖTEN|r)",
                    "Giftexplosion – Explosiver Gift-AoE um Boss. Wenn du siehst, wie er auflädt, raus oder blocken. (|cFF0000BEWEGEN / BLOCKEN|r)",
                    "Herausforderer Extra – Gift-AoEs heften sich an alle Spieler. Verteilen, um überlappenden tickenden DoT zu vermeiden. Heiler hält Gruppe am Leben. (|cFF0000NICHT überlappen|r)",
                },
            },
            {
                name = "Geheimnis #2 - Urvel Drath (Mini-Boss)",
                mechanics = {
                    "Beexilko der Behemoth – Startet eingesperrt mit wenig HP, regeneriert. Betäubt Urvel gelegentlich, hilft dir kurz. Dann zappt Urvel ihn wieder. (|cFF0000ACHTE auf Bossreaktion|r)",
                    "Lavasäulen – Beschwört Säulen, die sich nach außen ausbreiten. Einfach zur Seite treten. (|cFF0000BEWEGEN|r)",
                    "Suchende Flamme – Rote Rune über Kopf. Flammen-AoE jagt dich langsam. Kite vorsichtig; explodiert bei Kontakt. (|cFF7F00NICHT mit anderen überlappen|r)",
                    "Besiegen von Urvel Drath gewährt 'Ahnene Vitalität'-Buff (+30% Magicka- & Ausdauerregeneration).",
                },
            },
            {
                name = "Roksa die Verzerrte (Boss #2)",
                mechanics = {
                    "Dunkellichtkugeln – Erzeugt Kugeln, die Spieler fesseln. Schnell unterbrechen oder Schaden machen. Wenn nicht getan, stirbt gefesselter Spieler. (|cFF7F00UNTERBRECHEN oder KUGELN TÖTEN|r)",
                    "Dunkelheitsphase (~70% & 40%) – Raum wird dunkel. Nur 2 sichere Lichtzonen bleiben. Boss wirft AoEs nahe dir – bewege dich zum zweiten Licht, um ihnen auszuweichen. Adds erscheinen; töte sie. (|cFFA500IM LICHT STEHEN|r)",
                    "Tankstrahl – Nach Dunkelheit trifft Boss Tank mit tödlichem Strahl für ~10s. Heiler fokussiert Tank; Tank blockt oder schützt sich. (|cFF0000TANK HEILEN|r)",
                    "Herausforderer – Drei Strahlen gleichzeitig auf Tank, plus stärkere Illusionen. Längerer Kampf wegen 12.9M HP. (|cFF0000STARKE Heilung nötig|r)",
                },
            },
            {
                name = "Geheimnis #3 - Laserstrahl-Rätsel",
                mechanics = {
                    "Vier Laser an Rändern, zielen auf zentrales Totem. Bewege kleine reflektierende Steine, sodass jeder Laser Totem trifft. (|cFFA500Versuch & Irrtum|r)",
                    "Größere Blöcke können nicht reflektieren, nur die kleineren. Achte auf ihre Sichtlinie. (|cFF0000STRAHLEN AUSRICHTEN|r)",
                    "Abschluss gewährt 'Ahnene Entschlossenheit'-Buff (+3000 Max Leben, +10% Schadensresistenz).",
                },
            },
            {
                name = "Matriarchin Lladi Telvanni (Boss #3 / Endboss)",
                mechanics = {
                    "Brechkegel – Sehr breiter & langer Giftkegel auf Tank. (|cFF0000BLOCKEN als Tank oder HINTER BOSS BLEIBEN|r).",
                    "Giftsturm (~70% & 35%) – Gesamte Arena überflutet mit Gift, schwerer DoT. Nach paar Sekunden erscheint Synergie zum Reinigen & Betäuben von Adds. Töte sie für Schadensfenster. (|cFFD700ADDS NIEDERBRENNEN|r)",
                    "Peryites Ruhm – Grüne Klecks-Adds mit moderater HP. Tank sammelt sie; töte im Cleave, wenn dein AoE hoch ist. (|cFFD700FOKUSSIEREN bei wenig AoE|r)",
                    "Schwerere AoE – Sie platziert wirbelnde oder große bodenbasierte Giftkreise. Halte Füße in Bewegung. (|cFF0000BEWEGEN|r)",
                    "Herausforderer Extra – Adds werden komplett unverwundbar, außer wenn von Synergie betäubt. Erzeugt auch Skeever, die markierten Spieler jagen. Wenn gefangen, großer Debuff. (|cFF7F00SKEEVER KITEN; DPS schnell töten|r)",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 28) Halle der Schriftmeister (zoneId=1390)
    -------------------------------------------------------------------------------
    [1390] = {
        normalId = 615,
        vetId    = 616,
        zoneId   = 1390,
        sets     = {684,685,686,687},
        questID  = 7027,
        HM       = 3531,
        SR       = 3532,
        ND       = 3533,
        TR       = 3535,
        name     = "Halle der Schriftmeister",
        bosses = {
            {
                name = "Ritenmeister Naqri",
                mechanics = {
                    "|cFF0000Versteckter Kodex (80%, 55%, 35%)|r: Großes schwebendes Buch erscheint, wendet farbcodierte Angriffe an (|cFF0000Rot|r = |cFF7F00UNTERBRECHUNG|r nötig, |c00FF00Grün|r = kleine |cFF0000BLOCK|r AoEs, |cFFFFFFWeiß|r = schwere Treffer müssen |cFF0000GEBLOCKT|r werden). Finde & zerstöre 2 versteckte Bücher in Regalen, um es zu entfernen!",
                    "|cFF0000Instabile Literatur|r: Kleiner grüner AoE bildet sich. Ein Spieler muss darin stehen und |cFF0000BLOCKEN|r, sonst erleidet Gruppe riesigen Schaden. (Im Schweren Modus erscheinen 2 gleichzeitig.)",
                    "|cFF0000Eisbuchsturm|r: Mehrere Eisprojektile wirbeln nach außen – verteilen oder in Bewegung bleiben. Heiler muss starke (|c00FF00HEILUNG|r) über Zeit nutzen, da Burst-Schaden hochschnellen kann.",
                    "|cFF0000Schwerer Stabangriff|r: Muss |cFF0000GEBLOCKT|r werden, sonst schlägt er nieder / tötet Weiche.",
                },
            },
            {
                name = "Ozezan das Inferno",
                mechanics = {
                    "|cFF0000Lavapools|r: Boss gräbt sich ein & erscheint wieder, hinterlässt große Lava-AoEs, die bestehen bleiben. Tank positioniert nahe Rändern, um zu überlappen und Platz zu sparen.",
                    "|cFF0000Kegelflamme|r: Großer frontaler Spaltangriff auf Tank – (|cFF0000BLOCKEN|r oder |cFF0000AUSWEICHEN|r), wenn anvisiert. Immer Boss von Gruppe wegdrehen.",
                    "|cFF0000Entwickelte Brutlinge|r: Kleine fliegende Adds – (|cFFD700TÖTEN|r schnell, sonst überwältigen sie). Sie kanalisieren tödliche DoTs – (|cFF7F00UNTERBRECHEN|r) sie!",
                    "|cFFA500Ansaugen (mitten im Kampf)|r: Boss bewegt sich zur Mitte; riesiger AoE dehnt sich aus, bedeckt Großteil des Bodens – (|cFFA500ZUM ÄUSSEREN RAND BEWEGEN|r) oder herangezogen werden und sterben.",
                    "|cFF0000Herausforderer|r: Laser zielen jetzt auf alle 4 Spieler statt 2. Bei 40% & 20% beschwört Boss Eisenatronachen – Tank muss versotten oder Gruppe muss (|cFFD700TÖTEN|r) sie. Auch grüne Käfer auf Boden – tritt darauf, sonst werden sie zu extra Adds!",
                },
            },
            {
                name = "Valinna (Mehrphasig mit Lamikhai)",
                mechanics = {
                    "|cFFA500Wütende Spinne|r: Lamikhai leuchtet rot. Ziehe sie in Eiskreis, um Wut zu entfernen. Lass auch Feuermeteore an Raumrändern fallen, um Mitte frei zu halten.",
                    "|cFF0000Raumeruption|r: Bei ~15–20% Lamikhai HP wird Raum tödlich. (|cFFA500BEWEGE dich schnell durch Netztür|r) oder One-Shot.",
                    "|cFF0000Stolperdraht|r: Zwei Spieler erhalten überlappende AoEs. Jeder muss im eigenen bleiben, sonst sterben beide! Überquere nie Linie zwischen ihnen!",
                    "|cFF0000Valinnas Feuerwut|r: Sie teleportiert & kanalisiert massiven Flammenkegel auf Tank. (|cFF0000BLOCKEN|r oder sterben). Halte ihn davon ab, Gruppe zu treffen.",
                    "|cFFA500Lamikhai kehrt bei 55% HP zurück|r: Spinnen erscheinen, haken Spieler ein. (|cFFD700TÖTE|r sie schnell!) Verlasse dann Raum wieder, wenn er ausbricht!",
                    "|cFF0000Explodierende Meteore|r: Große leuchtende Kugeln landen – (|cFFD700TÖTE|r sie schnell), sonst explodieren sie, stoßen zurück und schleudern dich wahrscheinlich von Arena!",
                    "Frühere Mechaniken überlappen: achte auf Stolperdrähte, Feuermeteore, große Flammenkegel, + keine Spinne mehr, aber minimaler Platz.",
                    "|cFF0000Herausforderer|r: Feuermeteor-Pools bleiben für immer, achte auf vorsichtige Platzierung. Höhere Gesundheit/Schaden – Team muss akribisch koordinieren.",
                },
            },
            {
                name = "Kartendieb-Skampen & Tresor-Mechanik",
                mechanics = {
                    "|cFF0000Tresortruhen|r: Zu Beginn des Dungeons verschlossener Tresor mit mehreren Truhen. Benötigt Schlüssel von 2 Kartendieb-Skampen pro Durchlauf (einer nach erstem Boss, einer nach zweitem).",
                    "Besiege jeden Skampen, bevor er flieht, um kleinen (Normal) oder großen (Veteran) Schlüssel zu verdienen. Sammle & öffne genug Tresortruhen, um geheimen Boss 'Kartoqueen' erscheinen zu lassen.",
                    "|cFF0000Kartoqueen|r: Skampen-ähnlicher Boss mit Flammenwellen, explosiven Mörser-Explosionen, rotierenden Säulen, die ihr Immunität geben, wenn sie darin steht – (|cFFD700SÄULEN zuerst TÖTEN|r!). Achte auf Wirbelangriffe & blocke große Treffer. Manage Totems oder Bomben schnell!",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 29) Grube der Eidgeschworenen (zoneId=1470)
    -------------------------------------------------------------------------------
    [1470] = {
        normalId = 638,
        vetId    = 639,
        zoneId   = 1470,
        sets     = {732,734,730,731},
        questID  = 7105,
        HM       = 3812,
        SR       = 3813,
        ND       = 3814,
        TR       = 3816,
        name     = "Grube der Eidgeschworenen",
        bosses = {
            {
                name = "Rudelführer Rethelros & Malthil",
                mechanics = {
                    "|cFF0000Wutanfall|r: Rethelros (Fernkampf) & Malthil (Wolf) werden wütend, wenn sie zu nah kommen, erhöht Malthils Schaden drastisch. Haltet sie getrennt!",
                    "|cFF0000Bärenfallen|r: Rethelros wirft Fallen auf Boden – Drauftreten wurzelt dich. Meiden oder schnell befreien!",
                    "|cFF7F00Schutztotem|r: Periodisch beschworen, gewährt Boss & Wolf Immunität. (|cFFD700TÖTE|r Totem, um Schild zu entfernen).",
                    "|cFF0000Glutschuss|r: Rethelros zielt mit feurigem Schuss auf 1–3 Spieler. Verteilen & BLOCKEN oder schnell zur Seite bewegen nach Aufprall (hinterlässt kleines Lagerfeuer).",
                    "|cFFA500Wolf-Aggro|r: Malthil verliert Aggro, jagt zufällige Spieler. Wenn wütend, kann er mit schwerem Biss töten – meiden oder von Rethelros getrennt halten.",
                    "|cFF7F00Herausforderer|r: Beide Bosse haben mehr HP/Schaden. |cFF0000Glutschuss|r zielt auf alle 4 Spieler. Schutztotem hat erhöhte HP."
                },
            },
            {
                name = "Anthelmirs Konstrukt",
                mechanics = {
                    "|cFF0000Glutmücken|r: Kleine fliegende Kreaturen zielen auf zufälligen Spieler & detonieren bei Kontakt. Lock sie nahe Fässer, um persistente Feuer-AoEs zu erzeugen oder töte sie schnell.",
                    "|cFF0000Explosive Fässer|r: Verstreut in Arena – detonieren bei Feuerberührung, hinterlassen permanente Lavaflecken. Meide Nähe zu ihnen, wenn Glutmücken nahen.",
                    "|cFFA500Axt greifen/werfen|r: Konstrukt greift Axt aus Ecke (langer linearer AoE). Stehe nicht im Weg. Wirft sie dann auf Spieler – ausweichen oder im letzten Moment blocken zum Überleben.",
                    "|cFF0000Hitzestoß|r: Anthelmir teleportiert & kanalisiert Feuerschild. Muss gebrochen werden (|cFFD700TÖTE|r ~132k HP Schild) oder Konstrukt auf 70% töten, damit es verschmilzt & sie abbricht.",
                    "|cFFA500Flammenwerfer|r: Sobald verschmolzen (~70%), entfesselt Boss frontalen Flammenangriff. Tank dreht von Gruppe weg & blockt schwere Treffer.",
                    "|cFF7F00Herausforderer|r: Konstrukt HP verdoppelt. |cFF0000Glutmücken|r erscheinen häufiger (123k HP). Hitzestoß-Schild stärker. Alles verursacht höheren Schaden."
                },
            },
            {
                name = "Aradros der Erwachte",
                mechanics = {
                    "|cFF0000Schwerer Angriff|r: Ein aufgeladener Schlag. Tank muss BLOCKEN, sonst tödlich. Macht auch kleine Ring-AoEs bei Landung.",
                    "|cFF0000Glühender Schlag|r: Schlägt Boden, entzündet Bodenplatten in Muster. Meiden oder großen Feuer-DoT erhalten.",
                    "|cFFA500Lauffeuer|r: Nach Schlag erhalten 2–4 Spieler Feuer-DoT, entzündet Platten unter Füßen. Bleibe in Bewegung & überlappe nicht.",
                    "|cFF7F00Geschmolzene Platte|r: Einige Platten werden zu Lavabögen. Kann kurz durchrollen, aber meide Stehen darin. Hoher DoT bei Betreten.",
                    "|cFF0000Seitenbosse bei 50%|r: Aradros entzündet gesamten Boden – renne in Seitenräume. Anzahl Sub-Bosse hängt von Schwierigkeit ab:\n• Normal: 1 Seitenboss\n• Veteran: 2 Seitenbosse\n• Herausforderer: 3 Seitenbosse\nNach Besiegen zurückkehren, um Aradros wieder mit intensiveren Plattenmustern zu begegnen.",
                    "|cFF0000Der Schmelzer|r: Beschwöre eigenen freundlichen Eisenatronachen durch Sammeln von Flammen aus 3 Schmieden & Nutzung an teilweisem Atronachen in Mittelraum. Hilft dir, Sub-Bosse zu bekämpfen!",
                    "|cFF7F00Herausforderer|r: Mehr Plattenentzündungen, schwerere Feuer-DoTs & 3 Seitenbosse gleichzeitig bei Vet HM. Aradros hat signifikant höhere Gesundheit/Schaden. Achte auf überlappende Mechaniken & halte große Heilungen aufrecht!"
                },
            },
            {
                name = "Sluthrug der Blutige (Geheimboss #1)",
                mechanics = {
                    "|cFFA500Prüfung des Blutes|r: Gefunden über versteckten Pfad vor erstem Boss. Beschwöre durch Aktivieren des Totems des Blutes.",
                    "|cFF0000Schwere Hiebe|r: Tank muss Aggro halten – Hiebe & Kegeltreffer können Weiche schnell töten.",
                    "|cFF7F00Blutkleckse|r: Bewegen sich herum, verschmelzen. Behalte im Auge, sonst bilden sie größere schädigende Pfützen. Einfache Bewegung meidet sie.",
                    "|cFFA500Eisstacheln|r: Überlappende Frost-AoEs auf Boden – ausweichen oder heraustreten, um anhaltenden Schaden zu vermeiden.",
                    "|cFF0000Blutige Vitalität Buff|r: +10% Heilung & -10% erlittener Schaden. Totem-Synergie gewährt +50% max Leben & verursacht Vergeltungsschläge bei Treffer – stackt Schaden mit Totemischer Gerinnung."
                },
            },
            {
                name = "Bolg der Üblen Stacheln (Geheimboss #2)",
                mechanics = {
                    "|cFFA500Prüfung der Eroberung|r: Freischalten durch Entzünden von 2 Kohlebecken nach erstem Boss. Dann Seitenbereich betreten & Totem der Eroberung aktivieren.",
                    "|cFF0000Spektrale Bogenschützen|r: Beschworene Adds – ziehe sie heran oder töte schnell. Sie machen Pfeilstürme mit moderatem Schaden.",
                    "|cFF7F00Geister der Eroberung|r: Geister, die Kohlebecken beanspruchen. Wenn erfolgreich, buffen sie Boss. (|cFFD700Unterbrechen oder töten|r sie schnell, oder erobere Kohlebecken selbst zurück!)",
                    "|cFFA500Hagel-AoEs|r: Bolg feuert Pfeilstürme, die Spieler verfolgen. Einfach in Bewegung bleiben.",
                    "|cFF0000Eroberers Elan Buff|r: +30% Magicka- & Ausdauerregeneration. Totem-Synergie gewährt 16 Ult dir/8 Ult Verbündeten alle 2 Sekunden – super für Burst-Phasen!"
                },
            },
            {
                name = "Grubduthag Vielschicksal (Geheimboss #3)",
                mechanics = {
                    "|cFFA500Prüfung des Krieges|r: Gefunden auf Pfad vor Endboss. Aktiviere Totem des Krieges, um ihn zu beschwören.",
                    "|cFF0000Schwerer Angriff|r: Muss geblockt werden, sonst One-Shot. Kann auch Meteor-AoE machen, den du blocken oder seitlich ausweichen kannst.",
                    "|cFF7F00Schmiedebeschwörungen|r: Er nutzt Schmieden, um Flammenatronachen zu beschwören. Beschwöre eigene Kaltflammen-Atronachen aus Schmieden, um zu helfen oder töte neue Erscheinungen schnell!",
                    "|cFF0000Kriegers Antlitz Buff|r: +10% Waffen-/Magieschaden. Totem-Synergie löst Flammen-DoT bei jedem leichten/mittleren/schweren Angriff aus. Stackt Kriegsmüdigkeit für höheren Schaden bei wiederholten Treffern!"
                },
            },
        },
    },

    ----------------------------------------------------------------------------
    -- 30) Schleier des Aufruhrs (zoneId=1471)
    ----------------------------------------------------------------------------
    [1471] = {
        normalId = 640,
        vetId    = 641,
        zoneId   = 1471,
        sets     = {736,737,738,735},
        questID  = 7155,
        HM       = 3853,
        SR       = 3854,
        ND       = 3855,
        TR       = 3857,
        name     = "Schleier des Aufruhrs",
        bosses = {
            {
                name = "Zerschmetterter Champion",
                mechanics = {
                    "|cFF0000Schwerer Angriff / Gehindert|r – Boss schlägt Boden, wendet Heilungsabsorptions-Debuff (|cFFFFFFGehindert|r) auf Getroffenen an. Tank muss |cFF0000BLOCKEN|r oder ausweichen. Betroffene Spieler benötigen ~24k Heilung zum Entfernen.",
                    "|cFFA500Scharfes Glas|r – Verzögerte Kreise unter jedem Spieler. Hinterlassen nach kurzer Zeit persistente AoEs. Wegtreten oder |cFF0000AUSWEICHEN|r beim finalen Aufprall, um Clustering in Mitte zu vermeiden.",
                    "|cFF7F00Glasier-Adds|r – Kanalisieren gelegentlich Schildstrahl, der Boss/Adds immun macht. Töte oder ziehe sie schnell heran. Normale Unterbrechungen wirken nicht, aber Heranziehen bricht Kanal ab.",
                    "|cFF0000Klaffende Wunde|r – Fast jeder Boss-Treffer wendet unschildbaren Oblivion-DoT an. Halte konsistente Heilungen/HoTs aufrecht, um überlappenden Schaden zu überleben.",
                    "|cFF7F00Glasring (70%, 50%)|r – Zwei kreisförmige Barrieren erscheinen von Außenkante nach innen. Überquere sie nicht. Kämpfe innerhalb oder zwischen sicheren Zonen, während Platz schrumpft.",
                    "|cFF0000Glassplitter|r – Erscheinen herum, feuern Blendende Salve. Brenne sie schnell nieder oder ziehe sie für AoE-Kills heran.",
                    "|cFFD700Herausforderer|r – Boss hat höhere HP (~8.12M), schwereren Schaden, häufigere AoEs/Adds. Mechaniken bleiben gleich, nur bestrafender."
                },
            },
            {
                name = "Dunkelsplitter",
                mechanics = {
                    "|cFF0000Schrei + Betäubung|r – Boss heult, stößt dich zurück & platziert großen AoE zu seinen Füßen. Befreien & zur Seite treten. Folge-Schwerer Angriff oder Kegel kann töten, wenn nicht geblockt.",
                    "|cFF7F00Beschwöre Mini-Bosse|r – Bei 80%/60%/40% HP verschwindet Boss, erzeugt:\n   • Maxus der Viele (Duplikate: Militanten & Elementaristen)\n   • Champion der Gräueltat (Mahlstrom Arena 6 Mechaniken: Obelisken entnetzen, Spinnenlinge handhaben, Wut betäuben)\n   • Argonischer Behemoth (Mahlstrom Arena 7: Giftblumen, reinigende Pools)\nBesiege jeden, damit Dunkelsplitter zurückkehrt. Adds erscheinen danach weiter, erschweren Kampf.",
                    "|cFF0000Schwerer Angriff|r – Tödlicher Überkopfschlag, wenn auf dich gezielt. Tank sollte |cFF0000BLOCKEN|r oder auf zufällige Schattentreffer gefasst sein. DPS/Heiler müssen auch darauf achten.",
                    "|cFFA500Greifender Schrei|r – Lila Blitze betäuben Spieler. Befreien. Hinterlässt AoE nahe Boss. Schatten könnte ähnlich jemand anderen anvisieren.",
                    "|cFF0000Giftblumen / Wasserpools|r – Argonischer Behemoth Phase bedeckt Boden mit tödlichen Blüten. Tritt in Pool zum Reinigen von Gift bei Berührung. Tank muss Hüter/Wut handhaben oder sie schnell töten.",
                    "|cFFD700Herausforderer|r – ~5.07M HP. Schnellere Erscheinungen von jedem Mini-Boss, schwerere Treffer. Obelisken/Spinnenling-Phasen unter Kontrolle halten ist entscheidend."
                },
            },
            {
                name = "Der Blinde (Endboss)",
                mechanics = {
                    "|cFF0000Verwünschung|r – Jeder Spieler erhält verzögerten AoE. Herausbewegen oder finalen Pop blocken/ausweichen. Hinterlässt schädigenden Bodeneffekt.",
                    "|cFF0000Levitationsschlag|r – Boss schwebt & kanalisiert großen AoE. Jeder Getroffene erleidet riesigen Schaden plus Heilungsabsorption. Befreien oder schnell raus.",
                    "|cFFA500Spiegelplasma-Adds|r – Erscheinen sporadisch, lassen kleine Boden-AoEs fallen. Töte sie, damit sie sich nicht stapeln.",
                    "|cFF7F00Schattenskelette|r – Bei 80/60/40/20% HP bewegt sich Der Blinde an Arenarand; Skelette erscheinen, feuern lineare Wellen (|cFF0000Gleißende Flut|r) oder Strahlen, die Bahnen blockieren. Frequenz von Wellen/Strahlen wächst jede Phase!",
                    "|cFFA500Glasüberreste|r – Kleinere ‘Zerschmetterter Champion’-Adds bei 60% & 40%. Müssen getötet werden, damit Der Blinde zurückkehrt. Sie wirken Blendende Salve – meiden oder blocken.",
                    "|cFFD700Rätsel-Synergien|r – Wenn alle 3 Rätsel gelöst sind, nutze Amulette:\n   • Zephyrus Obscuris (Strahlen/Wellen parieren)\n   • Okularer Disperser (Wellen teilen)\n   • Katatonischer Disruptor (große Kanäle unterbrechen/umwerfen)\nHelfen, Wellen/Strahlendruck in Endphasen zu managen."
                },
            },
            {
                name = "Rätsel-Synergien & Buffs",
                mechanics = {
                    "|cFFA500Erstes Rätsel|r – Entferne 2 Linien, lass 3 Quadrate übrig. Belohnt |cFF7F00Zephyrus Obscuris|r Synergie: 'Welle/Strahlen kurz an Barriere abwehren.'",
                    "|cFF0000Zweites Rätsel|r – Entferne 2 Linien, lass 2 Quadrate übrig (groß + klein). Belohnt |cFF7F00Okularer Disperser|r Synergie: 'Wellen-Gefahren bei Nutzung teilen.'",
                    "|cFF0000Drittes Rätsel|r – Entferne 3 Linien, lass 4 Quadrate übrig. Belohnt |cFF7F00Katatonischer Disruptor|r Synergie: 'Angreifer/große Kanäle kurz zu Boden zwingen.'",
                    "Abschluss jedes Rätsels gewährt auch extra Beute aus Schmucktruhe. Nur eine Synergie kann gleichzeitig genutzt werden (geteilte Abklingzeit) – koordiniert sie im Endkampf!"
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 31) Schanze der Abgeschiedenen (zoneId: 1496)
    -------------------------------------------------------------------------------
    [1496] = {
        normalId = 642,
        vetId    = 643,
        zoneId   = 1496,
        sets     = {797, 795, 796, 794},
        questID  = 7235,
        HM       = 4111,
        SR       = 4112,
        ND       = 4113,
        TR       = 4115,
        name     = "Schanze der Abgeschiedenen",
        bosses   = {
            {
                name = "Wachhauptmann Paratius (Geheimnis)",
                mechanics = {
                    "Beschwört Skelettschützer bei 50% und 30% HP, macht Boss |cFFD700IMMUN|r.",
                    "Nutzt |cFF0000SCHILDANSTURM|r auf entfernte Ziele.",
                    "Wirft seinen Schild zweimal – Spieler müssen |cFF0000AUSWEICHEN|r, |cFF0000ROLLEN|r oder |cFF0000BLOCKEN|r, um Angriff zu vermeiden.",
                    "Beschwört gelegentlich Skelettbogenschützen und -zauberer (|cFFD700ADDS TÖTEN|r).",
                },
            },
            {
                name = "Henker Jerensi",
                mechanics = {
                    "Wird |cFFD700IMMUN|r bei 75%, 50% und 30% HP, während er Kerkermeister/Folterer-Adds beschwört.",
                    "Wirft |cFF0000STACHELFALLEN|r auf Boden – Spieler sollten |cFF0000BEWEGEN|r, um sie zu vermeiden.",
                    "Platziert |cFF0000TODESGLOCKE|r AoEs auf Spieler; schnelle Bewegung nötig, um ihnen auszuweichen (|cFF0000BEWEGEN|r).",
                    "Ein Exekutionssprung wird angezeigt (|cFFFF00EXEKUTIEREN|r); Spieler sollten sich gruppieren, um Schaden zu teilen.",
                    "Nutzt |cFF0000ZERFETZEN|r und |cFF0000SCHATTENSPALTEN|r in Frontalangriff (|cFF0000BLOCKEN|r erforderlich).",
                },
            },
            {
                name = "Dozent Domitius (Geheimnis)",
                mechanics = {
                    "Wirkt |cFF0000SEELENZERTRÜMMERN|r, einen mäßig starken dunklen AoE zentriert auf Tankposition.",
                    "Beschwört fliegende, geisterhafte Objekte, die Spieler betäuben oder zu Boden werfen (|cFF7F00UNTERBRECHEN|r erforderlich).",
                    "Wirkt kleinen |c00FFFFEISBLITZ|r auf Tank.",
                    "Beschwört regelmäßig kleine Skelett-Adds (|cFFD700ADDS TÖTEN|r).",
                },
            },
            {
                name = "Primus-Zauberer Vandorallen",
                mechanics = {
                    "Schleudert |cFF0000STURMBLITZ|r auf entferntesten Spieler, hinterlässt Blitz-AoE-Feld.",
                    "Kettenblitz verbreitet sich, wenn Spieler im Feld bleiben (|cFF0000VERTEILEN|r).",
                    "Besteigt flammendes Pferd und führt |cFF0000EISENANSTURM|r aus, der Feuer-AoEs hinterlässt.",
                    "Beschwört |cFFD700EISENATRONACH-SPINNEN|r – nutze |c00FFFFGEFRORENE KUPPEL|r, um sie zu verlangsamen.",
                    "Verleiht zufälligem Spieler |cFF00FFSCHWARZDORNFLUCH|r (DoT).",
                    "Sendet |cFF7F00RASENDE FLAMMEN|r aus, die Salamander nach außen schießen.",
                    "Führt |cFF0000BLITZSTABSCHLAG|r aus, verursacht Mini-Blitz-AoEs unter jedem Spieler (|cFF0000BLOCKEN|r erforderlich).",
                    "Eine |cFF0000FUNKELNDE KUGEL|r durchquert Arena, betäubt jeden darin Gefangenen.",
                    "Simulakrum-Adds erscheinen unter 40% HP und wirken |cFFD700FEUERSTURM|r aus Distanz (|cFFD700ADDS TÖTEN|r).",
                },
            },
            {
                name = "Eliana Albus (Geheimnis)",
                mechanics = {
                    "Hinterlässt |cFF0000PFÜTZE DES KUMMERS|r, dunkle AoEs auf Boden.",
                    "Kanalisiert |cFF7F00ÜBERWÄLTIGENDER KUMMER|r Blitze für mehrere Sekunden.",
                    "Wirkt |cFF0000BÖSWILLIGE VERWEIGERUNG|r Kugeln, die von Wänden abprallen.",
                    "Erzeugt |cFFD700SCHATTIGES DUPLIKAT|r mit moderater Gesundheit.",
                    "Entfesselt |cFF0000ECHOENDER SCHMERZ|r Kegel, der Tank anvisiert (|cFF0000BLOCKEN|r erforderlich).",
                },
            },
            {
                name = "Sturm der Vergeltung",
                mechanics = {
                    "Führt |cFF0000SECHS-SCHWERTER-ANGRIFF|r aus, wobei Schwerter nach außen und dann zurück geworfen werden (|cFF0000AUSWEICHEN|r erforderlich).",
                    "Dreht sich in |cFF0000WIRBEL-AoE|r um sich selbst (|cFF0000VERMEIDEN|r).",
                    "Koordinierter Hieb: Schwerer Angriff auf Tank, der |cFF0000GEHINDERT|r und |cFF0000ERSCHÜTTERT|r anwendet (|cFF0000BLOCKEN|r erforderlich).",
                    "Feuerphase: Feueratronachen lassen |cFF0000FEUERKUGELN|r mit Entzündet-DoT fallen, während |cFF0000FEUERSTURM|r-Wirbel bestehen bleiben.",
                    "Frostphase: Frostatronachen lassen |c00FFFFFROSTKUGELN|r mit Frierender Tod-DoT fallen, und der |c00FFFFGEFRORENE BODEN|r schrumpft.",
                    "Sturmphase: Sturmatronachen lassen |cFF0000SCHOCKKUGELN|r mit Sturm-DoT fallen, begleitet von |cFF0000DONNERSCHLAG|r, der alle Spieler trifft.",
                },
            },
        },
    },

    -------------------------------------------------------------------------------
    -- 32) Lep Seclusa (zoneId = 1497)
    -------------------------------------------------------------------------------
    [1497] = {
        normalId = 644,
        vetId    = 645,
        zoneId   = 1497,
        sets     = {801, 799, 798, 800},
        questID  = 7237,
        HM       = 4130,
        SR       = 4131,
        ND       = 4132,
        TR       = 4134,
        name     = "Lep Seclusa",
        bosses   = {
            {
                name = "Lewin Frey (Überspringbar)",
                mechanics = {
                    "Geladener Schlag – Lewin kanalisiert starken Blitzangriff auf zufälligen Spieler, wendet Conduit-Schaden-über-Zeit-Effekt an. (|c00FF00SOFORT HEILEN|r!)",
                    "Funken – Führt kegelförmigen Flächenangriff auf Tank aus; blocke Angriff, um Schaden zu reduzieren. (|cFF0000BLOCKEN|r)",
                    "Gewitter – Beschwört krachende Blitzeinschläge, die bei Aufprall explodieren – weiche ihnen aus! (|cFF0000AUSWEICHEN|r)",
                    "Donnerdiener – Springt zu zufälliger Position, verursacht Schockschaden und Rückstoß; bewege dich schnell aus Explosionszone. (|cFF0000BEWEGEN|r)",
                },
            },
            {
                name = "Garvin der Spurensucher",
                mechanics = {
                    "Schnitt – Führt Basisangriff aus, der Blutungseffekt auf Tank verursacht; blocke wenn möglich. (|cFF0000BLOCKEN|r)",
                    "Wirbelwind – Dreht sich 360° für fegenden Flächenangriff; ausweichen oder blocken, um Schaden zu vermeiden. (|cFF0000AUSWEICHEN|r)",
                    "Giftiger Felsbrocken – Stürmt mit Felsbrocken vorwärts, der bei Aufprall toxischen Bereich erzeugt – brich Sichtlinie, um Effekt zu reduzieren. (|cFF7F00SICHTLINIE BRECHEN|r)",
                    "Verschwindepulver – Verschwindet und erscheint hinter großem Felsen wieder; positioniere schnell neu, um nachfolgende Gefahren zu vermeiden. (|cFF0000BEWEGEN|r)",
                    "Durchbohrender Derwisch – Entfesselt zweiseitigen Angriffshagel; stehe seitlich vom Boss, um Angriff auszuweichen. (|cFF0000AUSWEICHEN|r)",
                    "Rikoschett – Verbindet zwei Spieler mit giftiger Fessel; brich Sichtlinie zwischen ihnen, um Effekt zu löschen. (|c00FFFFBEFREIEN|r)",
                    "Gift Eruption – Füllt Bereich mit toxischen Wolken; gehe in Deckung, bis sie sich auflösen. (|cFF0000VERSTECKEN|r)",
                    "Unterbrich Adds – Unterbrich Casts von Deserteur-Infusor, Sturmmagier und Flammenbogenschütze, um Buffen und zusätzliche Flächeneffekte zu verhindern. (|cFF7F00UNTERBRECHEN|r)",
                },
            },
            {
                name = "Belagerungsmeister Malthoras (Überspringbar)",
                mechanics = {
                    "Ballistenmechanik – Bleibt auf Station, bis du Ballisten reparierst und bemannst; nutze sie, um seine Verteidigung zu schwächen. (|cFF7F00BALLISTE NUTZEN|r)",
                    "Durchbohrender Schuss – Feuert schnelle Pfeilsalven; blocken oder ausweichen, um Schaden zu mildern. (|cFF0000BLOCKEN oder AUSWEICHEN|r)",
                    "Feuerbomben – Wirft Feuerbomben, die brennende Flecken auf Boden hinterlassen; bewege dich aus Flammen. (|cFF0000BEWEGEN|r)",
                    "Gezielte Salve – Startet fokussierten Pfeilhagel auf Ziel; blocke, wenn du anvisiert wirst. (|cFF0000BLOCKEN|r)",
                    "Zerschmetterndes Stampfen – Schlägt Boden, verursacht Rückstoß; weiche Stampfer aus, um Schaden zu vermeiden. (|cFF0000AUSWEICHEN|r)",
                    "Bebenschuss – Feuert springende Projektile, die hinter initialem Ziel treffen können; positioniere neu, um zusätzlichen Schaden zu vermeiden. (|cFF0000BEWEGEN|r)",
                },
            },
            {
                name = "Noriwen",
                mechanics = {
                    "Schnitt – Führt schnellen Nahkampfangriff aus; meide ihn durch seitliche Positionierung. (|cFF0000AUSWEICHEN|r)",
                    "Brandmal – Schwerer, aufgeladener Schlag, der vom Tank geblockt werden muss; bei Ausweichen wird Boss wütend. (|cFF0000BLOCKEN|r)",
                    "Kettenzug – Nach Wegstürmen zieht Noriwen Tank heran, wenn zu weit weg; jage sie oder nutze Reinigungsfähigkeiten, um Effekt zu entfernen. (|c00FFFFBEFREIEN|r)",
                    "Explosionspulver – Wirft explosives Pulver, das gefährliche Flächeneffekte erzeugt; bewege dich aus Explosionszone. (|cFF0000BEWEGEN|r)",
                    "Greifenbomber – Beschwört fliegende Adds, die Bomben abwerfen; meide ihre Flugbahnen. (|cFF0000AUSWEICHEN|r)",
                    "Flammengreifen – Beschwört gelegentlich Flammengreifen, die feuerbasierte Angriffe wirken; unterbrich ihre Zauber, um Schaden zu reduzieren. (|cFF7F00UNTERBRECHEN|r)",
                    "Alcunar – Der massive Greif auf Felsvorsprung, der mit Flügelschlägen Schockschaden zufügt; sei achtsam auf seine Angriffe. (|cFF0000AUSWEICHEN|r)",
                },
            },
            {
                name = "Flammentänzer Ajim-Rei",
                mechanics = {
                    "Fackel – Führt Basis-Feuerangriff aus, der minimalen Schaden verursacht, wenn ausgewichen. (|cFFFFFFKEINE AKTION|r)",
                    "Einäschernder Tanz – Schwerer, kanalisierter Angriff, der unterbrochen oder ausgewichen werden muss, um hohen Schaden zu verhindern. (|cFF7F00UNTERBRECHEN|r oder |cFF0000AUSWEICHEN|r)",
                    "Drohende Eruption – Wirkt Feuerzonen unter jedem Spieler, die nach kurzer Verzögerung ausbrechen, verursachen Schaden gleich 50% deiner Gesundheit; stehe nie am selben Ort wie andere. (|cFF0000VERMEIDEN|r)",
                    "Hitzewelle – Zielt auf Spieler mit Serie von Hitzewellen, die Brenneffekt anwenden; wegbewegen oder unterbrechen, um Schaden zu reduzieren. (|cFF0000AUSWEICHEN oder UNTERBRECHEN|r)",
                    "Flammenaspekt – Beschwört Flammenaspekt, der Feuerbälle schießt oder intensive Hitze auf Ziel kanalisiert; unterbrich seinen Cast, um Schaden zu mildern. (|cFF7F00UNTERBRECHEN|r)",
                    "Lodernder Shalk – Stürmt auf Spieler zu und hinterlässt Flammenspur; positioniere schnell neu, um anhaltenden Brandschaden zu vermeiden. (|cFF0000BEWEGEN|r)",
                },
            },
            {
                name = "Orpheon der Taktiker",
                mechanics = {
                    "Schneller Schlag – Schneller, flächenwirkender Nahkampfangriff; blocken oder ausweichen, um Schaden zu reduzieren. (|cFF0000BLOCKEN oder AUSWEICHEN|r)",
                    "Realitätsriss – Schwerer, telegrafierter Flächenangriff zielt auf Tank; meide Nähe zum Tank während Ausführung. (|cFF0000VERMEIDEN|r)",
                    "Abgrundtiefe Reichweite – Beschwört massive Tentakel aus Boden; positioniere neu, um ihre niederschädigen Treffer zu vermeiden. (|cFF0000BEWEGEN|r)",
                    "Einkerkern – Erzeugt einengende Wände, die Kampffläche schrumpfen; bleibe in sicherer Zone, um Schaden zu vermeiden. (|cFF0000IN SICHERER ZONE BLEIBEN|r)",
                    "Arkane Ebenenverschmelzung – Bei spezifischen Gesundheitsschwellen wird Orpheon unverwundbar und beschwört Adds; beseitige Adds schnell, bevor er wieder angreift. (|cFFD700ADDS TÖTEN|r)",
                    "Verbotenes Wissen – Während unverwundbar, feuert Orpheon schädigende Sphären auf alle Spieler; ausweichen oder rollen, um Aufprall zu mildern. (|cFF0000AUSWEICHEN|r)",
                    "Arkaner Leerengeist – Größere Adds wie Arkaner Koloss und Geist wirken verheerende Flächenangriffe; meide ihre Schadenszonen. (|cFF0000WEGBEWGEN|r)",
                    "Alcunar – Beteiligt sich auch, indem er zusätzlichen Schaden mit Flügelschlägen zufügt; bleibe wachsam für seine Angriffe. (|cFF0000AUSWEICHEN|r)",
                },
            },
        },
    },

}