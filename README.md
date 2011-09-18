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

#### Fields
The fields for a row are specified in `settings.yml`. The first item in the file is the `field_count` option, which specifies how many fields each Item has. Then, each following `field[n]` row will become an attribute of Item. You can specify field names in human terms safely (for instance, a field name of "Album Title" will translate to the attribute name of "album_title". You can also refer to fields by their number (so `item.field0` will be equivalent to `item.title`). If you want to re-order fields in the table, you can just move the rows in the settings file.

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

### Fields
Les fields d'une rangée sont données en `settings.yml`. Le premier atricle dans le fichier est l'option `field_count`, qui dit comments attributs est sur chaque Item. Donc, les rangées `field[n]` vont devenir un attribut d'Item. On peut donner des noms pour les attributs dans la langue de l'homme (par exemple, un nom de "Titre d'album" va etre un attribut de "titre_d_album". On peut aussi accéder aux attributs par leur nombre (`item.field0` va etre equivalent à `item.titre`). Si on veut réorganiser les attributs, on peut juste la faire dans le fichier des options.

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
