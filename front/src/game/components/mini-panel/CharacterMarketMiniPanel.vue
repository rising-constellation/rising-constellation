<template>
  <div
    class="mp-container inverted"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.character_market.title') }}
      </div>
      <div class="mph-nav">
        <div
          v-for="type in characterMarket.slots"
          :key="type.key"
          :class="{ 'active': activeTab === type.key }"
          class="mph-nav-item"
          @click="switchTab(type.key)">
          {{ $tc(`data.character.${type.key}.name`, 2) }}
        </div>
      </div>
      <div class="mph-filter">
        <div
          class="mph-filter-item"
          :class="{
            'active': showCommon,
            'inactive': !showCommon && (showRemarkable || showExceptional),
          }"
          @click="showCommon = !showCommon">
          {{ $t(`data.character_rank.common.name`) }}
          {{ $t(`data.character_rank.common.star`) }}
        </div>
        <div
          class="mph-filter-item"
          :class="{
            'active': showRemarkable,
            'inactive': !showRemarkable && (showCommon || showExceptional),
          }"
          @click="showRemarkable = !showRemarkable">
          {{ $t(`data.character_rank.remarkable.name`) }}
          {{ $t(`data.character_rank.remarkable.star`) }}
        </div>
        <div
          class="mph-filter-item"
          :class="{
            'active': showExceptional,
            'inactive': !showExceptional && (showRemarkable || showCommon),
          }"
          @click="showExceptional = !showExceptional">
          {{ $t(`data.character_rank.exceptional.name`) }}
          {{ $t(`data.character_rank.exceptional.star`) }}
        </div>
      </div>
      <div class="mph-close-button" @click="close"></div>
    </div>
    <v-scrollbar
      class="mp-scrollbar"
      :settings="{
        wheelPropagation: false,
        suppressScrollY: true,
        useBothWheelAxes: true,
      }">
      <div
        class="mp-content"
        :style="{ height: `${height}px` }">
        <div class="mpc-stack-list">
          <div
            v-for="({rank, timestamp, nth, cooldown, character}, i) in characterByType(activeTab)"
            :key="i"
            class="character-stack">
            <div
              class="character-stack-cooldown"
              v-tooltip="speed !== 'fast'
                ? $t('minipanel.character_market.turnover', { date: $options.filters['luxon-std'](timestamp) })
                : ''">
              <progress-value
                :receivedAt="characterMarket.receivedAt"
                :current="cooldown.value"
                :total="cooldown.initial"
                :increase="-1" />
            </div>
            <div class="character-stack-label">
              <span class="nth">{{ nth }}</span>
              <span class="stars">{{ $t(`data.character_rank.${rank}.star`)}}</span>
            </div>
            <character-card
              v-if="character"
              :character="character"
              @hire="close" />
          </div>
        </div>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
import MiniPanelMixin from '@/game/mixins/MiniPanelMixin';

import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ProgressValue from '@/game/components/generic/ProgressValue.vue';

export default {
  name: 'character-market-mini-panel',
  mixins: [MiniPanelMixin],
  data() {
    return {
      showCommon: false,
      showRemarkable: false,
      showExceptional: false,
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    speed() { return this.$store.state.game.time.speed; },
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    tabs() { return ['admiral', 'spy', 'speaker']; },
    characterMarket() { return this.$store.state.game.character_market; },
  },
  methods: {
    characterByType(type) {
      if (!type) return [];

      return this.characterMarket.slots
        .find((t) => t.key === type).data
        .reduce((acc, { data, key }) => {
          if ((!this.showCommon && !this.showRemarkable && !this.showExceptional)
            || (key === 'common' && this.showCommon)
            || (key === 'remarkable' && this.showRemarkable)
            || (key === 'exceptional' && this.showExceptional)) {
            const characters = data.map((character) => {
              const timestamp = this.characterMarket.receivedAt + (character.cooldown.value * this.tickToMilisecondFactor);
              const c = {
                ...{
                  rank: key,
                  timestamp,
                },
                ...character,
              };

              return c;
            });

            return acc.concat(characters);
          }
          return acc;
        }, []);
    },
  },
  watch: {
    characterMarket: {
      deep: true,
      handler() {
        return this.$store.state.game.character_market;
      },
    },
  },
  components: {
    CharacterCard,
    ProgressValue,
  },
};
</script>
