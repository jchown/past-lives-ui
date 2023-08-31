<template>
  <v-timeline side="end">
    <v-timeline-item
      v-for="item in items"
      :key="item.id"
      :dot-color="item.color"
      size="small"
    >
      <template v-slot:opposite>
        {{ item.date }}
      </template>

      <v-alert :value="true" :color="item.color" :icon="item.icon">
        {{ item.text }}
      </v-alert>
    </v-timeline-item>
  </v-timeline>
</template>

<script lang="js">

  import shared from "../shared"

  import deadPeople from "../assets/dead-people.json"

  export default {
    data: () => ({
      items: [
        {
          id: 0,
          color: 'info',
          icon: 'mdi-information',
          date: '',
          text: '',
        },
      ],
    }),
    mounted: function () {

      var dob = Number(this.$route.params['dob'])
      var name = (this.$route.params['name'])

      this.$data.items[0].date = shared.toDateString(dob)
      this.$data.items[0].text = name + " was born."

      this.$nextTick(() => {

        var numDates = 0
        var numPeople = 0
        for(var date in deadPeople) {
          ++numDates
          numPeople += deadPeople[date].length
        }

        console.log(numDates + " dates of death for " + numPeople + " people.")

        this.getNext((dob - 1).toString())
      })
    },
    methods: {
      getNext: function(dod) {

        while (true) {
          console.log("Finding who died on " + shared.toDateString(Number(dod)))

          var next = deadPeople[dod]
          if(next == undefined) {
            console.log("Nobody famous...")
            return
          }
      
          var id = next[0].id

          fetch("https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=" + id + "&sitefilter=enwiki&origin=*",
          { method: "GET" })
          .then(response => response.json())
          .then(json => {

            console.log(json);
            
            var name = json.entities[id].labels.en.value
            var description = json.entities[id].description.en.value
            var dob = next[0].born

            var died = {
              id: this.$data.items.length,
              color: 'info',
              icon: 'mdi-information',
              date: shared.toDateString(Number(dod)),
              text: name + " died.",
              subtitle: description,
            }
        
            this.$data.items.push(died)

            var born = {
              id: this.$data.items.length,
              color: 'info',
              icon: 'mdi-information',
              date: shared.toDateString(dob),
              text: name + " was born.",
            }
        
            this.$data.items.push(born)
        
            dod = (dob - 1).toString()
          })
          .catch(error => { console.log("Error: " + error.message); });
        }
      }
    }
  };

</script>