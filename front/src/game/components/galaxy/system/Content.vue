<template>
  <div
    ref="container"
    class="system-content-container">
    <template v-if="system.contact.value > 0">
      <div
        v-if="tabs.length > 1"
        class="system-content-menu">
        <div
          v-for="(tab, index) in tabs"
          class="system-tab-item"
          :key="`tab-${index}`"
          :class="{ 'active': index === activeTab }"
          @click="activeTab = index">
        </div>
      </div>

      <v-scrollbar
        v-if="system.bodies.length > 0"
        :settings="{ wheelPropagation: false }"
        class="system-content-scrollbar">
        <system-bodies
          v-if="activeTab >= 0 && tabs[activeTab].includes('bodies')"
          :system="system"
          :isOwnSystem="isOwnSystem"
          :color="color"
          :hoveredOrbit="hoveredOrbit"
          @enterOrbit="enterOrbit"
          @leaveOrbit="$emit('leaveOrbit')" />

        <system-details
          v-if="activeTab >= 0 && tabs[activeTab].includes('details')"
          :system="system"
          :isOwnSystem="isOwnSystem"
          :color="color" />

        <system-state
          v-if="activeTab >= 0 && tabs[activeTab].includes('state')"
          :system="system"
          :isOwnProperty="isOwnProperty"
          :color="color" />
      </v-scrollbar>

      <div
        v-else
        class="system-content-orphan">
        <div class="system-content-group-header">
          <div class="main">{{ $t(`system.empty_system.label`) }}</div>
        </div>
        <p>{{ $t(`system.empty_system.content`) }}</p>
      </div>
    </template>

    <template v-else>
      <div class="system-content-orphan">
        <div class="system-content-group-header">
          <div class="main">{{ $t(`system.hidden_system.label`) }}</div>
        </div>
        <p>{{ $t(`system.hidden_system.content`) }}</p>
      </div>
    </template>
  </div>
</template>

<script>
import { TimelineLite, Expo } from 'gsap';

import SystemBodies from '@/game/components/galaxy/system/Bodies.vue';
import SystemDetails from '@/game/components/galaxy/system/Details.vue';
import SystemState from '@/game/components/galaxy/system/State.vue';

export default {
  name: 'system-content',
  data() {
    return {
      activeTab: 0,
    };
  },
  props: {
    system: Object,
    isOwnSystem: Boolean,
    isOwnProperty: Boolean,
    color: String,
    hoveredOrbit: Number,
  },
  computed: {
    tabs() {
      if (['uninhabitable', 'uninhabited'].includes(this.system.status)) {
        return [['bodies', 'state']];
      }
      return [['bodies'], ['details'], ['state']];
    },
  },
  methods: {
    enterOrbit(orbitId) {
      this.$emit('enterOrbit', orbitId);
    },
  },
  mounted() {
    new TimelineLite()
      .set(this.$refs.container, { left: -500 })
      .to(this.$refs.container, { left: 0, ease: Expo.easeOut, duration: 1 }, 0);
  },
  components: {
    SystemBodies,
    SystemDetails,
    SystemState,
  },
};
</script>
