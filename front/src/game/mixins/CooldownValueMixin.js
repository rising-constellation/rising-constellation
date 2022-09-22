import TimeMixin from '@/game/mixins/TimeMixin';

const CooldownValueMixin = {
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
      this.value = Math.max(0, this.value - timeFactor);
    },
  },
  mounted() {
    this.value = this.initial.value;
  },
};

export default CooldownValueMixin;
