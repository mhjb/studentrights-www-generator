cheerio = require 'cheerio'
fs = require 'fs'

template = fs.readFileSync 'template.html'
intro = fs.readFileSync 'intro.html'

error_handler = (err) -> console.log err if err

switch_class_for_tag = (class_name, tag) ->
  $ class_name
    .each (i, e) ->
      id = $(e).text()
        .replace /(\?)/g, ''
      $(e).replaceWith "<#{tag} id='#{id}'>#{$(e).html()}</#{tag}>"

write_file_with_template = (filename, title, content) ->
  populated_template = template
    .toString()
    .replace /{{title}}/g, title
    .replace /{{book}}/g, content
  fs.writeFile "../www/problems-at-school/#{filename}", populated_template, 'utf8', error_handler

remove_wrapping_elements = (array_of_selectors) ->
  array_of_selectors.forEach (selector) ->
    $ selector
      .each (i, e) ->
        $(e).replaceWith $(e).html()

$ = cheerio.load fs.readFileSync "problems at school.html"

remove_wrapping_elements ['.xref-box', '.xref', '.xref', '.url', '.chap-num', '.chapter-for-running-head', 'span:not([class!=""])']

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
    $("a[href='##{id}']").attr 'href', section + '.html#' + id
  no_page_refs = $(e).text().replace /, page \d+/g, ''
  $(e).text(no_page_refs)

