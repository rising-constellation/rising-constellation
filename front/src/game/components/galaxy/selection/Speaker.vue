<template>
  <div class="speaker-container">
    <div class="speaker-header">
      <div
        v-if="!character.speaker.make_dominion_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/make_dominion_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.speaker.make_dominion_coef.value | integer }}
          <svgicon name="action/make_dominion_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.speaker_make_dominion')"
          :precision="0"
          :value="character.speaker.make_dominion_coef.value"
          :details="character.speaker.make_dominion_coef.details" />
      </v-popover>

      <div
        v-if="!character.speaker.encourage_hate_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/encourage_hate_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.speaker.encourage_hate_coef.value | integer }}
          <svgicon name="action/encourage_hate_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.speaker_encourage_hate')"
          :precision="0"
          :value="character.speaker.encourage_hate_coef.value"
          :details="character.speaker.encourage_hate_coef.details" />
      </v-popover>

      <div
        v-if="!character.speaker.conversion_coef"
        class="def-list-prop">
        ░░ <svgicon name="ship/conversion_alt" />
      </div>
      <v-popover
        v-else
        trigger="hover">
        <div class="def-list-prop">
          {{ character.speaker.conversion_coef.value | integer }}
          <svgicon name="action/conversion_alt" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('galaxy.selection.view.speaker_conversion')"
          :precision="0"
          :value="character.speaker.conversion_coef.value"
          :details="character.speaker.conversion_coef.details" />
      </v-popover>
    </div>

    <div
      v-if="character.speaker.cooldown"
      class="speaker-cooldown">
      <template v-if="character.speaker.cooldown.value > 0">
        <div class="speaker-cooldown-status">
          {{ $t('galaxy.selection.view.speaker_cooldown') }}
        </div>
        <progress-value
          v-tooltip="tooltip"
          :current="character.speaker.cooldown.initial - character.speaker.cooldown.value"
          :total="character.speaker.cooldown.initial"
          :increase="1" />
      </template>
      <template v-else>
        <div class="speaker-cooldown-status">
          {{ $t('galaxy.selection.view.speaker_ready') }}
        </div>
      </template>
    </div>
    <div
      v-else
      class="speaker-cooldown">
      <div class="speaker-cooldown-status">
        {{ $t('galaxy.selection.view.speaker_ready') }}
      </div>
    </div>
  </div>
</template>

<script>
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';
import ProgressValue from '@/game/components/generic/ProgressValue.vue';

export default {
  name: 'speaker',
  props: {
    character: Object,
  },
  components: {
    ResourceDetail,
    ProgressValue,
  },
  computed: {
    speed() { return this.$store.state.game.time.speed; },
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    tooltip() {
      if (this.speed !== 'fast' && this.character.speaker.cooldown.value > 0) {
        const timestamp = this.character.receivedAt + (this.character.speaker.cooldown.value * this.tickToMilisecondFactor);
        const date = this.$options.filters['luxon-std'](timestamp);
        return this.$t('galaxy.selection.view.speaker_timestamp', { date });
      }

      return '';
    },
  },
};
</script>
