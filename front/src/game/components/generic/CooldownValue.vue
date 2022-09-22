<template>
  <span>{{ value | integer }}</span>
</template>

<script>
import CooldownValueMixin from '@/game/mixins/CooldownValueMixin';

export default {
  name: 'cooldown-value',
  mixins: [CooldownValueMixin],
};
</script>
