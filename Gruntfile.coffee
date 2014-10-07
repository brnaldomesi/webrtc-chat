module.exports = (grunt) ->
  # Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    watch:
      coffee:
        files: ["client.coffee"]
        tasks: 'coffee'

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true

        files:
          "public/js/client.js": ['client.coffee']
  });

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']
