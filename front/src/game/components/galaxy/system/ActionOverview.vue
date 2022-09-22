<template>
  <div class="overview">
    <div class="overview-value">
      {{ data.attacker | integer }}
      <svgicon :name="data.attackerIcon" />
    </div>
    <div class="overview-container">
      <div class="overview-space">
        <div
          :class="[
            { 'is-dashed': data.defender === null },
            `overview-theme-left-${data.defenderTheme}`,
            `overview-theme-right-${data.attackerTheme}`,
          ]"
          class="overview-ground">
          <div style="width: 5%"></div>
          <div style="width: 45%"></div>
          <div style="width: 45%"></div>
          <div style="width: 5%"></div>
        </div>
        <div
          v-if="data.defender !== null"
          class="overview-range"
          :style="`
            left: ${probaSpace.min}%;
            width: ${probaSpace.max - probaSpace.min}%;
          `">
        </div>
        <div
          v-if="data.defender !== null"
          class="overview-ratio"
          :style="`left: ${probaSpace.ratio}%;`">
        </div>
        <div
          v-if="probaSpace.result"
          class="overview-result"
          :style="`left: ${probaSpace.result}%;`">
        </div>
      </div>
    </div>
    <div class="overview-value">
      <template v-if="data.defender !== null">{{ data.defender | integer }}</template>
      <template v-else>?</template>
      <svgicon :name="data.defenderIcon" />
    </div>
  </div>
</template>

<script>
export default {
  name: 'action-overview',
  props: {
    data: Object,
  },
  computed: {
    probaSpace() {
      const ratio = this.data.attacker + this.data.defender !== 0
        ? (this.data.attacker / (this.data.attacker + this.data.defender))
        : 0.5;

      const result = this.data.result ? this.data.result * 100 : null;

      const min = Math.max(ratio - 0.20 + (0.01 * Math.min(this.data.attackerModifier, 20)), 0) * 100;
      const max = Math.min(ratio + 0.20, 1) * 100;

      return { ratio: ratio * 100, min, max, result };
    },
  },
  methods: {

  },
};
</script>
