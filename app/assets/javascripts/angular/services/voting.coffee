VotingService = [ '$rootScope', '$location', '$modal', 'RelatedVoteInTreeLoader', 'Proposal', 'svUtility', ( $rootScope, $location, $modal, RelatedVoteInTreeLoader, Proposal, svUtility ) ->

  support: ( clicked_proposal ) ->
    $rootScope.alertService.clearAlerts()
    $rootScope.sessionSettings.vote = {}

    startSupport = ->
      RelatedVoteInTreeLoader(clicked_proposal).then (relatedSupport) ->
        if relatedSupport.id?
          if relatedSupport.proposal.id is clicked_proposal.id
            $rootScope.alertService.setInfo 'Good news, it looks as if you have already supported this proposal. Further editing is not allowed at this time.', $rootScope, 'main'
            return
          $rootScope.alertService.setInfo 'We found support from you on another proposal. If you continue, your previous support will be moved here.', $rootScope, 'main'
          $rootScope.sessionSettings.vote.related_existing = relatedSupport
        $rootScope.sessionSettings.vote.target = clicked_proposal
        svUtility.focus '#new_vote_comment'
    if $rootScope.currentUser.id
      startSupport()
    else
      $rootScope.authService.signinFb($rootScope).then ->
        startSupport()
#      $rootScope.alertService.setInfo 'To support proposals you need to sign in.', $rootScope, 'main'

  improve: ( clicked_proposal ) ->
    $rootScope.alertService.clearAlerts()
    $rootScope.sessionSettings.vote = {}     # TODO this needed here?
#    console.log 'service improve: '

    startImrpove = ->
      RelatedVoteInTreeLoader(clicked_proposal).then (relatedSupport) ->
        if relatedSupport.id?
          $rootScope.alertService.setInfo 'We found support from you on another proposal. If you create a new, improved propsal your previous support will be moved here.', $rootScope, 'main'
          $rootScope.sessionSettings.vote.related_existing = relatedSupport
#        $rootScope.sessionSettings.vote.parent = clicked_proposal  # TODO Obolete, may be deleted.
        $rootScope.sessionSettings.newProposal =
          parent_id: clicked_proposal.id
          statement: clicked_proposal.statement
          votes_attributes:      # TODO Delete once Raisl guard is merged
            comment: undefined
        $rootScope.sessionSettings.actions.improveProposal.propStepText =
          'Edit or start over to make your <strong><i>New</i></strong> proposal.'
        svUtility.focus '#new_proposal_statement'

    if $rootScope.currentUser.id
      startImrpove()
    else
      $rootScope.authService.signinFb($rootScope).then ->
        startImrpove()

  new: ->
    $rootScope.alertService.clearAlerts()
    $rootScope.sessionSettings.actions.newProposal.started = false
    if !$rootScope.currentUser.id?
      $rootScope.alertService.setInfo 'To create proposals you need to sign in.', $rootScope, 'main'
    else
#      $rootScope.sessionSettings.newProposal =
#        votes_attributes:    # Needed for Commentless Voting
#          comment: undefined
     $location.path '/start'

#  edit_old: ( scope, clicked_proposal ) ->
#    scope.clicked_proposal = clicked_proposal
#
#    if !scope.currentUser.id?
#      $rootScope.alertService.setInfo 'To proceed you need to sign in.', $rootScope, 'main'
#    else
#      if $rootScope.sessionSettings.openModals.editProposal is false
#        modalInstance = $modal.open
#          templateUrl: 'proposals/_edit_proposal_modal.html'
#          controller: 'EditProposalCtrl'
#          scope: scope      # Optional to pass the scope here?
#        modalInstance.opened.then ->
#          $rootScope.sessionSettings.openModals.editProposal = true
#        modalInstance.result.finally ->
#          $rootScope.sessionSettings.openModals.editProposal = false

  edit: ( clicked_proposal ) ->
    $rootScope.alertService.clearAlerts()
#    $rootScope.sessionSettings.vote = {}
#    console.log 'service edit: ', clicked_proposal

    startEdit = ->
      $rootScope.sessionSettings.newProposal =
        id: clicked_proposal.id
#        proposal:
        statement: clicked_proposal.statement
        votes_attributes:
          id: clicked_proposal.votes[0].id
          comment: clicked_proposal.votes[0].comment
      $rootScope.sessionSettings.actions.improveProposal.propStepText =
        '<strong><i>Editing</i></strong> your main proposal statement.'
      svUtility.focus '#new_proposal_statement'

    if $rootScope.currentUser.id
      startEdit()
    else
      $rootScope.authService.signinFb($rootScope).then ->
        startEdit()

  delete: (scope, clicked_proposal) ->
    scope.clicked_proposal = clicked_proposal

    if !scope.currentUser.id?
      $rootScope.alertService.setInfo 'To proceed you need to sign in.', $rootScope, 'main'
    else
      if $rootScope.sessionSettings.openModals.deleteProposal is false
        modalInstance = $modal.open
          templateUrl: 'proposals/_delete_proposal_modal.html'
          controller: 'DeleteProposalCtrl'
          scope: scope       # Optional to pass the scope here?
        modalInstance.opened.then ->
          $rootScope.sessionSettings.openModals.deleteProposal = true
        modalInstance.result.finally ->
          $rootScope.sessionSettings.openModals.deleteProposal = false

  commentStep: ->
#    console.log 'comment step: '
#    $rootScope.sessionSettings.actions.newProposal.comment = 'active'
    $rootScope.sessionSettings.actions.focus = 'comment'
    svUtility.focus '#new_vote_comment'

  hubStep: ->
#    $scope.sessionSettings.actions.newProposal.comment = 'complete'
    $rootScope.sessionSettings.actions.focus = 'hub'
    $rootScope.sessionSettings.actions.hubShow = true
    if $rootScope.sessionSettings.hub_attributes
      if $rootScope.sessionSettings.newProposal.statement
#        $rootScope.sessionSettings.actions.focus = 'publish'
#        Focus '#new_vote_comment'
#        this.commentStep(proposal.id)
        this.commentStep()
      else
        $rootScope.alertService.setCtlResult 'The proposal is not quite right, too short perhaps?', $rootScope, 'main'
    else
      $rootScope.$broadcast 'focusHubFilter'
#      $rootScope.$select.activate()

  saveNewProposal: ->
    $rootScope.alertService.clearAlerts()

    newProposal =
      proposal: $rootScope.sessionSettings.newProposal
    if $rootScope.sessionSettings.newProposal.id
      newProposal.id = $rootScope.sessionSettings.newProposal.id
    else
      newProposal.proposal.hub_id = $rootScope.sessionSettings.hub_attributes.id
      newProposal.proposal.hub_attributes = $rootScope.sessionSettings.hub_attributes

#    console.log 'voting service: saveNewProposal', newProposal

    saveSuccess = (response, status, headers, config) ->
      $rootScope.$broadcast 'event:proposalsChanged'
#      $rootScope.$broadcast 'event:votesChanged'     # Needed for Update?
      $rootScope.alertService.setSuccess 'Your new proposal stating: \"' + response.statement + '\" was saved.', $rootScope, 'main'
      $location.path('/proposals/' + response.id).search('hub', response.hub_id).search('filter', 'my').hash('navigationBar')
      $rootScope.sessionSettings.actions.offcanvas = false
      $rootScope.sessionSettings.newProposal = {}

    saveFail = (response, status, headers, config) ->
      $rootScope.alertService.setCtlResult 'Sorry, your proposal was not saved.', $rootScope, 'modal'
      $rootScope.alertService.setJson response.data

    saveProposal = ->
      Proposal.save newProposal, saveSuccess, saveFail

    updateProposal = ->
      console.log 'update hit: '
      Proposal.update newProposal, saveSuccess, saveFail

#      , (response, status, headers, config) ->
#        $rootScope.$broadcast 'event:votesChanged'
#        $rootScope.alertService.setSuccess 'Your proposal stating: \"' + response.statement + '\" has been saved.', $rootScope
#      , (response, status, headers, config) ->
#        $rootScope.alertService.setCtlResult 'Sorry, your improved proposal was not saved.', $rootScope
#        $rootScope.alertService.setJson response.data
#      )

    if newProposal.proposal.statement and newProposal.proposal.statement.length >= $rootScope.sessionSettings.spokenvote_attributes.minimumProposalLength
      switch
        when newProposal.proposal.id
          updateProposal()
        when $rootScope.sessionSettings.hub_attributes.id
          saveProposal()
        else switch
          when not $rootScope.sessionSettings.hub_attributes.formatted_location
            $rootScope.alertService.setCtlResult 'Sorry, your New Group location appears to be invalid.', $rootScope, 'main'
            this.hubStep()
            return
          when not $rootScope.sessionSettings.hub_attributes.group_name
            $rootScope.alertService.setCtlResult 'Sorry, your New Group name appears to be missing.', $rootScope, 'main'
            this.hubStep()
            return
          when $rootScope.sessionSettings.hub_attributes.group_name.length < $rootScope.sessionSettings.spokenvote_attributes.minimumHubNameLength
            $rootScope.alertService.setCtlResult 'Sorry, your New Group name appears to be invalid, perhaps it\'s too short?', $rootScope, 'main'
            this.hubStep()
            return
          else
            saveProposal()
    else
      $rootScope.alertService.setCtlResult 'Sorry, No Proposal to save found or your Proposal is too short.', $rootScope, 'main'

#    if not $rootScope.sessionSettings.newProposal.votes_attributes or not $rootScope.sessionSettings.newProposal.votes_attributes.comment
#      $rootScope.sessionSettings.newProposal.votes_attributes =
#        comment: undefined            # Needed for Commentless Voting

]

# Register
App.Services.factory 'VotingService', VotingService
