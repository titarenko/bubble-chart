express = require "express"
icedCompiler = require "./middleware/iced-compiler-middleware"
lessCompiler = require "./middleware/less-compiler-middleware"

app = express()

app.set "views", __dirname
app.set "view engine", "jade"

app.use express.favicon()

app.use icedCompiler __dirname
app.use lessCompiler __dirname

app.get "/", (req, res) ->
	res.render "index"

app.listen 80, -> console.log "Listening on 80..."
