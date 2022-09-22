<template>
  <div
    v-if="isQueueOpen || production"
    :class="{ 'has-background': production }"
    class="system-production">
    <template v-if="production">
      <div class="system-production-header">
        <template v-if="productionType === 'building'">
          <svgicon :name="`stellar_body/${body.type}`" />
          <span>{{ $t('production.build_on') }}</span>
          <strong>{{ body.name }}</strong>
        </template>
        <template v-else>
          <svgicon name="agent/admiral" />
          <span>{{ $t('production.order_for') }}</span>
          <strong>{{ character.name }}</strong>

          <div
            class="header-button"
            @click="showAllShips = !showAllShips">
            <span
              v-tooltip="$t('production.hide_all_ships')"
              v-if="showAllShips">−</span>
            <span
              v-tooltip="$t('production.shows_all_ships')"
              v-else>+</span>
          </div>
        </template>
      </div>
      <v-scrollbar
        :settings="{ wheelPropagation: false }"
        class="system-production-content">
        <div
          v-for="category in categories"
          :key="category"
          class="system-production-category">
          <div
            v-for="{ data, status, message } in itemByCategory(category)"
            :key="data.key">
            <div
              class="tile"
              :class="{
                'is-hoverable': status === 'buildable',
                'has-dashed-background': status === 'locked',
              }"
              @click="order(data, status, productionType)"
              @mouseenter="enterTile(data, message, productionType)"
              @mouseleave="leaveTile()">
              <svgicon
                v-if="status === 'locked'"
                class="tile-icon is-transparent is-small"
                name="unlock" />
              <template v-else>
                <svgicon
                  v-if="productionType === 'building'"
                  class="tile-icon"
                  :name="`building/${data.key}`"
                  :class="{ 'is-transparent': status === 'disabled' }" />
                <svgicon
                  v-else
                  class="tile-icon"
                  :name="`ship/${data.key}`"
                  :class="{ 'is-transparent': status === 'disabled' }" />
              </template>
            </div>
          </div>
        </div>
      </v-scrollbar>
      <div
        v-if="hoveredTile.type === 'building'"
        class="system-production-building-card">
        <building-card
          :buildingKey="hoveredTile.data.key"
          :level="1"
          :body="body"
          :system="system"
          :showCost="true"
          :theme="color"
          :disabled="hoveredTile.message" />
      </div>
      <div
        v-if="hoveredTile.type === 'ship'"
        class="system-production-ship-card">
        <ship-card
          :shipKey="hoveredTile.data.key"
          :showCost="true"
          :theme="color"
          :system="system"
          :disabled="hoveredTile.message"
          :initialXP="0" />
      </div>
    </template>
    <v-scrollbar
      :settings="{ wheelPropagation: false }"
      v-else-if="isQueueOpen && system.queue"
      class="system-production-queue"
      style="width: 310px;">
      <closed-production-card
        v-for="item in productions"
        :key="`production-${item.id}`"
        :production="item"
        :systemId="system.id"
        :theme="color" />
    </v-scrollbar>
  </div>
</template>

<script>
import { i18n } from '@/plugins/i18n';

import buildingValidation from '@/utils/buildingValidation';

import BuildingCard from '@/game/components/card/BuildingCard.vue';
import ShipCard from '@/game/components/card/ShipCard.vue';
import ClosedProductionCard from '@/game/components/card/ClosedProductionCard.vue';

