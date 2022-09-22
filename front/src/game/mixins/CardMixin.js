const CardMixin = {
  data() {
    return {
      panelContainerPosition: 0,
      activePanel: 0,
      panelCount: 0,
      leftControl: true,
      rightControl: true,
      activeChild: null,
    };
  },
  props: {
    child: {
      type: Boolean,
      default: false,
    },
    panel: {
      type: Number,
      default: 1,
    },
    theme: {
      type: String,
      default: 'none',
    },
  },
  methods: {
    movePanelToLeft() {
      this.movePanel(-1);
    },
    movePanelToRight() {
      this.movePanel(1);
    },
    movePanel(value) {
      const newPosition = this.panelContainerPosition - (value * 298);
      const maxPosition = -(this.panelCount - 1) * 298;

      this.leftControl = newPosition < 0;
      this.rightControl = newPosition > maxPosition;

      this.panelContainerPosition = newPosition <= 0 && newPosition >= maxPosition
        ? newPosition
        : this.panelContainerPosition;
    },
    showChild(child) {
      this.activeChild = child;
    },
    hideChild() {
      this.activeChild = null;
    },
  },
  mounted() {
    if (this.$refs.panelContainer) {
      this.panelCount = this.$refs.panelContainer.childElementCount;
      this.movePanel(this.panel - 1);
    }
  },
};

export default CardMixin;
