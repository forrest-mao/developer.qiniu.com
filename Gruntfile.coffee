module.exports = (grunt) ->
    # Constants

    require('load-grunt-tasks')(grunt)

    ASSETS_PATH = 'static/'
    JS_PATH = ASSETS_PATH + 'js/'
    ADDON_PATH = ASSETS_PATH + 'add-on/'

    LESS_MAIN = ASSETS_PATH + 'css/less/main.less'
    CSS_MAIN = ASSETS_PATH + 'css/main.css'
    LESS_FILES = ASSETS_PATH + 'css/less/_*.less'

    CSS_MAIN_FILES = CSS_MAIN: [LESS_MAIN]

    JS_FILE = JS_PATH + 'docs.js'

    grunt.initConfig
        jshint:
            options:
                jshintrc: '.jshintrc'
            all: [JS_FILE]

        csslint:
            options:
                csslintrc: '.csslintrc'
            strict:
                src: [CSS_MAIN]

        less:
            development:
                options:
                    dumpLineNumbers: 'comments'
                files: [{
                    src: LESS_MAIN
                    dest: CSS_MAIN
                }]
            production:
                options:
                    yuicompress: true
                files: [{
                    src: LESS_MAIN
                    dest: CSS_MAIN
                }]

        useminPrepare:
            html: '_footer.html'
            options:
                dest: '.'

        copy:
            html:
                src: '_includes/footer_template.html'
                dest: '_footer.html'
            back:
                src: '_footer.html'
                dest: '_includes/footer.html'

        filerev:
            options:
                algorithm: 'md5'
                length: 8
            images:
                src: ['static/image/logo-download.png', 'static/image/logo.png', 'static/image/qiniu_logo_small.png']
                dest: '.tmp'
            js:
                src: ['static/js/docs.min.js', 'static/js/app.js']

        usemin:
            html: ['_footer.html']

        clean:[
            '_footer.html'
        ]


    grunt.registerTask 'production', [
#        'coffee'
        'copy:html'
        'useminPrepare'
        'jshint'
        'uglify:compress'
        'less:production'
        'csslint:strict'
        'usemin'
    ]

    grunt.registerTask 'default', [
#        'coffee'
        'copy:html'
        'useminPrepare'
        'jshint'
        'less:development'
        'csslint:strict'
        'uglify'
        'concat'
        'filerev'
        'usemin'
        'copy:back'
        'clean'
    ]

