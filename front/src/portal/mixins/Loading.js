const Loading = {
  data() {
    return {
      loaded: false,
    };
  },
  methods: {
    async releaseLoading(fn, delay = 250) {
      if (typeof fn !== 'object') {
        await this.timeout(fn || delay);
        this.loaded = true;
        return true;
      }
      if (Array.isArray(fn)) {
        const results = await Promise.all([
          ...fn,
          this.timeout(delay),
        ]);
        this.loaded = true;
        return results.slice(0, fn.length);
      }

      const results = await Promise.all([
        fn,
        this.timeout(delay),
      ]);
      this.loaded = true;
      return results[0];
    },
    async waitFor(fn, delay = 250) {
      if (typeof fn !== 'object') {
        await this.timeout(fn || delay);
        this.loaded = true;
        return true;
      }
      if (Array.isArray(fn)) {
        const results = await Promise.all([
          ...fn,
          this.timeout(delay),
        ]);
        return results.slice(0, fn.length);
      }

      const results = await Promise.all([
        fn,
        this.timeout(delay),
      ]);
      return results[0];
    },
    timeout(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
  },
};

export default Loading;
