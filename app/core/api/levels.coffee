fetchJson = require './fetch-json'

module.exports = {
  fetchForClassroomAndCourse: ({classroomID, courseID}, options={}) ->
    fetchJson("/db/classroom/#{classroomID}/courses/#{courseID}/levels", options)
}
