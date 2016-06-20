# xmlconv

* https://github.com/zdavatz/xmlconv

## DESCRIPTION:

xmlconverter, convert XML to flat files.

## REQUIREMENTS:

* xmlconv - sudo gem install sandozxmlconv

## INSTALL:

* sudo gem install xmlconv

## Debugging

Use the `bin/xmlconv_admin config=/path/to/your/config.yml`. There you may call stuff like

```transactions.size
transactions.last.status
transactions.last.output[0..120]
transactions.last.uri
transactions.last.commit_time
transactions.last.destination.uri
transactions.last.arguments
transactions.last.transaction_id
transactions.last.update_status
transactions.last.response
transactions.last.output_model
transactions.last.partner
transactions.last.reader
transactions.last.writer```


## DEVELOPERS:

* Zeno R.R. Davatz
* Masaomi Hatakeyama
* Hannes Wyss (up to Version 1.0)
* Niklaus Giger (Ported to Ruby 2.3.1)

## LICENSE:

GPLv2.0
