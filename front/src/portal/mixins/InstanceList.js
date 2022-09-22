const InstanceList = (speed) => ({
  data() {
    return {
      instances: [],
      profiles: [],
      polling: null,
      state: 'open,running,paused,not_running,maintenance',
      availableStates: [
        { key: 'open', value: 'open,running,paused,not_running,maintenance', label: this.$t('page.play.status_filters.open') },
        { key: 'closed', value: 'ended', label: this.$t('page.play.status_filters.closed') },
      ],
    };
  },
  computed: {
    account() { return this.$store.state.portal.account; },
  },
  watch: {
    state() { this.loadData(); },
  },
  methods: {
    async loadData() {
      const [profiles, instances] = await this.waitFor([
        this.$axios.get(`/accounts/${this.account.id}/profiles`),
        this.$axios.get(`/instances?speed=${speed}&state=${this.state}`),
      ]);

      this.profiles = profiles.data;
      this.instances = instances.data;

      this.loaded = true;
    },
  },
  mounted() {
    this.loaded = false;
    this.loadData();

    this.polling = setInterval(() => {
      this.loadData();
    }, this.$config.POLLING.LONG);
  },
  beforeDestroy() {
    clearInterval(this.polling);
  },
});

export default InstanceList;
