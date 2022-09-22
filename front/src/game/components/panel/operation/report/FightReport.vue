<template>
  <div class="fight-report">
    <div
      v-for="type in ['attackers', 'defenders']"
      :key="type">
      <div class="title">
        {{ $t(`panel.operations.fight_side_${type}`) }}
      </div>

      <div
        v-for="(character, idx) in content.initial[type]"
        :key="character.id">
        <div v-if="idx > 0">{{ $t('panel.operations.fight_and') }}</div>
        <span :class="`theme-${theme(character.owner.faction)}`">
          {{ $t(`data.character.${character.type}.specializations.${character.specialization}`) }}
          <strong>
            {{ character.name }}
          </strong>
          {{ $t('panel.operations.fight_lvl', {lvl: character.level}) }}
        </span>
        {{ $t('panel.operations.fight_under_owner') }}
        <strong :class="`theme-${theme(character.owner.faction)}`">
          {{ character.owner.name }}
        </strong> :
        <div
          v-for="(tile, idx) in character.army.tiles"
          :key="idx">
          <template v-if="tile.ship_status === 'filled'">
            <strong :class="`theme-${theme(character.owner.faction)}`">
              {{ $t(`data.ship.${tile.ship.key}.name`) }}
              [{{ tile.id }}]
            </strong>
            {{ $t('panel.operations.fight_lvl', {lvl: tile.ship.level}) }}
          </template>
        </div>
      </div>
    </div>
    <div class="title">
      {{ $t('panel.operations.fight_course') }}
    </div>
    <div
      class="round"
      v-for="(round, j) in content.battle"
      :key="`round-${j}`">
      <div class="round-title">
        {{ j + 1 }}
      </div>
      <div class="round-content">
        <div
          v-for="(action, k) in round"
          :key="`action-${k}`">
          <template v-if="action.type === 'transfer' && action.data.target === 'field'">
            <strong :class="`theme-${getShip(action.source).theme}`">
              {{ $t(`data.ship.${getShip(action.source).key}.name`) }}
              [{{ action.source.tile }}]
            </strong>
            {{ $t('panel.operations.fight_arrival') }}
          </template>

          <template v-else-if="action.type === 'transfer' && action.data.target === 'army'">
            <strong :class="`theme-${getShip(action.source).theme}`">
              {{ $t(`data.ship.${getShip(action.source).key}.name`) }}
              [{{ action.source.tile }}]
            </strong>
            {{ $t('panel.operations.fight_leave') }}
          </template>

          <template v-else-if="action.type === 'destroyed'">
            <strong :class="`theme-${getShip(action.source).theme}`">
              {{ $t(`data.ship.${getShip(action.source).key}.name`) }}
              [{{ action.source.tile }}]
            </strong>
            {{ $t('panel.operations.fight_destroyed') }}
          </template>

          <template v-else-if="action.type === 'escaping'">
            <strong :class="`theme-${getShip(action.source).theme}`">
              {{ $t(`data.ship.${getShip(action.source).key}.name`) }}
              [{{ action.source.tile }}]
            </strong>
            {{ $t('panel.operations.fight_fly') }}
          </template>

          <template v-else-if="action.type === 'attack'">
            <strong :class="`theme-${getShip(action.source).theme}`">
              {{ $t(`data.ship.${getShip(action.source).key}.name`) }}
              [{{ action.source.tile }}]
            </strong>
            {{ $t('panel.operations.fight_attacks', {attack_count: action.data.actions.length}) }}
            <strong :class="`theme-${getShip(action.data.target).theme}`">
              {{ $t(`data.ship.${getShip(action.data.target).key}.name`) }}
              [{{ action.data.target.tile }}]
            </strong>
            <span v-html="computeStrikes(action.data.actions)"></span>
          </template>

          <template v-else>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'fight-report',
  props: {
    report: String,
  },
  computed: {
    content() {
      try {
        return JSON.parse(this.report);
      } catch (error) {
        this.$toastError(error);
      }

      return {};
    },
    faction() { return this.$store.state.game.faction; },
    characters() { return this.content.initial.attackers.concat(this.content.initial.defenders); },
  },
  methods: {
    getShip(ref) {
      const character = this.characters.find((c) => c.id === ref.character);
      const tile = character.army.tiles.find((t) => t.id === ref.tile);

      return {
        theme: this.$store.getters['game/themeByKey'](character.owner.faction),
        ...tile.ship,
      };
    },
    computeStrikes(actions) {
      const strikes = actions.reduce((acc1, action) => action.strikes.reduce((acc2, strike) => {
        if (strike.action === 'missed') {
          acc2.missed += 1;
        } else if ([].includes(strike.action)  === 'hit') {
          acc2.hit += 1;
        } else if (strike.action === 'hit_and_crashed') {
          acc2.hit_and_crashed += 1;
        }

        acc2.damages += strike.damages;
        return acc2;
      }, acc1), { missed: 0, hit: 0, hit_and_crashed: 0, damages: 0 });

      return this.$tmd('panel.operations.fight_strike', {
        damages: Math.round(strikes.damages),
        hit_count: strikes.hit + strikes.hit_and_crashed,
        missed_count: strikes.missed,
        crashed_count: strikes.hit_and_crashed,
      });
    },
    theme(faction) {
      return this.$store.getters['game/themeByKey'](faction);
    },
  },
};
</script>
