# Préambule
------
Commencer par cloner le repo :
```
git clone https://github.com/KspR/test-site
```

# Arborescence
------
Le repo contient un dossier src/ où sont mis tous les fichiers source qui permettent de générer le site.
Ce dossier src/ contient :
- un dossier lang/ où on met les fichiers de traduction ;
- un dossier views/ où on met les templates des pages.

Les fichiers sources sont compilés dans dist/ (pour la partie site) par l'intermédiaire du script watch.js et du compilateur sass.
On édite donc les fichiers de src/, et on ouvre le site depuis dist/.

# Commandes
------
##### Lancer les compilateurs
Les commandes qui suivent sont des "watchers" qui compilent dès lorsqu'un changement est détecté. Il n'y a donc pas besoin de les relancer à chaque modification.
- Traductions et templates html :
  ```
  node scripts/watch.js
  ```
- SASS :
  ```
  sass --sourcemap=none --watch src/sass:dist/css
  ```

# Editer le site
------
### Traductions
Les fichiers de traduction sont dans un format custom et sont placés dans src/lang. Ce format permet de générer un fichier JSON correspondant à chaque langue. Ces fichiers JSON sont ensuite utilisés lors de la compilation des templates html pour remplacer les clés de traduction par les chaînes de caractères correspondantes.

#### Format des fichiers de traducion
###### Exemple
Le format ressemble à ça :
```
branche-niveau0-0
    branche-niveau1-0
        traduction-000
            [traduction_anglaise]
            [traduction_française]
        traduction-001
            [traduction_anglaise]
            [traduction_française]
    branche-niveau1-1
        branche-niveau2-0
            traduction-0101
                [traduction_anglaise]
                [traduction_française]
            ...
        ...
    ...
...
```

###### Structure
Une branche avec sous-branches d'avant dernier-niveau (dans l'exemple "traduction-xxx") est une entrée de traduction. Elle doit donc *obligatoirement* contenir exactement 2 sous-branches :
    - la première sous-branche est la traduction anglaise ;
    - la deuxième la traduction française.
    
###### Nom des branches
Les noms de branches et sous-branches ne doivent pas contenir d'espace. Par convention on utilise du kebab-case (pas de majuscules et des tirets pour séparer les mots).

###### Multiligne
Les traductions normales ne peuvent pas contenir de retour à la ligne comme ça serait interprété comme un passage à la branche suivante. Pour faire des traductions multilignes, il faut donc englober les deux traductions dans 6 tirets à la suite, et les séparer par 3 tirets à la suite, comme sur l'exemple suivant :
```
# traductions multilignes
branche-niveau0-0
    traduction-multiligne-00
        ------
        traduction anglaise
        sur plusieurs lignes
        ---
        traduction française
        sur plusieurs lignes
        ------
```
Les retours à la ligne ne sont pas répercutés dans le HTML. On s'en sert pour des raisons de lisibilité.

###### Balises html dans les traductions
On peut mettre des balises HTML dans les traductions, on utilise donc des <br /> pour forcer des retours à la ligne par exemple.

### Utilisation
Les traductions peuvent être insérer dans les fichiers templates (de src/views/) en utilisant la syntaxe {{{branche.sous-branche.traduction}}}. On utilise le format de templating [handlebars](https://handlebarsjs.com/).