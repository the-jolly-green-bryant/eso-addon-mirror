# Team Shadows Buffs

Addon séparé de Team Shadows Manager pour suivre les buffs et les débuffs sous forme de cercles.

Le noyau charge chaque module avec `pcall`. Si un module rencontre une erreur, il est marqué comme défaillant et les autres modules continuent de fonctionner.

Bibliothèque requise à installer avec Minion :

- `LibAddonMenu-2.0` pour afficher les réglages dans les paramètres d'ESO

Si la bibliothèque manque, TESO l'affiche comme dépendance manquante dans le menu Extensions.

Réglages dans les paramètres d'ESO :

- même fenêtre, buffs et débuffs séparés, ou chaque tracker dans sa propre fenêtre
- ordre des buffs et des débuffs
- liste des buffs et débuffs majeurs
- activation et désactivation de chaque tracker
- nom, abréviation, taille de cellule et couleur personnalisables pour chaque tracker
- option pour masquer les noms et garder seulement cercle + acronyme
- réinitialisation globale ou par tracker
- activation automatique des trackers normaux pour tous les sets à stacks du catalogue
- tracker visible à 0 stack dès que le bonus du set est actif, puis affichage des stacks réels
- disparition automatique du tracker quand le set est retiré ou perd son bonus sur la barre active
- Yokeda implacable, Siroria, Relequen, Tzogvin, Kinras, Z'en, Catalyseur élémentaire et mythiques à stacks pris en charge
- liens de contact en jeu vers `@TeamFF` et `@Eyr0n`

Commande :

```text
/tsb
```

Ouvre directement la fenêtre de gestion de Team Shadows Buffs. Toutes les fonctions sont accessibles depuis l'interface.

Partage de groupe :

- les configurations de panel et de tracker sont découpées en morceaux contrôlés
- chaque destinataire confirme chaque morceau reçu
- seuls les morceaux manquants sont renvoyés, avec trois tentatives au maximum
- le chat confirme le nombre de destinataires ou indique les comptes qui n'ont pas répondu
- l'ancien format de partage reste accepté à la réception

Depuis la version `0.4.5`, l'addon envoie aussi une copie compatible avec les anciennes versions et détecte d'abord les joueurs capables de confirmer. Les anciennes versions ne provoquent donc plus de tentatives inutiles. Tous les membres doivent utiliser la version `0.4.5` ou une version supérieure pour participer aux confirmations fiables.
