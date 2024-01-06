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
          But who might they be? As we know when you were born, maybe we can
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
                  <v-text-field
                    id="date=of-birth"
                    v-model="dob"
                    :rules="dobRules"
                    :counter="10"
                    label="Date of Birth"
                    required
                    :readonly="true"
                    @click="OpenDatePicker('keyboard')"
                    hide-details
                  ></v-text-field>
                  <span class="text-subtitle-2 font-weight-light">
                    Your date of birthday is needed to calculate the past lives.
                  </span>
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

            <v-dialog v-model="picker" persistent>
              <v-date-picker
                v-model="date_picked"
                class="elevation-1"
                :input-mode="pickerMode"
                input-placeholder="mm/dd/yyyy"
                scrollable
                @click:save="OnDatePicked"
                @click:cancel="picker = false"
              ></v-date-picker>
            </v-dialog>
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
        <span class="text-subtitle-2"> Version: </span>
          {{ versionText }}
      </div>
    </v-sheet>
  </v-footer>
</template>

<script lang="ts">
export default {
  data: () => ({
    picker: false,
    pickerMode: "calendar" as "keyboard" | "calendar",
    ensoulment: 'Stoic (at birth)',
    ensoulmentOptions: ['Stoic (at birth)', 'Aristotelian (40 days after conception)', 'Epicurean (at conception)'],
    ensoulmentDays: [0, 240, 280],
    ensoulmentDay: 0,
    famous: true,
    loading: false,
    valid: false,
    name: "",
    date_picked: undefined,
    dob: "",
    dobDate: new Date(),
    nameRules: [
      (value: any) => {
        if (value) return true;

        return "Please enter your name.";
      },
    ],
    dobRules: [
      (value: any) => {
        if (value) return true;

        return "Please select your birth date.";
      },
    ],
  }),

  mounted() {
    console.log("Home mounted");
  },

  computed: {
    versionText: function () {
        return process.env.VUE_APP_VERSION;
    },
  },

  methods: {
    OnSetEnsoulment() {
      this.ensoulmentDay = this.ensoulmentDays[this.ensoulmentOptions.indexOf(this.ensoulment)];
      console.log("Ensoulment set to: " + this.ensoulment + " (" + this.ensoulmentDay + " days)");
    },

    OpenDatePicker(inputMode: "keyboard" | "calendar") {
      this.pickerMode = inputMode;
      this.picker = true;
    },

    OnDatePicked() {
      this.picker = false;
      this.$nextTick(() => {
        console.log("Date picked: " + this.date_picked);

        if (this.date_picked != null) this.dobDate = this.date_picked as Date;
        this.dob = this.dobDate.toDateString();
      });
    },

    OnSubmit() {
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
