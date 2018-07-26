var restify = require('restify')
var serveStatic = require('serve-static-restify')
 
var app = restify.createServer()
 
app.pre(serveStatic('public', {'index': ['index.html', 'default.htm']}))
app.listen(8080)

