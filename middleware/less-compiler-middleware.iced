fs = require "fs"
compiler = require "less"

module.exports = (basedir) -> 
	(req, res, next) ->
		return next() if req.url.indexOf(".css") == -1
		await fs.readFile basedir + req.url.replace(".css", ".less"), "utf-8", defer error, code
		return next() if error
		await compiler.render code, compress: true, defer error, rendered
		return next() if error
		res.header "Content-Type", "text/css"
		res.send rendered
