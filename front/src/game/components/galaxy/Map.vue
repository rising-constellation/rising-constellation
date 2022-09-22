<template>
  <div>
    <div
      v-show="this.view === 'map'"
      class="map-options">
      <div class="map-options-group">
        <div
          class="map-options-item"
          v-tooltip="$t(`galaxy.map.modes.character-label`)"
          :class="{ 'is-active': mapOptions.showCharacterLabel }"
          @click="updateMapOptions('showCharacterLabel', !mapOptions.showCharacterLabel)">
          <svgicon name="bookmark" />
        </div>
      </div>
      <div class="map-options-group">
        <div
          class="map-options-item"
          v-for="mode in modes"
          v-tooltip="$t(`galaxy.map.modes.${mode.key}`)"
          :key="mode.key"
          :class="{ 'is-active': mode.key === mapOptions.mode }"
          @click="updateMapOptions('mode', mode.key)">
          <svgicon :name="mode.icon" />
        </div>
      </div>
    </div>
    <div class="map-cross">
      <div class="map-cross-a"></div>
      <div class="map-cross-b"></div>
    </div>
    <div
      v-show="this.view === 'map'"
      class="map-position">
      <div class="map-position-xy">
        {{ mapPosition.x }}:{{ mapPosition.y }}
      </div>
    </div>
    <div
      v-if="activeSector"
      class="map-overlay">
      <sector-card :sector="activeSector" />
    </div>
    <div ref="mapcontainer"></div>
  </div>
</template>

<script>
import * as THREE from 'three';
import Map from '@/game/map/map';

import SectorCard from '@/game/components/card/SectorCard.vue';

// declare it outside of the component because we don't want it to be 'Observe'd by Vue,
// it would slow things down and potentially mess with the map object.
let map;

export default {
  name: 'universe-map',
  props: {
    data: Object,
  },
  data() {
    return {
      modes: [
        { key: 'population', icon: 'layers' },
        { key: 'visibility', icon: 'eye' },
        { key: 'radar', icon: 'disc' },
      ],
    };
  },
  computed: {
    view() { return this.$store.state.game.view; },
    mapOptions() { return this.$store.state.game.mapOptions; },
    mapPosition() { return this.$store.state.game.mapPosition; },
    activeSector() {
      if (this.$store.state.game.mapOverlay) {
        if (this.$store.state.game.mapOverlay.type === 'sector') {
          return this.$store.state.game.galaxy.sectors
            .find((s) => s.id === this.$store.state.game.mapOverlay.data);
        }
      }

      return null;
    },
  },
  methods: {
    updateMapOptions(key, value) {
      if (value !== this.mapOptions.mode) {
        this.$store.commit('game/updateMapOptions', { key, value });
        this.data.forceRedrawRadars();
      }
    },
  },
  async mounted() {
    if (this.$store.state.game.time.speed === 'fast') {
      this.updateMapOptions('mode', 'radar');
    }

    const { mapcontainer } = this.$refs;

    const fov = 30;
    const camera = new THREE.PerspectiveCamera(fov, mapcontainer.clientWidth / mapcontainer.clientHeight, 1, 1500);
    const scene = new THREE.Scene();
    const renderer = new THREE.WebGLRenderer({ antialias: true });

    renderer.setSize(mapcontainer.clientWidth, mapcontainer.clientHeight);
    mapcontainer.appendChild(renderer.domElement);

    map = new Map({
      scene,
      camera,
      renderer,
      fov,
      $root: this.$root,
      vm: this,
      data: this.data,
      $socket: this.$socket,
      $$toasted: this.$$toasted,
    });

    await map.init();
    map.onZ(camera.position.z);
    map.bindEvents();

    // background color
    renderer.setClearColor(0x000000, 1);
  },
  beforeDestroy() {
    map.destroy();
  },
  components: {
    SectorCard,
  },
};
</script>
