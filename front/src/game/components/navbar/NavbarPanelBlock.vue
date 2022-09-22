<template>
  <div class="navbar-panel-block">
    <div
      @click="isOpen = !isOpen"
      class="navbar-panel-header">
      <h1>
        <span>{{ title }}</span>
        <svgicon v-show="isOpen" class="icon" name="caret-down" />
        <svgicon v-show="!isOpen" class="icon" name="caret-up" />
      </h1>
    </div>

    <div
      class="navbar-panel-content"
      v-show="isOpen">
      <slot></slot>
    </div>
  </div>
</template>

<script>
export default {
  name: 'navbar-panel-block',
  data() {
    return {
      isOpen: true,
    };
  },
  props: {
    title: String,
  },
};
</script>
