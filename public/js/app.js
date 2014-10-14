var ChatClientApp, ChatClientView, PeerModel,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ChatClientApp = (function() {
  function ChatClientApp() {
    var $client;
    $client = this;
    $.post('/me', function(data) {
      if (data.user != null) {
        $client.peer = new PeerModel(data.user);
        $client.view = new ChatClientView({
          model: $client.peer
        });
        return $client.peer.fetchFacebookData();
      }
    });
  }

  return ChatClientApp;

})();

ChatClientView = (function(_super) {
  __extends(ChatClientView, _super);

  function ChatClientView() {
    return ChatClientView.__super__.constructor.apply(this, arguments);
  }

  ChatClientView.prototype.el = "#chat-view";

  ChatClientView.prototype.template = "#chat-app-template";

  ChatClientView.prototype.initialize = function() {
    var $view;
    $view = this;
    return this.model.on('change', function() {
      return $view.render();
    });
  };

  ChatClientView.prototype.render = function() {
    var $view, contents;
    contents = $(this.template).html();
    $view = this;
    $(this.el).html(contents);
    this.self_video_el = $(this.el).find(".self");
    this.stream_video_el = $(this.el).find(".stream");
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
    return navigator.getUserMedia({
      audio: true,
      video: true
    }, function(stream) {
      return $($view.self_video_el).prop('src', URL.createObjectURL(stream));
    }, function(error) {
      return console.log(error);
    });
  };

  return ChatClientView;

})(Backbone.View);

PeerModel = (function(_super) {
  __extends(PeerModel, _super);

  function PeerModel() {
    return PeerModel.__super__.constructor.apply(this, arguments);
  }

  PeerModel.prototype.initialize = function() {
    return console.log("testing2");
  };

  PeerModel.prototype.fetchFacebookData = function() {
    var $this;
    $this = this;
    return FB.getLoginStatus(function(response) {
      if (response.status === "connected") {
        return $this.verifyPeer(response.authResponse, function() {
          $this.getPeerId();
          return $this.getDisplayPicture();
        });
      }
    });
  };

  PeerModel.prototype.verifyPeer = function(authResponse, next) {
    if (authResponse.accessToken != null) {
      return $.post('/verify', {
        accessToken: authResponse.accessToken
      }, function(data) {
        if (data.verified === true) {
          return next();
        } else {
          return console.log("Couldn't verify your authenticity!!!");
        }
      });
    }
  };

  PeerModel.prototype.getPeerId = function() {
    var $this;
    $this = this;
    this.peer = new Peer({
      host: window.PEER_SERVER_HOST,
      port: window.PEER_SERVER_PORT,
      path: '/peer',
      debug: 3
    });
    return this.peer.on('open', function(id) {
      return $this.set('peer_id', id);
    });
  };

  PeerModel.prototype.getDisplayPicture = function() {
    var $this;
    $this = this;
    return FB.api('/me/picture', {
      height: 200,
      width: 200,
      type: 'square'
    }, function(response) {
      return $this.set('dp', response.data.url);
    });
  };

  return PeerModel;

})(Backbone.Model);

//# sourceMappingURL=app.js.map
