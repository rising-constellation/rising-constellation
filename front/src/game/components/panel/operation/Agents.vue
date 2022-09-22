<template>
  <div class="panel-content is-small">
    <v-scrollbar class="has-padding">
      <section>
        <h1 class="panel-default-title">
          {{ $t('panel.operations.onboard') }}
          <span>{{ $t('panel.operations.onboard_subtitle') }}</span>
        </h1>

        <div
          class="pcb-character"
          v-for="character in onboards"
          :key="`onboard-${character.id}`"
          @click="openCharacter(character)">
          <div class="icon">
            <svgicon :name="`agent/${character.type}`" />
          </div>
          <div class="name">
            <strong>{{ character.name }}</strong>
            {{ $t(`data.character.${character.type}.specializations.${character.specialization}`) }}
          </div>
          <div class="level">
            {{ $t('panel.operations.level', { level: character.level }) }}
          </div>
        </div>
        <div
          v-if="onboards.length === 0"
          class="pcb-character-empty">
          {{ $t('panel.operations.no_onboard') }}
        </div>
      </section>

      <hr class="panel-default-hr">

      <section>
        <h1 class="panel-default-title">
          {{ $t('panel.operations.governors') }}
          <span>{{ $t('panel.operations.governors_subtitle') }}</span>
        </h1>

        <div
          class="pcb-character"
          v-for="character in governors"
          :key="`governor-${character.id}`"
          @click="openGovernor(character)">
          <div class="icon">
            <svgicon :name="`agent/${character.type}`" />
          </div>
          <div class="name">
            <strong>{{ character.name }}</strong>
            {{ $t(`data.character.${character.type}.specializations.${character.specialization}`) }}
          </div>
          <div class="level">
            {{ $t('panel.operations.level', { level: character.level }) }}
          </div>
        </div>
        <div
          v-if="governors.length === 0"
          class="pcb-character-empty">
          {{ $t('panel.operations.no_governors') }}
        </div>
      </section>

      <div class="anchor"></div>
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'operation-agents-panel',
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    onboards() { return this.$store.state.game.player.characters.filter((c) => c.status === 'on_board'); },
    governors() { return this.$store.state.game.player.characters.filter((c) => c.status === 'governor'); },
  },
  methods: {
    openGovernor(character) {
      this.$emit('close');
      this.$store.dispatch('game/openSystem', { vm: this, id: character.system });
      this.$store.dispatch('game/openCharacter', { vm: this, id: character.id });
    },
    openCharacter(character) {
      this.$emit('close');
      this.$root.$emit('map:centerToCharacter', character);
      this.$store.dispatch('game/openCharacter', { vm: this, id: character.id });
    },
  },
};
</script>
