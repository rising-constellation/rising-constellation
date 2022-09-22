<template>
  <div
    class="card-container closed"
    :class="`f-${theme}`"
    @click="select">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`stellar_system/${system.type}`" />
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ system.name }}
        </div>
        <div
          v-if="system.queue > 0"
          class="title-actions"
          v-tooltip="$t('card.closed_system.construction_queue')">
          <div
            v-for="i in system.queue"
            :key="`build-${i}`"
            class="title-actions-item is-jump">
          </div>
        </div>
      </div>
      <div
        v-if="system.siege"
        v-tooltip.left="$t(`data.character_action_status.${system.siege.type}.name`)"
        class="card-header-toast active colored">
        <svgicon :name="`action/${system.siege.type}`" />
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';

export default {
  name: 'closed-system-card',
  mixins: [CardMixin],
  props: {
    system: Object,
  },
  methods: {
    select() {
      this.$emit('select', this.system);
    },
  },
};
</script>
