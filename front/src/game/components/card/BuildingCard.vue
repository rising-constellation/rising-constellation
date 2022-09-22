<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`building/${buildingKey}`" />
        <span class="level">{{ level }}</span>
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ $t(`data.building.${buildingKey}.name`) }}
        </div>
        <div
          v-show="buildingData.workforce > 0"
          class="title-small">
          {{ buildingData.workforce }}
          <svgicon
            class="text-icon"
            name="resource/population" />
          {{ $t('card.building.mobilized') }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img
          v-if="!disabled"
          :src="`data/buildings/${buildingData.illustration}`" />
        <div
          v-else
          class="locked-item">
          <svgicon
            class="locked-icon"
            name="unlock" />
          <div
            v-html="disabled"
            class="locked-reason">
          </div>
        </div>

        <div
          class="toast"
          v-tooltip="$t('card.building.limited_hint')"
          v-if="buildingData.limitation === 'unique_body'">
          {{ $t('card.building.limited') }}
        </div>
        <div
          class="toast"
          v-tooltip="$t('card.building.unique_hint')"
          v-if="buildingData.limitation === 'unique_system'">
          {{ $t('card.building.unique') }}
        </div>
      </div>

      <div class="card-information">
        <div class="card-panel-controls">
          <svgicon
            class="card-panel-control"
            name="caret-left"
            @click="movePanelToLeft"
            v-if="leftControl" />
          <div v-else></div>
          <svgicon
            class="card-panel-control"
            name="caret-right"
            @click="movePanelToRight"
            v-if="rightControl" />
          <div v-else></div>
        </div>

        <div class="card-panel-window">
          <div
            ref="panelContainer"
            class="card-panel-container"
            :style="{ left: panelContainerPosition + 'px' }">
            <div class="card-panel">
              <blockquote>
                {{ $t(`data.building.${buildingKey}.quote`) }}
              </blockquote>

              <card-complex-bonus
                :bonus="levelData.bonus"
                :body="body"
                :system="system" />
            </div>

            <div class="card-panel">
              <h2>{{ $t('card.building.about') }}</h2>
              <p>{{ $t(`data.building.${buildingKey}.description`) }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div
      v-if="showCost"
      class="card-cost">
      <div class="icon-value">
        {{ levelData.production | integer }}
        <svgicon name="resource/production" />
        <template v-if="system">
          ({{ (levelData.production / system.production.value) * tickToSecondFactor | counter }})
        </template>
      </div>
      <div class="icon-value">
        {{ levelData.credit | integer }}
        <svgicon name="resource/credit" />
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import CardComplexBonus from '@/game/components/card/CardComplexBonus.vue';

export default {
  name: 'building-card',
  mixins: [CardMixin],
  props: {
    buildingKey: String,
    level: Number,
    body: {
      type: Object,
      required: false,
    },
    system: {
      type: Object,
      required: false,
    },
    showCost: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: String,
      required: false,
    },
  },
  computed: {
    buildingData() { return this.$store.state.game.data.building.find((b) => b.key === this.buildingKey); },
    levelData() { return this.buildingData.levels[this.level - 1]; },
    tickToSecondFactor() { return this.$store.getters['game/tickToSecondFactor']; },
  },
  components: {
    CardComplexBonus,
  },
};
</script>
