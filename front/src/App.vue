<template>
  <div id="app">
    <app-loading
      v-if="loading"
      @loaded="loading = false" />

    <template v-else>
      <div
        v-if="isInMaintenance"
        class="maintenance">
        <div class="maintenance-content">
          {{ $t('loading_messages.ongoing_maintenance') }}
        </div>

        <div
          class="exit-button"
          @click="logout">
          {{ $t('page.menu.exit') }}
        </div>
      </div>

      <transition :name="transition">
        <router-view />
      </transition>
    </template>
  </div>
</template>

<script>
import '@/styles/main.scss';

import { mapState } from 'vuex';
import AppLoading from '@/portal/components/AppLoading.vue';

export default {
  name: 'App',
  data() {
    return {
      transition: 'default',
      loading: true,
    };
  },
  computed: mapState('portal', [
    'isInMaintenance',
  ]),
  watch: {
    // eslint-disable-next-line
    '$route'(to, from) {
      this.transition = from.name === null || from.name === 'menu'
        ? 'menu' : 'default';
    },
  },
  methods: {
    logout() {
      this.$store.dispatch('portal/logout');
    },
  },
  components: { AppLoading },
};
</script>
