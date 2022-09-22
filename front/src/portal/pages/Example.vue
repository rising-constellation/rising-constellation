<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        Panel 1
        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content">
        <div class="close-button">
          Fermer
        </div>

        <div class="toolbar">
          Toolbar
        </div>

        <v-scrollbar class="content">
          Contenu
          <hr class="margin">
        </v-scrollbar>
      </div>

      <v-scrollbar class="panel-aside">
        Panel 2
        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';

export default {
  name: 'play',
  data() {
    return {
      // ...
    };
  },
  components: {
    DefaultLayout,
  },
};
</script>
