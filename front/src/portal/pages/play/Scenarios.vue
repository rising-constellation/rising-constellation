<template>
  <div class="panel-fragment">
    <div class="panel-content is-full-sized">
      <div class="panel-header">
        <h1 v-html="$tmd('page.play.scenarios.header')" />
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <router-link
          class="close-button"
          :to="`/play/${speed}`">
          {{ $t('page.instance.back') }}
        </router-link>
        <div
          v-if="scenarios.length === 0"
          class="full-sized-text">
          {{ $t('page.play.scenarios.no_scenario_found') }}
        </div>
        <template v-else>
          <table class="default-table scenarios-table">
            <tr
              v-for="scenario in scenarios"
              :key="scenario.id">
              <td>
                <h2>{{ scenario.game_metadata.name }}</h2>
                <em>
                  {{ $t(`map.size.${scenario.game_metadata.size}.toast`) }},
                  {{ $t('page.play.scenarios.info', {
                    factions: scenario.game_metadata.factions.length,
                    speed: $t(`page.play.speeds.${scenario.game_metadata.speed}`)
                  }) }}
                </em>
              </td>
              <td>
              </td>
              <td class="actions">
                <router-link
                  class="default-button"
                  :to="`/play/new/${scenario.id}`">
                  {{ $t('page.play.scenarios.choose') }}
                </router-link>
              </td>
            </tr>
          </table>
        </template>

        <hr class="margin">
      </v-scrollbar>
      <loading-mask v-else />
    </div>

    <v-scrollbar class="panel-aside">
      <!--
      <div class="panel-aside-info">
        <h2>TODO</h2>
        <p>
          Filtres sur les scenarios :<br>
          - Size<br>
          - Year<br>
          - ...
        </p>
      </div>
      -->
      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
import Loading from '@/portal/mixins/Loading';

import LoadingMask from '@/portal/components/LoadingMask.vue';

export default {
  name: 'play-scenarios',
  mixins: [Loading],
    data() {
    return {
      speed: undefined,
      scenarios: [],
      totalScenarios: 0,
    };
  },
  methods: {
    async loadData() {
      const resp = await this.releaseLoading(this.$axios.get(`/scenarios?speed=${this.speed}&is_official=true`));
      this.scenarios = resp.data;
      this.totalScenarios = resp.headers.total;
    },
  },
  mounted() {
    this.speed = this.$route.params.speed;
    this.loadData();
  },
  components: {
    LoadingMask,
  },
};
</script>
