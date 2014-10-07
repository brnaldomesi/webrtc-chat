var Chat;

Chat = (function() {
  function Chat() {}

  Chat.Login = function(user) {
    return console.log(user);
  };

  Chat.FetchFacebookProfileData = function() {
    return FB.api('/me', function(user) {
      return Chat.Login(user);
    });
  };

  Chat.FacebookLogin = function() {
    return FB.login(function(response) {
      if (response.authResponse) {
        return Chat.FetchFacebookProfileData();
      } else {
        return "User didn't login";
      }
    });
  };

  return Chat;

})();

//# sourceMappingURL=client.js.map
