<template>
  <div
    class="army-container"
    :class="`context-${context}`">
    <template v-if="hasHeader">
      <div
        class="army-reactions"
        :class="`is-${halign}`">
        <div
          v-if="character.army.reaction"
          class="item active"
          v-tooltip.left="$t(`character_reaction.${character.army.reaction}`)">
          <svgicon :name="`reaction/${character.army.reaction}`" />
        </div>
        <div
          v-else
          class="item active">
          ?
        </div>

        <div
          v-if="context === 'selection'"
          class="hidden">
          <div
            v-for="reaction in reactions"
            v-tooltip.left="$t(`character_reaction.${reaction}`)"
            class="item"
            :key="reaction"
            @click="updateReaction(reaction)">
            <svgicon :name="`reaction/${reaction}`" />
          </div>
        </div>
      </div>
      <div class="army-header">
        <div>
          <div
            v-if="!character.army.repair_coef"
            class="def-list-prop">
            ░░ <svgicon name="ship/repair" />
          </div>
          <v-popover
            v-else
            trigger="hover">
            <div class="def-list-prop">
              {{ character.army.repair_coef.value | integer }}
              <svgicon name="ship/repair" />
            </div>
            <resource-detail
              slot="popover"
              :title="$t('galaxy.selection.view.army_repair')"
              :precision="0"
              :value="character.army.repair_coef.value"
              :details="character.army.repair_coef.details" />
          </v-popover>

          <div
            v-if="!character.army.raid_coef"
            class="def-list-prop">
            ░░ <svgicon name="ship/raid" />
          </div>
          <v-popover
            v-else
            trigger="hover">
            <div class="def-list-prop">
              {{ character.army.raid_coef.value | integer }}
              <svgicon name="ship/raid" />
            </div>
            <resource-detail
              slot="popover"
              :title="$t('galaxy.selection.view.army_raid')"
              :precision="0"
              :value="character.army.raid_coef.value"
              :details="character.army.raid_coef.details" />
          </v-popover>

          <div
            v-if="!character.army.invasion_coef"
            class="def-list-prop">
            ░░ <svgicon name="ship/invasion" />
          </div>
          <v-popover
            v-else
            trigger="hover">
            <div class="def-list-prop">
              {{ character.army.invasion_coef.value | integer }}
              <svgicon name="ship/invasion" />
            </div>
            <resource-detail
              slot="popover"
              :title="$t('galaxy.selection.view.army_invasion')"
              :precision="0"
              :value="character.army.invasion_coef.value"
              :details="character.army.invasion_coef.details" />
          </v-popover>
        </div>

        <div>
          <div
            v-if="!character.army.maintenance"
            class="def-list-prop">
            ░░░ <svgicon name="resource/credit" />
          </div>
          <v-popover
            v-else
            trigger="hover">
            <div class="def-list-prop">
              {{ character.army.maintenance.value | integer }}
              <svgicon name="resource/credit" />
            </div>
            <resource-detail
              slot="popover"
              :title="$t('galaxy.selection.view.army_maintenance')"
              :precision="0"
              :value="character.army.maintenance.value"
              :details="character.army.maintenance.details" />
          </v-popover>
        </div>
      </div>
    </template>

    <div
      class="army-line"
      v-for="i in character.army.tiles.length / armyLineSize"
      :key="i">
      <div class="header">
        {{ $t('galaxy.selection.view.line_short', {n: i}) }}
      </div>
      <div
        v-for="j in armyLineSize"
        :key="getTileIndex(i, j)">
        <template v-if="getTile(i, j).ship_status === 'filled'">
          <div
            class="tile"
            :class="{ 'is-destroyed': diff && getTile(i, j, true).ship_status === 'empty' }"
            @mouseenter="enterTile(getTile(i, j))"
            @mouseleave="leaveTile">
            <svgicon
              v-if="getTile(i, j).ship !== 'hidden'"
              class="tile-icon is-rotated"
              :name="`ship/${getTile(i, j).ship.key}`" />
            <svgicon
              v-else
              class="tile-icon is-rotated"
              name="ship/frame_ship_hidden" />
            <div class="tile-level">
              <template v-if="getTile(i, j).ship !== 'hidden' && getTile(i, j).ship.level !== 'hidden'">
                <template v-if="!diff">
                  {{ getTile(i, j).ship.level + 1 }}
                </template>
                <template v-else-if="getTile(i, j, true).ship_status !== 'empty'">
                  {{ getTile(i, j, true).ship.level + 1 }}
                </template>
              </template>
              <template v-else>?</template>
            </div>
            <div
              v-if="getTile(i, j).ship !== 'hidden' && getTile(i, j).ship.units !== 'hidden'"
              class="life-container">
              <template v-if="!diff">
                <div class= "life-content" :style="{ 'height': `${getTileLife(i, j)}%` }"></div>
              </template>
              <template v-else>
                <div class= "life-content is-fadded" :style="{ 'height': `${getTileLife(i, j)}%` }"></div>
                <template v-if="getTile(i, j, true).ship_status !== 'empty'">
                  <div class= "life-content" :style="{ 'height': `${getTileLife(i, j, true)}%` }"></div>
                </template>
              </template>
            </div>
            <div
              v-if="context === 'selection'"
              v-tooltip.bottom="$t('card.ship.scrap_ship')"
              class="tile-toast is-hidden bottom right is-active"
              @click="destroyShip(getTile(i, j).id)">
              <svgicon name="close" />
            </div>
          </div>
        </template>
        <template v-if="getTile(i, j).ship_status === 'planned'">
          <div
            class="tile"
            @mouseenter="enterTile(getTile(i, j))"
            @mouseleave="leaveTile">
            <svgicon
              class="tile-icon is-rotated is-transparent"
              :name="`ship/${getTile(i, j).ship.key}`" />
            <div
              v-tooltip.bottom="$t('card.ship.under_production')"
              class="tile-toast bottom left">
              <svgicon name="options" />
            </div>
          </div>
        </template>
        <template v-if="getTile(i, j).ship_status === 'empty'">
          <div
            :class="{
              'is-hoverable': isIdleAndAtHome,
              'is-active': isIdleAndAtHome && false,
              'has-dashed-background': context === 'selection' && !isIdleAndAtHome,
              'is-active': activeTile === getTile(i, j).id,
            }"
            class="tile"
            @click="clickTile(getTileIndex(i, j))">
            <svgicon
              v-if="context === 'selection' && !isIdleAndAtHome"
              class="tile-icon is-transparent is-small"
              name="unlock" />
          </div>
        </template>
      </div>
    </div>
    <div
      v-if="hoveredTile"
      class="army-ship-card"
      :class="`is-${valign} is-${halign}`">
      <ship-card
        :shipKey="hoveredTile.ship.key"
        :ship="hoveredTile.ship"
        :theme="theme" />
    </div>
  </div>
