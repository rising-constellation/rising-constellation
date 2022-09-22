<template>
  <div>
    <div class="box-notification-header">
      <svgicon name="action/colonization_alt" />
      <div
        class="name"
        v-html="$tmd(
          `notification.box.colonization.title`,
          { system: data.system.name }
        )">
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
            `notification.box.colonization.description`,
            {
              system: data.system.name,
              admiral: data.admiral.current.name,
            }
          )">
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
          <character-card
            :character="data.admiral.previous"
            :diff="data.admiral.current"
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
import Army from '@/game/components/galaxy/selection/Army.vue';

export default {
  name: 'colonization-notif',
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
      const tab2 = ['admiral', 'admiral-army'];

      if (this.data.admiral.current.level > this.data.admiral.previous.level) {
        tab1.push('level');
      }

      return [tab1, tab2];
    },
  },
  methods: {
    theme(factionKey) {
      return this.$store.getters['game/themeByKey'](factionKey);
    },
  },
  components: {
    CharacterCard,
    Army,
  },
};
</script>
