passport = require('passport')
FacebookStrategy = require('passport-facebook').Strategy

class Auth
  constructor: () ->
    @passport = passport
    @passport.serializeUser (user, done) ->
      done(null, user.id)

    @passport.deserializeUser (id, done) ->
      done(null, id)

    facebook_strategy = new FacebookStrategy({
      clientID: process.env.FACEBOOK_CLIENT_ID
      clientSecret: process.env.FACEBOOK_CLIENT_SECRET
      callbackURL: "http://localhost:3000/auth/facebook/callback"
      enableProof: false
    }, Auth.OnSuccessfulOauthCallback)

    @passport.use(facebook_strategy)

  @OnSuccessfulOauthCallback: (accessToken, refreshToken, profile, done) ->
    done(null, profile)


module.exports = new Auth()