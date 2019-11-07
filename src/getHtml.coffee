fs              = require("fs")
axios           = require ("axios")
cheerio         = require("cheerio")
entities        = new (require('html-entities').XmlEntities)()
turndownService = new require('turndown')()

rootPath  = "./debug"


parseSeminare = (html) ->
  items = []
  $ = cheerio.load(html)
  $(".node").each (i, elem) ->
    performersRaw = $(this).find(".field-field-leitung").text().replace("Leitung:", "").trim()
    if performersRaw.match("Lehr-Assistenz:")
      console.log lehrAssistenz = performersRaw.match("Lehr-Assistenz:(.*)")[1].trim()
    nodePath =  $(this).find("h2 a").attr("href")
    nodeName = nodePath.replace("/node/", "")
    try seminarDetailsHtml = await getSeminarDetailsHtml(nodePath)
    catch err then console.log err
    $seminarDetails = cheerio.load(seminarDetailsHtml)
    #console.log "##############################"

    seminar = {
      title:            $(this).find("h2").text().trim()
      #url:              $(this).find("h2 a").attr("href")
      startDate:        $(this).find(".event-start").text().trim()
      endDate:          $(this).find(".event-end").text().trim()
      # this is like a thing in bold
      #description0:     $seminarDetails(".field-field-weiterfuehrendekursbeschr").prev().prev().text().trim()
      descriptionShort: entities.decode($seminarDetails(".field-field-weiterfuehrendekursbeschr").prev().text().trim())
      description:      entities.decode($seminarDetails(".field-field-weiterfuehrendekursbeschr").text().trim())
      honorar:          $seminarDetails(".field-field-dana .field-items .field-item.odd").text().replace("Honorar:", "").trim()
      kursgebuehr:      entities.decode($seminarDetails(".field-field-kursgebuehr .field-items .field-item.odd").text().replace("Kursgebühr:", "").trim())
      unterkunft:       $seminarDetails(".field-field-unterkunft .field-items .field-item.odd").text().replace("Unterkunft und Verpflegung:", "").trim()
      dozentenbeschreibung: turndownService.turndown(entities.decode($seminarDetails(".field-field-dozentenbeschreibung .field-items .field-item.odd p")?.html()?.trim()))
      # sollte es die möglichkeit geben mehrere webseiten und dozenten anzuzeigen. oder gleich in der beschreibung
      website:          $seminarDetails(".field-field-website .field-items .field-item.odd a").text().trim()
      websiteUrl:       $seminarDetails(".field-field-website .field-items .field-item.odd a").attr("href")
      
      performers:       performersRaw
    }
    items.push(seminar)
    seminarArray = []
    Object.keys(seminar).forEach((key) -> seminarArray.push("#{key}: '#{seminar[key]}'") )
    #Object.keys(seminar).forEach((key) -> seminarArray.push("#{key}: #{seminar[key]}") )
    markdown = """
      ---
      layout: SeminarLayout
      #{seminarArray.join("\n")}
      ---
    """
    
    fs.writeFileSync("#{rootPath}/markdown/#{nodeName}.md", markdown)
    # add to production site
    if nodeName.match(/201\d+/)
      console.log nodeName
      fs.writeFileSync("/Users/andrej.kralj/dev/github/simplify-it.net/docs/seminare/#{nodeName}.md", markdown)


getSeminareHtml = (url) ->
  try
    html = fs.readFileSync("#{rootPath}/seminare")
    console.log "have html yea"
  catch err
    response = await axios.get(url)
    if response.status is 200
      html = response.data
      fs.writeFileSync("#{rootPath}/seminare", html)
  # parse stuff
  return html

getSeminarDetailsHtml = (nodePath) ->
  url = "http://seminarhaus-engl.de" + nodePath
  nodeName = nodePath.replace("/node/", "")
  try
    html = fs.readFileSync("#{rootPath}/seminare-list/#{nodeName}")
    #console.log "have node #{nodeName} yea"
  catch err
    response = await axios.get(url)
    if response.status is 200
      html = response.data
      fs.writeFileSync("#{rootPath}/seminare-list/#{nodeName}", html)
  # parse stuff
  return html


parseSeminareJob = ->
  html = await getSeminareHtml("http://seminarhaus-engl.de/Seminare")
  await parseSeminare(html)
  console.log new Date()

parseSeminareJob()