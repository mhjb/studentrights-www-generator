cheerio = require 'cheerio'
fs = require 'fs'


error_handler = (err) -> console.log err if err

stick_it_in_the_json = (selector) ->
  $ selector
    .each (i, e) ->
      answer_content = $(e).nextUntil header_tags
      if answer_content.length
        console.log "#{$(e).prop('tagName')}: #{$(e).text()}"
        json.data.push
          q: $(e).text()
          a: answer_content
            .map (i, e) ->
              x = $(e).text().replace /[\n\t]/g, ' '
              $(e).remove()
              x
            .get()
            .join ' '
            .replace /( ){2,10}/g, ' ' # ditch multiple spaces
            .replace /( \.)/g, '.'
        $(e).remove()

json = []

$ = cheerio.load fs.readFileSync "problems at school.html"
$.fn.reverse = [].reverse


switch_class_for_tag = (class_name, tag) ->
  $ class_name
    .each (i, e) ->
      $(e).replaceWith "<#{tag}>#{$(e).text()}</#{tag}>"

remove_wrapping_elements = (selector) ->
  $ selector
    .each (i, e) ->
      $(e).replaceWith $(e).html()

summarise = (selector) ->
  $(selector).each (i, e) ->
    heading = $(e)
    content = $(e).nextUntil(selector)
    $(e).nextUntil(selector).remove()
    $(e).replaceWith "\n<details>\n<summary>#{heading}</summary>\n#{content}\n</details>\n"

summarise 'p.Heading-1'
summarise 'p.Heading-2'
summarise 'p.Heading-3'
summarise 'p.Heading-3-first'
summarise 'p.Heading-4'
summarise 'p.Heading-4-first'
summarise 'p.Heading-5'
summarise 'p.Heading-5-first'


remove_wrapping_elements '.xref-box'

$('.char-style-override-3').remove() # bullets
$('.char-style-override-5').remove() # numbers
$('.No-Paragraph-Style').remove()
$('.frame-2').remove() #images
$('table').remove() # temporary

switch_class_for_tag 'p.Heading-1', 'h1'
switch_class_for_tag 'p.Heading-2', 'h2'
switch_class_for_tag 'p.Heading-3', 'h3'
switch_class_for_tag 'p.Heading-3-first', 'h3'
switch_class_for_tag 'p.Heading-4', 'h4'
switch_class_for_tag 'p.Heading-4-first', 'h4'
switch_class_for_tag 'p.Heading-5', 'h5'


fs.writeFile "export/problems at school.html", $.html(), 'utf8', error_handler
# fs.writeFile "export/problems at school.json", JSON.stringify(json, null, 4), 'utf8', error_handler
# fs.writeFile "export/problems at school.json", json, 'utf8', error_handler
