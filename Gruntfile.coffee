###*
global module:false
###
module.exports = (grunt)->
    'use strict'

    # Project configuration.
    config = {
        # Metadata.
        pkg: grunt.file.readJSON('package.json')
        banner: '''
            /*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - 
            <%= grunt.template.today("yyyy-mm-dd") %>
            <%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>
            * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>
             Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */
        '''
        # Task configuration.
        concat: {
            options: {
                banner: '<%= banner %>'
                stripBanners: true
            }
            dist: {
                src: ['lib/<%= pkg.name %>.js']
                dest: 'dist/<%= pkg.name %>.js'
            }
        }
        uglify: {
            options: {
                banner: '<%= banner %>'
            }
            dist: {
                src: '<%= concat.dist.dest %>'
                dest: 'dist/<%= pkg.name %>.min.js'
            }
        }
        jshint: {
            options: {
                curly: true
                eqeqeq: true
                immed: true
                latedef: true
                newcap: true
                noarg: true
                sub: true
                undef: true
                unused: true
                boss: true
                eqnull: true
                browser: true
                node: true
                globals: {}
            }
            gruntfile: {
                src: 'Gruntfile.js'
                options: {
                    globals: {
                        grunt: true
                    }
                }
            }
            lib_test: {
                src: ['lib/**/*.js', 'test/**/*.js']
            }
        }
        qunit: {
            files: ['test/**/*.html']
        }
        watch: {
            gruntfile: {
                files: '<%= jshint.gruntfile.src %>'
                tasks: ['jshint:gruntfile']
            }
            lib_test: {
                files: '<%= jshint.lib_test.src %>'
                tasks: ['jshint:lib_test', 'qunit']
            }
            coffee: {
                files: ['src/coffee/*.coffee']
                tasks: ['coffee']
            }
        }
        coffee: {
            all: {
                files: {
                    cwd: 'src/coffee/'
                    src: '*.coffee'
                    dest: 'src/js/'
                    ext: '.js'
                    flatten: true
                    expand: true
                }
            }
            led: {
                files: {
                    'src/js/led.js': 'src/coffee/led.coffee'
                }
            }
            "led-fade": {
                files: {
                    'src/js/led-fade.js': 'src/coffee/led-fade.coffee'
                }
            }
            "led-strobe": {
                files: {
                    'src/js/led-strobe.js': 'src/coffee/led-strobe.coffee'
                }
            }
            servo: {
                files: {
                    'src/js/servo.js': 'src/coffee/servo.coffee'
                }
            }
            button: {
                files: {
                    'src/js/button.js': 'src/coffee/button.coffee'
                }
            }
            ping: {
                files: {
                    'src/js/ping.js': 'src/coffee/ping.coffee'
                }
            }
            socket: {
                files: {
                    'src/js/socket.js': 'src/coffee/socket.coffee'
                }
            }
            indicator: {
                files: {
                    'src/js/indicator.js': 'src/coffee/indicator.coffee'
                }
            }
            indicator_client: {
                files: {
                    'src/js/indicator-client.js': 'src/coffee/indicator-client.coffee'
                }
            }
            manager: {
                files: {
                    'src/js/manager.js': 'src/coffee/manager.coffee'
                }
            }
        }
        copy: {
            build: {
                files: [
                    # { dest: 'public/styles/', src: ['src/css/*'], filter: 'isFile', flatten: true ,expand: true }
                    { dest: 'public/js/', src: ['src/js/*'], filter: 'isFile', flatten: true, expand: true}
                    { dest: 'public/js/', src: ['src/external/*.js'], filter: 'isFile', flatten: true, expand: true}
                ]
            }
        }
    }
    grunt.initConfig(config)

    # These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-concat')
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-contrib-nodeunit')
    grunt.loadNpmTasks('grunt-contrib-jshint')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-copy')
    grunt.loadNpmTasks('grunt-contrib-qunit')

    # Default task.
    grunt.registerTask('default', ['jshint', 'qunit', 'concat', 'uglify'])
    grunt.registerTask 'indicator', ['coffee:manager', 'coffee:indicator_client', 'coffee:indicator', 'copy:build']
