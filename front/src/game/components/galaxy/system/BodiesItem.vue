<template>
  <div v-if="validBodies.includes(body.type)">
    <div class="system-content-group-item">
      <div class="body-icon">
        <svgicon :name="`stellar_body/${body.type}`" />
      </div>
      <div class="body-info">
        <div class="body-info-type">
          {{ $t(`data.stellar_body.${body.type}.name`) }}
        </div>
        <div class="body-info-potentials">
          <div
            class="potential-item"
            :class="`f-${body.industrial_factor}`"
            v-tooltip="$t(`data.bonus_pipeline_in.body_ind.name`)">
            <span>{{ body.industrial_factor }}</span>
            <svgicon name="stellar_body/industrial_factor" />
          </div>
          <div
            class="potential-item"
            :class="`f-${body.technological_factor}`"
            v-tooltip="$t(`data.bonus_pipeline_in.body_tec.name`)">
            <span>{{ body.technological_factor }}</span>
            <svgicon name="stellar_body/technological_factor" />
          </div>
          <div
            class="potential-item"
            :class="`f-${body.activity_factor}`"
            v-tooltip="$t(`data.bonus_pipeline_in.body_act.name`)">
            <span>{{ body.activity_factor }}</span>
            <svgicon name="stellar_body/activity_factor" />
          </div>
        </div>
      </div>
      <div class="body-tiles">
        <div
          v-for="({ tile, status, icon, level, classes, iconClasses, actions }, index) in tiles"
          :key="index"
          :class="classes"
          class="tile"
          @click="clickTile(tile)">
          <template v-if="status === 'visible'">
            <svgicon
              class="tile-icon"
              :class="iconClasses"
              :name="icon"
              @mouseenter.native="enterTile(tile, body, false)"
              @mouseleave.native="leaveTile()" />
            <div
              v-if="!['none', 'hidden'].includes(tile.construction_status)"
              v-tooltip.bottom="$t(`card.building.production.${tile.construction_status}`)"
              class="tile-toast bottom left">
              <svgicon name="options" />
            </div>
            <div
              v-if="level"
              class="tile-level">
              {{ level }}
            </div>
            <template v-if="isOwnSystem">
              <div
                v-if="actions.includes('repair')"
                v-tooltip="$t('card.building.repair')"
                class="tile-toast top left is-active"
                @click.stop="buildTile(tile, 'repair')">
                <svgicon name="check" />
              </div>
              <div
                v-else-if="actions.includes('upgrade')"
                v-tooltip="$t('card.building.upgrade')"
                class="tile-toast top left is-active"
                @click.stop="buildTile(tile, 'build')"
                @mouseenter="enterTile(tile, body, true)"
                @mouseleave="leaveTile()">
                <svgicon name="caret-up" />
              </div>
              <div
                v-if="actions.includes('delete')"
                v-tooltip.bottom="$t('card.building.delete')"
                class="tile-toast is-hidden bottom right is-active"
                @click.stop="removeTile(tile)">
                <svgicon name="close" />
              </div>
            </template>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import buildingValidation from '@/utils/buildingValidation';

