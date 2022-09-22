<template>
  <div
    ref="container"
    class="system-population">
    <div
      v-if="[4, 17].includes(tutorialStep)"
      class="tutorial-pointer is-bottom">
    </div>
    <div class="box-line header">
      <strong>{{ $t('galaxy.system.population.workforce') }}</strong>
      <template v-if="system.population">
        {{ $t('galaxy.system.population.growth_adj', {adj: growthToLabel()}) }}
      </template>
      <template v-else>
        {{ $t('galaxy.system.population.unknown_workforce') }}
      </template>
    </div>

    <div class="progres-container">
      <progress-value
        v-if="system.population"
        :current="system.population.value - Math.trunc(system.population.value)"
        :total="1"
        :increase="system.population.change" />
      <progress-value
        v-else
        :current="0"
        :total="0"
        :increase="0" />
    </div>

    <div class="box-line">
      <div v-if="!system.workforce">
        <div class="yield-box">
          ░░/░░ <svgicon name="resource/population" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div
          :class="{ 'highlighted': system.used_workforce >= system.workforce }"
          class="yield-box">
          {{ system.used_workforce }}/{{ system.workforce }}
          <svgicon name="resource/population" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.system.population.workforce')"
          :description="$t(`resource-description.workforce`)"
          :precision="0"
          :details="[
            { reason: $t('galaxy.system.population.workforce_mobilized'), value: system.used_workforce},
            { reason: $t('galaxy.system.population.workforce_total'), value: system.workforce}
          ]" />
      </v-popover>

      <div v-if="!system.habitation">
        <div class="yield-box">
          ░░░░ <svgicon name="resource/habitation" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div class="yield-box">
          {{ system.habitation.value }}
          <svgicon name="resource/habitation" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.system.population.habitation')"
          :description="$t(`resource-description.habitation`)"
          :precision="0"
          :value="system.habitation.value"
          :details="system.habitation.details" />
      </v-popover>

      <div v-if="!system.happiness">
        <div class="yield-box">
          ░░░░ <svgicon name="resource/happiness" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div
          :class="{ 'highlighted': system.happiness.value < 0 }"
          class="yield-box">
          {{ system.happiness.value | integer }}
          <svgicon name="resource/happiness" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.system.population.happiness')"
          :description="$t(`resource-description.happiness`)"
          :value="system.happiness.value"
          :details="system.happiness.details" />
      </v-popover>
    </div>
  </div>
</template>

<script>
import { TimelineLite, Expo } from 'gsap';

import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';
import ProgressValue from '@/game/components/generic/ProgressValue.vue';

export default {
  name: 'system-population',
  data() {
    return {
      growth: [
        { boundaries: [1, 0.06], label: this.$t('galaxy.system.population.growth_0') },
        { boundaries: [0.06, 0.04], label: this.$t('galaxy.system.population.growth_1') },
        { boundaries: [0.04, 0.02], label: this.$t('galaxy.system.population.growth_2') },
        { boundaries: [0.02, 0.001], label: this.$t('galaxy.system.population.growth_3') },
        { boundaries: [0.001, -0.001], label: this.$t('galaxy.system.population.growth_4') },
        { boundaries: [-0.001, -1], label: this.$t('galaxy.system.population.growth_5') },
      ],
    };
  },
  props: {
    system: Object,
    isOwnSystem: Boolean,
  },
  computed: {
    tutorialStep() { return this.$store.state.game.tutorialStep; },
  },
  methods: {
    growthToLabel() {
      const growth = this.system.population.change;
      const obj = this.growth.find((g) => growth <= g.boundaries[0] && growth > g.boundaries[1]);
      if (obj) {
        return obj.label;
      }
      return '';
    },
  },
  mounted() {
    new TimelineLite()
      .set(this.$refs.container, { left: -500 })
      .to(this.$refs.container, { left: 0, ease: Expo.easeOut, duration: 0.8 }, 0);
  },
  components: {
    ResourceDetail,
    ProgressValue,
  },
};
</script>
