ça vaudrait le coup de faire une PR à json-resume-cli qui fait des bails chelous en fait ... vu que leur code dans la function `createPdf` du fichier `export-resume.js` il fait un truc chelou avec la fonction [`emulateMediaType` de puppeteer](https://pptr.dev/api/puppeteer.page.emulatemediatype "ou puppeteer default de base sur screen mais json-resume-cli refait la roue pour refaire le même truc (avec une syntaxe bien outdated en plus) pour re-default sur le même default dans une situation où je ne comprends même pas pourquoi ne pas justement default sur un mediatype print ...")

- faire des socials qui sont plus jolis quand on est en pdf (que les vieux liens pétés là)
  - chercher la mention `show-only-url-print` et voir comment gérer ça

- ajouter le merdier chelou de skills qui n'apparaissent pas actuellement et idéalement mettre les sources en lien dans le pdf

- trouver un moyen de rendre ces modifications permanentes
  - à terme ce sera une PR pour jdambron mais avant ça il faut essayer de faire un truc un peu rapide pour pas avoir à publier un npm de merde là