export default {
  name: 'system-bodies-item',
  data() {
    return {
      validBodies: [
        'habitable_planet',
        'sterile_planet',
        'moon',
        'asteroid',
      ],
    };
  },
  props: {
    body: Object,
    isOwnSystem: Boolean,
    system: Object,
    visibility: Number,
  },
  computed: {
    patents() { return this.$store.state.game.player.patents; },
    production() { return this.$store.state.game.production; },
    buildings() { return this.$store.state.game.data.building; },
    bodies() { return this.$store.state.game.data.stellar_body; },
    bodyData() { return this.bodies.find((b) => b.key === this.body.type); },
    tiles() {
      return [...Array(8).keys()]
        .map((i) => {
          const tile = this.body.tiles[i];
          const payload = {
            tile,
            status: '',
            icon: '',
            level: '',
            classes: [],
            iconClasses: [],
            actions: [],
          };

          if (tile === undefined) {
            payload.status = 'nonexistent';
            payload.classes.push('is-transparent');
            return payload;
          }

          if (tile.type === 'infrastructure') {
            payload.classes.push('is-important');
          }

          if (['uninhabitable', 'uninhabited'].includes(this.system.status)) {
            payload.status = 'hidden';
            payload.classes.push('is-fadded');
            return payload;
          }

          payload.status = 'visible';

          if (!this.isOwnSystem) {
            if (tile.building_status === 'hidden') {
              payload.classes.push('is-fadded');
              return payload;
            }

            if (tile.building_status === 'empty') {
              return payload;
            }

            if (tile.building_status === 'damaged') {
              payload.classes.push('has-dashed-background');
            }

            payload.status = 'visible';
            payload.iconClasses.push('is-transparent');

            payload.icon = tile.building_key === 'hidden'
              ? `building/frame_${this.bodyData.biome}_hidden`
              : `building/${tile.building_key}`;

            payload.level = tile.building_level === 'hidden'
              ? '?' : tile.building_level;
          } else {
            if (this.production
              && this.production.data.type === 'building'
              && this.production.data.targetId === this.body.uid
              && this.production.data.tileId === tile.id
              && !tile.building_key) {
              payload.classes.push('is-active');
            }

            if (tile && tile.building_status === 'empty') {
              const data = { playerPatents: this.patents, bodiesData: this.bodies, buildingsData: this.buildings };

              if (buildingValidation.isBuildable(tile, this.body, data)) {
                if (tile.building_key) {
                  payload.icon = `building/${tile.building_key}`;
                  payload.iconClasses.push('is-transparent');
                  return payload;
                }

                payload.icon = `building/frame_${this.bodyData.biome}`;
                payload.iconClasses.push('is-transparent');

                if (this.isOwnSystem) {
                  payload.classes.push('is-hoverable');
                }

                return payload;
              }

              payload.classes.push('has-dashed-background');
              payload.icon = 'unlock';
              payload.iconClasses.push('is-small');
              payload.iconClasses.push('is-transparent');
              return payload;
            }

            payload.icon = `building/${tile.building_key}`;
            payload.level = tile.building_level;

            if (tile.building_status === 'damaged') {
              payload.classes.push('has-dashed-background');
              payload.iconClasses.push('is-transparent');

              if (tile.construction_status === 'none') {
                payload.actions.push('repair');
              }
            }

            const data = this.buildings.find((b) => b.key === tile.building_key);

            if (data) {
              if (buildingValidation.upgradeBuildingStatus(tile, this.body, this.patents, data)) {
                payload.actions.push('upgrade');
              }

              if (data.type !== 'infrastructure' && tile.construction_status === 'none') {
                payload.actions.push('delete');
              }
            }
          }

          return payload;
        });
    },
  },
  methods: {
    enterTile(tile, body, wantToUpgrade) {
      if (tile && tile.building_key !== null) {
        this.$emit('enterTile', { body, tile: { ...tile }, wantToUpgrade });
      }
    },
    leaveTile() {
      this.$emit('leaveTile');
    },
    clickTile(tile) {
      if (this.isOwnSystem) {
        const data = { playerPatents: this.patents, bodiesData: this.bodies, buildingsData: this.buildings };

        if (this.production && tile
          && this.production.data.type === 'building'
          && this.production.data.targetId === this.body.uid
          && this.production.data.tileId === tile.id) {
          this.$store.commit('game/clearProduction');
        } else if ((buildingValidation.isBuildable(tile, this.body, data))
          && tile.building_key === null) {
          this.$ambiance.sound('open-production');
          this.$store.commit('game/prepareProduction', {
            systemId: this.system.id,
            data: {
              type: 'building',
              targetId: this.body.uid,
              tileId: tile.id,
            },
          });
        }
      }
    },
    buildTile(tile, type) {
      if (this.isOwnSystem) {
        const productionLevel = type === 'build'
          ? tile.building_level + 1
          : tile.building_level;

        this.$ambiance.sound('order-building');

        this.$socket.player.push('order_building', {
          system_id: this.system.id,
          production_data: {
            type,
            target_id: this.body.uid,
            tile_id: tile.id,
            prod_key: tile.building_key,
            prod_level: productionLevel,
          },
        }).receive('error', (data) => {
          this.$toastError(data.reason);
        });
      }
    },
    removeTile(tile) {
      if (this.isOwnSystem) {
        this.$socket.player.push('remove_building', {
          system_id: this.system.id,
          production_data: {
            target_id: this.body.uid,
            tile_id: tile.id,
          },
        }).receive('error', (data) => {
          this.$toastError(data.reason);
        });
      }
    },
  },
};
</script>
