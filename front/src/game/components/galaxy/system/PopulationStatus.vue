<template>
  <div>
    <div class="system-content-group">
      <div class="system-content-group-header">
        <div class="main">
          {{ $t('galaxy.system.pop_status.title') }}
        </div>
        {{ formatProductivity(currentPenalty) }}%
      </div>

      {{ $t(`data.population_status.${system.population_status}.desc`) }}

      <div class="system-content-group-pop-state">
        <div
          v-for="ps in blockPopStatus"
          v-tooltip="formatTooltip(ps.key, ps.display_min, ps.display_max, formatProductivity(ps.penalty))"
          class="pop-state-item"
          :style="{ width: `${ps.width}%` }"
          :class="{ 'is-active': ps.key === system.population_status }"
          :key="ps.key">
          {{ formatProductivity(ps.penalty) }}%
        </div>
      </div>
      <div class="generic-progress-container">
        <div
          class="generic-progress-bar"
          :style="`width: ${rangedHappiness}%;`">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'system-population-status',
  props: {
    system: Object,
    color: String,
  },
  computed: {
    populationStatus() { return this.$store.state.game.data.population_status; },
    currentPenalty() {
      return this.system.population_status
        ? this.populationStatus.find((ps) => ps.key === this.system.population_status).penalty
        : 'hidden';
    },
    maxHappiness() { return this.populationStatus[0].display_max; },
    minHappiness() { return this.populationStatus[this.populationStatus.length - 1].display_min; },
    totalHappiness() { return Math.abs(this.maxHappiness) + Math.abs(this.minHappiness); },
    rangedHappiness() {
      if (!this.system.happiness) {
        return 0;
      }

      const ranged = Math.max(Math.min(this.system.happiness.value, this.maxHappiness), this.minHappiness);
      return (Math.abs(ranged - this.maxHappiness) / this.totalHappiness) * 100;
    },
    blockPopStatus() {
      return this.populationStatus.map((ps) => {
        const width = (Math.abs(ps.display_min - ps.display_max) / this.totalHappiness) * 100;
        return { width, ...ps };
      });
    },
  },
  methods: {
    formatTooltip(key, min, max, penalty) {
      let main = '<strong>' + this.$t(`data.population_status.${key}.name`) + '</strong><br>';

      if (key !== 'normal') {
        main += `— ${this.$t('galaxy.system.pop_status.happiness', { max, min })}<br>`;
      }

      main += `— ${this.$t('galaxy.system.pop_status.productivity', { penalty })}`;
      return main;
    },
    formatProductivity(penalty) {
      return typeof penalty === 'number'
        ? Math.round((1 - penalty) * 100)
        : '░░';
    },
  },
};
</script>
