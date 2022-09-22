<template>
  <default-layout>
    <div class="fluid-panel is-not-full-sized">
      <v-scrollbar class="panel-aside">
        <section class="panel-aside-links">
          <router-link to="/account/info">
            {{ $t('page.account.info') }}
          </router-link>

          <router-link
            v-show="!account.steam_id"
            to="/account/password">
            {{ $t('page.account.password') }}
          </router-link>

          <router-link
            v-show="isSteam && canBeBound"
            to="/account/bind-web">
            {{ $t('page.account.bind_web') }}
          </router-link>
        </section>

        <hr class="margin">
      </v-scrollbar>

      <router-view></router-view>

      <v-scrollbar class="panel-aside">
        <div v-if="loaded">
          <section class="panel-aside-list-tuple">
            <h2>{{ $t('page.account.logs') }}</h2>
            <ul>
              <li
                v-for="log in logs"
                :key="log.id">
                <span class="main">{{ $t(`log_action.${log.action}`) }}</span>
                <span class="secondary">{{ log.date | datetime-short }}</span>
              </li>
            </ul>
          </section>

          <hr class="margin">
        </div>
        <loading-mask v-else />
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import Loading from '@/portal/mixins/Loading';

import DefaultLayout from '@/portal/layouts/Default.vue';
import LoadingMask from '@/portal/components/LoadingMask.vue';
import config from '@/config';

export default {
  name: 'account',
  mixins: [Loading],
  data() {
    return {
      isSteam: config.IS_STEAM,
      logs: [],
    };
  },
  computed: {
    account() { return this.$store.state.portal.account; },
    canBeBound() { return !this.account.email; },
  },
  methods: {
    async loadData() {
      const { data } = await this.releaseLoading(this.$axios.get(`/logs/${this.account.id}`));
      this.logs = data;
    },
  },
  mounted() {
    this.loadData();
  },
  components: {
    DefaultLayout,
    LoadingMask,
  },
};
</script>
