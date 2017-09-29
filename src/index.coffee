
foo = ->
  new Promise (resolve) ->
    setTimeout ( resolve "await works" ), 111
bar = ->
  console.log await foo()
bar()
