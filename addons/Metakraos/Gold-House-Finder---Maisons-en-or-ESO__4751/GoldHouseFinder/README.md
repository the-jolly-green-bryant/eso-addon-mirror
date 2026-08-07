# Gold House Finder

Petit add-on ESO avec interface dans `Reglages > Extensions` pour lister les maisons connues comme achetables avec de l'or, les filtrer par budget, puis les previsualiser ou se teleporter vers celles deja possedees.

Langues supportees : francais et anglais. Les noms de maisons sont lus via l'API ESO dans la langue du client quand ils sont disponibles ; les tables internes servent aux prix, prerequis et alias de recherche.

Auteur : Metakraos

## Installation

Copier le dossier `GoldHouseFinder` dans :

`Documents\Elder Scrolls Online\live\AddOns\`

Ensuite lance ESO ou tape `/reloadui`, puis active **Gold House Finder** dans le menu des add-ons.

## Utilisation

- Ouvre `Reglages > Extensions > Gold House Finder`, ou utilise `/ghf` pour y aller directement.
- Utilise la recherche et le budget : `Tous`, `< 100k`, `100k - 500k`, `500k - 1M`, `> 1M`.
- Filtre aussi par `Zone`, `Type d'emplacement`, `Taille terrain` et `Taille habitation`.
- Le filtre `A acheter` masque les maisons deja possedees. Clique dessus pour afficher aussi les maisons possedees.
- Selectionne une maison dans la liste deroulante pour afficher son image et ses details.
- Les maisons dont le succes lie n'est pas valide par le personnage courant, ou dont l'achat or est refuse par la boutique native ESO pour ce personnage, sont affichees en rouge.
- Le panneau affiche le succes requis quand il est connu et propose `Succes requis` pour le chercher puis l'ouvrir.
- Exemple : `Refuge d'Arbreroche` utilise `Malabal Tor Adventurer`, avec recherche aussi sur `Aventurier de Malabal Tor` et `Malabal Tor`.
- Utilise `Apercu / visiter` ou `TP exterieur`.

## Reglages ESO

Si `LibAddonMenu-2.0` est installe, les options et l'interface apparaissent dans :

`Reglages > Extensions > Gold House Finder`

Options disponibles :

- rechercher une maison ;
- filtrer par tranche de budget ;
- filtrer par zone ESO native de la maison ;
- filtrer par ville, bord de mer, riviere/lac ou campagne/isole ;
- filtrer par taille de terrain et taille d'habitation ;
- afficher seulement les maisons a acheter ;
- selectionner une maison ;
- afficher l'image de fond native des Collections/Habitations si disponible, dans un grand panneau fixe ;
- afficher en rouge les maisons dont le succes lie manque au personnage courant ou dont la boutique native ESO refuse l'achat or ;
- chercher et ouvrir le succes requis quand son nom est disponible ;
- lancer l'apercu ou le TP ;
- scanner les maisons du client.

## Commandes de secours

- `/ghf`, `/goldhouses`, `/maisonsor` : ouvrir/fermer l'interface.
- `/ghfdump` : scanne toutes les maisons vues par ton client ESO et sauvegarde le resultat dans `SavedVariables\GoldHouseFinder.lua`.
- `/ghfadd houseId prixOr` : ajoute manuellement une maison achetable en or si elle manque, par exemple `/ghfadd 44 322000`.

## Notes

- Pour une maison non possedee, le bouton ouvre l'apercu de maison. L'achat en or se fait ensuite dans l'interface native du jeu si le prerequis est rempli.
- Le statut rouge cherche le succes requis puis le compare au personnage courant. Sur client francais, l'addon essaie aussi des alias francais connus et un terme de zone pour les succes de type Adventurer/Aventurier.
- Pour une maison possedee, les boutons **Interieur** et **Exterieur** utilisent `RequestJumpToHouse`.
- Le filtrage principal s'appuie sur les `houseId`, donc il devrait fonctionner avec un client francais. La table par noms anglais sert surtout de secours pour des maisons ajoutees ou renommees.
- Les SavedVariables utilisent le nom du serveur comme profil afin de ne pas melanger les donnees NA/EU.
- AI disclosure: cet add-on a ete developpe avec une assistance IA, puis relu et maintenu par Metakraos.
