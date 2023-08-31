<template>
  <v-form v-model="valid">
    <v-container>
      <v-row>
        <v-col
          cols="12"
          md="4"
        >
          <v-text-field
            v-model="name"
            :rules="nameRules"
            :counter="10"
            label="Person's Name"
            required
            hide-details
          ></v-text-field>
        </v-col>
        </v-row>

        <v-row>
        <v-col
          cols="12"
          md="4"
        >
        <v-text-field
            v-model="dob"
            :rules="dobRules"
            :counter="10"
            label="Date of Birth"
            required
            :readonly=true
            hide-details
          ></v-text-field>

        <!--v-date-picker></v-date-picker-->
        </v-col>

        <v-col
          cols="4"
          md="4"
        >
          <v-btn
          @click="dialog = true"
          >Pick</v-btn>
        
        </v-col>

      </v-row>

        <v-row>
        <v-col
          cols="12"
          md="4"
        >
          <v-btn
            prepend-icon="$vuetify"
          >Submit</v-btn>
        </v-col>
      </v-row>
    </v-container>
  </v-form>

  <v-dialog
      v-model="dialog"
      width="auto"
    >
    <v-card>
        <v-date-picker
        v-model="date_picked"
        @click:save="OnDatePicked"
        @click:cancel="dialog = false"
        ></v-date-picker>
    </v-card>
  </v-dialog>
  
</template>

<script lang="ts">
import { off } from 'process';

export default {
  data: () => ({
    dialog: false,
    valid: false,
    name: "",
    date_picked: undefined,
    dob: "",
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
  methods: {
    OnDatePicked() {
      this.dialog = false; 
      this.$nextTick(() => {
        if (this.date_picked != null)
          this.dob = (this.date_picked as Date).toDateString();
      });
    },
  },
};
</script>