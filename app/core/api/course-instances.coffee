fetchJson = require './fetch-json'

module.exports = {
  fetchProjectGallery: ({ courseInstanceID }, options={}) ->
    fetchJson("/db/course_instance/#{courseInstanceID}/peer-projects", options)
}
