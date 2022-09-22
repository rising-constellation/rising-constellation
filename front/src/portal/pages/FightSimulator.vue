<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <div class="panel-aside-info">
          <h2>{{ $t('page.fight_simulator.player', {number: 1}) }}</h2>
          <p>{{ $t('page.fight_simulator.attacker') }}</p>
        </div>

        <div class="panel-aside-bloc">
          <div
            class="default-input">
            <label for="attacker_initial_xp">
              {{ $t('page.fight_simulator.initial_xp') }}
            </label>
            <input
              type="number"
              id="attacker_initial_xp"
              v-model.number="attacker.initial_xp" />
          </div>
        </div>

        <div class="panel-aside-bloc">
          <div
            class="default-input has-small-margin"
            v-for="(key, i) in attacker.tiles"
            :key="`attacker-line-${i}`">
            <label>
              {{ $t('page.fight_simulator.position', {line: Math.floor(i / 3) + 1, box: (i % 3) + 1}) }}
            </label>
            <div class="content">
              <select
                :name="`tile-${i}`"
                v-model="attacker.tiles[i]">
                <option :value="null">
                  {{ $t('page.fight_simulator.empty') }}
                </option>
                <option
                  v-for="ship in data.ship"
                  :value="ship.key"
                  :key="ship.key">
                  {{ $t(`data.ship.${ship.key}.name`) }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content is-full-sized">
        <div class="panel-header">
          <h1>
            <strong>{{ $t('page.fight_simulator.title') }}</strong>
          </h1>

          <button
            @click="fight"
            class="default-button">
            {{ $t('page.fight_simulator.launch') }}
          </button>
        </div>

        <v-scrollbar
          v-if="logs"
          class="content">
          <div class="fight-report">
            <div
              v-for="type in ['attackers', 'defenders']"
              :key="type">
              <div class="title">
                {{ $t(`panel.operations.fight_side_${type}`) }}
              </div>

              <div
                v-for="(character, idx) in initialCharacters[type]"
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
              v-for="(round, j) in logs"
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

          <hr class="margin">
        </v-scrollbar>

        <v-scrollbar
          v-else
          class="content">
        </v-scrollbar>
      </div>

      <v-scrollbar class="panel-aside">
        <div class="panel-aside-info">
          <h2>{{ $t('page.fight_simulator.player', {number: 2}) }}</h2>
          <p>{{ $t('page.fight_simulator.defender') }}</p>
        </div>

        <div class="panel-aside-bloc">
          <div
            class="default-input">
            <label for="attacker_initial_xp">
              {{ $t('page.fight_simulator.initial_xp') }}
            </label>
            <input
              type="number"
              id="defender_initial_xp"
              v-model.number="defender.initial_xp" />
          </div>
        </div>

        <div class="panel-aside-bloc">
          <div
            class="default-input has-small-margin"
            v-for="(key, i) in defender.tiles"
            :key="`defender-line-${i}`">
            <label>
              {{ $t('page.fight_simulator.position', {line: Math.floor(i / 3) + 1, box: (i % 3) + 1}) }}
            </label>
            <div class="content">
              <select
                :name="`tile-${i}`"
                v-model="defender.tiles[i]">
                <option :value="null">
                  {{ $t('page.fight_simulator.empty') }}
                </option>
                <option
                  v-for="ship in data.ship"
                  :value="ship.key"
                  :key="ship.key">
                  {{ $t(`data.ship.${ship.key}.name`) }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import DefaultLayout from '@/portal/layouts/Default.vue';

export default {
  name: 'fight-simulator',
  data() {
    return {
      attacker: {},
      defender: {},
      logs: null,
      initialCharacters: [],
      finalCharacters: [],
    };
  },
  computed: {
    data() { return this.$store.state.portal.data; },
  },
  methods: {
    async fight() {
      try {
        const { data } = await this.$axios.post(
          '/run-fight',
          { attacker: this.attacker, defender: this.defender },
        );
        const { initial, final, logs } = data;

        this.logs = logs;
        this.initialCharacters = initial;
        this.finalCharacters = final;
      } catch (err) {
        this.$toastChangesetError(err);
      }
    },
    getShip(ref) {
      const characters = this.initialCharacters.attackers.concat(this.initialCharacters.defenders);
      const character = characters.find((c) => c.id === ref.character);
      const tile = character.army.tiles.find((t) => t.id === ref.tile);

      return {
        theme: this.theme(character.owner.faction),
        ...tile.ship,
      };
    },
    computeStrikes(actions) {
      const strikes = actions.reduce((acc1, action) => action.strikes.reduce((acc2, strike) => {
        if (strike.action === 'missed') {
          acc2.missed += 1;
        } else if (strike.action === 'hit') {
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
      return this.$store.state.portal.data.faction.find((f) => f.key === faction).theme;
    },
  },
  mounted() {
    this.attacker = {
      initial_xp: 0,
      tiles: [...Array(18)].map(() => null),
    };

    this.defender = {
      initial_xp: 0,
      tiles: [...Array(18)].map(() => null),
    };
  },
  components: {
    DefaultLayout,
  },
};
</script>
