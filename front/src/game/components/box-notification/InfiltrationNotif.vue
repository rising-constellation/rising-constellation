<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/infiltrate_alt" />
      <div
        class="name"
        v-html="$tmd(
          `notification.box.infiltration.${data.side}.title`,
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
            `notification.box.infiltration.${data.side}.description.${data.outcome}`,
            {
              spy: data.spy.current.name,
              system: data.system.name,
              player: (data.system.owner ? data.system.owner.name : $t('galaxy.system.properties.autonomous_system')),
              contact: data.contact_count,
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
          <span v-html="$tmd('notification.box.level_gained', { level: data.spy.current.level })"></span>
        </div>
        <div
          v-if="tabs[activeTab].includes('spy')"
          class="box-notification-bloc">
          <character-card
            :character="data.spy.previous"
            :diff="data.spy.current"
            :theme="theme(data.spy.current.owner.faction)" />
        </div>
        <div
          v-if="tabs[activeTab].includes('cover')"
          class="box-notification-bloc is-boxed">
          <span v-html="$tmd('notification.box.cover_lost', { cover })"></span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';

export default {
  name: 'infiltration-notif',
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
      const tab1 = ['text', 'bop', 'cover'];
      const tab2 = ['spy'];

      if (this.data.spy.current.level > this.data.spy.previous.level) {
        tab1.push('level');
      }

      return [tab1, tab2];
    },
    overview() {
      return {
        attacker: this.data.balance_of_power.attack,
        attackerIcon: 'action/infiltrate_alt',
        attackerModifier: this.data.spy.previous.level,
        attackerTheme: this.theme(this.data.spy.previous.owner.faction),
        defender: this.data.balance_of_power.defense,
        defenderIcon: 'resource/counter_intelligence',
        defenderTheme: this.theme(this.data.system.owner?.faction),
        result: this.data.balance_of_power.result,
      };
    },
    cover() {
      return Math.round(this.data.spy.previous.spy.cover.value - this.data.spy.current.spy.cover.value);
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
  },
};
</script>
