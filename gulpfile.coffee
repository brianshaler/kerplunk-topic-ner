gulp = require 'gulp'
glut = require 'glut'

coffee = require 'gulp-coffee'

glut gulp,
  tasks:
    coffee:
      runner: coffee
      src: 'src/**/*.coffee'
      dest: 'lib'
