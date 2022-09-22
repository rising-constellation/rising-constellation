<template>
  <div
    class="card-container closed"
    :class="`f-${theme}`"
    @click="select">
    <div class="card-header">
      <div
        v-if="character.status === 'on_board' && character.type === 'admiral'"
        class="card-header-army">
        <div
          v-if="character.army_size"
          class="card-header-army-item is-faded"
          :style="{ height: `${character.army_size.planned / army_tile_count * 100}%` }"></div>
        <div
          v-if="character.army_size"
          class="card-header-army-item"
          :style="{ height: `${character.army_size.filled / army_tile_count * 100}%` }"></div>
      </div>
      <div
        v-if="character.status === 'on_board'
          && character.type === 'spy'
          && character.is_discovered"
        class="card-header-cover">
        <svgicon name="agent/discovered" />
      </div>
      <div class="card-header-icon">
        <svgicon :name="`agent/${character.type}`" />
        <span class="level">
          {{ character.level }}
        </span>
        <span
          v-show="group"
          class="group">
          {{ group }}
        </span>
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          {{ character.name }}
        </div>
        <div
          v-if="actions.length"
          class="title-actions">
          <counter
            class="counter"
            v-if="character.actions && character.actions.queue[0].remaining_time !== 'unknown_yet'"
            :current="character.actions.queue[0].remaining_time"
            :receivedAt="character.receivedAt" />
          <div
            v-for="(action, i) in actions"
            :key="`c${character.id}-a${i}`"
            :class="{
              'is-action': action !== 'jump',
              'is-big': action === 'jump' && i === 0
            }"
            class="title-actions-item is-jump"></div>
        </div>
        <div
          v-else-if="character.action_status === 'docking'"
          class="title-small">
          {{ $t(`data.character_action_status.${character.action_status}.name`) }}
        </div>
      </div>
      <div
        v-if="character.status === 'on_board' && character.actions
          && character.actions.queue.length
          && character.actions.queue[0].type !== 'jump'"
        v-tooltip.left="$t(`data.character_action_status.${character.action_status}.name`)"
        class="card-header-toast active">
        <svgicon :name="`action/${character.actions.queue[0].type}`" />
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';
import Counter from '@/game/components/generic/Counter.vue';

export default {
  name: 'closed-character-card',
  mixins: [CardMixin],
  props: {
    character: Object,
  },
  computed: {
    army_tile_count() { return this.$store.state.game.data.constant[0].army_tile_count; },
    actions() {
      if (!this.character.actions) {
        return [];
      }

      const actions = this.character.actions.queue.map((action) => action.type);
      return actions.slice(0, 10);
    },
    group() {
      return Object.keys(this.$store.state.game.charactersGroup)
        .find((key) => this.$store.state.game.charactersGroup[key] === this.character.id);
    },
  },
  methods: {
    select() {
      if (this.character.status === 'governor' || this.character.status === 'on_board') {
        this.$emit('select', this.character);
      }
    },
  },
  components: {
    Counter,
  },
};
</script>
