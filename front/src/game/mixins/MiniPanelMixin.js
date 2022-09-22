const MiniPanelMixin = {
  data() {
    return {
      activeTab: undefined,
      counter: 0,
    };
  },
  props: {
    defaultTab: {
      type: String,
      required: false,
    },
    height: Number,
  },
  computed: {
    tabs() { return []; },
  },
  methods: {
    switchTab(key) {
      if (this.tabs.includes(key)) {
        this.activeTab = key;
        this.counter += 1;
      }
    },
    close() {
      this.$emit('close');
    },
  },
  mounted() {
    if (this.defaultTab === undefined || this.defaultTab === '') {
      this.switchTab(this.tabs[0]);
    } else {
      this.switchTab(this.defaultTab);
    }
  },
};

export default MiniPanelMixin;
