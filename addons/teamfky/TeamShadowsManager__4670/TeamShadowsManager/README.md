# Team Shadows Manager

Author: TeamFF - EyrOn

Team Shadows Manager regroupe des comptes a rebours de prebuff pour les raids, un decompte synchronise de groupe, des outils pour mannequin et un gestionnaire de packs de markers monde.

## Dependances

Obligatoires :

- `LibAddonMenu-2.0` version 38 ou superieure
- `LibTeamShadows` version 10100 ou superieure

Optionnelle :

- `LibGroupBroadcast` version 91 ou superieure pour le partage direct des packs de markers

## Commande

```text
/tsm
```

Ouvre directement la fenetre Team Shadows Manager. Les autres fonctions sont disponibles dans l'interface ou avec les raccourcis configurables des controles ESO.

## Fonctions principales

- timers de prebuff stricts pour les ouvertures et retours de boss pris en charge
- decompte groupe de 0 a 20 secondes
- delai personnel local sans modifier l'affichage des autres joueurs
- decalages distincts pour l'aggro, le DPS et les ultimes de support
- annonces centrales, couleurs, sons et echelle configurables
- timer automatique ou manuel pour mannequin d'entrainement
- placement et edition de markers monde au reticule
- packs de markers propres aux zones et epreuves
- export, import et partage volontaire des packs
- interface francaise et anglaise
- liens de contact en jeu vers `@TeamFF` et `@Eyr0n`

## Partage des packs

Le bouton `ENVOYER AU GROUPE` partage le pack selectionne avec les membres qui possedent Team Shadows Manager et LibGroupBroadcast. La reception demande toujours un choix : enregistrer, utiliser seulement jusqu'a la deconnexion ou refuser.

Le partage direct est limite aux joueurs groupes et hors combat. Les donnees sont validees, decoupees en morceaux controles et confirmees par les destinataires compatibles. L'export/import manuel reste disponible.

## Raccourcis configurables

- ouvrir le menu
- activer ou desactiver les timers boss
- activer ou desactiver le decompte
- lancer ou annuler le decompte groupe
- placer un marker

## Epreuves prises en charge

- Cloudrest
- Halls of Fabrication
- Asylum Sanctorium
- Maw of Lorkhaj
- Aetherian Archive
- Sunspire
- Kyne's Aegis
- Dreadsail Reef
- Sanity's Edge

Les fonctions sans declencheur fiable restent volontairement desactivees afin d'eviter les faux comptes a rebours.

## Credits

Les identifiants de combat et timings ont ete verifies avec les evenements ESO, des logs publics et des references communautaires reconnues : CrutchAlerts, Code's Combat Alerts, RaidNotifier Updated, HowToCloudrest, HowToSunspire, Qcell's Dreadsail Reef Helper, Qcell's Rockgrove Helper, AsylumNotifier/Tracker et HoFNotifier. Aucun code de ces addons n'est inclus.
