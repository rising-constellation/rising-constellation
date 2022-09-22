<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/fight_alt" />
      <div
        class="name"
        v-html="$tmd(
          `report.fight_scale_${scaleText(data.scale)}`,
          { name: data.system.name }
        )">
      </div>
      <div class="outcome">
        {{ $t(`notification.box.fight.outcome.${data.outcome}`) }}
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
            'notification.box.fight.description',
            {
              system: data.system.name,
              system_player: systemOwnerName,
              admiral_count: data.admirals.length,
            }
          )">
        </div>

        <div
          v-if="tabs[activeTab].includes('text')"
          class="box-notification-bloc">
          <button
            @click="openReport(data.report_id)"
            class="default-button">
            <div>
              {{ $t(`notification.box.fight.report`) }}
            </div>
          </button>
        </div>

        <template v-for="(admiral, i) in data.admirals">
          <div
            v-if="tabs[activeTab].includes(`admiral-${i}`)"
            class="box-notification-bloc"
            :key="`admiral-${i}`">
            <h2>{{ $t(`notification.box.fight.${admiral.side}.${admiral.status}`) }}</h2>
            <character-card
              :character="admiral.previous"
              :diff="(admiral.has_died ? null : admiral.current)"
              :theme="theme(admiral.current.owner.faction)"
              :isDead="admiral.has_died" />
          </div>
          <div
            v-if="tabs[activeTab].includes(`admiral-army-${i}`)"
            class="box-notification-bloc is-army"
            :class="`f-${theme(admiral.current.owner.faction)}`"
            :key="`admiral-army-${i}`">
            <army
              :has-header="false"
              :context="'display'"
              :character="admiral.previous"
              :diff="admiral.current" />
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import CharacterCard from '@/game/components/card/CharacterCard.vue';
import Army from '@/game/components/galaxy/selection/Army.vue';

export default {
  name: 'fight-notif',
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
      const tab1 = ['text'];
      const tabs = this.data.admirals.map((admiral, i) => [`admiral-${i}`, `admiral-army-${i}`]);

      return [tab1].concat(tabs);
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
    scaleText(scale) {
      if (scale > 2000) { return 'xxbig'; }
      if (scale > 1000) { return 'xbig'; }
      if (scale > 600) { return 'big'; }
      if (scale > 300) { return 'medium'; }
      if (scale > 100) { return 'small'; }
      return 'xsmall';
    },
    openReport(reportId) {
      this.$root.$emit('togglePanel', 'operations', { reportId });
    },
  },
  components: {
    CharacterCard,
    Army,
  },
};
</script>
