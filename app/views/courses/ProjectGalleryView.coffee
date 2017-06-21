RootComponent = require 'views/core/RootComponent'
FlatLayout = require 'core/components/FlatLayout'
api = require 'core/api'
User = require 'models/User'
Level = require 'models/Level'
utils = require 'core/utils'

ProjectGalleryComponent = Vue.extend
  name: 'project-gallery-component'
  template: require('templates/courses/project-gallery-view')()
  components:
    'flat-layout': FlatLayout
  props:
    courseInstanceID:
      type: String
      default: -> null
  data: ->
    levelSessions: []
    users: []
    classroom: null
    levels: null
    level: null
    course: null
    courseInstance: null
  computed:
    levelName: -> @level and utils.i18n(@level, 'name')
    courseName: -> @course and utils.i18n(@course, 'name')
  created: ->
    Promise.all([
      api.courseInstances.fetchProjectGallery({ @courseInstanceID }).then((@levelSessions) =>)
      api.courseInstances.getByHandle(@courseInstanceID).then (@courseInstance) =>
        Promise.all([
          api.classrooms.getByHandle(@courseInstance.classroomID).then((@classroom) =>).then =>
            api.users.getForClassroom(@classroom, removeDeleted: true).then((@users) =>)
          api.courses.getByHandle(@courseInstance.courseID).then((@course) =>)
          api.levels.fetchForClassroomAndCourse({ classroomID: @courseInstance.classroomID, courseID: @courseInstance.courseID }).then((@levels) =>)
        ])
    ]).then =>
      @level = _.find(@levels, Level.isProject)
      @users.forEach (user) =>
        Vue.set(user, 'broadName', User.broadName(user))
  methods:
    getProjectViewUrl: (session) ->
      return "/play/#{@level?.type}-level/#{@level?.slug}/#{session._id}"
    getProjectEditUrl: (session) ->
      return "/play/level/#{@level?.slug}?course=#{@course?._id}&course-instance=#{@courseInstance?._id}"
    isMyProject: (session) ->
      session.creator is me.id
    creatorOfSession: (session) ->
      _.find(@users, { _id: session.creator })

module.exports = class ProjectGalleryView extends RootComponent
  id: 'project-gallery-view'
  template: require 'templates/base-flat'
  VueComponent: ProjectGalleryComponent
  constructor: (options, @courseInstanceID) ->
    @propsData = { @courseInstanceID }
    super options
