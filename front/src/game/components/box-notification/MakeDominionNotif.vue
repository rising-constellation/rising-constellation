<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/make_dominion_alt" />
      <div
        class="name"
        v-html="$tmd(
          `notification.box.make_dominion.title`,
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
            `notification.box.make_dominion.description.${data.side}.${data.outcome}`,
            {
              system: data.system.name,
              system_player: systemOwnerName,
              speaker: data.speaker.current.name,
              speaker_player: data.speaker.current.owner.name,
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
          <span v-html="$tmd('notification.box.level_gained', { level: data.speaker.current.level })"></span>
        </div>
        <div
          v-if="tabs[activeTab].includes('speaker')"
          class="box-notification-bloc">
          <h2>{{ $t('notification.box.attacker') }}</h2>
          <character-card
            :character="data.speaker.previous"
            :diff="(data.side === 'attacker' ? data.speaker.current : null)"
            :theme="theme(data.speaker.current.owner.faction)" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';

export default {
  name: 'make-dominion-notif',
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
      const tab1 = ['text', 'bop'];
      const tab2 = ['speaker'];

      if (this.data.side === 'attacker' && this.data.speaker.current.level > this.data.speaker.previous.level) {
        tab1.push('level');
      }

      return [tab1, tab2];
    },
    overview() {
      return {
        attacker: this.data.balance_of_power.attack,
        attackerIcon: 'action/make_dominion_alt',
        attackerModifier: this.data.speaker.previous.level,
        attackerTheme: this.theme(this.data.speaker.previous.owner.faction),
        defender: this.data.balance_of_power.defense,
        defenderIcon: 'resource/happiness',
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
  },
};
</script>
