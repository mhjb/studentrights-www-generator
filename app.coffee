require('dotenv').config()
cheerio = require 'cheerio'
fs = require 'fs'

{ write_file_with_template } = require './templater'
{ schematize } = require './schema'

{ path } = process.env

acts_and_links = require './acts-and-links'
intro = fs.readFileSync 'templates/intro.html'


switch_class_for_tag = (class_name, tag) ->
  $ class_name
    .each (i, e) ->
      id = $(e).text()
        .replace /(\?)/g, ''
      $(e).replaceWith "<#{tag} id='#{id}'>#{$(e).html()}</#{tag}>"


remove_wrapping_elements = (array_of_selectors) ->
  array_of_selectors.forEach (selector) ->
    $ selector
      .each (i, e) ->
        $(e).replaceWith $(e).html()


remove_chapter_number = (text) -> text.replace /(\d+\. ?\t)/g, ''


get_chapter_number = (text) -> (text.match /^(\d+)\./)?[1]


section_to_filename = (section) ->
  section
    .replace /( )/g, '-'
    .replace /(\t)/g, '-'
    .replace /([:,’“”])/g, ''


tidy_citation = (citation) ->
  citation
    .replace /(ss? \w+(( – |-|, )\w+)?)/g, '<nobr>$1</nobr>'
    .replace /(\.)$/, ''   # trailing full stop




pas_text = fs.readFileSync "problems at school.html"

pas_text = pas_text.toString()
  .replace //g, '✔'  # fix bad checks & crosses
  .replace //g, '✘'
  .replace /<p class="body">&#160;<\/p>/gi, ''  # get rid of some empty paras
  .replace /<p class="Heading-4-first">&#160;<\/p>/gi, ''
  .replace /([A-Z]{2}[A-Z]+)/g, '<span class="smallcaps">$1</span>'

$ = cheerio.load pas_text

remove_wrapping_elements ['div', 'div', 'div', '.xref-box', '.xref', '.xref', '.url', '.chap-num', '.chapter-for-running-head', 'span:not([class!=""])']

$('.char-style-override-3').remove() # bullets
$('.char-style-override-5').remove() # numbers
$('.No-Paragraph-Style').remove()
$('.frame-2').remove() # images
$('img').remove()


switch_class_for_tag 'p.Heading-1', 'h1'
switch_class_for_tag 'p.Heading-2', 'h2'
switch_class_for_tag 'p.Heading-3', 'h3'
switch_class_for_tag 'p.Heading-3-first', 'h3'
switch_class_for_tag 'p.Heading-4', 'h4'
switch_class_for_tag 'p.Heading-4-first', 'h4'
switch_class_for_tag 'p.Heading-5', 'h5'

# I don't know why I need to do this
fs.writeFileSync "export/problems at school.html", $.html(), 'utf8', console.error
$ = cheerio.load fs.readFileSync "export/problems at school.html"


# clean up links & anchors
$('a').each (i, e) ->
  id = $(e).attr 'id'
  if id
    if $(e).parent().is('h1') or $(e).parent().is('h2')
      section = remove_chapter_number $(e).parent().text()
    else
      section = $(e).parent().prevAll('h2').eq(0).text()
    $("a[href='##{id}']").attr 'href', section_to_filename section + '.html#' + id
  no_page_refs = $(e).text().replace /, page \d+/g, ''
  $(e).text(no_page_refs)


# link up legislation
$('p.legislation').each (i, e) ->
  citations = $(e).text().split(/; ?/)
  links = ''
  citations.forEach (citation) ->
    link = acts_and_links citation
    citation = tidy_citation citation
    if link
      links += "<a target=\"legislation\" href=\"#{link}\">#{citation}</a><br/>\n"
    else
      links += "#{citation}<br/>"
  if links then $(e).html links


# make phone numbers clickable
$('p').each (i, e) ->
  $(e).html $(e).html().replace /((0800|\(0\d\))[\d ]{3,8})/g, "<span itemprop=\"telephone\" content=\"$1\"><a href=\"tel:$1\">$1</strong></a></span>"


# build main & chapter contents pages
pages = []
main_contents = "<ul class=\"contents\">\n"
$('h1').each (i, e) ->
  h1_heading = remove_chapter_number $(e).text()
  h1_file = section_to_filename h1_heading + '.html'
  h1_image = section_to_filename h1_heading + '.jpg'
  h1_breadcrumb = "<p class=\"breadcrumb\"><a href=\"../index.html\">Student Rights</a>\n > <a href=\"index.html\">Problems at School</a>\n > #{h1_heading}</p>"
  content = h1_breadcrumb + "<h1>#{h1_heading}</h1>\n" + $(e).nextUntil('h2,h1')
  full_content = $(e).nextUntil('h1')

  if get_chapter_number $(e).text()
    main_contents += "<li><a href=\"#{h1_file}\"><img src=\"../img/chapter/#{h1_image}\" />#{h1_heading}</a>\n"
  else
    main_contents += "<li><a href=\"#{h1_file}\">#{h1_heading}</a>\n"

  schematize full_content, $

  sections = []
  index_before_section = pages.length
  full_content.filter('h2').each (i, e) ->
    h2_heading = $(e).text().replace(/(\t)/g, ' ')
    h2_file = section_to_filename h2_heading + '.html'
    h2_breadcrumb = "<p class=\"breadcrumb\"><a href=\"../index.html\">Student Rights</a>\n > <a href=\"index.html\">Problems at School</a> > <a href=\"#{h1_file}\">#{h1_heading}</a> > #{h2_heading}</p>\n"
    h2_content = h2_breadcrumb + "<h2>#{h2_heading}</h2>\n" + $(e).nextUntil('h2,h1')
    pages.push
      file: h2_file
      title: h2_heading
      content: h2_content
    sections.push
      section: h2_heading
      file: h2_file

  section_contents = "<ul class=\"contents\">\n"
  sections.forEach (e) ->
    section_contents += "<li><a href=\"#{e.file}\">#{e.section}</a></li>\n"
  section_contents += "</ul>\n"

  main_contents += section_contents + "</li>\n"

  pages.splice index_before_section, 0,
    file: h1_file
    title: h1_heading
    content: content + section_contents

main_contents += "</ul>"
pages.unshift
  file: 'index.html'
  title: 'Problems at School'
  content: intro + main_contents

pages.forEach (page, index) ->
  if index > 0 then prev = pages[index - 1].file else prev = null
  if index < pages.length - 1 then next = pages[index + 1].file else next = null
  write_file_with_template page.file, page.title, page.content, prev, next


headings = []
['h5', 'h4', 'h3', 'h2', 'h1'].forEach (selector) ->
  $(selector).each (i, e) ->
    id = ''
    label = remove_chapter_number $(e).text()
    if selector is 'h1' or selector is 'h2'
      section = remove_chapter_number $(e).text()
    else
      section = $(e).prevAll('h2,h1').eq(0).text()
      id = $(e).attr('id')
    headings.push
      label: label
      link: "#{section_to_filename section}.html##{id}"

fs.writeFileSync "#{path}/headings.json", JSON.stringify(headings, null, 4), 'utf8', console.error
