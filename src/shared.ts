export default {
    formatter: new Intl.DateTimeFormat('en-GB', { dateStyle: 'full', timeZone: 'UTC' }),
    
    toDateString: function(unixDay: number) {
        return this.formatter.format(new Date(unixDay * (24 * 60 * 60 * 1000)))
    },

    hashString: function(str: string) {
        let hash = 0;
        for (let i = 0, len = str.length; i < len; i++) {
            let chr = str.charCodeAt(i);
            hash = (hash << 5) - hash + chr;
            hash |= 0; // Convert to 32bit integer
        }
        return hash;
    }
    
}