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
  created: ->
    api.courseInstances.fetchProjectGallery({ @courseInstanceID })
    .then (sessions) =>
      console.log {sessions}
      @levelSessions = sessions
      userIDs = _.unique(_.map(sessions, 'creator'))
      Promise.all userIDs.map (userID) ->
        api.users.getByHandle(userID)
    .then (users) =>
      @users = users
  methods:
    getProjectViewUrl: (session) ->
      projectType = 'web-dev'
      levelSlug = 'wanted-poster'
      return "/play/#{projectType}-level/#{levelSlug}/#{session._id}"
    creatorOfSession: (session) ->
      debugger
      _.find(@users, { _id: session.creator })

module.exports = class ProjectGalleryView extends RootComponent
  id: 'project-gallery-view'
  template: require 'templates/base-flat'
  VueComponent: ProjectGalleryComponent
  constructor: (options, @courseInstanceID) ->
    @propsData = { @courseInstanceID }
    super options
