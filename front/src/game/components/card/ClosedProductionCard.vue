<template>
  <div
    class="card-container closed"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon
          v-if="production.type === 'ship'"
          :name="`ship/${production.prod_key}`" />
        <svgicon
          v-else
          :name="`building/${production.prod_key}`" />
        <span
          v-if="production.type === 'building'"
          class="level">
          {{ production.prod_level }}
        </span>
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          <template v-if="production.type === 'ship'">
            {{ $t(`data.ship.${production.prod_key}.name`) }}
          </template>
          <template v-else>
            <svgicon
              v-if="production.type ==='building' && production.prod_level > 1"
              v-tooltip="$t('card.building.production.upgrade')"
              class="title-toast"
              name="caret-up" />
            <svgicon
              v-else-if="production.type ==='building_repairs'"
              v-tooltip="$t('card.building.production.repair')"
              class="title-toast"
              name="check" />
            {{ $t(`data.building.${production.prod_key}.name`) }}
          </template>
        </div>
        <div
          v-if="speed !== 'fast'"
          class="title-small">
          {{ production.timestamp | luxon-std }}
        </div>
      </div>
      <div class="card-header-toast hidden">
        <svgicon
          @click="cancelProduction"
          name="close" />
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';

export default {
  name: 'closed-production-card',
  mixins: [CardMixin],
  props: {
    production: Object,
    systemId: Number,
  },
  computed: {
    speed() { return this.$store.state.game.time.speed; },
  },
  methods: {
    cancelProduction() {
      this.$socket.player.push('cancel_production', {
        system_id: this.systemId,
        production_id: this.production.id,
      }).receive('error', (data) => {
        this.$toastError(data.reason);
      });
    },
  },
};
</script>
