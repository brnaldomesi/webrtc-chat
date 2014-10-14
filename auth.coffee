passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy

class Auth
  constructor: () ->
    @current_user = null
    @passport = passport
    @passport.serializeUser (user, done) ->
      done(null, user)

    @passport.deserializeUser (user_data, done) ->
      done(null, user_data)

    facebook_strategy = new FacebookStrategy({
      clientID: process.env.FACEBOOK_CLIENT_ID
      clientSecret: process.env.FACEBOOK_CLIENT_SECRET
      callbackURL: process.env.FACEBOOK_CALLBACK_URL
      enableProof: false
    }, Auth.OnSuccessfulOauthCallback)

    @passport.use(facebook_strategy)

  @serializableFacebookProfile: (profile) ->
    return {
      id: profile._json.id
      name: profile._json.name,
      email: profile._json.email
    }
    return profile

  @OnSuccessfulOauthCallback: (accessToken, refreshToken, profile, done) ->
    serializedUserProfile = Auth.serializableFacebookProfile(profile)
    done(null, serializedUserProfile)


module.exports = new Auth()