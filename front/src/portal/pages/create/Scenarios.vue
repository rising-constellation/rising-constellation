<template>
  <div class="panel-fragment">
    <div class="panel-content is-full-sized">
      <div class="panel-header">
        <h1>
          <strong>{{ totalScenarios }}</strong> scénarios
        </h1>
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <div
          v-if="scenarios.length === 0"
          class="full-sized-text">
          Aucun résultat trouvé
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
                  {{ scenario.game_metadata.factions.length }} factions,
                  {{ $t(`data.speed.${scenario.game_metadata.speed}.name`) }}
                  <span
                    class="toast"
                    v-if="scenario.is_official">
                    scénario officiel
                  </span>
                </em>
              </td>
              <td>
              </td>
              <td class="actions">
                <router-link
                  class="default-button"
                  :to="`/create/scenario/edit/${scenario.id}`">
                  Editer
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
      <div class="panel-aside-info">
        <h2>TODO</h2>
        <p>
          Filtres sur les scénarios :<br>
          - Scénarios officiels<br>
          - Scénarios personnels<br>
          - Nombre de factions<br>
          - Vitesse<br>
          - Filtre de taille
        </p>
      </div>
      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
import Loading from '@/portal/mixins/Loading';

import LoadingMask from '@/portal/components/LoadingMask.vue';

export default {
  name: 'create-scenarios',
  mixins: [Loading],
    data() {
    return {
      scenarios: [],
      totalScenarios: 0,
    };
  },
  methods: {
    async loadData() {
      const resp = await this.releaseLoading(this.$axios.get('/scenarios'));
      this.scenarios = resp.data;
      this.totalScenarios = resp.headers.total;
    },
  },
  mounted() {
    this.loadData();
  },
  components: {
    LoadingMask,
  },
};
</script>
