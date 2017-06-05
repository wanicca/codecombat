fetchJson = require './fetch-json'

module.exports = {
  getByHandle: (courseInstanceID, options={}) ->
    fetchJson("/db/course_instance/#{courseInstanceID}", options)

  fetchProjectGallery: ({ courseInstanceID }, options={}) ->
    fetchJson("/db/course_instance/#{courseInstanceID}/peer-projects", options)
}
