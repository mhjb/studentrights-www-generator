const builder = require('xmlbuilder')


const url_template = (loc, lastmod) => ({
  url: {
    loc: { '#text': loc },
    lastmod: { '#text': lastmod }
  }
})

 
const sitemap_template = urls => ({
  urlset: {
    '@xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9',
    x: urls.map(url_template)
    // url: {
    //   loc: { '#text': 'http://www.example.com/' },
    //   lastmod: { '#text': '2005-01-01' }, 
    // }
  }
})

urls = [
  {
    loc: 'http://google.com',
    lastmod: '2019-19-11'
  },
  {
    loc: 'https://google.com',
    lastmod: '2019-19-11'
  },
]


const sitemap = builder.create(sitemap_template(urls), { 'encoding': 'utf-8' }).end({ pretty: true})

console.log(sitemap)
