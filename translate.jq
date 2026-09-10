jq --arg lang fr 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .[$lang] else . end)' input.json

    walk(...) : traverse récursivement toute la structure JSON
    if type == "object" : vérifie que c'est un objet
    keys | all(...) : vérifie que toutes les clés sont des codes de langue
    .[$lang] : extrait la valeur correspondant à la langue sélectionnée
    --arg lang fr : passe la variable lang à jq

echo '{
  "a": "toto",
  "b": {"fr": "coucou", "en": "hey mate"},
  "c": [
    {"d": {"e": 12}},
    {"d": {"f": {"fr": "prout", "en": "fart"}}}
  ]
}' | jq --arg lang fr 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .[$lang] else . end)'







j'ai un fichier json de type
```json
{
  "a": "toto"
  "b": {"fr": "coucou", "en": "hey mate"},
  "c": [
    {"d": {"e":12}},
    {"d": {"f":{"fr":"prout","en":"fart"}}}
  ]
}
```

qui puisse me sortir (si je choisi fr)
```json
{
  "a": "toto"
  "b": "coucou",
  "c": [
    {"d": {"e":12}},
    {"d": {"f":"prout"}}
  ]
}
```
qui puisse me sortir (si je choisi en)
```json
{
  "a": "toto"
  "b": "hey mate",
  "c": [
    {"d": {"e":12}},
    {"d": {"f":"fart"}}
  ]
}
```

Vous avez besoin d'une fonction qui traverse récursivement votre structure JSON et extrait les valeurs dans la langue sélectionnée lorsqu'elle rencontre un objet avec des clés de langue.

Voici une solution en JavaScript :
javascript

function extractLanguage(obj, lang) {
  if (obj === null || obj === undefined) {
    return obj;
  }

  // Si c'est un tableau, traiter chaque élément
  if (Array.isArray(obj)) {
    return obj.map(item => extractLanguage(item, lang));
  }

  // Si c'est un objet
  if (typeof obj === 'object') {
    // Vérifier si c'est un objet de langue (toutes les clés sont des codes de langue)
    const keys = Object.keys(obj);
    const isLanguageObject = keys.length > 0 &&
                             keys.every(key => typeof obj[key] === 'string');

    // Si c'est un objet de langue et la clé demandée existe
    if (isLanguageObject && lang in obj) {
      return obj[lang];
    }

    // Sinon, traiter récursivement chaque propriété
    const result = {};
    for (const key of keys) {
      result[key] = extractLanguage(obj[key], lang);
    }
    return result;
  }

  // Valeurs primitives
  return obj;
}

// Test
const data = {
  "a": "toto",
  "b": {"fr": "coucou", "en": "hey mate"},
  "c": [
    {"d": {"e": 12}},
    {"d": {"f": {"fr": "prout", "en": "fart"}}}
  ]
};

console.log(JSON.stringify(extractLanguage(data, 'fr'), null, 2));
console.log(JSON.stringify(extractLanguage(data, 'en'), null, 2));

Comment ça marche

La fonction extractLanguage(obj, lang) :

    Traite les tableaux : applique la fonction à chaque élément
    Détecte les objets de langue : vérifie si toutes les clés sont des codes de langue (chaînes de caractères simples)
    Extrait la valeur : si c'est un objet de langue et la clé existe, retourne directement la chaîne
    Récurse : sinon, traite chaque propriété récursivement
    Préserve les valeurs primitives : les nombres et chaînes simples restent inchangés

Alternative plus robuste

Si vous avez besoin de distinguer plus clairement les objets de langue (au cas où vous auriez des objets normaux avec seulement des clés fr et en), vous pourriez ajouter une convention, comme un préfixe ou une vérification de contexte :
javascript

function extractLanguage(obj, lang, isRoot = true) {
  if (obj === null || obj === undefined) return obj;

  if (Array.isArray(obj)) {
    return obj.map(item => extractLanguage(item, lang, false));
  }

  if (typeof obj === 'object') {
    const keys = Object.keys(obj);

    // Déterminer si c'est un objet de langue
    // (options : vérifier les codes de langue ISO, avoir une clé spéciale, etc.)
    const commonLangs = ['fr', 'en', 'es', 'de', 'it', 'pt', 'ja', 'zh'];
    const isLanguageObject = keys.length > 0 &&
                             keys.every(key => commonLangs.includes(key) &&
                                              typeof obj[key] === 'string');

    if (isLanguageObject && lang in obj) {
      return obj[lang];
    }

    const result = {};
    for (const key of keys) {
      result[key] = extractLanguage(obj[key], lang, false);
    }
    return result;
  }

  return obj;
}

Cette version vérifie contre une liste de codes de langue courants, ce qui réduit le risque de confondre un objet normal avec un objet de langue.

alors tout ça mais avec jq

Voici la solution avec jq :
bash

jq 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .fr else . end)' input.json

Pour sélectionner la langue dynamiquement, passez-la en variable :
bash

