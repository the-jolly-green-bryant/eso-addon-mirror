# Team Shadows Manager

Author: TeamFky - EyrOn

Team Shadows Manager est un addon ESO léger qui affiche un compte à rebours de prebuff avant l'engagement réel de boss de trials avec cinématique, RP, animation d'entrée ou délai d'invulnérabilité.

## Installation

Copier le dossier complet :

```text
TeamShadowsManager/
```

dans :

```text
Documents/Elder Scrolls Online/live/AddOns/
```

La structure finale doit être :

```text
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/TeamShadowsManager.txt
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/TeamShadowsManager.lua
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/TeamShadowsManagerUI.lua
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/SavedVariables.lua
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/Bindings.xml
Documents/Elder Scrolls Online/live/AddOns/TeamShadowsManager/README.md
```

Relancer l'interface avec `/reloadui`, puis activer l'addon dans le menu Add-Ons si nécessaire.

## Reglages

Team Shadows Manager fonctionne sans dependance obligatoire.

Si `LibAddonMenu-2.0` est installe, un panneau `Team Shadows Manager` apparait dans les reglages d'extensions avec :

- activation addon
- onglet `Reglages generiques`
- onglet `Annonce visuelle`
- onglet `Mannequin`
- onglets par raid informatifs pour les timers boss natifs
- timer mannequin
- auto timer apres reset mannequin
- decompte groupe 0-20s
- decalage aggro 0-10s
- delai DPS 0-3s
- decalage ulti support: colosse necro, War Machine, cor de guerre

Sans `LibAddonMenu-2.0`, utiliser les commandes slash ci-dessous.

## Commandes

```text
/pbtunlock
```

Verrouille ou déverrouille la fenêtre. Quand elle est déverrouillée, elle affiche `MOVE` et peut être déplacée.

```text
/pbtscale 1.2
```

Change la taille de la fenêtre. Valeurs acceptées : `0.5` à `2.5`.

```text
/pbtcolor 1 0 0
```

Change la couleur RGB du timer. Valeurs acceptées : `0` à `1`.

Exemples :

```text
/pbtcolor 1 0 0
/pbtcolor 1 1 1
/pbtcolor 0.3 0.8 1
```

```text
/pbtboss
```

Affiche les noms exacts des unites `boss1` a `boss6` detectees par ton client. Utile si le client est en francais et qu'un nom localise ne correspond pas encore a la table.

```text
/pbtzone
```

Affiche le nom de zone lu par ESO. Utile pour verifier les verrous de zone HoF/vSS si un timer ne part pas ou part au mauvais endroit.

```text
/pbtpractice
```

Lance le timer mannequin avec la duree sauvegardee.

```text
/pbtpractice 8
```

Regle temporairement le timer mannequin sur 8 secondes et le lance.

```text
/pbtpracticetime 6
```

Sauvegarde la duree du timer mannequin.

```text
/pbtpull 10
```

Lance un decompte groupe au centre de l'ecran. Plage acceptee : `0` a `20` secondes.

Un raccourci clavier est aussi disponible dans les controles ESO : `Team Shadows Manager: decompte groupe`.

```text
/pbtmarker
```

Place un marker a l'endroit vise par le reticule et l'enregistre dans le pack actif. Le marker peut utiliser les carres, fleches, roles ou icones personnalisees Team Shadows.

Tous les joueurs doivent avoir `Team Shadows Manager` et `LibTeamShadows` actifs pour voir les markers monde.

Le partage direct des markers est desactive volontairement : il passe par les pings de carte et peut afficher des fleches instables chez les autres joueurs. Pour partager une strat, utilise `Exporter` puis colle le code chez les autres joueurs dans `Importer`, comme avec Helms Marker. La sauvegarde persistante reste locale a chaque compte, limitation normale d'ESO.

Raccourcis configurables dans les contrôles clavier ESO :

- `Team Shadows Manager: ouvrir menu`
- `Team Shadows Manager: ON / OFF timer boss`
- `Team Shadows Manager: ON / OFF décompte`
- `Team Shadows Manager: décompte groupe`
- `Team Shadows Manager: placer marker`

Appuyer une deuxième fois sur `Team Shadows Manager: décompte groupe` annule le décompte groupe en cours.

Le réglage `Décompte groupe` correspond à la durée envoyée à tout le groupe par le raid lead.

Le réglage `Mon délai` corrige uniquement ton affichage local, sans modifier ce que les autres joueurs voient.

Exemple : si le raid lead envoie `20` secondes, `Mon délai = -2` affiche ton `GO` à `18` secondes. `Mon délai = +2` affiche ton `GO` 2 secondes après celui du raid lead.

`/pbtbutton` remet le bouton logo au centre de l'écran. Le bouton logo ouvre maintenant une fenêtre indépendante Team Shadows Manager qui peut rester ouverte pendant que tu poses les fanaux.

```text
/pbtia tho'at replicanum
/pbtia frost atronach
/pbtia mantikora
/pbtia dragon
/pbtia marauder bittog
```

Lance un timer manuel pour l'Archive infinie. Les boss de cycle sont aleatoires, donc l'automatisation IA restera limitee aux signaux fiables.

## Mannequin

F5 reste le reset natif du mannequin dans une maison.

Quand `Auto timer apres reset mannequin` est active, Team Shadows Manager capte un combat contre un mannequin par son nom dans les events de combat. A la sortie de combat suivante, il lance le timer mannequin avec la duree sauvegardee.

Les commandes `/pbtpractice` et `/pbtpracticetime` restent disponibles en secours.

## Trials inclus

