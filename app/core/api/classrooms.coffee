fetchJson = require './fetch-json'

module.exports = {
  getByHandle: (classroomID, options={}) ->
    fetchJson("/db/classroom/#{classroomID}", options)
}