export default {
  name: 'system-production',
  data() {
    return {
      hoveredTile: {},
      showAllShips: false,
    };
  },
  props: {
    system: Object,
    color: String,
    isQueueOpen: Boolean,
  },
  computed: {
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    production() { return this.$store.state.game.production; },
    character() { return this.$store.state.game.selectedCharacter; },
    patents() { return this.$store.state.game.player.patents; },
    productionType() {
      return this.production
        ? this.production.data.type : '';
    },
    body() {
      return this.productionType === 'building'
        ? this.getBody(this.system, this.production.data.targetId)
        : null;
    },
    tile() {
      return this.productionType === 'building'
        ? this.body.tiles.find((t) => t.id === this.production.data.tileId)
        : null;
    },
    categories() {
      const categories = this.items.reduce((acc, item) => {
        if (this.productionType === 'building') {
          return acc.add(item.data.display);
        }
        return acc.add(item.data.class);
      }, new Set());

      return Array.from(categories);
    },
    items() {
      return this.productionType === 'building'
        ? this.buildings : this.ships;
    },
    productions() {
      return this.system.queue.queue.reduce((acc, item) => {
        acc.prod += item.remaining_prod;

        const remainingTicks = acc.prod / this.system.production.value;
        item.timestamp = Math.round(this.system.receivedAt + (remainingTicks * this.tickToMilisecondFactor));
        acc.queue.push(item);
        return acc;
      }, { queue: [], prod: 0 }).queue;
    },
    buildings() {
      const { biome } = this.$store.state.game.data.stellar_body
        .find((s) => s.key === this.body.type);

      return this.$store.state.game.data.building
        .filter((b) => b.biome === biome && b.type === this.tile.type)
        .map((b) => {
          const { patent } = b.levels[0];

          let status = 'buildable';
          let message = '';

          if (patent !== null && !this.patents.some((p) => p === patent)) {
            const patentName = i18n.t(`data.patent.${patent}.name`);
            status = 'locked';
            message = this.$t('production.patent_needed', { patentName });
          }

          if (b.limitation === 'unique_body' && this.body.tiles.find((t) => t.building_key === b.key)) {
            status = 'disabled';
            message = this.$t('production.unique_building');
          }

          if (b.limitation === 'unique_system' && this.buildingExist(this.system.bodies, b.key)) {
            status = 'disabled';
            message = this.$t('production.unique_system');
          }

          return { data: b, status, message };
        });
    },
    ships() {
      let ships = this.$store.state.game.data.ship
        .map((s) => {
          const { shipyard, patent } = s;

          let status = 'buildable';
          let message = '';

          if (shipyard && !this.buildingBuilt(this.system.bodies, shipyard)) {
            const buildingName = i18n.t(`data.building.${shipyard}.name`);
            status = 'locked';
            message = this.$t('production.building_needed', { buildingName });
          }

          const hasAncestorPatents = this.$store.state.game.data.ship
            .filter((s2) => s2.model === s.model && s2.unit_count < s.unit_count)
            .every((s2) => this.patents.some((p) => p === s2.patent));

          if (patent !== null && !(hasAncestorPatents && this.patents.some((p) => p === patent))) {
            const patentName = i18n.t(`data.patent.${patent}.name`);
            status = 'locked';
            message = this.$t('production.patent_needed', { patentName });
          }

          return { data: s, status, message };
        });

      if (!this.showAllShips) {
        const models = ships.reduce((acc, ship) => {
          if (!acc[ship.data.model]) {
            acc[ship.data.model] = [];
          }

          acc[ship.data.model].push(ship);
          return acc;
        }, {});

        ships = Object.keys(models).map((key) => {
          const sorted = models[key].sort((a, b) => b.data.unit_count - a.data.unit_count);

          let ship = sorted.find((s) => s.status !== 'locked');
          if (!ship) {
            ship = sorted[sorted.length - 1];
          }

          return ship;
        });
      }

      return ships;
    },
  },
  methods: {
    enterTile(data, message, type) {
      this.hoveredTile = { data, message, type };
    },
    leaveTile() {
      this.hoveredTile = {};
    },
    order(item, status, type) {
      if (status === 'buildable') {
        const payload = type === 'building'
          ? { target_id: this.body.uid, tile_id: this.tile.id, prod_key: item.key, prod_level: 1, type: 'build' }
          : { target_id: this.character.id, tile_id: this.production.data.tileId, prod_key: item.key };

        if (type === 'building') {
          this.$ambiance.sound('order-building');
        } else {
          this.$ambiance.sound('order-ship');
        }

        this.$socket.player.push(`order_${type}`, {
          system_id: this.system.id,
          production_data: payload,
        }).receive('ok', () => {
          this.nextTile();
        }).receive('error', (data) => {
          this.$toastError(data.reason);
        });
      }
    },
    nextTile() {
      if (this.productionType === 'building') {
        const initial = { lookingNext: false, found: false };
        const data = {
          playerPatents: this.patents,
          bodiesData: this.$store.state.game.data.stellar_body,
          buildingsData: this.$store.state.game.data.building,
        };

        const location = buildingValidation
          .findEmptyTile(this.system.bodies, this.body.uid, this.tile.id, initial, data);

        if (location.found) {
          this.$store.commit('game/prepareProduction', {
            systemId: this.systemId,
            data: {
              type: 'building',
              targetId: location.body.uid,
              tileId: location.tile.id,
            },
          });
        } else {
          this.$store.commit('game/clearProduction');
        }
      } else {
        let tile = this.character.army.tiles
          .find((t) => t.id > this.production.data.tileId && t.ship_status === 'empty');

        if (!tile) {
          tile = this.character.army.tiles.find((t) => t.id > 0 && t.ship_status === 'empty');
        }

        if (tile && tile.id !== this.production.data.tileId) {
          this.$store.commit('game/prepareProduction', {
            systemId: this.character.system,
            data: {
              type: 'ship',
              targetId: this.character.id,
              tileId: tile.id,
            },
          });
        } else {
          this.$store.commit('game/clearProduction');
        }
      }
    },
    itemByCategory(category) {
      return this.productionType === 'building'
        ? this.items.filter((item) => item.data.display === category)
        : this.items.filter((item) => item.data.class === category);
    },
    getBody(system, bodyUId) {
      for (let i = 0; i < system.bodies.length; i += 1) {
        const body = system.bodies[i];
        if (body.uid === bodyUId) return body;

        const subbody = body.bodies.find((sb) => sb.uid === bodyUId);
        if (subbody) return subbody;
      }
      return null;
    },
    buildingExist(bodies, buildingKey) {
      return bodies.reduce((acc, body) => {
        const hasTiles = body.tiles.some((t) => t.building_key === buildingKey);
        const subs = this.buildingExist(body.bodies, buildingKey);

        return acc || hasTiles || subs;
      }, false);
    },
    buildingBuilt(bodies, buildingKey) {
      return bodies.reduce((acc, body) => {
        const hasTiles = body.tiles
          .some((t) => t.building_key === buildingKey && t.building_status === 'built');
        const subs = this.buildingBuilt(body.bodies, buildingKey);

        return acc || hasTiles || subs;
      }, false);
    },
  },
  components: {
    BuildingCard,
    ShipCard,
    ClosedProductionCard,
  },
};
</script>
