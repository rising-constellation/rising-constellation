<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/conversion_alt" />
      <div
        class="name"
        v-html="$tmd(
          `notification.box.conversion.title`,
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
            `notification.box.conversion.description.${data.side}.${data.outcome}`,
            {
              system: data.system.name,
              speaker: data.speaker.current.name,
              speaker_player: data.speaker.current.owner.name,
              target: data.target.name,
              target_player: data.target.owner.name,
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
          v-if="tabs[activeTab].includes('cover')"
          class="box-notification-bloc is-boxed">
          <span v-html="$tmd('notification.box.cover_lost', { cover })"></span>
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
        <div
          v-if="tabs[activeTab].includes('target')"
          class="box-notification-bloc">
          <h2>{{ $t('notification.box.target') }}</h2>
          <character-card
            :character="data.target"
            :theme="theme(data.target.owner.faction)" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';

export default {
  name: 'conversion-notif',
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
      const tab3 = ['target'];

      if (this.data.side === 'attacker' && this.data.speaker.current.level > this.data.speaker.previous.level) {
        tab1.push('level');
      }

      return [tab1, tab2, tab3];
    },
    overview() {
      return {
        attacker: this.data.balance_of_power.attack,
        attackerIcon: 'action/conversion_alt',
        attackerModifier: this.data.speaker.previous.level,
        attackerTheme: this.theme(this.data.speaker.previous.owner.faction),
        defender: this.data.balance_of_power.defense,
        defenderIcon: 'agent/determination',
        defenderTheme: this.theme(this.data.target.owner.faction),
        result: this.data.balance_of_power.result,
      };
    },
    cover() {
      return Math.round(this.data.speaker.previous.speaker.cover.value - this.data.speaker.current.speaker.cover.value);
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
