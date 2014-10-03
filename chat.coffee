express = require('express')
morgan = require('morgan')
swig = require('swig');
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
PeerServer = require('peer').PeerServer

auth = require('./auth')

class Chat
  constructor: () ->
    @app = express()

    @setupEnvironment()
    @setupAuthMiddleware()
    @setupRoutes()

  setupEnvironment: () ->
    # Set Logger
    @app.use(morgan('dev'))

    # Set static file serving from public directory
    @app.use('/public', express.static('public'))

    # Set SWIG to handle rendering
    @app.engine('html', swig.renderFile)
    @app.set('view engine', 'html')
    @app.set('views', __dirname + '/views')
    @app.set('view cache', false)
    swig.setDefaults({ cache: false })

  setupAuthMiddleware: () ->
    @app.use(cookieParser())
    @app.use(bodyParser())
    @app.use(session({ secret: process.env.COOKIE_SECRET }))
    @app.use(auth.passport.initialize())
    @app.use(auth.passport.session())

  setupRoutes: () ->
    # Authentication based views
    @app.get '/auth/facebook', auth.passport.authenticate('facebook', {scope: ['email']})
    @app.get '/auth/facebook/callback', auth.passport.authenticate('facebook', { successRedirect: '/success', failureRedirect: '/failure' })
    # The default route
    @app.get '/', (request, response) ->
      response.render('index')

    @app.get '/success', (request, response) ->
      response.send("Success.")

    @app.get '/failure', (request, response) ->
      response.send('Failure.')

  startServer: () ->
    $this = @
    @server = @app.listen 3000, () ->
      console.log "Listening on port %d", $this.server.address().port

    @peer_server = PeerServer({server: @server, path: '/peer'})
    @peer_server.on 'connection', (id) ->
      console.log id

    @app.use(@peer_server)

  stopServer: () ->
    # do nothing for the moment

module.exports= new Chat()