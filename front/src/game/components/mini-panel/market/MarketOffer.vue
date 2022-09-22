<template>
  <div
    class="mpc-offer-item"
    :class="`theme-${theme}`">
    <div class="mpc-oi-header">
      <span class="mpc-oi-name">
        #{{ offer.id }}
        <span
          v-html="`<span class='is-color-${theme}'>${offer.profile.name}</span>`"
          @click="openPlayer(offer.profile.id)">
        </span>
      </span> 
      <span class="mpc-oi-date">{{ offer.inserted_at | date-short }}</span>
    </div>

    <div
      v-if="['character_deck', 'board_character'].includes(offer.type)"
      class="flying">
      <div class="fl-content">
        <character-card
          :character="offer.data.character"
          :theme="theme"
          :noAction="true" />

        <div
          class="fl-side-content"
          v-if="offer.type === 'board_character'">
          <army
            v-if="offer.data.character.type === 'admiral'"
            :theme="theme"
            :valign="'top'"
            :halign="'right'"
            :context="'display'"
            :character="offer.data.character" />

          <spy
            v-if="offer.data.character.type === 'spy'"
            :character="offer.data.character" />

          <speaker
            v-if="offer.data.character.type === 'speaker'"
            :character="offer.data.character" />
        </div>
      </div>
    </div>

    <div
      class="card-container closed"
      v-if="['technology', 'ideology'].includes(offer.type)">
      <div class="card-header">
        <div class="card-header-icon">
          <svgicon :name="`resource/${offer.type}`" />
        </div>
        <div class="card-header-content">
          <div class="title-large nowrap">
            {{ offer.data.amount | integer }}
            <svgicon
              :name="`resource/${offer.type}`"
              class="has-no-background" />
          </div>
          <div class="title-small nowrap">
            {{ offer.type }}
          </div>
        </div>
      </div>
    </div>

    <closed-character-card
      v-else
      :character="offer.data.character"
      :theme="theme" />

    <button
      v-if="button === 'buy'"
      @click="handelClick('buy')"
      v-tooltip="$t(
        'minipanel.market.tooltip',
        {price: $options.filters.integer(offer.price), fees: $options.filters.integer(fees)},
      )"
      class="default-button"
      :disabled="clicked">
      <div>{{ $t('minipanel.market.buy') }}</div>
      <div class="icon-value">
        {{ finalPrice | integer }}
        <svgicon name="resource/credit" />
      </div>
    </button>
    <button
      v-if="button === 'cancel'"
      @click="handelClick('cancel')"
      class="default-button"
      :disabled="clicked">
      <div>{{ $t('minipanel.market.cancel') }}</div>
    </button>
  </div>
</template>

<script>
import ClosedCharacterCard from '@/game/components/card/ClosedCharacterCard.vue';
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import Army from '@/game/components/galaxy/selection/Army.vue';
import Spy from '@/game/components/galaxy/selection/Spy.vue';
import Speaker from '@/game/components/galaxy/selection/Speaker.vue';

export default {
  name: 'market-mini-panel-offer',
  props: {
    offer: {
      type: Object,
      required: true,
    },
    button: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      clicked: false,
    };
  },
  computed: {
    fees() { return this.offer.value * this.$store.state.game.data.constant[0].market_taxe },
    finalPrice() { return this.offer.price + this.fees; },
    theme() {
      const player = this.$store.state.game.galaxy.players[this.offer.profile.id];
      return this.$store.getters['game/themeByKey'](player.faction);
    },
  },
  methods: {
    getPlayerTheme(name, pid) {
      if (!pid) return name;
      return `<span class="is-color-${theme}">${name}</span>`;
    },
    openPlayer(playerId) {
      this.$store.dispatch('game/openPlayer', { vm: this, id: playerId });
    },
    handelClick(mode) {
      if (!this.clicked) {
        this.clicked = true;
        this.$emit(mode, this.offer.id);
      }
    },
  },
  components: {
    ClosedCharacterCard,
    CharacterCard,
    Army,
    Spy,
    Speaker,
  },
};
</script>
