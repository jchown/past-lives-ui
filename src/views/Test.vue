<template>

  <v-container>
    <v-row>
      <v-col cols="4" md="4">
        <v-btn @click="dialog = true">Pick</v-btn>
      </v-col>
    </v-row>
  </v-container>

  <v-dialog v-model="dialog" persistent>
    <v-date-picker scrollable @click:cancel="dialog = false" />
  </v-dialog>

</template>

<script lang="ts">

export default {
  data: () => ({
    dialog: false,
  }),
};

</script>