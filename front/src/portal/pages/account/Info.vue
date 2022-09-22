<template>
  <div class="panel-content is-small">
    <div class="panel-header">
      <h1 v-html="$tmd('page.account_info.header')" />

      <button
        class="default-button"
        :disabled="!isValid"
        @click="save">
        <template v-if="waiting">...</template>
        <template v-else>{{ $t('page.account_info.save') }}</template>
      </button>
    </div>

    <v-scrollbar class="content">
      <div class="default-input">
        <label for="id">{{ $t('page.account_info.field_id') }}</label>
        <input
          type="text"
          id="id"
          disabled="true"
          :value="`#${account.id}`" />
      </div>

      <div
        v-show="account.steam_id"
        class="default-input">
        <label for="steam_id">{{ $t('page.account_info.field_steam_id') }}</label>
        <input
          type="text"
          id="steam_id"
          disabled="true"
          :value="account.steam_id" />
      </div>

      <div
        v-show="!account.steam_id"
        class="default-input">
        <label for="email">{{ $t('page.account_info.field_email') }}</label>
        <input
          type="text"
          id="email"
          disabled="true"
          v-model="account.email" />
      </div>

      <div class="default-input">
        <label for="name">{{ $t('page.account_info.field_name') }}</label>
        <input
          type="text"
          id="name"
          autocomplete="off"
          v-model="account.name" />
      </div>

      <div class="default-input">
        <label for="type">{{ $t('page.account_info.field_type') }}</label>
        <input
          type="text"
          id="type"
          disabled="true"
          :value="$t(`page.account.type_${account.is_free ? 'free' : 'paid'}`)" />
      </div>

      <hr class="margin">
    </v-scrollbar>
  </div>
</template>

<script>
export default {
  name: 'account-info',
  data() {
    return {
      account: {},
      snapshot: {},
      waiting: false,
    };
  },
  computed: {
    isValid() {
      return JSON.stringify(this.account) !== JSON.stringify(this.snapshot)
        && this.account.name.length < 40
        && !this.waiting;
    },
  },
  methods: {
    async save() {
      if (this.isValid) {
        this.waiting = true;

        try {
          const { data } = await this.$axios
            .put(`/accounts/${this.account.id}`, { account: this.account });

          this.account = { ...data };
          this.snapshot = { ...data };
          this.$store.commit('portal/account', data);
          this.$toasted.success(this.$t('page.account_info.update_success'));
        } catch (err) {
          this.$toastError(err);
        }

        this.waiting = false;
      }
    },
  },
  created() {
    const account = this.$store.state.portal.account;
    this.account = { ...account };
    this.snapshot = { ...account };
  },
};
</script>
