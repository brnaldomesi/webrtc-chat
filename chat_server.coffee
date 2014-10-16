express = require('express')
morgan = require('morgan')
swig = require('swig');
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('cookie-session')
PeerServer = require('peer').PeerServer
FB = require('fb')
auth = require('./auth')


class ChatServer
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
    expiry_date = new Date()
    expiry_date.setDate(expiry_date.getDate() + 10)

    @app.use(cookieParser())
    @app.use(bodyParser())
    @app.use(session({ name: 'chat', secret: process.env.COOKIE_SECRET, expires: expiry_date  }))
    @app.use(auth.passport.initialize())
    @app.use(auth.passport.session())

    $app = @app
    @app.use (req, res, next) ->
      $app.locals.user = req.user
      $app.locals.facebook_public_app_id = process.env.FACEBOOK_PUBLIC_APP_ID
      $app.locals.peer_server_port = process.env.PEER_SERVER_PORT
      $app.locals.peer_server_host = process.env.PEER_SERVER_HOST

      next()

  setupRoutes: () ->
    # Authentication based views
    @app.get '/auth/facebook', auth.passport.authenticate('facebook', {scope: ['email']})
    @app.get '/auth/facebook/callback', auth.passport.authenticate('facebook', { successRedirect: '/dashboard', failureRedirect: '/failure' })

    # The default route
    @app.get '/', (request, response) ->
      response.render('index')

    # Logged in router to check for all logged in routes
    @loggedinRouter = express.Router()
    @loggedinRouter.use (req, res, next) ->
      if req.user?
        next()
      else
        res.redirect('/')

    @loggedinRouter.get '/dashboard', (request, response) ->
      response.render('dashboard', {enable_chat_client: true})

    @loggedinRouter.get '/failure', (request, response) ->
      response.send('Failure.')

    @loggedinRouter.post '/me', (request, response) ->
      response.send({user: request.user})

    @loggedinRouter.get '/logout', (request, response) ->
      request.logout()
      response.redirect('/')

    @loggedinRouter.post '/verify', (request, response) ->
      accessToken =  request.body.accessToken
      if accessToken?
        FB.setAccessToken(accessToken)
        FB.api "me", (fb_response) ->
          if request.user.id == fb_response.id
            response.send({verified: true})
          else
            response.send({verified: false})

    @app.use(@loggedinRouter)


  startServer: () ->
    $this = @
    port = process.env.PORT
    @server = @app.listen port, () ->
      console.log "Listening on port %d", $this.server.address().port

    @peer_server = PeerServer({server: @server, path: '/peer'})
    @peer_server.on 'connection', (id) ->
      console.log id

    @app.use(@peer_server)

  stopServer: () ->
    # do nothing for the moment

module.exports= new ChatServer()