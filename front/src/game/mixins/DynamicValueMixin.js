import TimeMixin from '@/game/mixins/TimeMixin';

const DynamicValueMixin = {
  mixins: [TimeMixin],
  data() {
    return {
      value: 0,
    };
  },
  props: {
    initial: Object,
  },
  watch: {
    initial(value) {
      this.value = value.value;
    },
  },
  methods: {
    updateValue(timeFactor) {
      if (this.initial.value <= 0 && this.initial.change <= 0) {
        this.value = 0;
      } else {
        this.value += (timeFactor * this.initial.change);
      }
    },
  },
  mounted() {
    this.value = this.initial.value;
  },
};

export default DynamicValueMixin;
