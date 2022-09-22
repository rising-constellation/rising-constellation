<template>
  <div class="card-container">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon
          v-if="sector.owner"
          :name="`faction/${getOwner(sector.owner)}-small`" />
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ sector.name }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img src="data/sectors/default.jpg" />
        <div
          :class="`force-${ownerTheme(sector.owner)}`"
          class="marker"></div>
        <div class="marker-label">
          {{ sector.victory_points }}
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
              <h2>{{ $t(`card.sector.repartition`) }}</h2>

              <div
                v-for="(f, i) in sector.division"
                :key="i"
                class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`data.faction.${getOwner(f.faction)}.name`) }}</div>
                  <div>
                    <strong>{{ f.points }}</strong>
                  </div>
                </div>
                <div class="skills-line">
                  <span
                    :style="`width: ${f.points / totalPoints * 100}%;`"
                    :class="`force-color-${ownerTheme(f.faction)}`">
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';

export default {
  name: 'sector-card',
  mixins: [CardMixin],
  props: {
    sector: {
      type: Object,
      required: true,
    },
  },
  computed: {
    totalPoints() { return this.sector.division.reduce((acc, x) => acc + x.points, 0); },
  },
  methods: {
    getOwner(faction) { return faction || 'neutral'; },
    ownerTheme(faction) { return this.$store.getters['game/themeByKey'](faction); },
  },
};
</script>
