<template>
  <v-app-bar :elevation="2" class="banner">
    <v-app-bar-title class="title">
      <img src="@/assets/triskelion.png" alt="Triskelion" height="32" width="32" style="margin-right: 12px;"/>
      <span>
        <router-link to="/" style="text-decoration: none; color: inherit; font-size: 32pt;">Past Lives</router-link>
      </span>
    </v-app-bar-title>
  </v-app-bar>
</template>

<script lang="ts" setup>

</script>

<style scoped>
.banner {
  height: 60px;
}
</style>