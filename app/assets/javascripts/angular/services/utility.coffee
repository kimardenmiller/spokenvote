Focus = ($timeout) ->
  (id) ->
    $timeout ->
#      console.log 'Utility id arg: ', id
      element = angular.element( document.querySelector id )
#      console.log 'Focus Utility element: ', element
      element[0].focus()  if element

# Register
App.Services.factory 'Focus', Focus