- Rockgrove
- Dreadsail Reef
- Sunspire
- Kyne's Aegis
- Cloudrest
- Lucent Citadel
- Sanity's Edge
- Asylum Sanctorium
- Maw of Lorkhaj
- Halls of Fabrication

## Timers boss natifs

Les timings boss ne sont pas exposes en reglages joueur. Les onglets par raid dans le panneau servent seulement a verifier quels boss/mecaniques sont geres.

Les valeurs sont centralisees dans le code de l'addon :

```lua
PBT.trials
```

Chaque boss possède une valeur :

```lua
seconds = 10
```

Ces valeurs sont volontairement natives : elles seront ajustees dans l'addon apres validation par logs/tests, pas par chaque joueur en jeu.

Sources inspectees pour les timings :

- CrutchAlerts : timers `DisplayDamageable` pour certains boss/phases, notamment Sunspire et Halls of Fabrication.
- RaidNotifier Updated : logique de countdown et commentaires de spawn, notamment Asylum Sanctorium.
- Code's Combat Alerts : timers de cast/mecaniques.
- Qcell's Rockgrove Helper : timers Rockgrove de mecaniques internes.
- Qcell's Dreadsail Reef Helper : timers Dreadsail Reef de mecaniques internes.

Important : ces addons ne fournissent pas une table universelle "prebuff avant pull" pour tous les boss. Un timer automatique fiable doit venir d'un signal avant apparition : narration, cast, effet, mort d'add ou autre evenement loggable. Les detections par nom de boss et boss units restent des modes legacy/desactives par defaut, car elles declenchent souvent trop tard ou sur trash.

Remerciements sources : CrutchAlerts, HowToCloudrest, HowToSunspire, Qcell's Dreadsail Reef Helper, Combat Alerts, AsylumNotifier/Tracker, HoFNotifier et les logs ESO publics servent de references pour verifier les IDs, les timings et les comportements.

## Notes techniques

- Lua natif ESO uniquement.
- Aucune dépendance externe obligatoire.
- Panneau de reglages optionnel si `LibAddonMenu-2.0` est deja installe.
- UI créée en Lua, sans XML.
- Détection via `EVENT_BOSSES_CHANGED`, `EVENT_COMBAT_EVENT` et `EVENT_EFFECT_CHANGED`.
- Les noms anglais et francais utiles sont geres dans l'addon.
- Déclenchement protégé contre les doubles lancements.
- Scan throttlé pour éviter le spam d'événements.
- Aucun traitement périodique hors countdown actif.

## Timers automatiques stricts

Les timers automatiques sont maintenant volontairement limites aux fenetres codees et sourcees. Pas de detection large par trash, pas de timer sur boss rendu invulnerable par une strat de joueur, pas de retour dependant uniquement de la vitesse de mort d'adds.

Actifs actuellement :

- Cloudrest `Creeper` : ability Samurai `105016`, zone `1051`, `2.0s`.
- Cloudrest `Icy Teleport` : ability Samurai `106682`, zone `1051`, `2.0s`.
- HoF `Hunter-Killer Fabricants` : ability `94805`, zone `975`, `23.2s`, source CrutchAlerts `DisplayDamageable`.
- HoF `Pinnacle Factotum` : narration Samurai `There! Somethings coming through! Another fabricant!`, `7.2s`.
- HoF `Triplets` : narration Samurai `Reprocessing yard contamination critical`, `9.3s`.
- vAS `Saint Olms` : ability `98535`, zone `1000`, countdown depuis le 1er saut de chaque phase vers le 4e atterrissage.
- MoL `Zhaj'hassa` : narration Samurai, zone `725`, `15.6s`.
- MoL `Rakkhat` : narration Samurai, zone `725`, `24.4s`.
- AA `Varlariel` : narration Samurai, zone `638`, `4.4s`.
- Sunspire `Nahviintaas` intro : narration Samurai, zone `1121`, `21.2s`.
- Sunspire `Lokkestiiz` retours : abilities `122820`, `122821`, `122822`, zone `1121`, `53.3s`, `64.9s`, `63.9s`.
- Sunspire `Yolnahkriin` landings : abilities `124910`, `124915`, `124916`, zone `1121`, `22.8s`, `23.4s`, `23.5s`.
- Sunspire `Nahviintaas Landing` : ability `118884`, zone `1121`, uniquement `ACTION_RESULT_BEGIN` avec `hitValue < 2000`, `22.5s`.
- Sunspire portail Nahviintaas : pendant `Time Breach` (`121216`), affiche le prochain seuil HP `70%` ou `50%`. Ce n'est pas un timer : vert = seuil declenche pendant que le joueur est encore dans le portail precedent, rouge = sortie avant le skip.
- Kyne's Aegis `Falgravn Return` : ability `135281` marque l'envol, puis le timer part seulement apres 3 morts d'adds/prisons du sous-sol. Verrouille zone `1196`, une fois par combat.
- Dreadsail Reef `Taleria Execute` : annonce HP a `20%`, zone `1344`. Pas de faux countdown.
- Sanity's Edge `Yaseyla` : annonces HP pour Wamasu/portails aux seuils CrutchAlerts, zone `1427`. Pas de faux countdown.

Desactive volontairement pour l'instant :

- Z'Maja par morts d'adds : trop fragile et pouvait partir au mauvais moment.
- Reef Guardian : ignore sur demande.
- Rockgrove : ignore sur demande.
- Lucent Citadel : ignore sur demande.
- Yandir leap : mecanique de combat, pas fenetre boss spawn/damageable.
- Modes generiques `bossUnitDetection` et `genericCinematicTimers` : trop souvent trop tard ou sur trash.
