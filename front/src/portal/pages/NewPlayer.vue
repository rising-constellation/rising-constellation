<template>
  <no-navbar-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <section
          class="panel-aside-info"
          v-html="$tmd('page.newplayer.welcome')" />

        <section
          class="panel-aside-info"
          v-html="$tmd('page.newplayer.earlyaccess')" />

        <hr class="margin">
      </v-scrollbar>

      <profile-detail />
    </div>
  </no-navbar-layout>
</template>

<script>
import NoNavbarLayout from '@/portal/layouts/NoNavbar.vue';

import ProfileDetail from '@/portal/pages/profile/Detail.vue';

export default {
  name: 'new-player',
  components: {
    NoNavbarLayout,
    ProfileDetail,
  },
};
</script>
