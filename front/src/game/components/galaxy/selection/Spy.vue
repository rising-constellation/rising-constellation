<template>
  <div class="spy-container">
    <div class="spy-header">
      <div
        v-if="!character.spy.infiltrate_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/infiltrate_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.spy.infiltrate_coef.value | integer }}
          <svgicon name="action/infiltrate_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.spy_infiltration')"
          :precision="0"
          :value="character.spy.infiltrate_coef.value"
          :details="character.spy.infiltrate_coef.details" />
      </v-popover>

      <div
        v-if="!character.spy.assassination_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/assassination_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.spy.assassination_coef.value | integer }}
          <svgicon name="action/assassination_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.spy_assassination')"
          :precision="0"
          :value="character.spy.assassination_coef.value"
          :details="character.spy.assassination_coef.details" />
      </v-popover>

      <div
        v-if="!character.spy.sabotage_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/sabotage_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.spy.sabotage_coef.value | integer }}
          <svgicon name="action/sabotage_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.spy_sabotage')"
          :precision="0"
          :value="character.spy.sabotage_coef.value"
          :details="character.spy.sabotage_coef.details" />
      </v-popover>
    </div>
    <div class="spy-cover">
      <div class="spy-cover-icon">
        <svgicon
          v-if="isUndercover"
          v-tooltip="$t('galaxy.selection.view.undercover')"
          name="agent/undercover" />
        <svgicon
          v-else
          v-tooltip="$t('galaxy.selection.view.discovered')"
          class="is-active"
          name="agent/discovered" />
      </div>
      <div
        v-if="character.spy.cover"
        class="spy-cover-content">
        <div class="spy-cover-title">
          <template v-if="coverChange > 0">
            {{ $t('galaxy.selection.view.cover_gain') }}
          </template>
          <template v-else>
            {{ $t('galaxy.selection.view.cover_locked') }}
          </template>
        </div>
        <div
          v-tooltip="tooltip"
          class="spy-cover-info">
          <progress-value
            :current="character.spy.cover.value"
            :total="100"
            :blockAtEnd="true"
            :cursor="constant.cover_threshold"
            :increase="coverChange" />
        </div>
      </div>
      <div
        v-else
        class="spy-cover-content">
        <div class="spy-cover-info">
          <progress-value
            :current="0"
            :total="100"
            :cursor="constant.cover_threshold"
            :increase="0" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';
import ProgressValue from '@/game/components/generic/ProgressValue.vue';

export default {
  name: 'spy',
  props: {
    character: Object,
  },
  computed: {
    constant() { return this.$store.state.game.data.constant[0]; },
    speed() { return this.$store.state.game.time.speed; },
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    isUndercover() {
      return this.character.spy.cover
        ? this.character.spy.cover.value > this.constant.cover_threshold : false;
    },
    coverChange() {
      return this.character.action_status === 'idle' && this.character.spy.cover.value < 100
        ? this.character.spy.cover.change : 0;
    },
    tooltip() {
      if (this.speed !== 'fast' && this.character.spy.cover.value < 100 && this.character.action_status === 'idle') {
        const threshold = this.character.spy.cover.value < this.constant.cover_threshold
          ? this.constant.cover_threshold : 100;

        const ticks = (threshold - this.character.spy.cover.value) / this.character.spy.cover.change;
        const timestamp = this.character.receivedAt + (ticks * this.tickToMilisecondFactor);
        const date = this.$options.filters['luxon-std'](timestamp);

        return this.character.spy.cover.value < this.constant.cover_threshold
          ? this.$t('galaxy.selection.view.cover_timestamp', { date })
          : this.$t('galaxy.selection.view.max_cover_timestamp', { date });
      }

      return '';
    },
  },
  components: {
    ResourceDetail,
    ProgressValue,
  },
};
</script>
