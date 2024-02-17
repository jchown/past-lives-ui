<template>
  <v-container>
    <v-col cols="12" md="10">
      <v-row class="pa-4">
        <div class="text-body">
          Many people in the world believe in reincarnation or feel that they have
          lived one or more past lives.
        </div>
      </v-row>
      <v-row class="pa-4">
        <div class="text-body">
          But who might they be? If we know when you were born, maybe we can
          take a guess on who you might have been resurrected from, based on who
          died just before (let's say within a week). We can even take it
          further and see who they were resurrected from, and so on, and so
          on...
        </div>
      </v-row>
      <v-row class="pa-4">
        <div class="text-body">
          Want to see who died just before you were born, and who you may have
          been in a past life? Enter your name and date of birth below to find
          out!
        </div>
      </v-row>

      <v-row>
        <v-sheet elevation="2">
          <v-form v-model="valid">
            <v-container>
              <v-row>
                <v-col>
                  <v-text-field
                    id="name"
                    v-model="name"
                    :rules="nameRules"
                    :counter="10"
                    label="Your Name"
                    autocomplete="on"
                    required
                    hide-details
                  ></v-text-field>
                  <span class="text-subtitle-2 font-weight-light">
                    Your name is used as a random number seed. Use your full
                    name as it was when you were born, so you get completely
                    unique results.
                  </span>
                </v-col>
              </v-row>

              <v-row>
                <v-col>
                  <v-select label="Day" density="compact" v-model="day_of_birth" :items=days v-on:update:model-value="OnSetDOB" />
                </v-col>
                <v-col>
                  <v-select label="Month" density="compact" v-model="month_of_birth" :items=months v-on:update:model-value="OnSetDOB"/>
                </v-col>
                <v-col>
                  <v-text-field
                    density="compact" 
                    id="year-of-birth"
                    v-model="year_of_birth"
                    :rules="yearRules"
                    label="Year"
                    required
                    v-on:update:model-value="OnSetDOB"
                  ></v-text-field>
                </v-col>
              </v-row>

              <v-expansion-panels variant="inset">
                <v-expansion-panel elevation="0" >
                  <v-expansion-panel-title>Options</v-expansion-panel-title>
                  <v-expansion-panel-text>
                    <v-select label="Ensoulment" density="compact" v-model="ensoulment" :items=ensoulmentOptions v-on:update:model-value="OnSetEnsoulment" />
                    <v-checkbox label="Prefer Famous" density="compact" v-model="famous" />
                  </v-expansion-panel-text>
                </v-expansion-panel>
              </v-expansion-panels>

              <v-row>
                <v-col cols="12" md="4" class="pt-8">
                  <v-btn
                    prepend-icon="mdi-calendar-question"
                    :disabled="!valid"
                    @click="OnSubmit"
                    color="primary"
                    >Submit</v-btn
                  >
                </v-col>
              </v-row>

            </v-container>
          </v-form>
        </v-sheet>
      </v-row>
    </v-col>
  </v-container>

  <v-overlay v-model="loading">
    <v-dialog :scrim="false" persistent width="auto" v-model="loading">
      <v-alert color="primary" elevation="2">
        <v-alert-title>Loading...</v-alert-title>
        <v-progress-linear
          indeterminate
          color="white"
          height="10"
          rounded
        ></v-progress-linear>
      </v-alert>
    </v-dialog>
  </v-overlay>

  <v-footer>
    <v-sheet class="text-caption" >
      <div class="pa-4">
        <span class="text-subtitle-2"> Privacy Policy: </span>
        This app collects no user data and no analytics are kept. Source code is
        available on
        <a href="https://github.com/jchown/past-lives-ui">Github</a>. 
        
        Crash reports may be sent to <a href="https://sentry.io">Sentry</a> for debugging purposes, in the event that you manage to break it.
        In this case, your data may be collected by Sentry and processed under <a href="https://sentry.io/legal/dpa/">these terms</a>. Just don't break it, OK?
      </div>
      <div class="pa-4">
        <span class="text-subtitle-2"> Credits: </span>
        Written by <a href="https://www.jasonchown.com">Jason Chown</a> using
        <a href="https://vuetifyjs.com">Vuetify</a>. Triskelion image
        <a
          href="https://en.wikipedia.org/wiki/Triskelion#/media/File:Triple-Spiral-Symbol.svg"
          >from Wikipedia</a
        >. All data is derived from the open
        <a href="https://wikidata.org">Wikidata</a> project (snapshot from
        2023/09/06) and their API is used to render the results. Page ranks are derived from data <a href="https://github.com/athalhammer/danker">generated by Andreas Thalhammer</a> (snapshot from 2023/12/04).
      </div>
      <div class="pa-4">
        <span class="text-subtitle-2"> User Interface: </span>
          {{ versionText }}
      </div>
      <div class="pa-4">
        <span class="text-subtitle-2"> API Version: </span>
          {{ apiVersion }}
      </div>
    </v-sheet>
  </v-footer>
</template>

<script lang="ts">
import { useUserStore } from '../stores/userStore'
const userStore = useUserStore()

export default {
  data: () => ({
    picker: false,
    pickerMode: "calendar" as "keyboard" | "calendar",
    days: Array.from({ length: 31 }, (_, i) => (i + 1).toString()),
    months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
    ensoulment: 'Stoic (at birth)',
    ensoulmentOptions: ['Stoic (at birth)', 'Aristotelian (40 days after conception)', 'Epicurean (at conception)'],
    ensoulmentDays: [0, 240, 280],
    ensoulmentDay: userStore.ensoulmentDay,
    famous: userStore.famous,
    loading: false,
    valid: false,
    name: userStore.name,
    day_of_birth: userStore.dayOfBirth,
    month_of_birth: userStore.monthOfBirth,
    year_of_birth: userStore.yearOfBirth,
    dobDate: new Date(),
    nameRules: [
      (value: any) => {
        if (value) return true;

        return "Please enter your name.";
      },
    ],
    yearRules: [
      (value: any) => {
        if (value) return true;

        return "Please select your birth year.";
      },
    ],
    apiVersion: "Fetching..."
  }),

  mounted() {
    console.log("Home mounted");

    if (this.day_of_birth != "" && this.month_of_birth != "" || this.year_of_birth != "") {
      this.CalcDOBDate();
    }

    // https://x7d98fqunc.execute-api.eu-west-2.amazonaws.com/production/  (original)
    // https://d-a32w1gxg6h.execute-api.eu-west-2.amazonaws.com (custom domain)
    
    fetch("https://past-lives-api.datasmelter.com",
        {
          method: "POST",
          body: JSON.stringify({ "name": "PING", "date": 0, "famous": false }),
        })
        .then(response => response.json().then(data => {
          this.apiVersion = data["id"].substring(7);
        }));
  },

  computed: {
    versionText: function () {
        return process.env.VUE_APP_VERSION;
    },
  },

  methods: {
    OnSetEnsoulment() {
      this.ensoulmentDay = this.ensoulmentDays[this.ensoulmentOptions.indexOf(this.ensoulment)];
      userStore.setDayOfBirth(this.ensoulmentDay);
      console.log("Ensoulment set to: " + this.ensoulment + " (" + this.ensoulmentDay + " days)");
    },

    OnSetDOB() {
      if (this.day_of_birth == "" || this.month_of_birth == "" || this.year_of_birth == "") {
        this.valid = false;
        return;
      }

      userStore.setDayOfBirth(this.day_of_birth);
      userStore.setMonthOfBirth(this.month_of_birth);
      userStore.setYearOfBirth(this.year_of_birth);

      this.CalcDOBDate();
    },

    CalcDOBDate() {
      console.log("DOB set to: " + this.day_of_birth + " " + this.month_of_birth + " " + this.year_of_birth);

      var yi = Number(this.year_of_birth);
      var mi = this.months.indexOf(this.month_of_birth);
      var di = Number(this.day_of_birth);

      console.log("DOB as integers: " + yi + "/" + mi + "/" + di);

      try {
        this.dobDate = new Date(yi, mi, di);
        console.log("Birth date set to: " + this.dobDate.toDateString());
        this.valid = this.name != "";
      } catch (e) {
        this.valid = false;
      }
    },

    OnSubmit() {

      userStore.setName(this.name);
      console.log("Ensoulment days before birth: " + this.ensoulmentDay);

      //  Convert date picked to UNIX epoch day

      let unixTime = this.dobDate.getTime();
      console.log("DOB as UNIX timestamp: " + unixTime / 1000);
      let dateTime = Math.round(unixTime / (24 * 60 * 60 * 1000));

      this.loading = true;

      //setTimeout(() => this.loading = false, 3000)

      this.$router.push({
        name: "Timeline",
        params: {
          name: this.name,
          dob: dateTime,
          ensoulment: this.ensoulmentDay,
          famous: this.famous ? 1 : 0,
        },
      });
    },
  },
};
</script>
