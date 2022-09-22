<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`patent/${patent.key}`" />
      </div>
      <div class="card-header-content">
        <div class="title-large">
          {{ $t(`data.patent.${patent.key}.name`) }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img :src="`data/patents/${patent.illustration}`">
      </div>

      <div class="card-information">
        <div class="card-panel-controls">
          <svgicon
            class="card-panel-control"
            @click="movePanelToLeft()"
            name="caret-left"
            v-if="leftControl" />
          <div v-else></div>
          <svgicon
            class="card-panel-control"
            @click="movePanelToRight()"
            name="caret-right"
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
                {{ $t(`data.patent.${patent.key}.quote`) }}
              </blockquote>

              <div
                v-for="unlock in patent.unlock"
                :key="`unlock-${patent.key}-${unlock.key}`"
                class="complex-bonus"
                @mouseover="showChild({type: unlock.type, key: unlock.key, level: unlock.level})"
                @mouseleave="hideChild()">
                <div v-if="unlock.type === 'building'">
                  <span v-html="$t('card.patent.unlocks_something', {something: $t(`data.building.${unlock.key}.name`)})" />
                  <span v-if="unlock.level > 1" v-html="$t('card.patent.level_hint', {lvl: unlock.level})" />
                </div>
                <div
                  v-if="unlock.type === 'ship'"
                  v-html="$t('card.patent.unlocks_something', {something: $t(`data.ship.${unlock.key}.name`)})">
                </div>
              </div>

              <div
                v-if="patent.info"
                class="complex-bonus">
                <div>{{ $t(`data.patent_info.${patent.info}`) }}</div>
              </div>
            </div>

            <div class="card-panel">
              <h2>{{ $t('card.patent.about') }}</h2>
              <p>{{ $t(`data.patent.${patent.key}.description`) }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      class="card-action"
      v-if="!child">
      <div class="card-action-button">
        <div
          v-if="patent.status === 'locked'"
          class="button disabled">
          <div class="dashed">{{ $t('card.patent.locked') }}</div>
          <div class="dashed icon-value">
            {{ cost | integer }}
            <svgicon name="resource/technology" />
          </div>
        </div>
        <div
          v-if="patent.status === 'available'"
          class="button"
          @click="purchase(patent.key)">
          <div>{{ $t('card.patent.buy') }}</div>
          <div class="icon-value">
            {{ cost | integer }}
            <svgicon name="resource/technology" />
          </div>
        </div>
        <div
          v-if="patent.status === 'purchased'"
          class="button active"
          :class="`f-${theme}`">
          <div>{{ $t('card.patent.purchased') }}</div>
        </div>
      </div>
    </div>

    <div
      v-if="!child && activeChild !== null"
      class="card-child">
      <building-card
        v-if="activeChild.type === 'building'"
        :child="true"
        :buildingKey="activeChild.key"
        :level="activeChild.level"
        :theme="theme"
        :showCost="true" />
      <ship-card
        v-if="activeChild.type === 'ship'"
        :child="true"
        :shipKey="activeChild.key"
        :theme="theme"
        :showCost="true" />
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import BuildingCard from '@/game/components/card/BuildingCard.vue';
import ShipCard from '@/game/components/card/ShipCard.vue';

export default {
  name: 'patent-card',
  mixins: [CardMixin],
  props: {
    patent: Object,
    costFactor: Number,
  },
  computed: {
    cost() { return this.patent.cost * (1 + this.costFactor); },
  },
  methods: {
    purchase(patentkey) {
      this.$emit('purchase', patentkey);
    },
  },
  components: {
    BuildingCard,
    ShipCard,
  },
};
</script>
