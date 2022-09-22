<template>
  <div
    class="generic-circle-progress-container"
    :class="`f-${theme}`">
    <svg
      :width="size + (2 * width)"
      :height="size + (2 * width)">
      <circle
        class="background"
        :r="radius"
        :cx="radius + width"
        :cy="radius + width"
        :stroke-width="width">
      </circle>
      <circle
        class="foreground"
        :r="radius"
        :cx="radius + width"
        :cy="radius + width"
        :stroke-width="width + 1"
        :stroke-dasharray="dasharray">
      </circle>
    </svg>
  </div>
</template>

<script>
import TimeMixin from '@/game/mixins/TimeMixin';

export default {
  name: 'circle-progress-value',
  mixins: [TimeMixin],
  data() {
    return {
      value: undefined,
    };
  },
  props: {
    current: Number,
    total: Number,
    increase: Number,
    width: Number,
    size: Number,
    theme: String,
  },
  computed: {
    radius() { return this.size / 2; },
    ratio() { return this.value / this.total; },
    dasharray() { return `${Math.PI * this.size * this.ratio}, 1000`; },
  },
  watch: {
    current(value) {
      this.value = value;
    },
  },
  methods: {
    updateValue(timeFactor) {
      let val = this.value + (timeFactor * this.increase);

      if (this.increase > 0 && val > this.total) {
        val = 0;
        this.$emit('finished');
      }

      if (this.increase < 0 && val < 0) {
        val = 0;
        this.$emit('finished');
      }

      this.value = val;
    },
  },
  mounted() {
    this.value = this.current;
  },
};
</script>
