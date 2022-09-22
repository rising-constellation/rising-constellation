<template>
  <div
    class="navbar-maxed-value"
    v-bind:class="{ 'active': isActive }">
    <div class="value">{{ value }}</div>
    <div class="infos">
      <div class="label">{{ label }}</div>
      <div class="generic-progress-container">
        <div
          class="generic-progress-bar"
          v-bind:style="`width: ${position}%;`">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'navbar-maxed-value',
  props: {
    label: String,
    value: Number,
    maximum: Number,
  },
  computed: {
    isActive() {
      return this.maximum !== 0;
    },
    position() {
      return this.maximum === 0
        ? 100
        : (this.value / this.maximum) * 100;
    },
  },
};
</script>
