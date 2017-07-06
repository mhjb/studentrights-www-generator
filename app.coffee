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

summarise = (selector) ->
  $(selector).each (i, e) ->
    heading = $(e)
    content = $(e).nextUntil(selector)
    $(e).nextUntil(selector).remove()
    $(e).replaceWith "\n<details>\n<summary>#{heading}</summary>\n#{content}\n</details>\n"

write_file_with_template = (filename, content) ->
  # console.log "Writing ../www/problems-at-school/#{filename}"
  fs.writeFile "../www/problems-at-school/#{filename}", header + content + footer, 'utf8', error_handler

remove_wrapping_elements = (selector) ->
  $ selector
    .each (i, e) ->
      $(e).replaceWith $(e).html()


$ = cheerio.load fs.readFileSync "problems at school.html"

remove_wrapping_elements '.xref-box'
remove_wrapping_elements '.xref'
remove_wrapping_elements '.xref'
remove_wrapping_elements '.url'
remove_wrapping_elements '.chap-num'
remove_wrapping_elements '.chapter-for-running-head'
remove_wrapping_elements 'span:not([class!=""])'

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

# I don't know why I need to do this
fs.writeFileSync "export/problems at school.html", $.html(), 'utf8', error_handler
$ = cheerio.load fs.readFileSync "export/problems at school.html"

# clean up links & anchors
$('a').each (i, e) ->
  id = $(e).attr 'id'
  if id
    if $(e).parent().is('h1') or $(e).parent().is('h2')
      section = $(e).parent().text()
    else
      section = $(e).parent().prevAll('h2').eq(0).text()

    section = section.replace(/(\t)/g, ' ').replace(/(:)/g, '')

    console.log "id: #{id}, section #{section}"
    $("a[href='##{id}']").attr 'href', section + '.html#' + id

  no_page_refs = $(e).text().replace /, page \d+/g, ''
  $(e).text(no_page_refs)


header = fs.readFileSync 'header.html'
footer = fs.readFileSync 'footer.html'
intro = fs.readFileSync 'intro.html'

main_contents = "<ul class=\"contents\">\n"
$('h1').each (i, e) ->
  h1_heading = $(e).text().replace(/(\d\. ?\t)/g, '')
  h1_file = h1_heading.replace(/:/g, '') + '.html'
  h1_breadcrumb = "<p class=\"breadcrumb\"><a href=\"../index.html\">Student Rights</a>\n > <a href=\"index.html\">Problems at School</a>\n > #{h1_heading}</p>"
  content = h1_breadcrumb + "<h1>#{h1_heading}</h1>\n" + $(e).nextUntil('h2')
  full_content = $(e).nextUntil('h1')

  main_contents += "<li><a href=\"#{h1_file}\">#{h1_heading}</a>\n"

  sections = []
  full_content.filter('h2').each (i,e) ->
    h2_heading = $(e).text().replace(/(\t)/g, ' ')
    h2_file = h2_heading.replace(/:/g, '') + '.html'
    h2_breadcrumb = "<p class=\"breadcrumb\"><a href=\"../index.html\">Student Rights</a>\n > <a href=\"index.html\">Problems at School</a> > <a href=\"#{h1_file}\">#{h1_heading}</a> > #{h2_heading}</p>\n"
    h2_content = h2_breadcrumb + "<h2>#{h2_heading}</h2>\n" + $(e).nextUntil('h2')
    write_file_with_template h2_file, h2_content
    sections.push
      section: h2_heading
      file: h2_file

  section_contents = "<ul class=\"contents\">\n"
  sections.forEach (e) ->
    section_contents += "<li><a href=\"#{e.file}\">#{e.section}</a></li>\n"
  section_contents += "</ul>\n"

  main_contents += section_contents + "</li>\n"

  write_file_with_template h1_file, content + section_contents

main_contents += "</ul>"

write_file_with_template 'index.html', intro + main_contents



collect_heading = (selector) ->
  $(selector).each (i, e) ->
    id = $(e).attr('id')
    if selector is 'h1' or selector is 'h2'
      section = $(e).text()
    else
      section = $(e).prevAll('h2').eq(0).text()
    section = section.replace(/(\t)/g, ' ').replace(/(:)/g, '')
    link = encodeURI section + '.html#' + id
    headings.push
      label: $(e).text().replace(/(\t)/g, ' ')
      value: $(e).text().replace(/(\t)/g, ' ')
      link: link

headings = []
collect_heading 'h5'
collect_heading 'h4'
collect_heading 'h3'
collect_heading 'h2'
collect_heading 'h1'

fs.writeFileSync "../www/problems-at-school/headings.json", JSON.stringify(headings, null, 4), 'utf8', error_handler
