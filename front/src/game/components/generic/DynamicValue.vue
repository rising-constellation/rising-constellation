<template>
  <span>{{ value | integer }}</span>
</template>

<script>
import DynamicValueMixin from '@/game/mixins/DynamicValueMixin';

export default {
  name: 'dynamic-value',
  mixins: [DynamicValueMixin],
};
</script>
