<template>
  <span>{{ convertToSeconds(value) | counter }}</span>
</template>

<script>
import TimeMixin from '@/game/mixins/TimeMixin';

export default {
  name: 'counter',
  mixins: [TimeMixin],
  data() {
    return {
      value: undefined,
    };
  },
  props: {
    current: Number,
    receivedAt: {
      type: Number,
      required: false,
    },
  },
  watch: {
    current(value) {
      this.value = value;
    },
  },
  computed: {
    tickToSecondFactor() { return this.$store.getters['game/tickToSecondFactor']; },
  },
  methods: {
    updateValue(timeFactor) {
      this.value += (timeFactor * -1);

      if (this.value <= 0) {
        this.value = 0;
        this.$emit('finished');
      }
    },
    convertToSeconds(ticks) {
      return Math.round(ticks * this.tickToSecondFactor);
    },
  },
  mounted() {
    this.value = this.current;

    if (this.receivedAt) {
      this.correctValue(this.receivedAt);
    }
  },
};
</script>
