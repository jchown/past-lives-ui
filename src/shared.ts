export default {
    formatter: new Intl.DateTimeFormat('en-GB', { dateStyle: 'full', timeZone: 'UTC' }),
    toDateString: function(unixDay: number) {
        return this.formatter.format(new Date(unixDay * (24 * 60 * 60 * 1000)))
      }
}