</template>

<script>
import ShipCard from '@/game/components/card/ShipCard.vue';
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';

export default {
  name: 'army',
  props: {
    character: Object,
    theme: String,
    diff: {
      type: Object,
      default: null,
    },
    halign: {
      type: String,
      default: 'left',
    },
    valign: {
      type: String,
      default: 'bottom',
    },
    context: {
      type: String,
      default: 'display',
    },
    isIdleAndAtHome: {
      type: Boolean,
      default: false,
    },
    hasHeader: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      hoveredTile: undefined,
      armyLineSize: 3,
      reactions: ['flee', 'fight_back', 'defend', 'attack_enemies', 'attack_everyone'],
    };
  },
  computed: {
    shipsData() { return this.$store.state.game.data.ship; },
    activeTile() {
      const production = this.$store.state.game.production;

      if (production && production.data.type === 'ship'
        && production.data.targetId === this.character.id) {
        return production.data.tileId;
      }
      return 0;
    },
  },
  methods: {
    clickTile(tileId) {
      if (this.context === 'selection') {
        const tile = this.character.army.tiles[tileId - 1];
        if (tile.ship_status === 'empty' && this.isIdleAndAtHome) {
          if (!this.$store.state.game.selectedSystem) {
            this.$store.dispatch('game/openSystem', {
              vm: this,
              id: this.character.system,
            }).then(() => {
              this.toggleProduction(tileId);
            });
          } else {
            this.toggleProduction(tileId);
          }
        }
      }
    },
    toggleProduction(tileId) {
      if (this.context === 'selection') {
        const active = this.activeTile;

        if (active) {
          this.$store.commit('game/clearProduction');
        }

        if (active !== tileId) {
          this.$ambiance.sound('open-production');
          this.$store.commit('game/prepareProduction', {
            systemId: this.character.system,
            data: {
              type: 'ship',
              targetId: this.character.id,
              tileId,
            },
          });
        }
      }
    },
    updateReaction(reaction) {
      if (this.context === 'selection') {
        if (this.character.type === 'admiral') {
          this.$socket.player.push('update_reaction', {
            character_id: this.character.id,
            reaction,
          }).receive('error', (data) => {
            this.$toastError(data.reason);
          });
        }
      }
    },
    destroyShip(tileId) {
      if (this.context === 'selection') {
        if (this.character.type === 'admiral') {
          this.$socket.player.push('destroy_ship', {
            character_id: this.character.id,
            tile_id: tileId,
          }).receive('ok', () => {
            this.leaveTile();
          }).receive('error', (data) => {
            this.$toastError(data.reason);
          });
        }
      }
    },
    getTileIndex(line, nth) {
      return ((line - 1) * this.armyLineSize) + nth;
    },
    getTile(line, nth, isDiff = false) {
      if (isDiff) {
        return this.diff.army
          ? this.diff.army.tiles[this.getTileIndex(line, nth) - 1]
          : { id: 0, ship_status: 'empty', ship: null };
      }

      return this.character.army.tiles[this.getTileIndex(line, nth) - 1];
    },
    getTileLife(line, nth, isDiff = false) {
      const tile = this.getTile(line, nth, isDiff);
      const shipData = this.shipsData.find((ship) => ship.key === tile.ship.key);

      const maxLife = shipData.unit_hull * shipData.unit_count;
      const currentLife = tile.ship.units.reduce((acc, unit) => unit.hull + acc, 0);

      return (currentLife / maxLife) * 100;
    },
    enterTile(payload) {
      if (payload.ship !== 'hidden') {
        this.hoveredTile = payload;
      }
    },
    leaveTile() {
      this.hoveredTile = undefined;
    },
  },
  components: {
    ResourceDetail,
    ShipCard,
  },
};
</script>
