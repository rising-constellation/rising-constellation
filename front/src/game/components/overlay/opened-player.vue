<template>
  <div
    v-if="player"
    class="opened-character-container"
    :class="`f-${theme}`"
    @click.self="close">
    <div
      @click.self="close"
      class="opened-character">
      <div class="opened-character-card">
        <profile-card
          :open="true"
          :profile="player"
          :theme="theme"
          :lock="true"
          @sendMessage="sendMessage" />
      </div>
    </div>
  </div>
</template>

<script>
import ProfileCard from '@/game/components/card/ProfileCard.vue';

export default {
  name: 'opened-player',
  computed: {
    player() { return this.$store.state.game.openedPlayer; },
    theme() {
      return this.$store.getters['game/themeByKey'](this.player.faction);
    },
  },
  methods: {
    close() {
      this.$store.dispatch('game/closePlayer');
    },
    sendMessage(profileId) {
      this.$root.$emit('togglePanel', 'messenger', { initConversation: profileId });
      this.close();
    },
  },
  components: {
    ProfileCard,
  },
};
</script>
