<template>
  <div id="galaxy-container">
    <system-view
      v-if="selectedSystem"
      @closeStellarSystem="closeStellarSystemView" />

    <selection-view v-if="selection" />
  </div>
</template>

<script>
import SystemView from '@/game/components/galaxy/system/View.vue';
import SelectionView from '@/game/components/galaxy/selection/View.vue';

export default {
  name: 'galaxy-container',
  computed: {
    selectedSystem() { return this.$store.state.game.selectedSystem; },
    selection() { return this.$store.state.game.selectedCharacter; },
  },
  methods: {
    closeStellarSystemView() {
      this.$store.dispatch('game/closeSystem', this);
    },
    handleScroll(event) {
      if (this.selectedSystem && !(this.assignment) && event.deltaY > 0) {
        this.closeStellarSystemView();
      }
    },
  },
  mounted() {
    document.addEventListener('wheel', this.handleScroll);
  },
  destroyed() {
    document.removeEventListener('wheel', this.handleScroll);
  },
  components: {
    SystemView,
    SelectionView,
  },
};
</script>
