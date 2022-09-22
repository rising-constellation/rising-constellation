<template>
  <div class="panel-fragment">
    <div class="panel-content is-full-sized">
      <div class="panel-header">
        <h1>
          <strong>{{ totalMaps }}</strong> cartes
        </h1>

        <router-link
          to="/create/map/new"
          class="default-button">
          Nouvelle carte
        </router-link>
      </div>

      <v-scrollbar
        v-if="loaded"
        class="content">
        <div
          v-if="maps.length === 0"
          class="full-sized-text">
          Aucun résultat trouvé
        </div>
        <template v-else>
          <table class="default-table maps-table">
            <tr
              v-for="map in maps"
              :key="map.id">
              <td>
                <h2>{{ map.game_metadata.name }}</h2>
                <em>
                  {{ $t(`map.size.${map.game_metadata.size}.toast`) }}
                  <span
                    class="toast"
                    v-if="map.is_official">
                    carte officielle
                  </span>
                </em>
              </td>
              <td>
              </td>
              <td class="actions">
                <router-link
                  class="default-button"
                  :to="`/create/map/${map.id}`">
                  Editer
                </router-link>
                <router-link
                  class="default-button"
                  :to="`/create/scenario/new/${map.id}`">
                  Utiliser pour un scénario
                </router-link>
              </td>
            </tr>
          </table>
        </template>
      </v-scrollbar>
      <loading-mask v-else />
    </div>

    <v-scrollbar class="panel-aside">
      <div class="panel-aside-info">
        <h2>TODO</h2>
        <p>
          Filtres sur les cartes :<br>
          - Cartes officielles<br>
          - Cartes personnelles<br>
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
  name: 'create-maps',
  mixins: [Loading],
  data() {
    return {
      maps: [],
      totalMaps: 0,
    };
  },
  methods: {
    async loadData() {
      const resp = await this.releaseLoading(this.$axios.get('/maps'));
      this.maps = resp.data;
      this.totalMaps = resp.headers.total;
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
