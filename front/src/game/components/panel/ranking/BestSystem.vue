<template>
  <div class="panel-content is-medium">
    <v-scrollbar class="has-padding">
      <h1 class="panel-default-title">{{ $t(`panel.ranking.${typeName}_title`) }}</h1>
      <table class="panel-table ranking-table">
        <tr
          v-for="(stat, index) in players"
          :key="stat.player_id">
          <td>
            #{{ index + 1 }}
          </td>
          <td
            class="name"
            :class="`theme-${getTheme(stat.faction)}`"
            @click="openPlayer(stat.player_id)">
            {{ stat.player_name }}
            <template v-if="!stat.is_player_active">
              ({{ $t('inactive') }})
            </template>
          </td>
          <td class="highlighted align-right">
            {{ stat[`best_${type}`] | integer }}
            <svgicon :name="`resource/${typeName}`" />
          </td>
        </tr>
      </table>

      <div class="anchor"></div>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'ranking-best-system',
  props: {
    players: Array,
    type: String,
  },
  computed: {
    typeName() {
      if (this.type === 'prod') {
        return 'production';
      }
      return this.type;
    },
  },
  methods: {
    getTheme(key) {
      return this.$store.getters['game/themeByKey'](key);
    },
    openPlayer(playerId) {
      this.$store.dispatch('game/openPlayer', { vm: this, id: playerId });
    },
  },
};
</script>
