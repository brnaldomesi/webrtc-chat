dbConfig =
  client: 'postgresql'
  connection:
    host: process.env.PG_HOST
    user: process.env.PG_USER
    password: process.env.PG_PASSWORD
    database: process.env.PG_DATABASE

knex = require('knex')(dbConfig)
bookshelf = require('bookshelf')(knex)
async = require('async')

class User extends bookshelf.Model
  tableName: "users"

  initialize: () ->

  serialize: () ->
    {
      id: @get('id'),
      name: @get('name')
      email: @get('email')
    }

  @findOrCreate: (data, callback) ->
    user_data = 
      id: data.profile._json.id
      name: data.profile._json.name
      email: data.profile._json.email

    $this = @
    $user = null

    async.waterfall([
      (finished) ->
        new User({id: user_data.id}).fetch().then (model) ->
          $user = model.serialize()
          finished()

      (finished) ->
        if not $user?
          User.forge(user_data).save({}, {method: 'insert'}).then (model) ->
            $user = model.serialize()
            finished()
        else
          finished()

      (finished) ->
        callback($user)

    ])

module.exports.User = User