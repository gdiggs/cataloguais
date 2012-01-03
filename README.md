# Cataloguais - catalog anything

## English
Cataloguais is a simple app to catalog and keep track of whatever it is you collect.

### Installation
You must have [MongoDB](http://www.mongodb.org/) installed prior to running Cataloguais. On OS X with homebrew, you can just do `brew install mongo`.

Once you have Mongo running and have cloned the app to your local directory, you can run:

```
bundle install
ruby ./cataloguais.rb
```

### Configuration
In development mode, Cataloguais will just look for your mongo instance locally. In production mode, however, you must specify an `ENV['MONGOHQ_URL']` variable to point to the currect mongo instance.

You should also add an `ENV['ADMIN_PASSWORD']` variable if you want to allow editing/adding of items.

To set a default sorting value, add an `ENV['DEFAULT_SORT']` value. An error will be raised at startup if this value is invalid.

#### Fields
The fields for a row are specified in `settings.yml`. You can specify field names in human terms safely (for instance, a field name of "Album Title" will translate to the attribute name of "album_title". You can also refer to fields by their number (so `item.field0` will be equivalent to `item.title`). If you want to re-order fields in the table, you can just change the order in the settings file.

### Testing
You can run the tests by running `ruby ./cataloguais_test.rb`. Make sure Mongo is running.

### Submitting Patches
If you have a feature, or want to fix a bug, I invite you to do so! Please make sure all code in Pull Requests is documented and tested or it may not be accepted immediately.

## Français
Cataloguais est une application simple pour cataloguer ce qu'on collectionne.

### Installation
On doit installer [MongoDB](http://www.mongodb.org/) avant de utiliser Cataloguais. Avec OS X et homebrew, on peut faire `brew install mongo`.

Après avoir installé Mongo et avoir cloné l'application à votre système, on peut faire:

```
bundle install
ruby ./cataloguais.rb
```

### Configuration
Dans la mode de developement, Cataloguais utilisera l'instance de mongo local. Dans la mode de production, on doit donner un variable `ENV['MONGOHQ_URL']` pour préciser l'instance de mongo.

On doit aussi créer un `ENV['ADMIN_PASSWORD']` variable si on veut permettre l'addition et l'édition des articles.

Pour ajouter un valeur de la classification, créez un `ENV['DEFAULT_SORT']` variable. Il y aurait une erreur si ce valeur n'est pas valide.

### Fields
Les fields d'une rangée sont données en `settings.yml`. On peut donner des noms pour les attributs dans la langue de l'homme (par exemple, un nom de "Titre d'album" va etre un attribut de "titre_d_album". On peut aussi accéder aux attributs par leur nombre (`item.field0` va etre equivalent à `item.titre`). Si on veut réorganiser les attributs, on peut juste la faire dans le fichier des options.

### Testing
On peut executer les tests avec `ruby ./cataloguais_test.rb`. Mongo doit etre commencé.

### Soumettre du code
Si on a du code pour ce projet, on peut soumettre un Pull Request. SVP, vous assurez que tous le code dans votre Pull Request est doccumenté et évalué avant de le soumettre.

## License
### The MIT License (MIT)
Copyright (c) 2011 Gordon Diggs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
