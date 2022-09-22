<template>
  <div
    class="mp-container inverted"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.market.title') }}
      </div>
      <div class="mph-nav">
        <div
          v-for="tab in tabs"
          :key="tab"
          :class="{ 'active': activeTab === tab }"
          class="mph-nav-item"
          @click="switchTab(tab)">
          {{ $t(`minipanel.market.tabs.${tab}`) }}
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
        :style="{
          height: `${height}px`,
          padding: '25px',
         }">
        <template v-if="activeTab === 'buy'">
          <div
            v-if="offers.length > 0"
            class="mpc-offers-list">
            <market-offer
              v-for="offer in offers"
              :key="offer.id"
              :offer="offer"
              :button="'buy'"
              @buy="buy" />
          </div>

          <div
            v-else
            class="mpc-empty-state">
            <h2>{{ $t('minipanel.market.empty_state_buy_title') }}</h2>
            <p>{{ $t('minipanel.market.empty_state_buy_desc') }}</p>
          </div>
        </template>

        <market-sell
          v-else-if="activeTab === 'sell'"
          @created="created" />

        <template v-if="activeTab === 'own'">
          <div
            v-if="ownOffers.length > 0"
            class="mpc-offers-list">
            <market-offer
              v-for="offer in ownOffers"
              :key="offer.id"
              :offer="offer"
              :button="'cancel'"
              @cancel="cancel" />
          </div>

          <div
            v-else
            class="mpc-empty-state">
            <h2>{{ $t('minipanel.market.empty_state_own_title') }}</h2>
            <p>{{ $t('minipanel.market.empty_state_own_desc') }}</p>
          </div>
        </template>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
import MiniPanelMixin from '@/game/mixins/MiniPanelMixin';
import MarketSell from '@/game/components/mini-panel/market/MarketSell';
import MarketOffer from '@/game/components/mini-panel/market/MarketOffer';

export default {
  name: 'market-mini-panel',
  mixins: [MiniPanelMixin],
  data() {
    return {
      offers: [],
      ownOffers: [],
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    tabs() { return ['buy', 'sell', 'own']; },
  },
  methods: {
    fetch() {
      this.$socket.player
        .push('get_offers', {})
        .receive('ok', ({ offers }) => { this.offers = this.parseOffers(offers); })
        .receive('error', (data) => { this.$toastError(data.reason); });
    },
    fetchOwn() {
      this.$socket.player
        .push('get_own_offers', {})
        .receive('ok', ({ offers }) => { this.ownOffers = this.parseOffers(offers); })
        .receive('error', (data) => { this.$toastError(data.reason); });
    },
    cancel(offerId) {
      this.$socket.player.push('cancel_offer', {
        offer_id: offerId,
      }).receive('ok', () => {
        this.fetchOwn();
      }).receive('error', (data) => {
        this.$toastError(data.reason);
      });
    },
    buy(offerId) {
      this.$socket.player.push('buy_offer', {
        offer_id: offerId,
      }).receive('ok', () => {
        this.fetch();
        // this.fetchOwn(); ... signal ...
      }).receive('error', (data) => {
        this.$toastError(data.reason);
      });
    },
    parseOffers(offers) {
      return offers.map((offer) => {
        offer.data = JSON.parse(offer.data);
        offer.profile = this.$store.state.game.galaxy.players[offer.profile_id];
        return offer;
      });
    },
    created() {
      this.fetchOwn();
      this.switchTab('own');
    },
  },
  mounted() {
    this.fetch();
    this.fetchOwn();
  },
  components: {
    MarketSell,
    MarketOffer,
  },
};
</script>
