describe 'Controllers Test', ->
  $scope = undefined
  ctrl = undefined
  beforeEach ->
    module 'spokenvote'
    module 'spokenvoteMocks'

  describe 'Initial Validation Test', ->
    it "should match", ->
      expect 'string'
        .toMatch new RegExp '^string$'

  describe 'ProposalListCtrl in Learning', ->
    beforeEach inject ($rootScope, $controller, _$httpBackend_, SessionSettings) ->
      $rootScope.sessionSettings = SessionSettings
      $scope = $rootScope.$new()
      ctrl = $controller "ProposalListCtrl",
        $scope: $scope

    it 'should have loaded list of proposals', ->
      $scope.$apply()
      expect $scope.proposals
        .toEqual [ 1, 2, 3 ]
      expect $scope.proposalsLoading
        .toBe false


