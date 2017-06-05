fetchJson = require './fetch-json'

module.exports = {
  getByHandle: (courseID, options={}) ->
    fetchJson("/db/course/#{courseID}", options)
}
