<template>
  <v-timeline align="start" side="end">
    <v-timeline-item
      v-for="item in items"
      :key="item.id"
      :dot-color="item.dot_color"
      icon="mdi-calendar"
    >
      <template v-slot:opposite>
        {{ item.date }}
      </template>

      <div v-if="item.died">
        <v-card>
          <div class="d-flex flex-no-wrap justify-space-between">
            <div>
              <v-card-title>
                <v-icon left>{{ item.icon }}</v-icon>
                {{ item.name }}
              </v-card-title>
              <v-card-subtitle>
                {{ capitalise(item.description) }}
              </v-card-subtitle>
              <v-card-text> Died aged {{ item.age }} </v-card-text>
              <v-card-actions>
                <v-btn
                  text
                  color="primary"
                  v-if="item.link != null"
                  :href="item.link"
                  >Wikipedia</v-btn
                >
              </v-card-actions>
            </div>
            <div v-if="item.image != null">
              <v-avatar class="ma-3" size="125" rounded="0">
                <v-img :src="item.image" />
              </v-avatar>
              </div>
          </div>
        </v-card>
      </div>

      <div v-else>
        <v-alert :value="true" :color="item.color" :icon="item.icon">
          <span v-html="summary(item)"></span>

          <div>
            {{ capitalise(item.description) }}
          </div>
        </v-alert>
      </div>
    </v-timeline-item>
  </v-timeline>
</template>

<script lang="js">

  import shared from "../shared"

  import deadPeople from "../assets/dead-people-min.json"

  export default {
    data: () => ({
      items: [
        {
          died: false,
          id: 0,
          dot_color: 'info',
          color: 'info',
          icon: 'mdi-star',
          date: '',
          name: '',
        },
      ],
    }),
    mounted: function () {

      var dob = Number(this.$route.params['dob'])
      var name = (this.$route.params['name'])

      this.$data.items[0].date = shared.toDateString(dob)
      this.$data.items[0].name = name

      this.$nextTick(() => {

        var numDates = 0
        var numPeople = 0
        for(var date in deadPeople) {
          ++numDates
          numPeople += deadPeople[date].length
        }

        console.log(numDates + " dates of death for " + numPeople + " people.")

        this.getNext((dob - 0).toString())
      })
    },
    methods: {
      capitalise: function(item) {
        if (item == undefined)
          return undefined

        return item.charAt(0).toUpperCase() + item.slice(1)
      },
      summary: function(item) {
        if (!item.died)
          return item.name + " was born."

        var died = " died."

        if (item.link != null)
          return "<a href='" + item.link + "'>" + item.name + "</a>" + died

        return item.name + died
      },
      getNext: function(dod) {

        var next = undefined
        for (var i = 0; i < 5 && next == undefined; ++i) {

          console.log("Finding who died on " + dod + " (" + shared.toDateString(Number(dod)) + ")")

          next = deadPeople[dod]
          if (next == undefined)
            dod = (Number(dod) - 1).toString()
        }

        if(next == undefined) {
            console.log("Nobody famous...")
            return
          }
    
        var id = next[0].id

        fetch("https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=" + id + "&origin=*",
        { method: "GET" })
        .then(response => response.json())
        .then(json => {

          console.log(json);
          
          var name = this.getValue(json.entities[id].labels)
          var description = this.getValue(json.entities[id].descriptions)
          var dob = next[0].born
          var image = this.getImage(json.entities[id].claims)

          var died = {
            died: true,
            id: this.$data.items.length,
            color: 'info',
            dot_color: 'grey',
            icon: 'mdi-book-variant',
            date: shared.toDateString(Number(dod)),
            name: name,
            description: description,
            link: this.getSitePage(json.entities[id].sitelinks),
            age: this.getAge(Number(dod) - Number(dob)),
            image: image,
          }
      
          this.$data.items.push(died)

          var born = {
            died: false,
            id: this.$data.items.length,
            color: 'info',
            dot_color: 'info',
            icon: 'mdi-star',
            date: shared.toDateString(dob),
            name: name,
          }
      
          this.$data.items.push(born)
      
          dod = (dob - 1).toString()

          this.getNext(dod)
        })
      },
      getValue: function(values) {
        if (values == undefined)
          return "???"

        try {
          return values.en.value
        }
        catch (error) {
        }
        try {
          return values.fr.value
        }
        catch (error) {
        }
        try {
          return values.de.value
        }
        catch (error) {
        }

        for(var key in values) {
          return values[key].value
        }
      },
      getSitePage: function(sitelinks) {
        if (sitelinks == undefined)
          return undefined

        try {
          return "https://en.wikipedia.org/wiki/" + sitelinks.enwiki.title
        }
        catch (error) {
        }
        try {
          return "https://fr.wikipedia.org/wiki/" + sitelinks.frwiki.title
        }
        catch (error) {
        }
        try {
          return "https://de.wikipedia.org/wiki/" + sitelinks.dewiki.title
        }
        catch (error) {
        }
        try {
          return "https://es.wikipedia.org/wiki/" + sitelinks.eswiki.title
        }
        catch (error) {
        }
        for(var key in sitelinks) {
          if (key == "commonswiki")
            continue

          var subdomain = key.substring(0, key.indexOf("wiki"))
          return "https://" + subdomain + ".wikipedia.org/wiki/" + sitelinks[key].title
        }
      },
      getImage: function(claims) {
        if (claims == undefined)
          return undefined

        try {
          var image = claims.P18[0].mainsnak.datavalue.value
          return "https://commons.wikimedia.org/wiki/Special:FilePath/" + image
        }
        catch (error) {
          return undefined
        }
      },
      getAge: function(daysAlive) {
        var age = ""
        if (daysAlive > 364) {
          var years = Math.floor(daysAlive / 365)
          age += years + " year"
          if (years > 1)
            age += "s"
          daysAlive -= years * 365
        }

        if (daysAlive > 29) {
          var months = Math.floor(daysAlive / 30)
          if (age != "")
            age += ", "
          age += months + " month"
          if (months > 1)
            age += "s"
          daysAlive -= months * 30          
        }

        if (daysAlive > 0) {
          age += " and " + daysAlive + " day"
          if (daysAlive > 1)
            age += "s"
        }

        return age
      }
    }
  };

</script>