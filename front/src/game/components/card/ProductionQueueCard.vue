<template>
  <div
    class="card-container"
    :class="`f-${theme}`">
    <div
      class="card-header">
      <div class="card-header-icon">
        <svgicon
          v-if="item.type === 'building'"
          :name="`building/${item.prod_key}`" />
        <svgicon
          v-if="item.type === 'ship'"
          :name="'ship/frame_ship'" />
      </div>
      <div class="card-header-content">
        <div class="title-large">
          <template v-if="item.type === 'building'">
            {{ $t(`data.building.${item.prod_key}.name`) }}
          </template>
          <template v-else>
            {{ $t(`data.ship.${item.prod_key}.name`) }}
          </template>
        </div>
        <div class="title-small">
          <template v-if="item.prod_level === 1">
            {{ $t(`card.production_queue.new_building`) }}
          </template>
          <template v-else>
            {{ $t(`card.production_queue.level`, {lvl: item.prod_level - 1}) }}
            <svgicon name="caret-right" />
            {{ item.prod_level }}
          </template>
        </div>
        <div
          v-if="cancelable"
          @click="cancel"
          class="cancel-button">
          ×
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'production-queue-card',
  props: {
    item: Object,
    theme: {
      type: String,
      default: 'none',
    },
    cancelable: {
      type: Boolean,
      default: false,
    },
  },
  methods: {
    cancel() {
      this.$emit('cancel');
    },
  },
};
</script>
