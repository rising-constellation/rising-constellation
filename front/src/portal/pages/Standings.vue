<template>
  <default-layout>
    <div class="fluid-panel is-not-full-sized">
      <v-scrollbar class="panel-aside">
        <section
          class="panel-aside-info"
          v-html="$tmd('page.standings.description')">
        </section>

        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content is-small">
        <div class="panel-header">
          <h1>
            <strong>{{ $t('page.standings.title') }}</strong>
          </h1>
        </div>

        <v-scrollbar class="content">
          <table class="default-table standings-table">
            <tr
              v-for="(standing, i) in standings"
              :class="{ 'is-active': activeProfile.id === standing.id }"
              :key="standing.id"
              @click="toggleProfile(standing.id)">
              <td>{{ i + 1 }}</td>
              <td>{{ standing.name }}</td>
              <td>
                {{ standing.elo | integer }}
                <span class="toast">elo</span>
              </td>
            </tr>
          </table>
          <hr class="margin">
        </v-scrollbar>
      </div>

      <v-scrollbar class="panel-aside">
        <div class="panel-aside-profile">
          <div
            v-if="profileLoading"
            class="panel-aside-profile-loading">
            {{ $t('portal_components.loading.loading') }}
          </div>
          <player-card
            v-else-if="openedProfile"
            :profile="openedProfile" />
        </div>

        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';
import PlayerCard from '@/portal/components/card/PlayerCard.vue';

export default {
  name: 'standings',
  data() {
    return {
      standings: [],
      openedProfile: null,
      profileLoading: false,
    };
  },
  computed: {
    activeProfile() { return this.$store.state.portal.activeProfile; },
  },
  methods: {
    async loadData() {
      try {
        const { data } = await this.$axios.get('/standings');
        this.standings = data;
      } catch (err) {
        this.$toastError('Erreur');
      }
    },
    async toggleProfile(pid) {
      if (!this.profileLoading) {
        if (this.openedProfile && this.openedProfile.id === pid) {
          this.openedProfile = null;
        } else {
          this.profileLoading = true;

          const { data } = await this.$axios.get(`/profiles/${pid}`);

          this.openedProfile = data;
          this.profileLoading = false;
        }
      }
    },
  },
  async mounted() {
    await this.loadData();
  },
  components: {
    DefaultLayout,
    PlayerCard,
  },
};
</script>
