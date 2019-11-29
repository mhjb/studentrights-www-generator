fs = require 'fs'
pretty = require 'pretty'


{ path } = process.env

template = fs.readFileSync 'templates/template.html'


module.exports = 
  write_file_with_template: (filename, title, content, prev, next) ->
    populated_template = template.toString()
      .replace /{{title}}/, title
      .replace /{{book}}/, content
    if prev
      populated_template = populated_template
        .replace /{{prev}}/g, prev
        .replace /{{#if}}(.*){{\/if}}/g, '$1'
    else
      populated_template = populated_template.replace /{{#if}}.*{{prev}}.*{{\/if}}/, ''
    if next
      populated_template = populated_template
        .replace /{{next}}/g, next
        .replace /{{#if}}(.*){{\/if}}/g, '$1'
    else
      populated_template = populated_template.replace /{{#if}}.*{{next}}.*{{\/if}}/, ''

    prettified = pretty populated_template, ocd: true

    fs.writeFile path + filename, prettified, 'utf8', console.error
    console.log "Writing #{path}#{filename}"