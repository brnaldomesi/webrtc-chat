express = require('express')
PeerServer = require('peer').PeerServer
swig = require('swig');
morgan = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')

passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy

# Configure Passport for FB based login
passportOAuthHandler = (accessToken, refreshToken, profile, done) ->
  done(null, profile)

passportLoginSuccessHandler = (req, res) ->
    res.redirect '/'

passport.serializeUser (user, done) ->
  done(null, user.id)

passport.deserializeUser (id, done) ->
  done(null, id)

facebook_strategy = new FacebookStrategy({
  clientID: process.env.FACEBOOK_CLIENT_ID
  clientSecret: process.env.FACEBOOK_CLIENT_SECRET
  callbackURL: "http://localhost:3000/auth/facebook/callback"
  enableProof: false
}, passportOAuthHandler)

passport.use(facebook_strategy)

# The main Express app
app = express()

app.use(express.static('public'))
app.use(cookieParser())
app.use(bodyParser())
app.use(session({ secret: process.env.COOKIE_SECRET }))
app.use(passport.initialize())
app.use(passport.session())

# Set Logger
app.use(morgan('dev'))

# Set static file serving from public directory
app.use('/public', express.static('public'))

# Set SWIG to handle rendering
app.engine('html', swig.renderFile)
app.set('view engine', 'html')
app.set('views', __dirname + '/views')
app.set('view cache', false)
swig.setDefaults({ cache: false })

# Authentication based views
app.get '/auth/facebook', passport.authenticate('facebook')
app.get '/auth/facebook/callback', passport.authenticate('facebook', { successRedirect: '/success', failureRedirect: '/failure' })

# The default route
app.get '/', (request, response) ->
  response.render('index')

app.get '/success', (request, response) ->
  response.send("Success.")

app.get '/failure', (request, response) ->
  response.send('Failure.')

# Initialize server to listen to port
server = app.listen 3000, () ->
  console.log "Listening on port %d", server.address().port

# Peer server to act as peerjs server
peerserver = PeerServer({server: server, path: '/peer'})

peerserver.on 'connection', (id) ->
  console.log id

# Set app to use peerserver
app.use(peerserver)