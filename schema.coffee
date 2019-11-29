# Applies https://search.google.com/test/rich-results?utm_campaign=devsite&utm_medium=microdata&utm_source=faq-page

extend_cheerio = require('./extend_cheerio')

module.exports =
  schematize: (page_content, $) ->
    extend_cheerio $

    page_content.filter('h4').each (i, e) ->
      $(e).attr('itemprop', 'name')       # add to heading
      $(e).nextUntil('h4,h3,h2,h1')
        .wrapAll('<div itemprop="text"></div>')
      $(e).nextUntil('h4,h3,h2,h1')
        .wrapAll('<div itemscope itemprop="acceptedAnswer" itemtype="https://schema.org/Answer"></div>')
      $(e).nextUntil('h4,h3,h2,h1').addBack()
        .wrapAll('<div itemscope itemprop="mainEntity" itemtype="https://schema.org/Question"></div>')
