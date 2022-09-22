<template>
  <div class="panel-content is-small">
    <v-scrollbar>
      <section class="panel-content-sheet">
        <h1 class="header">
          <svgicon :name="`faction/${faction.key}`" />
          <div class="title">
            {{ $t(`data.faction.${faction.key}.name`) }}
          </div>
        </h1>

        <div class="body">
          {{ $t(`data.faction.${faction.key}.description`) }}
        </div>
      </section>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'faction-about-panel',
  computed: {
    faction() { return this.$store.state.game.faction; },
  },
};
</script>
