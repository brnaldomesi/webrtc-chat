class ChatClientApp
  constructor: () ->
    $client = @

    $.post '/me', (data) ->
      if data.user?
        $client.peer = new PeerModel(data.user)
        $client.view = new ChatClientView({model: $client.peer})

        # fetch facebook data
        $client.peer.fetchFacebookData()


class ChatClientView extends Backbone.View
  el: "#chat-view"
  template: "#chat-app-template"

  initialize: () ->
    $view = @
    @model.on 'change', () ->
      $view.render()

  render: () ->
    contents = $(@template).html()
    $view = @
    $(@el).html(contents)

    @self_video_el = $(@el).find(".self")
    @stream_video_el = $(@el).find(".stream")
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

    navigator.getUserMedia {audio: true, video: true}, (stream) ->
      $($view.self_video_el).prop('src', URL.createObjectURL(stream))
    , (error) -> 
      console.log(error)

class PeerModel extends Backbone.Model
  initialize: () ->
    console.log("testing2")

  fetchFacebookData: () ->
    $this = @
    FB.getLoginStatus (response) ->
      if response.status == "connected"
        $this.verifyPeer response.authResponse, () ->
          $this.getPeerId()
          $this.getDisplayPicture()

  verifyPeer: (authResponse, next) ->
    if authResponse.accessToken?
      $.post '/verify', {accessToken: authResponse.accessToken}, (data) ->
        if data.verified == true
          next()
        else
          console.log "Couldn't verify your authenticity!!!"

  getPeerId: () ->
    $this = @
    @peer = new Peer({host: window.PEER_SERVER_HOST, port: window.PEER_SERVER_PORT, path: '/peer', debug: 3})
    @peer.on 'open', (id) ->
      $this.set 'peer_id', id

  getDisplayPicture: () ->
    $this = @
    FB.api '/me/picture',{height: 200, width: 200, type: 'square'}, (response) ->
      $this.set 'dp', response.data.url