models = require('./models')
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
      callbackURL: "http://localhost:3000/auth/facebook/callback"
      enableProof: false
    }, Auth.OnSuccessfulOauthCallback)

    @passport.use(facebook_strategy)

  @OnSuccessfulOauthCallback: (accessToken, refreshToken, profile, done) ->
    models.User.findOrCreate(profile, (user) ->
      done(null, user)
    )



module.exports = new Auth()