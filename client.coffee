class Chat
  @Login: (user) ->
    console.log(user)

  @FetchFacebookProfileData: () ->
    FB.api '/me', (user) ->
      Chat.Login(user)

  @FacebookLogin: () ->
    FB.login (response) ->
      if response.authResponse
        Chat.FetchFacebookProfileData()
      else
        "User didn't login"