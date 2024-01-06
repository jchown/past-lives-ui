<template>
  <v-container>
    <v-timeline
      align="start"
      side="end"
      class="h-auto"
    >
      <v-timeline-item
        v-for="item in items"
        :key="item.id"
        :dot-color="item.dot_color"
        :icon="item.dot_icon"
        :id="item.id"
        min-width="60%"
        elevation="3"
      >
        <template v-slot:opposite v-if="item.type != 'Fin' && !isMobile()">
          {{ item.date }}
        </template>

        <template v-if="item.type != 'Fin' && isMobile()">
          <div style="margin-bottom: 4px; font-size: small">
            {{ item.date }}
          </div>
        </template>

        <div v-if="item.type == 'Died'">
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
                <v-card-text v-if="item.extract != null">
                  <div v-for="(text, index) in item.extract.split('\n')" :key="index" style="font-size: small; color: rgb(var(--v-theme-on-accent)) !important; margin-bottom: 12px;">
                    {{ text }}
                  </div>
                </v-card-text>
              </div>
              <div v-if="item.image != null">
                <img
                  :src="item.image"
                  style="border-radius: 8px; height: 125px; margin: 20px"
                />
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
          <v-alert
            :value="true"
            :color="item.color"
            :icon="item.icon"
            elevation="4"
          >
            <span v-html="summary(item)" v-if="item.type != 'Fin'" />

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

const EventType = {
  Born: "Born",
  Conceived: "Conceived",
  Ensouled: "Ensouled",
  Died: "Died",
  Fin: "Fin"
}

const DELAY_NEXT_MS = 100
const DELAY_BORN_MS = 10
const DELAY_ENSOULMENT_MS = 2

export default {

  data: () => ({
    items: [],
    ensoulment: 0,
    famous: false
  }),

  created() {
    this.$watch(
      () => this.$route.params,
      (toParams, previousParams) => {
        
        if (toParams.dob == undefined)  // Different route
          return

        if (toParams !== previousParams)
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

      this.$data.ensoulment = parseInt(this.$route.params['ensoulment'])
      this.$data.famous = parseInt(this.$route.params['famous']) == 1
      this.items = []

      var dob = Number(this.$route.params['dob'])
      var name = (this.$route.params['name'])

      console.log("Building timeline for " + name + ", born " + dob + ", ensoulment " + this.$data.ensoulment + " - prefer famous " + this.$data.famous)

      this.addBorn(name, dob, Date.now())
    
      this.$nextTick(() => {
        this.buildNext(name, (dob - 0).toString(), Date.now() + 2000)
      })
    },

    addBorn: function(name, dob, showTime) {

      this.showItem({
            type: EventType.Born,
            id: 0,
            dot_color: 'info',
            dot_icon: 'mdi-calendar',
            color: 'info',
            icon: 'mdi-star',
            date: shared.toDateString(dob),
            name: name
      }, showTime)
      
      if (this.ensoulment != 0) {
        this.showItem({
            type: this.ensoulment == 240 ? EventType.Ensouled : EventType.Conceived,
            id: 0,
            dot_color: 'info2',
            dot_icon: 'mdi-calendar-today',
            color: 'info2',
            icon: 'mdi-star-circle',
            date: shared.toDateString(dob - this.ensoulment),
            name: name
        }, showTime + DELAY_ENSOULMENT_MS)
      }
    },

    capitalise: function (item) {
      if (item == undefined)
        return undefined

      return item.charAt(0).toUpperCase() + item.slice(1)
    },

    summary: function (item) {

      switch (item.type) {
        case EventType.Born:
          return item.name + " was born."
        case EventType.Conceived:
          return item.name + " was conceived."
        case EventType.Ensouled:
          return item.name + " was ensouled."
        case EventType.Died:
          if (item.link != null)
            return "<a href='" + item.link + "'>" + item.name + "</a>" + died
          return item.name + " died."
        case EventType.Fin:
          return "No more data available."
      }
    },

    showFin: function (showTime) {
      var fin = {
        type: "Fin",
        color: 'light-grey',
        dot_icon: 'mdi-calendar-question',
        dot_color: 'grey',
        description: "No more data available.",
      }
      this.showItem(fin, showTime)
    },

    buildNext: function (name, dod, showTime, life = 0) {

      fetch("https://x7d98fqunc.execute-api.eu-west-2.amazonaws.com/production/",
        {
          method: "POST",
          body: JSON.stringify({ "name": name, "date": dod - this.$data.ensoulment, "famous": this.$data.famous }),
        })
        .then(response => response.json())
        .then(choice => {

          if (choice.id === "") {
            console.log("Nobody famous...")
            this.showFin(showTime);
            return
          }

          console.log(choice);

          dod = choice.dateOfDeath
          var id = choice.id
          var dob = choice.dateOfBirth
          
          fetch("https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=" + id + "&origin=*", { method: "GET" })
            .then(response1 => response1.json())
            .then(data => {
              
              var name = this.getValue(data.entities[id].labels)
              var description = this.getValue(data.entities[id].descriptions)
              var image = this.getImage(data.entities[id].claims)
              var link = this.getSitePage(id, data.entities[id].sitelinks)
              var pageName = link.substring(link.lastIndexOf('/') + 1)

              fetch("https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=" + pageName + "&origin=*", { method: "GET" })
                .then(response2 => response2.json())
                .then(extractJson => {

                  var extract = null
                  try {
                    var pageId = Object.keys(extractJson.query.pages)[0]
                    extract = extractJson.query.pages[pageId].extract
                  }
                  catch (error) {
                  }

                  var died = {
                    type: EventType.Died,
                    id: this.$data.items.length,
                    color: 'info',
                    dot_icon: 'mdi-calendar-text',
                    dot_color: 'grey',
                    icon: 'mdi-book-variant',
                    date: shared.toDateString(Number(dod)),
                    name: name,
                    description: description,
                    extract: extract,
                    link: link,
                    linkText: link.indexOf("wikidata") > -1 ? "Wikidata" : "Wikipedia",
                    age: this.getAge(Number(dod) - Number(dob)),
                    image: image
                  }

                  this.showItem(died, showTime)

                  this.addBorn(name, dob, showTime + DELAY_BORN_MS)

                  dod = (dob - 1).toString()

                  this.buildNext(name, dod, showTime + DELAY_NEXT_MS, life + 1)
                })
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