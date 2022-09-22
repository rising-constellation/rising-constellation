<template>
  <div class="custom-select">
    <div
      v-show="label"
      class="custom-select-label">
      {{ label }}
    </div>
    <div class="custom-select-input">
      <v-select
        :options="options"
        :filterable="false"
        :multiple="multiple"
        v-model="value"
        @input="input">
        <template slot="no-options">
          {{ $t('toast.error.select_no_result') }}
        </template>
      </v-select>
    </div>
  </div>
</template>

<script>
export default {
  name: 'faction-select',
  props: {
    multiple: {
      type: Boolean,
      default: false,
    },
    label: {
      type: String,
      required: false,
    },
    factions: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      options: [],
      value: null,
    };
  },
  methods: {
    input(value) {
      this.$emit('input', value);
    },
  },
  mounted() {
    this.options = this.factions;
  },
};
</script>
