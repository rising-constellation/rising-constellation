<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`ship/${shipKey}`" />
        <span class="level">{{ level + 1 }}</span>
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ $t(`data.ship.${shipKey}.name`) }}
        </div>
        <div
          v-if="ship !== undefined && shipData.class == 'capital'"
          class="title-small">
          {{ ship.name }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img
          v-if="!disabled"
          :src="`data/ships/${shipData.illustration}`" />
        <div
          v-else
          class="locked-item">
          <svgicon
            class="locked-icon"
            name="unlock" />
          <div
            v-html="disabled"
            class="locked-reason">
          </div>
        </div>

        <template v-if="!disabled">
          <svgicon
            v-for="(unit, i) in units"
            :key="`ship-unit-${i}`"
            v-tooltip="$t(`card.ship.hull_status`, { current: unit.hull, max: shipData.unit_hull })"
            class="ship-unit"
            name="ship/unit"
            :style="{
              'top': unit.position.x,
              'left': unit.position.y,
              'opacity': `${unit.status}`,
            }" />
        </template>

        <div class="toast is-bottom">
          <span>{{ morale }} {{ $t(`card.ship.morale`) }}</span>
        </div>
      </div>

      <div class="card-information">
        <div class="card-panel-controls">
          <svgicon
            class="card-panel-control"
            @click="movePanelToLeft"
            name="caret-left"
            v-if="leftControl" />
          <div v-else></div>
          <svgicon
            class="card-panel-control"
            @click="movePanelToRight"
            name="caret-right"
            v-if="rightControl" />
          <div v-else></div>
        </div>

        <div class="card-panel-window">
          <div
            ref="panelContainer"
            class="card-panel-container"
            :style="{ left: panelContainerPosition + 'px' }">
            <div class="card-panel">
              <div class="is-sparse-y">
                <div>
                  <div
                    v-tooltip="$t(`card.ship.repair`)"
                    class="simple-bonus">
                    {{ shipData.unit_repair_coef * shipData.unit_count }}
                    <svgicon name="ship/repair" />
                  </div>
                  <div
                    v-tooltip="$t(`card.ship.bombing`)"
                    class="simple-bonus">
                    {{ shipData.unit_raid_coef * shipData.unit_count }}
                    <svgicon name="ship/raid" />
                  </div>
                  <div
                    v-tooltip="$t(`card.ship.invasion`)"
                    class="simple-bonus">
                    {{ shipData.unit_invasion_coef * shipData.unit_count }}
                    <svgicon name="ship/invasion" />
                  </div>
                </div>
                <div>
                  <div
                    v-tooltip="$t(`card.ship.maintenance`)"
                    class="simple-bonus">
                    {{ shipData.maintenance_cost }}
                    <svgicon name="resource/credit" />
                  </div>
                </div>
              </div>

              <hr>

              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.hull`) }}</div>
                  <div>
                    <strong>{{ shipData.unit_hull }}</strong>
                    <svgicon name="ship/hull" />
                  </div>
                </div>
                <div class="skills-line">
                  <span :style="width(Math.log(shipData.unit_hull) * 100, 1000)"></span>
                </div>
              </div>
              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.maneuverability`) }}</div>
                  <div>
                    <strong>{{ formatPercent(unitHandling) }}</strong>
                    <svgicon name="ship/handling" />
                  </div>
                </div>
                <div class="skills-line">
                  <span :style="width(unitHandling, 100)"></span>
                </div>
              </div>
              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.energy_strikes`) }}</div>
                  <div>
                    <strong>{{ formatList(unitEnergyStrikes) }}</strong>
                    <svgicon name="ship/energy_strikes" />
                  </div>
                </div>
                <div class="skills-line">
                  <span
                    v-for="(strike, i) in unitEnergyStrikes"
                    :key="`energy-strike-${shipKey}-${i}`"
                    :style="width(strike, 1300)">
                  </span>
                </div>
              </div>
              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.explosive_strikes`) }}</div>
                  <div>
                    <strong>{{ formatList(unitExplosiveStrikes) }}</strong>
                    <svgicon name="ship/explosive_strikes" />
                  </div>
                </div>
                <div class="skills-line">
                  <span
                    v-for="(strike, i) in unitExplosiveStrikes"
                    :key="`explosive-strike-${shipKey}-${i}`"
                    :style="width(strike, 1100)">
                  </span>
                </div>
              </div>
              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.shields`) }}</div>
                  <div>
                    <strong>{{ formatPercent(unitShield) }}</strong>
                    <svgicon name="ship/shield" />
                  </div>
                </div>
                <div class="skills-line">
                  <span :style="width(unitShield, 100)"></span>
                </div>
              </div>
              <div class="ship-skills">
                <div class="skills-text">
                  <div>{{ $t(`card.ship.flak`) }}</div>
                  <div>
                    <strong>{{ formatPercent(unitInterception) }}</strong>
                    <svgicon name="ship/interception" />
                  </div>
                </div>
                <div class="skills-line">
                  <span :style="width(unitInterception, 100)"></span>
                </div>
              </div>
            </div>

            <div class="card-panel">
              <h2>{{ $t(`card.ship.about`) }}</h2>
            </div>
          </div>
        </div>
      </div>
    </div>

    <template>
      <div
        v-if="showCost"
        class="card-cost">
        <div
          class="icon-value">
          {{ shipData.production | integer }}
          <svgicon name="resource/production" />
          <template v-if="system">
            ({{ (shipData.production / system.production.value) * tickToSecondFactor | counter }})
          </template>
        </div>
        <div
          class="icon-value">
          {{ shipData.credit_cost | integer }}
          <svgicon name="resource/credit" />
        </div>
        <div
          class="icon-value">
          {{ shipData.technology_cost | integer }}
          <svgicon name="resource/technology" />
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import _groupBy from 'lodash/groupBy';

export default {
  name: 'ship-card',
  mixins: [CardMixin],
  props: {
    shipKey: String,
    ship: {
      type: Object,
      required: false,
    },
    initialXP: {
      type: Number,
      default: 0,
    },
    system: {
      type: Object,
      required: false,
    },
    showCost: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: String,
      required: false,
    },
  },
  computed: {
    tickToSecondFactor() { return this.$store.getters['game/tickToSecondFactor']; },
    shipData() {
      return this.$store.state.game.data.ship.find((s) => s.key === this.shipKey);
    },
    experience() {
      return (this.ship === undefined)
        ? this.initialXP
        : this.ship.experience;
    },
    level() {
      if (this.ship === undefined) return 0;
      if (this.ship.level === 'hidden') return '?';
      return this.ship.level;
    },
    morale() {
      const constant = this.$store.state.game.data.constant[0];
      return constant.army_unit_base_morale + (this.level * constant.army_unit_morale_per_level);
    },
    units() {
      return [...Array(this.shipData.unit_count).keys()].map((i) => {
        const position = { x: this.shipData.unit_pattern[i * 2], y: this.shipData.unit_pattern[(i * 2) + 1] };
        const hull = this.ship ? this.ship.units[i].hull : this.shipData.unit_hull;
        const status = hull / this.shipData.unit_hull;

        return { position, hull, status };
      });
    },
    unitHandling() {
      return this.ship
        ? Math.round(Math.min(this.shipData.unit_handling + (0.5 * this.ship.level), 95))
        : this.shipData.unit_handling;
    },
    unitInterception() {
      return this.ship && this.shipData.unit_interception > 0
        ? Math.round(Math.min(this.shipData.unit_interception + (0.5 * this.ship.level), 95))
        : this.shipData.unit_interception;
    },
    unitShield() {
      return this.ship && this.shipData.unit_shield > 0
        ? Math.round(Math.min(this.shipData.unit_shield + (0.5 * this.ship.level), 95))
        : this.shipData.unit_shield;
    },
    unitEnergyStrikes() {
      return this.ship
        ? this.shipData.unit_energy_strikes.map((s) => Math.round(s * (1 + 0.01 * this.ship.level)))
        : this.shipData.unit_energy_strikes;
    },
    unitExplosiveStrikes() {
      return this.ship
        ? this.shipData.unit_explosive_strikes.map((s) => Math.round(s * (1 + 0.01 * this.ship.level)))
        : this.shipData.unit_explosive_strikes;
    },
  },
  methods: {
    width(value, maximum) {
      return `width: ${(value / maximum) * 100}%`;
    },
    formatPercent(value) {
      return value === 0 ? '—' : `${value}%`;
    },
    formatList(list) {
      const grouped = _groupBy(list, (n) => n);

      let string = '';
      Object.entries(grouped).forEach(([key, value]) => {
        string += value.length === 1
          ? `, ${key}`
          : `, ${value.length}×${key}`;
      });

      return string.length === 0
        ? '—'
        : string.substr(2);
    },
  },
};
</script>
