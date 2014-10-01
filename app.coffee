express = require('express')
PeerServer = require('peer').PeerServer
swig = require('swig');

# The main Express app
app = express()

# Set static file serving from public directory
app.use('/public', express.static('public'))

# Set SWIG to handle rendering
app.engine('html', swig.renderFile)
app.set('view engine', 'html')
app.set('views', __dirname + '/views')
app.set('view cache', false)
swig.setDefaults({ cache: false })

# The default route
app.get '/', (request, response) ->
  response.render('index')

# Initialize server to listen to port
server = app.listen 3000, () ->
  console.log "Listening on port %d", server.address().port

# Peer server to act as peerjs server
peerserver = PeerServer({server: server, path: '/peer'})

peerserver.on 'connection', (id) ->
  console.log id

# Set app to use peerserver
app.use(peerserver)