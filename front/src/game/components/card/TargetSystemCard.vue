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
        <div class="title-large">
          {{ system.name }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'target-system-card',
  props: {
    system: Object,
    theme: String,
  },
  methods: {
    select() {
      this.$emit('select', this.system);
    },
  },
};
</script>
