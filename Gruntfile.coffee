module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    watch:
      coffee:
        files: ["chat_client.coffee"]
        tasks: 'coffee'

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true

        files:
          "public/js/app.js": ['chat_client.coffee']
  });

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']
