--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-02-18
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}
function Clock_TST.I18N()
    return {
        bindings = {
            nToggle = "Sichtbarkeit umschalten",
            nToggleTime = "Sichtbarkeit des Datums umschalten",
            nToggleMoon = "Sichtbarkeit des Mondes umschalten"
        },
        error = {
            library = "Konnte nicht mit der LibClockTST Bibliothek verbinden."
        },
        menu = {
            core = {
                nHeadTime = "Zeit und Datum",
                nHeadMoon = "Mond",
                nHeadGeneral = "Allgemein",
                nHeadDebug = "Fehlersuche",
            },
            presets = {
                nPreset = "Voreinstellung",
                wPreset = "Dadurch werden Ihre aktuellen Einstellungen durch eine Voreinstellung ersetzt.",
                nSave = "Speichern",
                wSave = "Dadurch wird Ihre aktuelle Voreinstellung überschrieben.",
                nDelete = "Löschen",
                wDelete = "Dadurch wird Ihre aktuelle Voreinstellung gelöscht.",
                nCurrent = "Aktuelle Voreinstellung",
            },
            account = {
                nAccount = "Einstellungen synchronisieren",
                tAccount = "Verwende die gleichen Einstellungen für alle Charaktäre."
            },
            booleans = {
                nSub = "Ein/Aus Einstellungen", -- togOpt
                nTimeVisible = "Zeige die Zeit", -- sTime
                nMouseEnabled = "Interaktionsfähig",
                nMovable = "Bewegbar", -- sMove
                tMovable = "Wähle ob die Clock bewegbar sein soll.", -- tMove
                nTooltip = "Tooltip beim Hovern anzeigen",
                nBackground = "Zeige Hintergrund", -- nsBg
                tTimeBackground = "Fügt einen Hintergrund hinter die Clock hinzu.", -- tsBg
                nAddZeroHour = "Zeros bis Stunde hinzufügen", -- sNum
                tAddZeroHour = "Einstellige Stunden mit Null auffüllen: 1:24 -> 01:24.", -- tNum
                nAddZeroMin = "Zeros auf Minute hinzufügen", -- sNum
                tAddZeroMin = "Füllen Sie einstellige Minuten mit Null ein: 1:4 -> 1:04.", -- tNum
                nAddZeroSec = "Zeros in Sekundenschnelle hinzufügen", -- sNum
                tAddZeroSec = "Füllen Sie einstellige Sekunden mit Null auf.", -- tNum
                nAddZeroDay = "Zeros bis Tage hinzufügen", -- sNum
                tAddZeroDay = "Füllen Sie einstellige Tage mit Null auf.", -- tNum
                nAddZeroMonth = "Fügen Sie dem Monat Nullen hinzu", -- sNum
                tAddZeroMonth = "Füllen Sie einstellige Monate mit Null auf.", -- tNum
                nUSFormat = "12h Format", -- sFormat,
				nMinAMPM = "A.M./P.M. -> am/pm", -- minAMPM
				tMinAMPM = "Formatieren Sie den Standalone-Takt-Text, um minimalistic AM/PM zu verwenden.", -- minAMPM
                nJapanese = "Zeige Mitternacht als 0", --sJap
                wAffect = "Dies betrifft nur ein benutzerdefiniertes Format, nicht #X oder %X.",
                nHoverScale = "Skalierung beim Hovern",
                nHoverColour = "Hervorhebung beim Hovern",
                nMoonVisible = "Zeige den Mond", -- sMoon
                nFight = "In Kämpfen verstecken",
                nMap = "Nur auf der Karte anzeigen",
                nLink = "Verbinde die Bewegungen des Schriftzugs mit dem Mond",
                nGroup = "In Gruppen verstecken",
                nDebug = "Debug-Modus",
            },
            styles = {
                nSub = "Aussehen Einstellungen", -- look
                nFormat = "Schreibe dein eigenes Format der Zeit und des Datums",
                tFormat = "Du kannst ein Symbol (# für Kunde, % für Realität und $ für falsche Kunde) "
                        .. "gefolgt von einem Buchstaben schreiben:",
                dFormat = "%A\t\t voller Wochentagsname [Freitag]\n"
                        .. "%a\t\t für den abgekürzten [Fre]\n"
                        .. "%B\t\t vollständiger Monatsname [März]\n"
                        .. "%b\t\t für den abgekürzten [Mer]\n"
                        .. "%D\t\t Tag des Monats [12th]\n"
                        .. "%d\t\t Tag als einfache Zahl [12]\n"
                        .. "%H\t\t Stunde\n"
                        .. "%M\t\t Minute\n"
                        .. "%m\t\t Monat\n"
                        .. "%p\t\t entweder \"am\" oder \"pm\"\n"
                        .. "%S\t\t Sekunde\n"
                        .. "%w\t\t Wochentag [1-7 = Montag-Sonntag]\n"
                        .. "%x\t\t Datum [17.02.20]\n"
                        .. "%X\t\t Zeit [23:48:10 | 11:48 PM]\n"
                        .. "%Y\t\t ganzes Jahr [2020]\n"
                        .. "%y\t\t verkürztes Jahr [20]",
                nColor = "Farbe", -- nColPick
                tColor = "Verändere die Farbe der Clock.", -- tColPick
                nFont = "Schriftart", -- nFont
                tFont = "Verändere die Schriftart der Clock.", -- tFont
                nStyle = "Design", -- nStyle
                tStyle = "Verändere die Design der Clock.", -- tStyle
                nSize = "Größe", -- nSize
                tSize = "Verändere die Schriftgröße der Clock.",
                nBackground = "Textur des Hintergrunds",
                nBackgroundColour = "Background colour",
                nBackgroundHoverColour = "Background hover colour",
                nBackgroundOffsetX = "Versatz der Hintergrundbreite",
                tBackgroundOffsetX = "Versatz auf die berechnete Breite des Hintergrunds.",
                nBackgroundOffsetY = "Versatz der Hintergrundhöhe",
                tBackgroundOffsetY = "Versatz auf die berechnete Höhe des Hintergrunds.",
                nMasser = "Die Textur von Masser",
                nSecunda = "Die Textur von Secunda",
                nMoonWidth = "Breite des Mondabstands",
                nMoonHeight = "Höhe des Mondabstands",
                nScale = "Skalierung",
                nAlpha = "Sichtbarkeit",
                nScaleFactor = "Skalierungsfaktor",
                tScaleFactor = "Wie stark sich der Posten beim Hovern erhöhen sollte."
            },
            feedback = {
                tFeedback = "Wenn du einen Fehler gefunden, eine Anfrage oder einen Vorschlag hast,\n"
                    .. "oder einfach nur spenden möchtest, kannst du mir gerne eine Mail schicken.",
                nMail = "In-Game-Feedback",
                nGitHub = "Ein Problem melden",
                nLessGold = "Kleine Spende",
                nMoreGold = "Größere Spende",
                nRealGold = "Echte Spende"
            }
        },
        view = {
            core = {
                menu = {
                    tooltip = "Tooltip anzeigen",
                    background = "Hintergrund anzeigen",
                    movable = "Ist beweglich",
                    link = "Die Bewegung des Mondes mit der Zeit verknüpfen",
                    open = "Einstellungsmenü öffnen",
                    scale = "Skalierung zurücksetzen",
                },
            },
            moon = {
                tooltip = {
                    full = "Der Mond ist gerade voll.\n"
                            .. "Er wird so für <<1 [weniger als eine Stunde/eine Stunde/$d Stunden]>> bleiben.\n",
                    isWaxing = "Der Mond ist zu <<1>>% voll und nimmt zu.\n"
                            .. "Er wird <<2[weniger als eine Stunde/eine Stunde/$d Stunden]>> brauchen,\n"
                            .. "um seine volle Pracht zu erreichen.\n",
                    isWaning = "Der Mond ist zu <<1>>% voll und nimmt ab.\n"
                            .. "Er wird wieder <<2>> Stunden brauchen,\n"
                            .. "um seine volle Pracht zu erreichen.\n",
                    duration = "Das <<1[ist weniger als ein Tag/ist ein Tag/sind $d Tage]>> in Tamriel."
                }
            },
            time = {
                am = "A.M.",
                pm = "P.M.",
				amM = "am",
				pmM = "pm",
            },
            date = {
                lore = {
                    week = {
                        [1] = "Morndas",
                        [2] = "Tirdas",
                        [3] = "Middas",
                        [4] = "Turdas",
                        [5] = "Fredas",
                        [6] = "Loredas",
                        [7] = "Sundas",
                    },
                    months = {
                        [1] = "Morgenstern",
                        [2] = "Sonnenaufgang",
                        [3] = "Erste Saat",
                        [4] = "Regenhand",
                        [5] = "Zweite Saat",
                        [6] = "Jahresmitte",
                        [7] = "Sonnenhöhe",
                        [8] = "Letzte Saat",
                        [9] = "Herzfeuer",
                        [10] = "Eisherbst",
                        [11] = "Sonnenuntergang",
                        [12] = "Abendstern",
                    },
                    year = "2Ä",
                },
                real = {
                    week = {
                        [1] = "Montag",
                        [2] = "Dienstag",
                        [3] = "Mittwoch",
                        [4] = "Donnerstag",
                        [5] = "Freitag",
                        [6] = "Samstag",
                        [7] = "Sonntag",
                    },
                    months = {
                        [1] = "Januar",
                        [2] = "Februar",
                        [3] = "März",
                        [4] = "April",
                        [5] = "Mai",
                        [6] = "Juni",
                        [7] = "Juli",
                        [8] = "August",
                        [9] = "September",
                        [10] = "Oktober",
                        [11] = "November",
                        [12] = "Dezember",
                    },
                },
            },
        }
    }
end
