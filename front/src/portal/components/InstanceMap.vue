<template>
  <div class="instance-map">
    <svg
      :width="size"
      :height="size"
      version="1.1"
      xmlns="http://www.w3.org/2000/svg"
      class="instance-map-container">
      <defs>
        <filter x="0" y="0" width="1" height="1" id="text-background">
          <feFlood flood-color="black" result="bg" />
          <feMerge>
            <feMergeNode in="bg"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <g class="systems">
        <circle
          v-for="s in scenario.game_data.systems"
          :key="`system-${s.key}`"
          :cx="resize(s.position.x)"
          :cy="resize(revert(s.position.y))"
          :class="s.type"
          class="system" />
      </g>
      <g class="sectors">
        <polygon
          v-for="s in scenario.game_data.sectors"
          :key="`sector-${s.key}`"
          :points="offsetPolygon(s.points, 0.5).flat().map(p => resize(p)).join()"
          class="sector"
          :class="[
            getTheme(s.faction),
            { 'is-active': s.faction  === selected },
          ]" />
      </g>
      <g class="blackholes">
        <circle
          v-for="b in scenario.game_data.blackholes"
          :key="`b-${b.key}`"
          :cx="resize(b.position.x)"
          :cy="resize(revert(b.position.y))"
          :r="resize(b.radius)"
          class="blackhole" />
      </g>
       <g class="names">
        <text
          v-for="s in scenario.game_data.sectors"
          :key="`sector-label-${s.key}-name`"
          :x="resize(s.centroid[0])"
          :y="resize(revert(s.centroid[1])) - 16"
          class="sector-name is-large"
          filter="url(#text-background)">
          {{ s.name }}
        </text>
        <text
          v-for="s in scenario.game_data.sectors"
          :key="`sector-label-${s.key}-points`"
          :x="resize(s.centroid[0])"
          :y="resize(revert(s.centroid[1]))"
          class="sector-name"
          filter="url(#text-background)">
          {{ $t('portal_components.instance_map.point_count', { count: s.victory_points }) }}
        </text>
        <text
          v-for="s in scenario.game_data.sectors"
          :key="`sector-label-${s.key}-systems`"
          :x="resize(s.centroid[0])"
          :y="resize(revert(s.centroid[1])) + 16"
          class="sector-name"
          filter="url(#text-background)">
          {{ $t('portal_components.instance_map.system_count', { count: s.systems.length }) }}
        </text>
      </g>
    </svg>

    <div class="instance-map-details">
      <div class="detail-item">
        <div class="detail-label">{{ $t('portal_components.instance_map.size') }}</div>
        <div class="detail-value">{{ $t(`map.size.${scenario.game_metadata.size}.toast`) }}</div>
      </div>

      <div class="detail-item">
        <div class="detail-label">{{ $t('portal_components.instance_map.speed') }}</div>
        <div class="detail-value">{{ $t(`data.speed.${scenario.game_metadata.speed}.name`) }}</div>
      </div>

      <div class="detail-item">
        <div class="detail-label">{{ $t('portal_components.instance_map.systems') }}</div>
        <div class="detail-value">{{ scenario.game_metadata.system_number }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import Offset from 'polygon-offset';

export default {
  name: 'instance-map',
  props: {
    size: Number,
    scenario: Object,
    selected: {
      required: false,
      type: String,
    },
  },
  computed: {
    data() { return this.$store.state.portal.data; },
  },
  methods: {
    getTheme(key) {
      if (this.data.faction) {
        return key
          ? `theme-${this.data.faction.find((f) => f.key === key).theme}`
          : '';
      }
    },
    offsetPolygon(points, size = 0.2) {
      const revertedPoints = points.map((coord) => [coord[0], this.revert(coord[1])]);
      const offset = new Offset();
      const p = offset.data(revertedPoints).padding(0);

      return offset.data(p).padding(size)[0];
    },
    resize(value) {
      return value * (this.size / this.scenario.game_metadata.size);
    },
    revert(value) {
      return this.scenario.game_metadata.size - value;
    },
  },
};
</script>
