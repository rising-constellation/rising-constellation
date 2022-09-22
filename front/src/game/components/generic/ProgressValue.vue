<template>
  <div class="generic-progress-container">
    <div
      class="generic-progress-bar"
      :style="{ width: percentValue }">
    </div>
    <div
      v-if="cursor"
      :style="{ left: percentCursor }"
      class="generic-progress-cursor">
    </div>
  </div>
</template>

<script>
import TimeMixin from '@/game/mixins/TimeMixin';

export default {
  name: 'progress-value',
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
    blockAtEnd: {
      type: Boolean,
      default: false,
    },
    cursor: {
      type: Number,
      required: false,
    },
    receivedAt: {
      type: Number,
      required: false,
    },
  },
  computed: {
    percentValue() { return `${(this.value / this.total) * 100}%`; },
    percentCursor() { return `${(this.cursor / this.total) * 100}%`; },
  },
  watch: {
    current(value) {
      this.value = value;
    },
  },
  methods: {
    updateValue(timeFactor) {
      this.value += (timeFactor * this.increase);
      if (this.value > this.total) {
        if (!this.blockAtEnd) {
          this.value = 0;
        }

        this.$emit('finished');
      }
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
