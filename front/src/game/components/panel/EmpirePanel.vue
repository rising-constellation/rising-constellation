<template>
  <div
    class="panel-container is-left"
    :class="theme"
    @click.self="close">
    <div class="panel-navbar">
      <button
        v-for="panel in panels"
        v-tooltip.right="$t(`panel.empire.${panel}`)"
        :key="panel"
        :class="{ 'is-active': activePanel === panel }"
        @click="activePanel = panel">
      </button>
    </div>

    <overall v-show="activePanel === 'overall'" />
    <possessions
      @close="close"
      v-show="activePanel === 'possessions'" />
  </div>
</template>

<script>
import Overall from '@/game/components/panel/empire/Overall.vue';
import Possessions from '@/game/components/panel/empire/Possessions.vue';

export default {
  name: 'faction-panel',
  data() {
    return {
      activePanel: 'overall',
      panels: ['overall', 'possessions'],
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
  },
  methods: {
    open(_data) {
      // ...
    },
    close() {
      this.$emit('close');
    },
  },
  components: {
    Overall,
    Possessions,
  },
};
</script>
