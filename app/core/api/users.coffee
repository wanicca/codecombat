fetchJson = require './fetch-json'

module.exports = {
  url: (userId, path) -> if path then "/db/user/#{userId}/#{path}" else "/db/user/#{userId}"
  
  getByHandle: (handle, options) ->
    fetchJson("/db/user/#{handle}", options)

  getByEmail: (email, options={}) ->
    fetchJson("/db/user", _.merge {}, options, { data: { email } })
    
  getForClassroom: (classroom, options) ->
    removeDeleted = options.removeDeleted
    delete options.removeDeleted
    classroomID = classroom._id or classroom
    limit = 10
    skip = 0
    size = _.size(classroom.members)
    url = "/db/classroom/#{classroomID}/members"
    options.data ?= {}
    options.data.memberLimit = limit
    options.remove = false
    jqxhrs = []
    while skip < size
      options = _.cloneDeep(options)
      options.data.memberSkip = skip
      jqxhrs.push(fetchJson(url, options))
      skip += limit
    return Promise.all(jqxhrs).then (data) ->
      users = _.flatten(data)
      if removeDeleted
        users = _.filter users, (user) ->
          not user.deleted
      return users

  signupWithPassword: ({userId, name, email, password}, options={}) ->
    fetchJson(@url(userId, 'signup-with-password'), _.assign({}, options, {
      method: 'POST'
      json: { name, email, password }
    }))
    .then ->
      window.tracker?.trackEvent 'Finished Signup', category: "Signup", label: 'CodeCombat'

  signupWithFacebook: ({userId, name, email, facebookID}, options={}) ->
    fetchJson(@url(userId, 'signup-with-facebook'), _.assign({}, options, {
      method: 'POST'
      json: { name, email, facebookID, facebookAccessToken: application.facebookHandler.token() }
    }))
    .then ->
      window.tracker?.trackEvent 'Facebook Login', category: "Signup", label: 'Facebook'
      window.tracker?.trackEvent 'Finished Signup', category: "Signup", label: 'Facebook'

  signupWithGPlus: ({userId, name, email, gplusID}, options={}) ->
    fetchJson(@url(userId, 'signup-with-gplus'), _.assign({}, options, {
      method: 'POST'
      json: { name, email, gplusID, gplusAccessToken: application.gplusHandler.token() }
    }))
    .then ->
      window.tracker?.trackEvent 'Google Login', category: "Signup", label: 'GPlus'
      window.tracker?.trackEvent 'Finished Signup', category: "Signup", label: 'GPlus'
      
  put: (user, options={}) ->
    fetchJson(@url(user._id), _.assign({}, options, {
      method: 'PUT'
      json: user
    }))
    
  resetProgress: (options={}) ->
    store = require('core/store')
    fetchJson(@url(store.state.me._id, 'reset_progress'), _.assign({}, options, {
      method: 'POST'
    }))
}
