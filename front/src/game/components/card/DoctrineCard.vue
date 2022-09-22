<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`doctrine/${doctrine.key}`" />
      </div>
      <div class="card-header-content">
        <div class="title-large">
          {{ $t(`data.doctrine.${doctrine.key}.name`) }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img :src="`data/doctrines/${doctrine.illustration}`">
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
                {{ $t(`data.doctrine.${doctrine.key}.quote`) }}
              </blockquote>

              <card-complex-bonus
                :bonus="doctrine.bonus"
                :player="player" />
            </div>

            <div class="card-panel">
              <h2>{{ $t('card.doctrine.about') }}</h2>
              <div>{{ $t(`data.doctrine.${doctrine.key}.description`) }}</div>
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
          v-if="doctrine.status === 'locked'"
          class="button disabled">
          <div class="dashed">{{ $t('card.doctrine.locked') }}</div>
          <div class="dashed icon-value">
            {{ cost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
        <div
          v-if="doctrine.status === 'available'"
          class="button"
          @click="purchase(doctrine.key)">
          <div>{{ $t('card.doctrine.buy') }}</div>
          <div class="icon-value">
            {{ cost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
        <template v-if="doctrine.status === 'purchased'">
          <div
            v-if="emptyPolicies"
            class="button"
            @click="choose(doctrine.key)">
            <div>{{ $t('card.doctrine.choose_lex') }}</div>
          </div>
          <div
            v-else
            class="button disabled">
            <div class="dashed">{{ $t('card.doctrine.no_lex_slot') }}</div>
          </div>
        </template>
        <div v-if="doctrine.status === 'chosen'">
          <div
            class="button active"
            :class="`f-${theme}`">
            <div>{{ $t('card.doctrine.active') }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import CardComplexBonus from '@/game/components/card/CardComplexBonus.vue';

export default {
  name: 'doctrine-card',
  mixins: [CardMixin],
  props: {
    doctrine: Object,
    emptyPolicies: Boolean,
    costFactor: Number,
  },
  computed: {
    player() { return this.$store.state.game.player; },
    cost() { return this.doctrine.cost * (1 + this.costFactor); },
  },
  methods: {
    purchase(doctrinekey) {
      this.$emit('purchase', doctrinekey);
    },
    choose(doctrinekey) {
      this.$emit('choose', doctrinekey);
    },
  },
  components: {
    CardComplexBonus,
  },
};
</script>
