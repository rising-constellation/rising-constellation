<template>
  <div class="app-loading">
    <div class="app-loading-content">
      <div
        class="app-loading-item"
        :class="{
          'pending': hasConnectivity === null,
          'failed': hasConnectivity === false,
          'success': hasConnectivity === true,
        }">
        {{ $t('loading_messages.connectivity_check') }}
      </div>
      <div
        class="app-loading-item"
        :class="{
          'pending': isInMaintenance === null,
          'failed': isInMaintenance === true,
          'success': isInMaintenance === false,
        }">
        {{ $t('loading_messages.maintenance_check') }}
      </div>
      <div
        v-show="isSteam"
        class="app-loading-item failed"
        :class="{
          'pending': hasCorrectVersion === null,
          'failed': hasCorrectVersion === false,
          'success': hasCorrectVersion === true,
        }">
        {{ $t('loading_messages.version_check') }}
        <span
          v-show="hasCorrectVersion === false"
          class="info">
          {{ $t('loading_messages.outdated_client') }}
        </span>
      </div>
      <div
        class="app-loading-item"
        :class="{
          'pending': isSignedIn === null,
          'failed': isSignedIn === false,
          'success': isSignedIn === true,
        }">
        {{ $t('loading_messages.signin') }}
      </div>
    </div>

    <div
      class="exit-button"
      @click="logout">
      {{ $t('page.menu.exit') }}
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import { maintenanceCheck, versionCheck, connectivityCheck } from '@/utils/loader';
import config from '@/config';
// import { steamInit, steamTicket, steamAuth } from '../../../steam-libs';

const redirectDelay = 3000;

export default {
  name: 'app-loading',
  data() {
    return {
      isSteam: config.IS_STEAM,
      redirectDelay: config.MODE === 'production' ? redirectDelay : 0,
    };
  },
  computed: mapState('portal', [
    'isSignedIn',
    'isInMaintenance',
    'hasCorrectVersion',
    'hasConnectivity',
  ]),
  async mounted() {
    const start = Date.now();
    try {
      await Promise.all([
        this.$store.dispatch('portal/initLanguage'),
        maintenanceCheck().then((isInMaintenance) => { this.$store.commit('portal/isInMaintenance', isInMaintenance); }),
        versionCheck().then((hasCorrectVersion) => { this.$store.commit('portal/hasCorrectVersion', hasCorrectVersion); }),
        connectivityCheck().then((hasConnectivity) => { this.$store.commit('portal/hasConnectivity', hasConnectivity); }),
        this.signIn().then((signInResult) => { this.$store.commit('portal/isSignedIn', signInResult); }),
      ]);
    } catch (err) {
      console.warn('AppLoading.mounted error');
      console.error(err);
      console.error(err.stack);
    }
    const loadingTime = Date.now() - start;
    this.redirectDelay = Math.max(this.redirectDelay - loadingTime, 0);
    console.log(`Loaded in ${loadingTime}ms`);

    if (!this.isSignedIn && !this.isSteam) {
      // web version doesn't automatically sign you in, redirect
      setTimeout(() => {
        window.location = config.BASE_URL;
      }, this.redirectDelay);
    }
  },
  watch: {
    isSignedIn() { this.start(); },
    isInMaintenance() { this.start(); },
    hasCorrectVersion() { this.start(); },
    hasConnectivity() { this.start(); },
  },
  methods: {
    async signIn() {
      if (config.IS_STEAM) {
        return this.steamSignIn();
      }
      return this.$store.dispatch('portal/init');
    },
    async steamSignIn() {
      // eslint-disable-next-line no-undef
      const steam = await steamInit();
      if (steam.error) {
        console.log('steam init error');
        console.error(steam.message);
        console.error(steam.stack);
        return false;
      }

      if (steam.lang) {
        this.$store.state.portal.settings.lang = steam.lang;
        localStorage.setItem('lang', steam.lang);
      }

      // if there's existing local connection token and account, try to use them
      const localApiToken = localStorage.getItem('apiToken');
      const localaccountId = localStorage.getItem('accountId');
      if (localApiToken && localaccountId) {
        await this.$store.dispatch('portal/setApiToken', localApiToken);
        const validTokens = await this.$store.dispatch('portal/init');
        if (validTokens) {
          console.log('logged in using localStorage');
          return true;
        }
        // localStorage API token was not valid
        await this.$store.dispatch('portal/setApiToken', '');
      }

      // eslint-disable-next-line no-undef
      const { ticketHex, steamid } = await steamTicket();
      if (!steamid) {
        return false;
      }
      // eslint-disable-next-line no-undef
      const { account, apiToken } = await steamAuth({ ticketHex, steamid });
      localStorage.setItem('accountId', account.id);
      localStorage.setItem('apiToken', apiToken);
      await this.$store.dispatch('portal/setApiToken', apiToken);
      await this.$store.dispatch('portal/init');
      return true;
    },
    logout() {
      this.$store.dispatch('portal/logout');
    },
    start() {
      if (this.isInMaintenance === false && this.hasCorrectVersion === true && this.hasConnectivity === true && this.isSignedIn) {
        setTimeout(() => {
          this.$emit('loaded');
        }, this.redirectDelay);
      }
    },
  },
};
</script>
