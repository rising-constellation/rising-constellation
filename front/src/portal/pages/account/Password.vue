<template>
  <div class="panel-content is-small">
    <div class="panel-header">
      <h1 v-html="$tmd('page.account_password.header')" />

      <button
        class="default-button"
        :disabled="!isValid"
        @click="update">
        <template v-if="waiting">...</template>
        <template v-else>{{ $t('page.account_password.modify') }}</template>
      </button>
    </div>

    <v-scrollbar class="content">
      <div class="default-input">
        <label for="password1">{{ $t('page.account_password.password') }}</label>
        <input
          type="password"
          id="password1"
          placeholder="___"
          v-model="password" />
      </div>

      <div class="default-input">
        <label for="password2">{{ $t('page.account_password.password_confirmation') }}</label>
        <input
          type="password"
          id="password2"
          placeholder="___"
          v-model="passwordConfirmation" />
      </div>

      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'account-password',
  data() {
    return {
      password: '',
      passwordConfirmation: '',
      waiting: false,
    };
  },
  computed: {
    account() { return this.$store.state.portal.account; },
    isValid() {
      return this.password !== '' && this.passwordConfirmation !== ''
        && this.password === this.passwordConfirmation
        && !this.waiting;
    },
  },
  methods: {
    async update() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.put(`/accounts/${this.account.id}`, {
            account: { password: this.password },
          });

          this.password = '';
          this.passwordConfirmation = '';
          this.$toasted.success(this.$t('page.account_password.update_success'));
        } catch (err) {
          this.$toastError(err);
        }

        this.waiting = false;
      }
    },
  },
};
</script>