jq --arg lang fr 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .[$lang] else . end)' input.json

Explication

    walk(...) : traverse récursivement toute la structure JSON
    if type == "object" : vérifie que c'est un objet
    keys | all(...) : vérifie que toutes les clés sont des codes de langue
    .[$lang] : extrait la valeur correspondant à la langue sélectionnée
    --arg lang fr : passe la variable lang à jq

Test
bash

# Avec le fichier input.json
jq --arg lang fr 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .[$lang] else . end)' input.json

# Ou directement avec echo
echo '{
  "a": "toto",
  "b": {"fr": "coucou", "en": "hey mate"},
  "c": [
    {"d": {"e": 12}},
    {"d": {"f": {"fr": "prout", "en": "fart"}}}
  ]
}' | jq --arg lang fr 'walk(if type == "object" and (keys | all(. == "fr" or . == "en" or . == "es" or . == "de")) then .[$lang] else . end)'

Version plus flexible (détection de langue)

Si vous voulez détecter automatiquement les codes de langue ISO courants :
bash

jq --arg lang fr 'walk(if type == "object" and (keys | all(test("^[a-z]{2}(-[a-z]{2})?$"))) and (keys | length > 0) and (.[$lang] != null) then .[$lang] else . end)' input.json

Cette version utilise une regex pour matcher les codes de langue (par ex. fr, en, pt-BR).

maintenant imaginons que le json il ressemble à ça
```json
{
  "a": "toto"
  "b": {"fr": "coucou", "en": "hey mate", "es":"hola compadre"},
  "c": [
    {"d": {"e":12}},
    {"d": {"f":{"fr":"prout","en":"fart"}}}
  ],
  "locales": [
    "fr", "en", "es"
  ]
}
```
et que pour les langues on cherches parmis celles présentes dans le .locales et que si une traduction manque pour la locale demandée on prend une autre traduction par ordre de préférence correspondant à l'ordre de cette locale dans l'array

Voici la solution avec jq :
bash

jq --arg lang fr '
  .locales as $locales |
  walk(
    if type == "object" and (keys | all(. as $k | $locales | index($k) != null)) and ($locales | index($lang) != null) then
      # C'est un objet de langue, chercher la traduction
      if .[$lang] != null then
        .[$lang]
      else
        # Sinon, prendre la première traduction disponible par ordre de préférence
        first($locales[] | select(. != $lang) | if .[$lang] != null then .[.] else empty end)
      end
    else
      .
    end
  ) |
  del(.locales)
' input.json

Explication

    .locales as $locales : stocke l'array des locales disponibles
    keys | all(. as $k | $locales | index($k) != null) : vérifie que toutes les clés sont dans .locales
    .[$lang] != null : si la traduction existe pour la langue demandée, on la retourne
    first($locales[]...) : sinon, on parcourt les locales dans l'ordre et on prend la première traduction disponible
    del(.locales) : supprime .locales du résultat final

Problème avec ma solution précédente

J'ai une erreur logique dans le fallback. Voici une version corrigée et plus claire :
bash

jq --arg lang fr '
  .locales as $locales |
  walk(
    if type == "object" and (keys | all(. as $k | $locales | index($k) != null)) and ($locales | index($lang) != null) then
      # Chercher par ordre de préférence dans les locales
      first(
        ($locales[] | select(. == $lang)) as $l |
        if .[$l] != null then .[$l] else empty end,
        # Si pas trouvé, chercher dans les autres locales par ordre
        ($locales[] | select(. != $lang)) as $l |
        if .[$l] != null then .[$l] else empty end
      )
    else
      .
    end
  ) |
  del(.locales)
' input.json

Test
bash

echo '{
  "a": "toto",
  "b": {"fr": "coucou", "en": "hey mate", "es": "hola compadre"},
  "c": [
    {"d": {"e": 12}},
    {"d": {"f": {"fr": "prout", "en": "fart"}}}
  ],
  "locales": ["fr", "en", "es"]
}' | jq --arg lang fr 'walk(if type == "object" and (keys | all(. as $k | .locales | index($k) != null)) then first(.locales[] as $l | select(. == $lang or ($lang != null)) | if .[$l] != null then .[$l] else empty end) else . end) | del(.locales)' input.json

Version encore plus robuste
bash

jq --arg lang fr '
  .locales as $locales |
  walk(
    if type == "object" and ($locales != null) and (keys - ["locales"]) != [] then
      # Vérifier si c'est un objet de langue (toutes les clés sont dans locales)
      if (keys | all(. as $k | $locales | index($k) != null)) then
        # Chercher la traduction avec fallback
        reduce $locales[] as $locale (
          null;
          if . != null then . else
            if .[$locale] != null and ($locale == $lang or . == null) then .[$locale]
            else . end
          end
        )
      else
        .
      end
    else
      .
    end
  ) |
  del(.locales)
' input.json

Quelle version préférez-vous ? La deuxième est plus lisible, la troisième plus robuste pour les cas limites.