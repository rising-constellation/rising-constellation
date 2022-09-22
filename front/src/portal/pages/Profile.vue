<template>
  <default-layout>
    <div class="fluid-panel is-not-full-sized">
      <v-scrollbar class="panel-aside">
        <section
          class="panel-aside-info"
          v-html="$tmd('page.profile.description')">
        </section>

        <hr class="margin">
      </v-scrollbar>

      <router-view></router-view>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';

export default {
  name: 'profile',
  components: {
    DefaultLayout,
  },
};
</script>
