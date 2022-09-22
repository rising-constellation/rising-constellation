<template>
  <div class="panel-content is-small">
    <v-scrollbar class="has-padding">
      <h1 class="panel-default-title">
        {{ $t('panel.faction.overall_title') }}
      </h1>

      <div class="panel-content-number-bloc">
        <div class="label">
          {{ $t('panel.faction.player_count') }}
        </div>
        <div class="value">
          {{ faction.players.length }}
        </div>
      </div>

      <h1 class="panel-default-title">
        {{ $t('page.instance.tradition') }}
      </h1>

      <div
        class="panel-content-text-bloc"
        v-for="tradition in factionData.traditions"
        :key="tradition.key">
        <div class="header">
          <strong>{{ $t(`data.tradition.${tradition.key}.name`) }}</strong>
          <span>{{ $t(`data.tradition.${tradition.key}.bonus`) }}</span>
        </div>
        <div class="body">
          {{ $t(`data.tradition.${tradition.key}.description`) }}
        </div>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'faction-overall-panel',
  computed: {
    faction() { return this.$store.state.game.faction; },
    victory() { return this.$store.state.game.victory; },
    factionData() {
      return this.$store.state.game.data.faction.find((f) => f.key === this.faction.key);
    },
  },
};
</script>
