<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <section class="panel-aside-links">
          <router-link to="/create/maps">
            {{ $t('page.create.maps') }}
          </router-link>
          <router-link to="/create/scenarios">
            {{ $t('page.create.scenarios') }}
          </router-link>
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
  name: 'create',
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
