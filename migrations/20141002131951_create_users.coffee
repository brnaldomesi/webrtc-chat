exports.up = (knex, Promise) ->
  knex.schema.createTable 'users', (table) ->
    table.string('id').primary().index()
    table.string('name')
    table.string('email').unique().index()
    table.string('picture_url')
    table.string('peer_data')
    table.timestamps()

exports.down = (knex, Promise) ->
  knex.schema.dropTable('users')