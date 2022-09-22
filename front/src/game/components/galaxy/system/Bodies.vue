<template>
  <div>
    <system-population-status
      v-if="system.population && system.population_status !== 'normal'"
      :system="system"
      :color="color" />

    <div
      class="system-content-group"
      v-for="body in system.bodies"
      :key="body.id"
      :class="{
        'hovered': body.id === hoveredOrbit,
        'active': hasBuilding(body),
      }"
      @mouseover="$emit('enterOrbit', body.id)"
      @mouseleave="$emit('leaveOrbit')">
      <div class="system-content-group-header">
        <div
          v-if="
            (body.id === 4 && [3, 5, 9, 16].includes(tutorialStep)) ||
            (body.id === 1 && [18, 21].includes(tutorialStep)) ||
            (body.id === 5 && [20].includes(tutorialStep))"
          class="tutorial-pointer is-right">
        </div>
        <div class="main">
          {{ body.name }}
          <span
            class="small"
            v-if="['asteroid_belt', 'gaseous_giant'].includes(body.type)">
            / {{ $t(`data.stellar_body.${body.type}.name`) }}
          </span>
        </div>
        <div
          v-if="body.population === 'hidden'"
          class="secondary">
          <span
            class="potential-item"
            v-tooltip="$t(`data.bonus_pipeline_in.body_pop.name`)">
            <span>░░░</span>
            <svgicon name="stellar_body/population" />
          </span>
        </div>
        <div
          v-else-if="body.population > 0"
          class="secondary">
          <span
            class="potential-item"
            :class="{
              'f-1': body.population < 5,
              'f-5': body.population > 12,
            }"
            v-tooltip="$t(`data.bonus_pipeline_in.body_pop.name`)">
            <span>{{ body.population }}</span>
            <svgicon name="stellar_body/population" />
          </span>
        </div>
      </div>

      <system-bodies-item
        :body="body"
        :isOwnSystem="isOwnSystem"
        :system="system"
        :visibility="system.contact.value"
        @enterTile="enterTile"
        @leaveTile="leaveTile" />
      <system-bodies-item
        v-for="subbody in body.bodies"
        :key="subbody.uid"
        :body="subbody"
        :isOwnSystem="isOwnSystem"
        :system="system"
        :visibility="system.contact.value"
        @enterTile="enterTile"
        @leaveTile="leaveTile" />
    </div>

    <div
      v-if="hoveredTile && system.contact.value === 5"
      :class="{ 'has-margin-bottom': hoveredTile.showCost }"
      class="system-building-card">
      <building-card
        :buildingKey="hoveredTile.tile.building_key"
        :level="hoveredTile.tile.building_level"
        :body="hoveredTile.body"
        :system="system"
        :theme="color"
        :showCost="hoveredTile.showCost" />
    </div>
  </div>
</template>

<script>
import SystemPopulationStatus from '@/game/components/galaxy/system/PopulationStatus.vue';
import SystemBodiesItem from '@/game/components/galaxy/system/BodiesItem.vue';
import BuildingCard from '@/game/components/card/BuildingCard.vue';

export default {
  name: 'system-bodies',
  data() {
    return {
      hoveredTile: undefined,
    };
  },
  props: {
    system: Object,
    isOwnSystem: Boolean,
    hoveredOrbit: Number,
    color: String,
  },
  computed: {
    patents() { return this.$store.state.game.player.patents; },
    tutorialStep() { return this.$store.state.game.tutorialStep; },
  },
  methods: {
    enterTile({ body, tile, wantToUpgrade }) {
      if (tile.building_key !== 'hidden') {
        tile.building_level = tile.building_level ? tile.building_level : 1;
        tile.building_level = wantToUpgrade ? tile.building_level + 1 : tile.building_level;

        this.hoveredTile = { body, tile, showCost: wantToUpgrade };
      }
    },
    leaveTile() {
      this.hoveredTile = undefined;
    },
    hasBuilding(orbit) {
      return orbit.tiles
        .concat(orbit.bodies.reduce((acc, body) => acc.concat(body.tiles), []))
        .find((t) => t.building_status !== 'empty' && t.building_status !== 'hidden') !== undefined;
    },
  },
  components: {
    SystemBodiesItem,
    BuildingCard,
    SystemPopulationStatus,
  },
};
</script>
