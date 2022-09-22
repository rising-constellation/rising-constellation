<template>
  <div class="settings">
    <ul>
      <li @click="close">
        <template v-if="isTutorial">
          {{ $t('in_game_settings.exit_tutorial') }}
        </template>
        <template v-else>
          {{ $t('in_game_settings.exit') }}
        </template>
      </li>
    </ul>
    <ul>
      <li @click="$emit('close')">
        {{ $t('in_game_settings.back') }}
      </li>
    </ul>
  </div>
</template>

<script>
import eventBus from '@/plugins/event-bus';

export default {
  name: 'settings',
  data() {
    return {
      waiting: false,
    };
  },
  computed: {
    isTutorial() { return this.$store.state.game.galaxy.tutorial_id; },
    instanceId() { return this.$store.state.game.auth.instance; },
  },
  methods: {
    async close() {
      if (!this.waiting) {
        this.waiting = true;

        const { auth } = this.$store.state.game;
        const isTutorial = this.isTutorial;

        if (isTutorial) {
          this.$socket.global.push('kill_instance', {});
        }

        this.$ambiance.changeContext('portal');
        this.$socket.leaveGame();
        this.$store.commit('game/clear');

        if (isTutorial) {
          this.$router.push('/play/tutorial');
        } else if (auth) {
          this.$router.push(`/instance/${auth.instance}`);
        } else {
          this.$router.push('/play');
        }
      }
    },
  },
  mounted() {
    eventBus.$on('signal:close_game', () => { this.close(); });
  },
};
</script>
