fs = require "fs"
compiler = require "iced-coffee-script"

module.exports = (basedir) -> 
	(req, res, next) ->
		return next() if req.url.indexOf(".js") == -1
		await fs.readFile basedir + req.url.replace(".js", ".iced"), "utf-8", defer error, code
		return next() if error
		try
			compiled = compiler.compile code		
		catch error		
			return next()
		res.header "Content-Type", "text/javascript"
		res.send compiled
