<template>
  <div
    class="mp-container"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.character_deck.title') }}
        <span class="small">
          {{ player.character_deck.length }}/{{ constant.max_character_in_deck }}
        </span>
      </div>
      <div class="mph-filter">
        <div
          class="mph-filter-item"
          :class="{
            'active': showAdmirals,
            'inactive': !showAdmirals && (showSpys || showSpeakers),
          }"
          @click="showAdmirals = !showAdmirals">
          {{ $tc(`data.character.admiral.name`, 2) }}
        </div>
        <div
          class="mph-filter-item"
          :class="{
            'active': showSpys,
            'inactive': !showSpys && (showAdmirals || showSpeakers),
          }"
          @click="showSpys = !showSpys">
          {{ $tc(`data.character.spy.name`, 2) }}
        </div>
        <div
          class="mph-filter-item"
          :class="{
            'active': showSpeakers,
            'inactive': !showSpeakers && (showAdmirals || showSpys),
          }"
          @click="showSpeakers = !showSpeakers">
          {{ $tc(`data.character.speaker.name`, 2) }}
        </div>
      </div>
      <div class="mph-close-button" @click="close"></div>
    </div>
    <v-scrollbar
      class="mp-scrollbar"
      :settings="{
        wheelPropagation: false,
        suppressScrollY: true,
        useBothWheelAxes: true,
      }">
      <div
        class="mp-content"
        :style="{ height: `${height}px` }">
        <div
          v-if="characterDeck.length === 0"
          class="mpc-empty-state">
          <h2>{{ $t('minipanel.character_deck.empty_state_title') }}</h2>
          <p>{{ $t('minipanel.character_deck.empty_state_market') }}</p>
          <p>{{ $t('minipanel.character_deck.empty_state_cost') }}</p>
        </div>
        <div class="mpc-card-list">
          <character-card
            v-for="{ cooldown, character } in characters"
            :key="character.id"
            :character="character"
            :theme="theme"
            :cooldown="cooldown"
            :receivedAt="player.receivedAt"
            :style="{ opacity: cardOpacity(character) }"
            @assign="assign"
            @dismiss="dismiss" />
        </div>
      </div>
    </v-scrollbar>

    <div
      class="flying-card-container"
      ref="flying">
      <character-card
        v-if="flyingCard"
        :character="flyingCard"
        :theme="theme" />
    </div>
  </div>
</template>

<script>
import { TimelineLite } from 'gsap';

import MiniPanelMixin from '@/game/mixins/MiniPanelMixin';
import CharacterCard from '@/game/components/card/CharacterCard.vue';

export default {
  name: 'character-deck-mini-panel',
  mixins: [MiniPanelMixin],
  data() {
    return {
      showAdmirals: false,
      showSpys: false,
      showSpeakers: false,
      flyingCard: null,
      frozenCharacters: [],
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    constant() { return this.$store.state.game.data.constant[0]; },
    player() { return this.$store.state.game.player; },
    characterDeck() {
      let characters = this.player.character_deck;
      if (this.showAdmirals || this.showSpys || this.showSpeakers) {
        characters = characters
          .filter((a) => (!this.showAdmirals ? (a.character.type !== 'admiral') : true))
          .filter((a) => (!this.showSpys ? (a.character.type !== 'spy') : true))
          .filter((a) => (!this.showSpeakers ? (a.character.type !== 'speaker') : true));
      }

      return Array.from(characters).sort((a, b) => b.character.experience.value - a.character.experience.value);
    },
    characters() {
      return this.frozenCharacters.length > 0
        ? this.frozenCharacters
        : this.characterDeck;
    },
  },
  methods: {
    assign({ systemId, character, mode, box }) {
      this.frozenCharacters = this.characterDeck;
      this.flyingCard = { ...character };

      const initial = {
        top: box.top,
        left: box.left,
        transform: 'rotate(0deg)',
        opacity: 1,
        display: 'block',
      };

      const final = mode === 'on_board'
        ? { top: box.top - 400, left: box.left + 100, transform: 'rotate(10deg)', duration: 0.5 }
        : { top: box.top - 400, left: box.left - 100, transform: 'rotate(-10deg)', duration: 0.5 };

      new TimelineLite({
        onComplete: () => {
          this.flyingCard = null;
        },
      }).set(this.$refs.flying, initial)
        .to(this.$refs.flying, final, 0)
        .to(this.$refs.flying, { opacity: 0, display: 'none', duration: 1 }, 0);

      this.$socket.player.push('activate_character', {
        system_id: systemId,
        character_id: character.id,
        mode,
      }).receive('ok', () => {
        setTimeout(() => {
          if (mode === 'on_board') {
            this.$store.dispatch('game/selectCharacter', { vm: this, id: character.id });
          }

          this.frozenCharacters = [];
          this.$emit('close');
        }, 250);
      }).receive('error', (data) => {
        this.flyingCard = null;
        this.$toastError(data.reason);
      });
    },
    dismiss({ character, box }) {
      this.frozenCharacters = this.characterDeck;
      this.flyingCard = { ...character };

      const initial = {
        top: box.top,
        left: box.left,
        transform: 'rotate(0deg)',
        opacity: 1,
        display: 'block',
      };

      new TimelineLite({
        onComplete: () => {
          this.flyingCard = null;
          this.frozenCharacters = [];
        },
      }).set(this.$refs.flying, initial)
        .to(this.$refs.flying, { top: box.top + 500, opacity: 0, display: 'none', duration: 0.5 }, 0);

      this.$socket.player.push('dismiss_character', {
        character_id: character.id,
      }).receive('error', (data) => {
        this.flyingCard = null;
        this.$toastError(data.reason);
      });
    },
    cardOpacity(character) {
      return this.flyingCard
        ? (character.id === this.flyingCard.id ? 0 : 1)
        : 1;
    },
  },
  components: {
    CharacterCard,
  },
};
</script>
