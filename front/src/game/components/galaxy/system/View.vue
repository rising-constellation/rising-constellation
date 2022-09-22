<template>
  <div :class="`f-${color}`">
    <div
      @click="$emit('closeStellarSystem')"
      class="stellar-system-view">
    </div>

    <template v-if="system">
      <system-production
        :system="system"
        :color="color"
        :isQueueOpen="isQueueOpen" />

      <div class="system-content">
        <system-actions
          :isOwnSystem="isOwnSystem"
          :isOwnProperty="isOwnProperty"
          :system="system" />

        <system-properties
          :isOwnSystem="isOwnSystem"
          :isOwnProperty="isOwnProperty"
          :system="system"
          :color="color"
          @toggleQueue="toggleProductionQueue" />

        <system-svg
          :key="rerenderKey"
          :hoveredOrbit="hoveredOrbit"
          :system="system"
          @enterOrbit="enterOrbit"
          @leaveOrbit="leaveOrbit" />
      </div>

      <div class="system-info">
        <system-population
          :isOwnSystem="isOwnSystem"
          :system="system" />

        <system-content
          :isOwnSystem="isOwnSystem"
          :isOwnProperty="isOwnProperty"
          :system="system"
          :color="color"
          :hoveredOrbit="hoveredOrbit"
          @enterOrbit="enterOrbit"
          @leaveOrbit="leaveOrbit" />
      </div>
    </template>
  </div>
</template>

<script>
import SystemSvg from '@/game/components/galaxy/system/Svg.vue';
import SystemProperties from '@/game/components/galaxy/system/Properties.vue';
import SystemActions from '@/game/components/galaxy/system/Actions.vue';
import SystemPopulation from '@/game/components/galaxy/system/Population.vue';
import SystemContent from '@/game/components/galaxy/system/Content.vue';
import SystemProduction from '@/game/components/galaxy/system/Production.vue';

export default {
  name: 'system-view',
  data() {
    return {
      isQueueOpen: false,
      rerenderKey: 0,
      hoveredOrbit: undefined,
    };
  },
  computed: {
    color() {
      return ['inhabited_player', 'inhabited_dominion'].includes(this.system.status)
        ? this.$store.getters['game/themeByKey'](this.system.owner.faction)
        : 'null';
    },
    system() { return this.$store.state.game.selectedSystem; },
    isOwnSystem() { return this.$store.state.game.player.stellar_systems.some((s) => s.id === this.system.id); },
    isOwnDominion() { return this.$store.state.game.player.dominions.some((s) => s.id === this.system.id); },
    isOwnProperty() { return this.isOwnSystem || this.isOwnDominion; },
  },
  watch: {
    system(ns, os) {
      if (ns.id !== os.id) {
        this.leaveOrbit();
      }
    },
  },
  methods: {
    toggleProductionQueue() {
      if (this.isOwnSystem) {
        this.$store.commit('game/clearProduction');
        this.isQueueOpen = !this.isQueueOpen;
      }
    },
    enterOrbit(orbitId) { this.hoveredOrbit = orbitId; },
    leaveOrbit() { this.hoveredOrbit = undefined; },
    handleResize() { this.rerenderKey += 1; },
  },
  mounted() {
    window.addEventListener('resize', this.handleResize);
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize);
  },
  components: {
    SystemSvg,
    SystemContent,
    SystemProperties,
    SystemActions,
    SystemPopulation,
    SystemProduction,
  },
};
</script>
