<template>
  <div class="mp-content-wrapper">
    <div class="mpc-header is-sparse-x">
      <div>
        <h2>{{ $t('minipanel.market.sell') }}</h2>
        <p
          v-if="offerType"
          @click="reset"
          class="info">
          {{ $t('minipanel.market.back') }}
        </p>
      </div>
    </div>

    <div v-if="!offerType">
      <div class="mpc-offers-list">
        <div
          v-for="type in offerTypes"
          :key="type"
          @click="offerType = type"
          class="mpc-offer-item is-header">
          {{ $t(`minipanel.market.types.${type}`) }}
        </div>
      </div>
    </div>

    <div
      v-if="offerType === 'character_deck' && !deckAgent"
      class="mpc-characters-list">
      <closed-character-card
        v-for="character in characters"
        :key="character.id"
        :character="character"
        :theme="theme"
        @click.native="deckAgent = character" />

      <span v-if="characters.length === 0">
        {{ $t('minipanel.market.characters_empty_state') }}
      </span>
    </div>

    <div
      v-if="offerType === 'board_character' && !boardAgent"
      class="mpc-characters-list">
      <closed-character-card
        v-for="character in characters"
        :key="character.id"
        :character="character"
        :theme="theme"
        @click.native="boardAgent = character" />

      <span v-if="characters.length === 0">
        {{ $t('minipanel.market.characters_empty_state') }}
      </span>
    </div>

    <template v-if="
      ['technology', 'ideology'].includes(offerType)
      || (offerType === 'character_deck' && deckAgent)
      || (offerType === 'board_character' && boardAgent)">
      <div class="mpc-form" style="margin-right: 10px;">
        <div class="mpc-form-bloc">
          <div
            class="mpc-h-input"
            v-if="['technology', 'ideology'].includes(offerType)">
            <label for="mpc-quantity">{{ $t('minipanel.market.quantity') }}</label>
            <div class="mpc-h-input-i">
              <input
                id="mpc-quantity"
                v-model.number="amount">
              <svgicon :name="`resource/${offerType}`" />
            </div>
          </div>

          <div
            class="mpc-character-input"
            v-if="offerType === 'character_deck'">
            <closed-character-card
              :character="deckAgent"
              :theme="theme" />
          </div>

          <div
            class="mpc-character-input"
            v-if="offerType === 'board_character'">
            <closed-character-card
              :character="boardAgent"
              :theme="theme" />
          </div>

          <div class="mpc-h-input">
            <label for="mpc-price">{{ $t('minipanel.market.price') }}</label>
            <div class="mpc-h-input-i">
              <input
                id="mpc-price"
                v-model.number="price">
              <svgicon name="resource/credit" />
            </div>
          </div>

          <div class="mpc-h-input">
            <label for="mpc-fees">
              {{ $t('minipanel.market.fees') }} ({{ (marketTaxe * 100) | float(1) }}%)
            </label>
            <div class="mpc-h-input-i">
              <input
                id="mpc-fees"
                disabled="true"
                :value="fees | integer">
              <svgicon name="resource/credit" />
            </div>
          </div>

          <div class="mpc-h-input">
            <label for="mpc-final">
              {{ $t('minipanel.market.final_price') }}
            </label>
            <div class="mpc-h-input-i">
              <input
                id="mpc-final"
                disabled="true"
                :value="(price + fees) | integer">
              <svgicon name="resource/credit" />
            </div>
          </div>
        </div>
      </div>
      <div class="mpc-form">
        <div class="mpc-form-bloc">
          <div class="mpc-v-input">
            <profile-select
              v-if="allowedFactions.length === 0"
              :label="$t('minipanel.market.allowed_players')"
              :instanceId="instanceId"
              :initials="profiles"
              :discardedIds="[profile.id]"
              :multiple="true"
              v-model="allowedPlayers" />
          </div>
          <div class="mpc-v-input">
            <faction-select
              v-if="allowedPlayers.length === 0"
              :label="$t('minipanel.market.allowed_factions')"
              :factions="factions"
              :multiple="true"
              v-model="allowedFactions" />
          </div>
        </div>

        <div class="mpc-form-bloc">
          <button
            class="mpc-button"
            @click="create">
            <div>{{ $t('minipanel.market.publish') }}</div>
          </button>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import ProfileSelect from '@/game/components/generic/ProfileSelect.vue';
