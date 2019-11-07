# https://jsfiddle.net/yndp5g87/11/ or a hight number at the end
#
#

$ = require("jquery")

getDateFromString = (string) ->
  if string
    [year, month, day]  = string.slice(0, 10).split('-')
    "#{day}.#{month}.#{year}"
  else ""

handleErrors = (response) ->
    if !response.ok
      throw Error(response.statusText)
    return response

vm = new Vue
  el: '#vue-instance'
  data:
    items: []
    searchString: ""
    tableHeaders: ["Num.", "Name", "Email", "Phone"]
    messages:
      networkError: ""
  
  created: ->
    self = this
    # await test
    console.log await 13

    #fetch("https://jsonplaceholder.typicode.com/users")
    fetch("http://seminarhaus-engl.de/Seminare")
    .then(handleErrors)
    .then((res) -> res.text())
    .then((html) ->
      #if json
        #console.log json
        #self.items = _.orderBy(json, ["name", "phone"], ["asc", "asc"])
      console.log html
    ).catch (err) -> self.messages.networkError = "Can't download data."

  
  computed:
    filteredData: ->
      self = this
      searchArray = self.items
      searchString = self.searchString
      searchString = searchString.toLowerCase()
      if searchString
        searchArray = searchArray.filter (item) ->
          if item.name.toLowerCase().indexOf(searchString) isnt -1 or item.phone.toLowerCase().indexOf(searchString) isnt -1
            return item

      return searchArray
