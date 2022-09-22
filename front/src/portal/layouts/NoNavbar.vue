<template>
  <div class="portal-context">
    <div class="layout no-navbar">
      <div class="layout-content">
        <slot />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'no-navbar-layout',
};
</script>
