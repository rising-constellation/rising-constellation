<template>
  <div class="panel-content is-medium">
    <v-scrollbar class="has-padding">
      <h1 class="panel-default-title">{{ $t(`panel.ranking.overall_title`) }}</h1>
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
          <td v-html="$t(
            'panel.ranking.possession_count',
            { value: $options.filters.integer(stat.total_systems) }
          )">
          <td v-html="$t(
            'panel.ranking.billion_population',
            { value: $options.filters.float(stat.total_population, 1) }
          )">
          </td>
          <td class="highlighted align-right">
            {{ stat.points | integer }}
            <span class="small">pts</span>
          </td>
        </tr>
      </table>

      <div class="anchor"></div>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'ranking-overall',
  props: {
    players: Array,
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
