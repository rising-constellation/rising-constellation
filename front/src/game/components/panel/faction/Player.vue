<template>
  <div class="panel-content is-small">
    <v-scrollbar class="has-padding">
      <h1 class="panel-default-title">
        {{ onlinePlayersCount }}/{{ faction.players.length }}
        <span>{{ $t('panel.faction.online_players') }}</span>
      </h1>

      <div
        v-for="p in players"
        class="pcb-player"
        :key="p.id">
        <div class="squared">
          <span
            v-tooltip="$t('panel.faction.online')"
            v-show="p.isOnline">
            ◉
          </span>
        </div>
        <div
          @click="openPlayer(p.id)"
          class="large">
          <strong>{{ p.name }}</strong>
          <template v-if="!p.isActive">
            ({{ $t('inactive') }})
          </template>
        </div>
        <div class="squared">
          <span
            @click="sendMessage(p.id)"
            v-tooltip="$t('card.profile.contact')"
            v-show="p.id !== player.id">
            ↦
          </span>
        </div>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'faction-players-panel',
  computed: {
    onlinePlayersCount() { return this.$store.getters['game/onlinePlayersNumber']; },
    faction() { return this.$store.state.game.faction; },
    player() { return this.$store.state.game.player; },
    galaxyPlayers() { return this.$store.state.game.galaxy.players; },
    players() {
      const onlines = this.$store.state.game.onlinePlayers;
      return this.faction.players.map((player) => {
        const isOnline = player.id in onlines;
        return { isActive: this.galaxyPlayers[player.id]['is_active'], ...player, ...{ isOnline } };
      });
    },
  },
  methods: {
    openPlayer(playerId) {
      this.$store.dispatch('game/openPlayer', { vm: this, id: playerId });
    },
    sendMessage(playerId) {
      this.$root.$emit('togglePanel', 'messenger', { initConversation: playerId });
    },
  },
};
</script>
