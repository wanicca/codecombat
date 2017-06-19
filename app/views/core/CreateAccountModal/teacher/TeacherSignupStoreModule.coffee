api = require 'core/api'
DISTRICT_NCES_KEYS = ['district', 'district_id', 'district_schools', 'district_students', 'phone']
SCHOOL_NCES_KEYS = DISTRICT_NCES_KEYS.concat(['id', 'name', 'students'])
ncesData = _.zipObject(['nces_'+key, ''] for key in SCHOOL_NCES_KEYS)
require('core/services/segment')()

module.exports = TeacherSignupStoreModule = {
  namespaced: true
  state: {
    trialRequestProperties: _.assign(ncesData, {
      organization: 'Foo'
      district: 'blah'
      city: 'Cronville'
      state: 'NJ'
      country: 'USA'
      phoneNumber: '555-555-5555'
      role: 'Parent'
      purchaserRole: 'No role in purchase decisions'
      numStudents: '1-10'
      numStudentsTotal: '1-500'
      notes: ''
      referrer: ''
      marketingReferrer: ''
      educationLevel: ["Elementary"]
      otherEducationLevel: false
      otherEducationLevelExplanation: ''
      siteOrigin: 'create teacher'
      firstName: 'Cat'
      lastName: 'FakeTeacher'
      email: 'cat+fake@codecombat.com'
    })
    signupForm: {
      name: ''
      email: ''
      password: ''
      firstName: ''
      lastName: ''
    }
    ssoAttrs: {
      email: '',
      gplusID: '',
      facebookID: ''
    }
    ssoUsed: '' # 'gplus', or 'facebook'
  }
  mutations: {
    updateTrialRequestProperties: (state, updates) ->
      _.assign(state.trialRequestProperties, updates)
    updateSignupForm: (state, updates) ->
      _.assign(state.signupForm, updates)
    updateSso: (state, { ssoUsed, ssoAttrs }) ->
      _.assign(state.ssoAttrs, ssoAttrs)
      state.ssoUsed = ssoUsed
  }
  actions: {
    createAccount: ({state, commit, dispatch, rootState}) ->
      
      return Promise.resolve()
      .then =>
        return dispatch('me/save', {
          role: state.trialRequestProperties.role.toLowerCase()
        }, {
          root: true
        })

      .then =>
        # add "other education level" explanation to the list of education levels
        properties = _.cloneDeep(state.trialRequestProperties)
        if properties.otherEducationLevel
          properties.educationLevel.push(properties.otherEducationLevelExplanation)
        delete properties.otherEducationLevel
        delete properties.otherEducationLevelExplanation
        properties.email = state.signupForm.email
        
        return api.trialRequests.post({
          type: 'course'
          properties
        })
      
      .then =>
        intercomTraits = _.pick state.trialRequestProperties, ["siteOrigin", "marketingReferrer", "referrer", "notes", "numStudentsTotal", "numStudents", "purchaserRole", "role", "phoneNumber", "country", "state", "city", "district", "organization", "nces_students", "nces_name", "nces_id", "nces_phone", "nces_district_students", "nces_district_schools", "nces_district_id", "nces_district"]
        intercomTraits.educationLevel_elementary = _.contains state.trialRequestProperties.educationLevel, "Elementary"
        intercomTraits.educationLevel_middle = _.contains state.trialRequestProperties.educationLevel, "Middle"
        intercomTraits.educationLevel_high = _.contains state.trialRequestProperties.educationLevel, "High"
        intercomTraits.educationLevel_college = _.contains state.trialRequestProperties.educationLevel, "College+"
        debugger
        application.tracker.identify me.id, intercomTraits


      .then =>
        signupForm = _.omit(state.signupForm, (attr) -> attr is '')
        ssoAttrs = _.omit(state.ssoAttrs, (attr) -> attr is '')
        attrs = _.assign({}, signupForm, ssoAttrs, { userId: rootState.me._id })
        if state.ssoUsed is 'gplus'
          return api.users.signupWithGPlus(attrs)
        else if state.ssoUsed is 'facebook'
          return api.users.signupWithFacebook(attrs)
        else
          return api.users.signupWithPassword(attrs)
  }
}

module.exports = TeacherSignupStoreModule
