#cp -R `dirname $1`/img/ ./html/`dirname $1`/img/
marp --allow-local-files --config-file ./marp-engine.js --html $1