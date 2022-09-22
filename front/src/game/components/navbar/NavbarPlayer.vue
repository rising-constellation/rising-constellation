<template>
  <div
    @click="openPanel"
    class="navbar-player navbar-central-box">
    <div class="navbar-player-image">
      <img :src="`data/avatars/${activeProfile.avatar}`" />
    </div>
    <div
      v-show="unreadMessages > 0"
      class="navbar-player-message">
      {{ unreadMessages }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'navbar-player',
  computed: {
    instanceId() { return this.$store.state.game.auth.instance; },
    activeProfile() { return this.$store.state.portal.activeProfile; },
    unreadMessages() { return this.$store.getters['portal/unreadMessages'](this.instanceId); },
  },
  methods: {
    openPanel() {
      this.$root.$emit('togglePanel', 'messenger');
    },
  },
};
</script>
