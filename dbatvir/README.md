# DBatVir: Database of bat-associated viruses

Source: [http://www.mgc.ac.cn/DBatVir/](http://www.mgc.ac.cn/DBatVir/)

## Data acquisition

```
curl -L "curl -L "http://www.mgc.ac.cn/cgi-bin/DBatVir/json_data.pl?limit=100" > dbatvir.json
```

Fix JSON using online tool adding double quotes.

Convert JSON to TSV:

```
cat dbatvir-fixed.json| jq '.data[]' | jq --slurp --raw-output '(map(keys) | add | unique) as $keys | $keys, map([.[ $keys[] ]|tostring])[] | @tsv' > dbbatvir.tsv
```