$('p.legislation').each (i, e) ->
  citations = $(e).text().split(/; ?/)
  links = ''
  citations.forEach (citation) ->
    link = switch
      when citation.match(/.*Education Act 1964.*/)
        'http://www.legislation.govt.nz/act/public/1964/0135/latest/DLM356732.html'
      when citation.match(/.*Education Act 1989.*/)
        'http://legislation.govt.nz/act/public/1989/0080/latest/DLM175959.html'
      when citation.match(/.*Education \(Stand-Down, Suspension, Exclusion, and Expulsion\) Rules 1999.*/)
        'http://www.legislation.govt.nz/regulation/public/1999/0202/latest/DLM288425.html'
      when citation.match(/.*New Zealand Bill of Rights Act 1990.*/)
        'http://www.legislation.govt.nz/act/public/1990/0109/latest/whole.html'
      when citation.match(/.*Human Rights Act 1993.*/)
        'http://www.legislation.govt.nz/act/public/1993/0082/latest/DLM304475.html'
      when citation.match(/.*Health \(Immunisation\) Regulations 1995.*/)
        'http://www.legislation.govt.nz/regulation/public/1995/0304/latest/whole.html'
      when citation.match(/.*Health \(Infectious and Notifiable Diseases\) Regulations 1966.*/)
        'http://www.legislation.govt.nz/regulation/public/1966/0087/latest/DLM24207.html'
      when citation.match(/.*Education \(School Attendance\) Regulations 1951.*/)
        'http://legislation.govt.nz/regulation/public/1951/0181/4.0/DLM5587.html'
      when citation.match(/.*Private Schools Conditional Integration Act 1975.*/)
        'http://www.legislation.govt.nz/act/public/1975/0129/latest/DLM437347.html'
      when citation.match(/.*National Administration Guidelines.*/)
        'https://education.govt.nz/ministry-of-education/legislation/nags/'
      when citation.match(/.*National Education Goal.*/)
        'https://education.govt.nz/ministry-of-education/legislation/negs/'
      when citation.match(/.*Te Ture mō te Reo Māori\/the Māori Language Act.*/)
        'http://www.legislation.govt.nz/act/public/2016/0017/29.0/DLM6174509.html'
      when citation.match(/.*United Nations Conventions on the Rights of the Child.*/)
        'http://www.ohchr.org/EN/ProfessionalInterest/Pages/CRC.aspx'
      when citation.match(/.*International Covenant on Civil and Political Rights.*/)
        'http://www.ohchr.org/EN/ProfessionalInterest/Pages/CCPR.aspx'
      when citation.match(/.*Assessment \(including Examination\) Rules for Schools with Consent to Assess 2015.*/)
        'http://www.nzqa.govt.nz/about-us/our-role/legislation/nzqa-rules/expired-rules/teo-rules-for-achievement-stds-2015/'
      when citation.match(/.*The Ministry Of Education Health And Safety Code Of Practice For State And State Integrated Schools.*/)
        'http://www.nzqa.govt.nz/about-us/our-role/legislation/nzqa-rules/expired-rules/teo-rules-for-achievement-stds-2015/'
      when citation.match(/.*Education \(School Trustee Elections\) Regulations 2000.*/)
        'http://www.legislation.govt.nz/regulation/public/2000/0195/latest/DLM8656.html'
      when citation.match(/.*Health and Safety at Work Act 2015.*/)
        'http://www.legislation.govt.nz/act/public/2015/0070/latest/DLM5976660.html'
      when citation.match(/.*Accident Compensation Act 2001.*/)
        'http://www.legislation.govt.nz/act/public/2001/0049/latest/DLM99494.html'
      when citation.match(/.*Code of Ethics for Registered Teachers.*/)
        'https://teachersandsocialmedia.co.nz/sites/default/files/resources/coe-poster-english.pdf'
      when citation.match(/.*Health Conditions in Education Settings.*/)
        'https://education.govt.nz/ministry-of-education/specific-initiatives/health-and-safety/practice-framework-resources-for-health-and-safety/health-conditions-in-education-settings-supporting-children-and-young-people/'
      when citation.match(/.*Crimes Act 1961.*/)
        'http://www.legislation.govt.nz/act/public/1961/0043/latest/whole.html'
      when citation.match(/.*Compliance Document for New Zealand Building Code, cl G1.*/)
        'https://www.building.govt.nz/assets/Uploads/building-code-compliance/g-services-and-facilities/g1-personal-hygiene/asvm/G1-personal-hygiene-2nd-edition-amendment-6.pdf'
      when citation.match(/.*Education Outside the Classroom Guidelines.*/)
        'http://eotc.tki.org.nz/EOTC-home/EOTC-Guidelines'
      when citation.match(/.*Summary Offences Act 1981.*/)
        'http://www.legislation.govt.nz/act/public/1981/0113/latest/whole.html'
      when citation.match(/.*New Zealand Bill of Rights 1990.*/)
        'http://www.legislation.govt.nz/act/public/1990/0109/latest/DLM224792.html'
      when citation.match(/.*Bovaird and the Board of Trustees of Lyndfield College v J (2008).*/)
        'http://www.nzsta.org.nz/media/1733/lynfield-decision-.pdf'
      when citation.match(/.*Privacy Act 1993.*/)
        'http://www.legislation.govt.nz/act/public/1993/0028/latest/whole.html'
      when citation.match(/.*Ombudsmen Act 1975.*/)
        'http://www.legislation.govt.nz/act/public/1975/0009/196.0/whole.html'
      when citation.match(/.*Education \(Surrender, Retention, and Search\) Rules 2013.*/)
        'http://www.legislation.govt.nz/regulation/public/2013/0469/latest/whole.html'
      when citation.match(/.*Guidelines for the Surrender and Retention of Property and Searches.*/)
        'https://education.govt.nz/school/managing-and-supporting-students/student-behaviour-help-and-guidance/searching-and-removing-student-property/'
      when citation.match(/.*Children, Young Persons, and Their Families Act 1989.*/)
        'http://www.legislation.govt.nz/act/public/1989/0024/latest/whole.html'
      when citation.match(/.*Harassment Act 1997.*/)
        'http://www.legislation.govt.nz/act/public/1997/0092/latest/whole.html'
      when citation.match(/.*Telecommunications Act 2001.*/)
        'http://www.legislation.govt.nz/act/public/2001/0103/latest/DLM124961.html'
      when citation.match(/.*Education \(Hostels\) Regulations 2005.*/)
        'http://legislation.govt.nz/regulation/public/2005/0332/13.0/whole.html'
      when citation.match(/.*Health Act 1956.*/)
        'http://www.legislation.govt.nz/act/public/1956/0065/latest/DLM306662.html'
      when citation.match(/.*Health Information Privacy Code 1994.*/)
        'http://www.privacy.org.nz/assets/Files/Codes-of-Practice-materials/Health-Information-Privacy-Code-1994-including-Amendment.pdf'
      when citation.match(/.*Public Records Act 2005.*/)
        'http://www.legislation.govt.nz/act/public/2005/0040/latest/DLM345529.html'
      when citation.match(/.*Search and Surveillance Act 2012.*/)
        'http://www.legislation.govt.nz/act/public/2012/0024/latest/whole.html'
      when citation.match(/.*Trespass Act 1980.*/)
        'http://www.legislation.govt.nz/act/public/1980/0065/latest/whole.html'
      when match = citation.match(/.* v .*?\[(\d\d\d\d)\] NZHC (\d\d\d\d).*/)
        "#{match[1]}/#{match[2]}"
    if link
      links += "<a target=\"legislation\" href=\"#{link}\">#{citation}</a><br/>\n"
    else
      links += "#{citation}<br/>"
  if links then $(e).html links


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
    write_file_with_template h2_file, h2_heading, h2_content
    sections.push
      section: h2_heading
      file: h2_file

  section_contents = "<ul class=\"contents\">\n"
  sections.forEach (e) ->
    section_contents += "<li><a href=\"#{e.file}\">#{e.section}</a></li>\n"
  section_contents += "</ul>\n"

  main_contents += section_contents + "</li>\n"

  write_file_with_template h1_file, h1_heading, content + section_contents

main_contents += "</ul>"

write_file_with_template 'index.html', 'Problems at School', intro + main_contents

headings = []
['h5', 'h4', 'h3', 'h2', 'h1'].forEach (selector) ->
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

fs.writeFileSync "../www/problems-at-school/headings.json", JSON.stringify(headings, null, 4), 'utf8', error_handler
