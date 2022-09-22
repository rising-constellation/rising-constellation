<template>
  <div class="default-input">
    <label for="id">{{ label }}</label>
    <v-select
      class="input-profile-select"
      :options="options"
      :filterable="false"
      :multiple="multiple"
      v-model="value"
      @search="fetchOptions"
      @input="input">
      <template slot="no-options">
        {{ $t('toast.error.select_no_result') }}
      </template>
    </v-select>
  </div>
</template>

<script>
export default {
  name: 'input-profile-select',
  props: {
    multiple: {
      type: Boolean,
      default: false,
    },
    label: {
      type: String,
      required: true,
    },
    discardedIds: {
      type: Array,
      default: (() => []),
    },
  },
  data() {
    return {
      options: [],
      value: null,
    };
  },
  methods: {
    async fetchOptions(search, loading) {
      if (search.length) {
        loading(true);

        const { data } = await this.$axios.get(`/profile/search/${search}`);
        this.options = data
          .filter((p) => !this.discardedIds.includes(p.id))
          .map((p) => ({ label: p.name, id: p.id }));

        loading(false);
      }
    },
    input(value) {
      this.$emit('input', value);
    },
  },
};
</script>
