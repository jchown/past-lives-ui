<template>
  <v-container>
    <v-timeline align="start" side="end" class="h-auto" density="{{ timelineDensity() }}">
      <v-timeline-item
        v-for="item in items"
        :key="item.id"
        :dot-color="item.dot_color"
        :icon="item.dot_icon"
        :id="item.id"
        min-width="60%"
        elevation="3"
      >
        <template v-slot:opposite v-if="!item.fin && !isMobile()">
          {{ item.date }}
        </template>

        <template v-if="!item.fin && isMobile()">
          <div style="margin-bottom: 4px; font-size: small;">{{ item.date }}</div>
        </template>

        <div v-if="item.died">
          <v-card color="accent" max-width="100%" elevation="8">
                <v-card-title style="">
                  <v-icon left>{{ item.icon }}</v-icon>
                  {{ item.name }}
                </v-card-title>
            <div class="d-flex flex-no-wrap justify-space-between">
              <div>
                <v-card-subtitle max-width="60%">
                  {{ capitalise(item.description) }}
                </v-card-subtitle>
                <v-card-text> Died aged {{ item.age }} </v-card-text>
              </div>
              <div v-if="item.image != null">
                <img :src="item.image" style="border-radius: 8px; height: 125px; margin: 20px;" />
              </div>
            </div>
                <v-card-actions>
                  <v-btn
                    text
                    color="#3281FF"
                    v-if="item.link != null"
                    :href="item.link"
                    >{{ item.linkText }}</v-btn
                  >
                </v-card-actions>
          </v-card>
        </div>

        <div v-else>
          <v-alert :value="true" :color="item.color" :icon="item.icon" elevation="4">
            <span v-html="summary(item)" v-if="!item.fin" />

            <div>
              {{ capitalise(item.description) }}
            </div>
          </v-alert>
        </div>
      </v-timeline-item>
    </v-timeline>
  </v-container>
</template>

<script lang="js">

import shared from "../shared"
import { useDisplay } from 'vuetify'

export default {

  data: () => ({
    items: [],
    ensoulment: "",
    ensoulmentEvent: ""
  }),

  created() {
    this.$watch(
      () => this.$route.params,
      (toParams, previousParams) => {
        
        if (toParams.dob == undefined)  // Different route
          return

        this.buildTimeline()  // Respond to param changes
      }
    )
  },

  mounted: function () {
    this.buildTimeline()
  },

  methods: {

    isMobile: function() {
      return screen.width <= 760
    }, 

    timelineDensity: function() {
      if (this.isMobile())
        return "dense";
      else
        return "default";
    },

    buildTimeline: function () {
      this.items = [
        {
          died: false,
          id: 0,
          dot_color: 'info',
          dot_icon: 'mdi-calendar',
          color: 'info',
          icon: 'mdi-star',
          date: '',
          name: ''
        },
      ]
      var dob = Number(this.$route.params['dob'])
      var name = (this.$route.params['name'])
      this.$data.ensoulment = parseInt(this.$route.params['ensoulment'])

      switch (this.$data.ensoulment) {
        case 0:
          this.$data.ensoulmentEvent = " was born."
          break
        case 240:
          this.$data.ensoulmentEvent = " was ensouled."
          break
        case 280:
          this.$data.ensoulmentEvent = " was conceived."
          break
        default:
          throw "Invalid ensoulment: " + this.$data.ensoulment
      }

      this.$data.items[0].date = shared.toDateString(dob)
      this.$data.items[0].name = name

      this.$nextTick(() => {
        this.buildNext(name, (dob - 0).toString(), Date.now() + 2000)
      })
    },

    capitalise: function (item) {
      if (item == undefined)
        return undefined

      return item.charAt(0).toUpperCase() + item.slice(1)
    },

    summary: function (item) {
      if (!item.died)
        return item.name + this.$data.ensoulmentEvent;

      var died = " died."

      if (item.link != null)
        return "<a href='" + item.link + "'>" + item.name + "</a>" + died

      return item.name + died
    },

    buildNext: function (name, dod, showTime, life = 0) {

      console.log("Fetching for day " + dod + "/" + this.$data.ensoulment)

      fetch("https://x7d98fqunc.execute-api.eu-west-2.amazonaws.com/production/",
        {
          method: "POST",
          body: JSON.stringify({ "name": name, "dateOfBirth": dod - this.$data.ensoulment }),
        })
        .then(response => response.json())
        .then(choice => {

          if (choice.id === "") {
            var fin = {
              fin: true,
              color: 'light-grey',
              dot_icon: 'mdi-calendar-question',
              dot_color: 'grey',
              description: "No more data available.",
            }
            this.showItem(fin, showTime)
            console.log("Nobody famous...")
            return
          }

          console.log(choice);

          dod = choice.dateOfDeath
          var id = choice.id
          var dob = choice.dateOfBirth

          fetch("https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=" + id + "&origin=*",
            { method: "GET" })
            .then(response => response.json())
            .then(json => {

              console.log(json);

              var name = this.getValue(json.entities[id].labels)
              var description = this.getValue(json.entities[id].descriptions)
              var image = this.getImage(json.entities[id].claims)
              var link = this.getSitePage(id, json.entities[id].sitelinks)

              var died = {
                died: true,
                id: this.$data.items.length,
                color: 'info',
                dot_icon: 'mdi-calendar',
                dot_color: 'grey',
                icon: 'mdi-book-variant',
                date: shared.toDateString(Number(dod)),
                name: name,
                description: description,
                link: link,
                linkText: link.indexOf("wikidata") > -1 ? "Wikidata" : "Wikipedia",
                age: this.getAge(Number(dod) - Number(dob)),
                image: image
              }

              this.showItem(died, showTime)

              var born = {
                died: false,
                id: this.$data.items.length,
                color: 'info',
                dot_icon: 'mdi-calendar',
                dot_color: 'info',
                icon: 'mdi-star',
                date: shared.toDateString(dob),
                name: name
              }

              this.showItem(born, showTime + 100)

              dod = (dob - 1).toString()

              this.buildNext(name, dod, showTime + 5000, life + 1)
        })
      })
    },
    showItem(item, showTime) {
      setTimeout(() => {
        this.$data.items.push(item)
        this.$nextTick(() => {
          var element = document.getElementById(item.id)
          if (element != null)
            element.scrollIntoView({ behavior: "smooth" })
        })
      }, showTime - Date.now())
    },
    getValue: function (values) {
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

      for (var key in values) {
        return values[key].value
      }
    },
    getSitePage: function (id, sitelinks) {
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
      for (var key in sitelinks) {
        if (key == "commonswiki")
          continue

        var subdomain = key.substring(0, key.indexOf("wiki"))
        return "https://" + subdomain + ".wikipedia.org/wiki/" + sitelinks[key].title
      }

      return "https://www.wikidata.org/wiki/" + id
    },
    getImage: function (claims) {
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
    getAge: function (daysAlive) {
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