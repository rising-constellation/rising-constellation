<template>
  <div class="panel-content is-small">
    <div class="panel-header">
      <h1 v-html="$tmd('page.account_bind_web.header')" />

      <button
        class="default-button"
        :disabled="!isValid"
        @click="update">
        <template v-if="waiting">...</template>
        <template v-else>{{ $t('page.account_bind_web.send') }}</template>
      </button>
    </div>

    <v-scrollbar class="content">
      <div
        class="default-help"
        v-html="$tmd('page.account_bind_web.help')">
      </div>

      <div class="default-input">
        <label for="email">{{ $t('page.account_bind_web.email') }}</label>
        <input
          type="text"
          id="email"
          placeholder="___"
          v-model="email" />
      </div>

      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'bind-web',
  data() {
    return {
      email: '',
      waiting: false,
    };
  },
  computed: {
    account() { return this.$store.state.portal.account; },
    isValid() {
      return this.email !== '' && !this.waiting;
    },
  },
  methods: {
    async update() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.put(`/accounts/${this.account.id}/bind`, {
            email: this.email,
          });

          this.password = '';
          this.passwordConfirmation = '';
          this.$toasted.success(this.$t('page.account_bind_web.send_success'));
        } catch (err) {
          this.$toastError(err);
        }

        this.waiting = false;
      }
    },
  },
};
</script>
