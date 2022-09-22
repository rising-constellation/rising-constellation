<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/loot_alt" />
      <div
        class="name"
        v-html="$tmd(
          `notification.box.loot.title`,
          { system: data.system.name }
        )">
      </div>
      <div class="outcome">
        {{ $t(`notification.box.outcome.${data.side}.${data.outcome}`) }}
      </div>
    </div>

    <div class="box-notification-tabs">
      <div class="box-notification-tab-buttons">
        <div
          v-for="(tab, i) in tabs"
          :key="i"
          :class="{ 'active': activeTab === i }"
          @click="activeTab = i"
          class="box-notification-tab-button">
        </div>
      </div>

      <div class="box-notification-tab-item">
        <div
          v-if="tabs[activeTab].includes('text')"
          class="box-notification-bloc"
          v-html="$tmd(
            `notification.box.loot.description.${data.side}.${data.outcome}`,
            {
              system: data.system.name,
              system_player: systemOwnerName,
              admiral: data.admiral.current.name,
              admiral_player: data.admiral.current.owner.name,
            }
          )">
        </div>
        <div
          v-if="tabs[activeTab].includes('log')"
          class="box-notification-bloc"
          v-html="$tmd(
            `notification.box.siege_logs`,
            {
              damaged_building: data.siege_logs.damaged_building,
              population_lost: $options.filters.float(data.siege_logs.population_lost, 3),
            }
          )">
        </div>
        <div
          v-if="tabs[activeTab].includes('loot')"
          class="box-notification-bloc"
          v-html="$tmd(
            `notification.box.siege_loot`,
            {
              credit: $options.filters.integer(data.loot.credit),
              technology: $options.filters.integer(data.loot.technology),
              ideology: $options.filters.integer(data.loot.ideology),
            }
          )">
        </div>
        <div
          v-if="tabs[activeTab].includes('bop')"
          class="box-notification-action toolbox-actions">
          <action-overview :data="overview" />
        </div>
        <div
          v-if="tabs[activeTab].includes('level')"
          class="box-notification-bloc is-boxed">
          <svgicon name="bookmark" />
          <span v-html="$tmd('notification.box.level_gained', { level: data.admiral.current.level })"></span>
        </div>
        <div
          v-if="tabs[activeTab].includes('admiral')"
          class="box-notification-bloc">
          <h2>{{ $t('notification.box.attacker') }}</h2>
          <character-card
            :character="data.admiral.previous"
            :diff="(data.side === 'attacker' ? data.admiral.current : null)"
            :theme="theme(data.admiral.current.owner.faction)" />
        </div>
        <div
          v-if="tabs[activeTab].includes('admiral-army')"
          class="box-notification-bloc is-army"
          :class="`f-${theme(data.admiral.current.owner.faction)}`">
          <army
            :has-header="false"
            :context="'display'"
            :character="data.admiral.previous"
            :diff="data.admiral.current" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';
import Army from '@/game/components/galaxy/selection/Army.vue';

export default {
  name: 'loot-notif',
  props: {
    data: Object,
  },
  data() {
    return {
      activeTab: 0,
    };
  },
  computed: {
    tabs() {
      const tab1 = ['text', 'bop', 'log', 'loot'];
      const tab2 = ['admiral', 'admiral-army'];

      if (this.data.side === 'attacker' && this.data.admiral.current.level > this.data.admiral.previous.level) {
        tab1.push('level');
      }

      return [tab1, tab2];
    },
    overview() {
      return {
        attacker: this.data.balance_of_power.attack,
        attackerIcon: 'ship/loot',
        attackerModifier: this.data.admiral.previous.level,
        attackerTheme: this.theme(this.data.admiral.previous.owner.faction),
        defender: this.data.balance_of_power.defense,
        defenderIcon: 'resource/defense',
        defenderTheme: this.theme(this.data.system.owner?.faction),
        result: this.data.balance_of_power.result,
      };
    },
    systemOwnerName() {
      return this.data.system.owner
        ? this.data.system.owner.name
        : this.$t('galaxy.system.properties.autonomous_system');
    },
    systemOwnerFaction() {
      return this.data.system.owner?.faction;
    },
  },
  methods: {
    theme(factionKey) {
      return this.$store.getters['game/themeByKey'](factionKey);
    },
  },
  components: {
    CharacterCard,
    ActionOverview,
    Army,
  },
};
</script>
