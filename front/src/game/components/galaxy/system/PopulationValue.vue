<template>
  <span>{{ integerValue | integer }}</span>
</template>

<script>
import TimeMixin from '@/game/mixins/TimeMixin';

export default {
  name: 'population-value',
  mixins: [TimeMixin],
  data() {
    return {
      value: undefined,
    };
  },
  props: {
    initial: Object,
  },
  computed: {
    integerValue() { return this.value * 1000000000; },
  },
  watch: {
    initial(value) {
      this.value = value.value;
    },
  },
  methods: {
    updateValue(timeFactor) {
      this.value += (timeFactor * (this.initial.change / 50));
    },
  },
  created() {
    this.value = this.initial.value;
  },
};
</script>
