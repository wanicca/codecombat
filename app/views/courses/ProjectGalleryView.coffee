RootComponent = require 'views/core/RootComponent'
FlatLayout = require 'core/components/FlatLayout'
api = require 'core/api'

ProjectGalleryComponent = Vue.extend
  name: 'project-gallery-component'
  template: require('templates/courses/project-gallery-view')()
  components:
    'flat-layout': FlatLayout
  methods:
    getLevelURL: (session) ->
      'yay'
  props:
    courseInstanceID:
      type: String
      default: -> null
  data: ->
    levelSessions: []
    users: []
    classroom: null
    course: null
    courseInstance: null
    loaded: false
  created: ->
    Promise.all([
      api.courseInstances.fetchProjectGallery({ @courseInstanceID }).then (@levelSessions) =>
        Promise.all(api.users.getByHandle(userID) for userID in _.unique(_.map(@levelSessions, 'creator'))).then((@users) =>)
      api.courseInstances.getByHandle(@courseInstanceID).then (@courseInstance) =>
        Promise.all([
          api.classrooms.getByHandle(@courseInstance.classroomID).then((@classroom) =>),
          api.courses.getByHandle(@courseInstance.courseID).then((@course) =>)
        ])
    ])
  methods:
    getProjectViewUrl: (session) ->
      projectType = 'web-dev'
      levelSlug = 'wanted-poster'
      return "/play/#{projectType}-level/#{levelSlug}/#{session._id}"
    creatorOfSession: (session) ->
      _.find(@users, { _id: session.creator })

module.exports = class ProjectGalleryView extends RootComponent
  id: 'project-gallery-view'
  template: require 'templates/base-flat'
  VueComponent: ProjectGalleryComponent
  constructor: (options, @courseInstanceID) ->
    @propsData = { @courseInstanceID }
    super options