import FactionSelect from '@/game/components/generic/FactionSelect.vue';
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ClosedCharacterCard from '@/game/components/card/ClosedCharacterCard.vue';

export default {
  name: 'market-sell',
  data() {
    return {
      offerTypes: ['technology', 'ideology', 'character_deck', 'board_character'],
      allowedPlayers: [],
      allowedFactions: [],
      offerType: null,
      deckAgent: null,
      boardAgent: null,
      amount: 1000,
      price: 0,
    };
  },
  computed: {
    instanceId() { return parseInt(this.$store.state.game.auth.instance, 10); },
    theme() { return this.$store.getters['game/theme']; },
    marketTaxe() { return this.$store.state.game.data.constant[0].market_taxe; },
    profile() { return this.$store.state.game.player; },
    profiles() {
      const players = this.$store.state.game.galaxy.players;
      return Object.keys(players).map((key) => ({ label: players[key].name, id: players[key].id }));
    },
    factions() {
      return this.$store.state.game.victory
        .factions.map((f) => ({ label: this.$t(`data.faction.${f.key}.name`), id: f.id }));
    },
    characters() {
      if (this.offerType === 'character_deck') {
        return this.$store.state.game.player.character_deck
          .filter(({ cooldown }) => !cooldown || cooldown.value === 0)
          .map(({ character }) => character)
          .filter((character) => !character.on_sold);
      }

      if (this.offerType === 'board_character') {
        return this.$store.state.game.player.characters
          .filter((character) => character.action_status === 'idle' && !character.on_sold);
      }

      return [];
    },
    offerValue() {
      if (!this.offerType) return 0;

      if (['technology', 'ideology'].includes(this.offerType)) {
        return this.amount * 10;
      }

      if (this.offerType === 'character_deck') {
        if (!this.deckAgent) return 0;
        return this.deckAgent.level * 50_000;
      }

      if (this.offerType === 'board_character') {
        if (!this.boardAgent) return 0;
        return this.boardAgent.level * 50_000 + this.boardAgent.army_maintenance * 250;
      }

      return 0;
    },
    fees() {
      return this.offerValue * this.marketTaxe;
    },
  },
  watch: {
    offerValue(val) {
      this.price = val;
    },
  },
  methods: {
    create() {
      if (!Number.isInteger(this.price) || this.price < 0 || this.price > 10000000000) {
        this.$toastError('wrong_market_price');
        return;
      }

      const payload = {};

      if (['technology', 'ideology'].includes(this.offerType)) {
        payload.amount = Number.isInteger(this.amount) && this.amount > 0 ? this.amount : 0;
      } else if (this.offerType === 'character_deck') {
        payload.character_id = this.deckAgent.id;
      } else if (this.offerType === 'board_character') {
        payload.character_id = this.boardAgent.id;
      }

      this.$socket.player.push('create_offer', { 
        type: this.offerType,
        data: payload,
        price: this.price,
        allowed_players: this.allowedPlayers.map((p) => p.id),
        allowed_factions: this.allowedFactions.map((f) => f.id),
      }).receive('ok', () => {
        this.reset();
        this.$emit('created');
      }).receive('error', (data) => {
        this.$toastError(data.reason);
      });
    },
    reset() {
      this.allowedPlayers = [];
      this.allowedFactions = [];
      this.offerType = null;
      this.deckAgent = null;
      this.boardAgent = null;
      this.amount = 1000;
      this.price = 0;
    }
  },
  components: {
    ProfileSelect,
    FactionSelect,
    CharacterCard,
    ClosedCharacterCard,
  },
};
</script>
