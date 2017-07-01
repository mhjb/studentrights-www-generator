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

switch_class_for_tag = (class_name, tag) ->
  $ class_name
    .each (i, e) ->
      id = $(e).text()
        .replace /(\?)/g, ''
      $(e).replaceWith "<#{tag} id='#{id}'>#{$(e).html()}</#{tag}>"

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


$ = cheerio.load fs.readFileSync "problems at school.html"

remove_wrapping_elements '.xref-box'
remove_wrapping_elements '.xref'

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


fs.writeFileSync "export/problems at school.html", $.html(), 'utf8', error_handler

# I don't know why I need to do this
$ = cheerio.load fs.readFileSync "export/problems at school.html"

anchors = []
$('a').each (i, e) ->
  id = $(e).attr 'id'
  if id then anchors.push
    anchor: id
    section: $(e).parent().prevAll('h2').eq(0)
      .text()
      .replace(/(\t)/g, ' ')
  no_pages = $(e).text().replace /, page \d+/g, ''
  $(e).text(no_pages)

anchors.forEach (i) ->
  $ "a[href='##{i.anchor}']"
    .attr 'href', "#{i.section}.html##{i.anchor}"

header = fs.readFileSync 'header.html'
footer = fs.readFileSync 'footer.html'

sections = []
$('h2').each (i, e) ->
  heading = $(e).text().replace(/(\t)/g, ' ')
  chapter = $(e).prevAll('h1').eq(0).text().replace(/(\t)/g, ' ')
  content = "<h2>#{heading}</h2>\n#{$(e).nextUntil('h2')}"
  file = "#{heading}.html"
  console.log "Writing ../www/#{file}"
  fs.writeFile "../www/#{file}", header + content + footer, 'utf8', error_handler
  sections.push
    section: heading
    chapter: chapter
    file: file

console.log "Writing contents page"

contents_page = "<h1>Browse the book</h1>\n<ul class=\"contents\">\n"
sections.forEach (e) ->
  contents_page += "<li>#{e.chapter}: <a href=\"#{e.file}\">#{e.section}</a></li>\n"
contents_page += "</ul>\n"

fs.writeFile '../www/problems-at-school.html', header + contents_page + footer, 'utf8', error_handler

collect_heading = (selector) ->
  $(selector).each (i, e) ->
    id = $(e).attr('id')
    section = $(e).prevAll('h2').eq(0)
      .text()
      .replace(/(\t)/g, ' ')
    link = section + '.html#' + id
    headings.push
      label: $(e).text().replace(/(\t)/g, ' ')
      value: $(e).text().replace(/(\t)/g, ' ')
      link: link

headings = []
collect_heading 'h5'
collect_heading 'h4'
collect_heading 'h3'
collect_heading 'h2'
# collect_heading 'h1'

fs.writeFileSync "../www/headings.json", JSON.stringify(headings, null, 4), 'utf8', error_handler
