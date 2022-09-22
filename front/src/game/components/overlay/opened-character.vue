<template>
  <div
    @click.self="close"
    v-if="character && character.owner"
    :class="`f-${theme}`"
    class="opened-character-container">
    <div class="opened-character">
      <div class="opened-character-owner">
        <span v-html="$tmd('galaxy.opened_character.commanded_by', {characterName: character.owner.name})"/>
        <hr />
        <span v-html="$tmd('galaxy.opened_character.character_faction', {faction: character.owner.faction})"/>
      </div>

      <div class="opened-character-card">
        <character-card
          v-if="character"
          @deactivated="deactivateCharacter"
          :open="true"
          :character="character"
          :theme="theme"
          :lock="true" />
      </div>

      <div
        v-if="character.status === 'on_board'"
        class="opened-character-aside">
        <army
          v-if="character.type === 'admiral'"
          :theme="theme"
          :valign="'top'"
          :halign="'right'"
          :context="'display'"
          :character="character" />

        <spy
          v-if="character.type === 'spy'"
          :character="character" />

        <speaker
          v-if="character.type === 'speaker'"
          :character="character" />
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import Army from '@/game/components/galaxy/selection/Army.vue';
import Spy from '@/game/components/galaxy/selection/Spy.vue';
import Speaker from '@/game/components/galaxy/selection/Speaker.vue';

export default {
  name: 'opened-character',
  computed: {
    character() { return this.$store.state.game.openedCharacter; },
    theme() {
      return this.character?.owner && this.$store.getters['game/themeByKey'](this.character.owner.faction);
    },
  },
  methods: {
    close() {
      this.$store.dispatch('game/closeCharacter');
    },
    deactivateCharacter() {
      this.$store.dispatch('game/closeCharacter');
    },
  },
  components: {
    CharacterCard,
    Army,
    Spy,
    Speaker,
  },
};
</script>
