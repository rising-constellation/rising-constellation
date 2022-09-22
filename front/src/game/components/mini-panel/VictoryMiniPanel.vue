<template>
  <div
    class="mp-container inverted"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.victory.title') }}
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
        <div class="victory-tracks">
          <div
            class="victory-tracks-lines"
            v-for="(victory, i) in victories"
            :key="victory">
            <div
              class="victory-tracks-header"
              v-tooltip.right="$t(`data.victory.${victory}.description`)"
              v-html="$tmd(`data.victory.${victory}.name`)">
            </div>
            <div
              class="victory-tracks-rows"
              :class="[
                `is-${j}`,
                { 'is-active': true },
              ]"
              v-for="(m, j) in milestones"
              :key="`l${i}-${j}`">
              <v-popover trigger="hover">
                <div class="content"></div>
                <resource-detail
                  slot="popover"
                  :precision="0"
                  :title="$t(`data.victory.${victory}.points`)"
                  :details="factionsPointsInMilestone(`${victory}_track`, j)" />
              </v-popover>
              <div
                class="track"
                :class="{ 'is-active': ownVictory[`${victory}_track`].points >= ownVictory[`${victory}_track`].milestones[j] }">
              </div>
              <div class="factions">
                <div
                  class="faction-item"
                  v-for="f in factionsInMilestone(`${victory}_track`, j)"
                  v-tooltip="$t(`data.faction.${f.key}.name`)"
                  :class="[`f-${getTheme(f.key)}`]"
                  :key="`l${i}-${j}-${f.key}`">
                  <svgicon :name="`faction/${f.key}-small`" />
                </div>
              </div>
              <template v-if="m !== 0">
                <div
                  :class="{ 'is-active': ownVictory[`${victory}_track`].points >= ownVictory[`${victory}_track`].milestones[j] }"
                  class="points">
                  <span
                    v-for="k in m"
                    :key="`s${i}-${j}-${k}`">
                    ★
                  </span>
                </div>
              </template>
            </div>
          </div>

          <div class="victory-factions">
            <div
              v-for="(f, i) in orderedFactions"
              :key="f.key"
              :class="[`f-${getTheme(f.key)}`]"
              class="victory-factions-item">
              <div class="header">
                <div class="rank">{{ numberToRoman(i + 1) }}</div>
                <div class="title">{{ $t(`data.faction.${f.key}.name`) }}</div>
              </div>
              <div class="body">
                <span
                  v-for="j in 14"
                  :class="{ 'is-active': j <= f.victory_points }"
                  :key="`f${f.key}-c${j}`">
                  ★
                </span>
              </div>
            </div>

            <div class="victory-time-limit">
              <h2>{{ $t('minipanel.victory.time-limit') }}</h2>
              <p>{{ timestamp | luxon-std }}</p>
            </div>
          </div>
        </div>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
import MiniPanelMixin from '@/game/mixins/MiniPanelMixin';

import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';

export default {
  name: 'victory-mini-panel',
  mixins: [MiniPanelMixin],
  data() {
    return {
      victories: ['conquest', 'population', 'visibility'],
      milestones: [0, 2, 3, 5],
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    ownFaction() { return this.$store.state.game.faction; },
    victory() { return this.$store.state.game.victory; },
    ownVictory() { return this.victory.factions.find((f) => f.key === this.ownFaction.key); },
    orderedFactions() {
      return Array.from(this.victory.factions).sort((a, b) => b.victory_points - a.victory_points);
    },
    timestamp() {
      return this.victory.receivedAt + (this.victory.ut_time_left * this.tickToMilisecondFactor);
    },
  },
  methods: {
    factionsInMilestone(track, milestone) {
      return this.victory.factions.filter((f) => f[track].index === milestone);
    },
    factionsPointsInMilestone(track, milestone) {
      return this.victory.factions
        .map((f) => {
          const threshold = this.ownFaction.key !== f.key && track === 'visibility_track' && !this.victory.winner
            ? '?' : f[track].points;

          return {
            reason: this.$t(`data.faction.${f.key}.name`),
            value: `${threshold} / ${f[track].milestones[milestone]}`,
          };
        });
    },
    getTheme(key) {
      return this.$store.getters['game/themeByKey'](key);
    },
    numberToRoman(number) {
      switch (number) {
        case 1: return 'I';
        case 2: return 'II';
        case 3: return 'III';
        case 4: return 'IV';
        case 5: return 'V';
        default: return '-';
      }
    },
  },
  components: {
    ResourceDetail,
  },
};
</script>
