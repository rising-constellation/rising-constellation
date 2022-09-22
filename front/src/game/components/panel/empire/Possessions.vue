<template>
  <div class="panel-content is-large">
    <v-scrollbar class="has-padding">
      <section
        v-for="sector in possessions"
        :key="`sector-${sector.id}`">
        <h1 class="panel-default-title">
          {{ sector.name }}
          <span>
            {{ $tc('panel.empire.systems', sector.systems.length, { number: sector.systems.length }) }}
          </span>
        </h1>

        <div
          class="pcb-system"
          v-for="system in sector.systems"
          :key="system.id"
          @click="openSystem(system.id)">
          <div class="icon">
            <svgicon :name="`stellar_system/${system.type}`" />
          </div>
          <div class="name">
            {{ system.name }}
            <span
              class="is-small"
              v-if="system.status === 'inhabited_dominion'">
              ({{ $t('panel.empire.dominion') }})
            </span>
            <svgicon
              v-if="system.governor"
              :name="`agent/${system.governor.type}`" />
          </div>
          <div class="resource-toast">
            <div class="header">
              {{ system.production | integer }}
              <svgicon name="resource/production" />
            </div>
            <div
              class="toast active"
              v-show="system.queue > 0"
              v-html="$t('panel.empire.items_in_queue', { number: system.queue })">
            </div>
            <div
              class="toast"
              v-show="system.queue === 0">
              {{ $t('panel.empire.empty_queue') }}
            </div>
          </div>
          <div class="resource-toast">
            <div class="header">
              {{ system.workforce | integer }}
              <svgicon name="resource/population" /> /
              {{ system.habitation | integer }}
              <svgicon name="resource/habitation" />
            </div>
            <div
              class="toast"
              :class="{ active: system.happiness > 0 }">
              <strong>{{ system.happiness | integer }}</strong>
              {{ $t('panel.empire.stability') }}
            </div>
          </div>
          <div class="resource">
            <template v-if="system.credit > 0">
              {{ system.credit | integer }}
              <svgicon name="resource/credit" />
            </template>
          </div>
          <div class="resource">
            <template v-if="system.technology > 0">
              {{ system.technology | integer }}
              <svgicon name="resource/technology" />
            </template>
          </div>
          <div class="resource">
            <template v-if="system.ideology > 0">
              {{ system.ideology | integer }}
              <svgicon name="resource/ideology" />
            </template>
          </div>
          <div class="resource-toast">
            <div class="header">
              {{ system.defense | integer }}
              <svgicon name="resource/defense" />
            </div>
            <div
              class="toast active"
              v-show="system.radar > 1">
              {{ $t('panel.empire.active_radar') }}
            </div>
            <div
              class="toast"
              v-show="system.radar <= 1">
              {{ $t('panel.empire.inactive_radar') }}
            </div>
          </div>
        </div>
      </section>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'empire-possessions-panel',
  computed: {
    player() { return this.$store.state.game.player; },
    possessions() {
      const systemsAndDominion = this.player.stellar_systems.concat(this.player.dominions);

      return this.$store.state.game.galaxy.sectors
        .map((sector) => {
          const inSector = systemsAndDominion.filter((s) => s.sector_id === sector.id);
          return { id: sector.id, name: sector.name, systems: inSector };
        })
        .filter(({ systems }) => systems.length > 0);
    },
    theme() { return this.$store.getters['game/theme']; },
  },
  methods: {
    openSystem(id) {
      this.$emit('close');
      this.$store.dispatch('game/openSystem', { vm: this, id });
    },
  },
};
</script>
