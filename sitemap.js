const { SitemapStream, streamToPromise } = require('sitemap')
const pretty = require('pretty')


/** Takes an array of urls, returns a sitemap xml. Url's lastmods are set to today's date */
module.exports = urls => new Promise((resolve, reject) => {
  const sitemap = new SitemapStream({ hostname: 'https://studentrights.nz' })
  const today = new Date()
  urls.forEach(url => sitemap.write({ url: 'problems-at-school/' + url, lastmod: today }))
  sitemap.end()
  streamToPromise(sitemap)
    .then(sm => resolve(pretty(sm.toString())))
    .catch(reject)
})
