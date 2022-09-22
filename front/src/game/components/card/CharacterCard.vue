<template>
  <div
    class="card-container"
    :class="`f-${theme}`"
    ref="card"
    @click="select">
    <div class="card-header">
      <div class="card-header-icon">
        <svgicon :name="`agent/${character.type}`" />
        <span class="level">
          <template v-if="diff">
            {{ diff.level | obfuscate(diff.level, '?') }}
          </template>
          <template v-else>
            {{ character.level | obfuscate(character.level, '?') }}
          </template>
        </span>
        <span
          v-show="group"
          class="group">
          {{ group }}
        </span>
      </div>
      <div class="card-header-content">
        <div class="title-large nowrap">
          <span v-if="isDead">(&#x271d;)</span>
          {{ character.name }}
        </div>
        <div class="title-small nowrap">
          {{ $t(specialization(character)) }}
        </div>
      </div>
    </div>

    <div class="card-body">
      <div class="card-illustration">
        <img :src="`data/agents/${character.illustration}`">
      </div>

      <div class="card-information">
        <div class="card-panel-controls">
          <svgicon
            class="card-panel-control"
            name="caret-left"
            @click="movePanelToLeft"
            v-if="leftControl" />
          <div v-else></div>
          <svgicon
            class="card-panel-control"
            name="caret-right"
            @click="movePanelToRight"
            v-if="rightControl" />
          <div v-else></div>
        </div>

        <div class="card-panel-window">
          <div
            ref="panelContainer"
            class="card-panel-container"
            :style="{ left: panelContainerPosition + 'px' }">
            <div class="card-panel">
              <div class="is-sparse-y">
                <div v-if="character.experience === null">
                  ░░░ ░░░░░░░
                </div>
                <div v-else>
                  <dynamic-value
                    v-if="character.status === 'governor'"
                    :initial="character.experience" />
                  <span v-else>
                    {{ character.experience.value | integer }}
                  </span>
                  <span class="card-diff" v-if="diff && diff.experience.value - character.experience.value > 0">
                    +{{ diff.experience.value - character.experience.value | integer }}
                  </span>
                  / {{ nextLevelExperience | integer }}
                  <strong>XP</strong>
                </div>
                <div>
                  {{ $t(`data.culture.${character.culture}.kind`) }}
                </div>
              </div>

              <div class="is-sparse-y">
                <div>
                  <div
                    v-tooltip="$t('card.character.protection')"
                    class="simple-bonus">
                    {{ character.protection | obfuscate(character.protection, '░░') }}
                    <span class="card-diff" v-if="diff && diff.protection - character.protection > 0">
                      +{{ diff.protection - character.protection | integer }}
                    </span>
                    <svgicon name="agent/protection" />
                  </div>
                  <div
                    v-tooltip="$t('card.character.determination')"
                    class="simple-bonus">
                    {{ character.determination | obfuscate(character.determination, '░░') }}
                    <span class="card-diff" v-if="diff && diff.determination - character.determination > 0">
                      +{{ diff.determination - character.determination | integer }}
                    </span>
                    <svgicon name="agent/determination" />
                  </div>
                </div>
                <div>
                  <div
                    v-tooltip="$t('card.character.salary')"
                    class="simple-bonus">
                    {{ character.level * constant.character_level_wages }}
                    <span class="card-diff" v-if="diff && (diff.level - character.level) * constant.character_level_wages > 0">
                      +{{ (diff.level - character.level) * constant.character_level_wages | integer }}
                    </span>
                    <svgicon name="resource/credit" />
                  </div>
                </div>
              </div>

              <hr>

              <template v-if="character.skills">
                <div
                  v-for="(skill, i) in character.skills"
                  :key="i">
                  <h2 v-if="i === 0">{{ $t('card.character.agent') }}</h2>
                  <h2 v-if="i === 3">{{ $t('card.character.governor') }}</h2>
                  <div
                    v-tooltip.left="$t(`data.character.${character.type}.skills[${i}].description`)"
                    :class="{ 'character-skill-active': data.specializations[i].key === character.specialization }"
                    class="is-sparse-y">
                    <div>{{ $t(`data.character.${character.type}.skills[${i}].name`) }}</div>
                    <div class="character-skill-points">
                      <template v-if="diff && skill !== diff.skills[i]">
                        <span
                          v-for="s in 12"
                          :key="s"
                          :class="{
                            'active': s <= skill,
                            'strong': s === skill,
                            'lvlup': s === skill + 1,
                            'inactive': s > skill + 1,
                          }">
                        </span>
                      </template>
                      <template v-else>
                        <span
                          v-for="s in 12"
                          :key="s"
                          :class="{
                            'active': s <= skill,
                            'strong': s === skill,
                            'inactive': s > skill,
                          }">
                        </span>
                      </template>
                    </div>
                  </div>
                </div>
              </template>
              <template v-else>
                <div
                  v-for="i in [0, 1, 2, 3, 4, 5]"
                  :key="i">
                  <h2 v-if="i === 0">{{ $t('card.character.agent') }}</h2>
                  <h2 v-if="i === 3">{{ $t('card.character.governor') }}</h2>
                  <div class="is-sparse-y">
                    <div>{{ $t(`data.character.${character.type}.skills[${i}].name`) }}</div>
                    <div class="character-skill-points">
                      <span
                        v-for="s in 12"
                        :key="s"
                        class="hidden">
                      </span>
                    </div>
                  </div>
                </div>
              </template>
            </div>

            <div class="card-panel">
              <h2>{{ $t('card.character.about') }}</h2>
              <p>
                <strong>{{ character.gender | obfuscate(character.gender, '░░░░') }}</strong> de
                <strong>{{ character.age | obfuscate(character.age, '░░') }}</strong> ans.
              </p>
              <p>
                Originaire des régions
                <strong>
                  {{ $t(`data.culture.${character.culture}.name`) }}
                </strong>.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      class="card-action"
      v-if="!child && !noAction">
      <div class="card-action-button">
        <div
          v-if="character.on_sold"
          class="button disabled">
          <div class="dashed">
            {{ $t('card.character.on_sold') }}
          </div>
        </div>
        <div
          v-else-if="character.status === 'for_hire'"
          class="button"
          @click="hire">
          <div>{{ $t('card.character.hire') }}</div>
          <div
            class="icon-value"
            v-if="character.credit_cost > 0">
            {{ character.credit_cost | integer }}
            <svgicon name="resource/credit" />
          </div>
          <div
            class="icon-value"
            v-if="character.technology_cost > 0">
            {{ character.technology_cost | integer }}
            <svgicon name="resource/technology" />
          </div>
          <div
            class="icon-value"
            v-if="character.ideology_cost > 0">
            {{ character.ideology_cost | integer }}
            <svgicon name="resource/ideology" />
          </div>
        </div>
        <template v-else-if="character.status === 'in_deck' && assignment">
          <div
            v-if="cooldown && cooldown.value != 0"
            class="button disabled">
            <div class="dashed">
              <template v-if="receivedAt && speed !== 'fast'">
                {{ $t(
                  'card.character.locked_character_date',
                  { date: $options.filters['luxon-std'](receivedAt + (cooldown.value * tickToMilisecondFactor)) }
                ) }}
              </template>
              <template v-else>
                {{ $t('card.character.locked_character') }}
              </template>
            </div>
          </div>
          <div
            v-else-if="charactersLimit.current < charactersLimit.max"
            class="button"
            @click="activate">
            <div>{{ $t('card.character.deploy') }}</div>
          </div>
          <div
            v-else
            class="button disabled">
            <div class="dashed">{{ $t(`card.character.${character.type}_limit_reached`) }}</div>
          </div>
        </template>
        <div
          v-else-if="character.status === 'in_deck' && !assignment"
          class="button"
          @click="dismiss">
          <div>{{ $t('card.character.fire') }}</div>
        </div>
        <div
          v-else-if="character.status === 'governor' && character.owner.id === playerId"
          class="button"
          @click="deactivate">
          <div>{{ $t('card.character.recall') }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardMixin from '@/game/mixins/CardMixin';

import DynamicValue from '@/game/components/generic/DynamicValue.vue';

export default {
  name: 'character-card',
  mixins: [CardMixin],
  props: {
    character: Object,
    diff: {
      type: Object,
      required: false,
    },
    isDead: {
      type: Boolean,
      default: false,
    },
    cooldown: {
      type: Object,
      required: false,
    },
    receivedAt: {
      type: Number,
      required: false,
    },
    noAction: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    tickToMilisecondFactor() { return this.$store.getters['game/tickToMilisecondFactor']; },
    speed() { return this.$store.state.game.time.speed; },
    assignment() { return this.$store.state.game.assignment; },
    constant() { return this.$store.state.game.data.constant[0]; },
    playerId() { return this.$store.state.game.player.id; },
    charactersLimit() {
      const bonusName = {
        admiral: 'max_admirals',
        spy: 'max_spies',
        speaker: 'max_speakers',
      };

      const max = this.$store.state.game.player[bonusName[this.character.type]].value;
      const current = this.$store.state.game.player.characters.filter((c) => c.type === this.character.type).length;

      return { current, max };
    },
    data() { return this.$store.state.game.data.character.find((c) => c.key === this.character.type); },
    nextLevelExperience() {
      return Math.round((10 * (this.character.level + 1)) + (((this.character.level + 1) / 2) ** 2.5));
    },
    group() {
      if (this.character.status === 'on_board') {
        return Object.keys(this.$store.state.game.charactersGroup)
          .find((key) => this.$store.state.game.charactersGroup[key] === this.character.id);
      }
      return null;
    },
  },
  methods: {
    hire() {
      if (this.character.status === 'for_hire') {
        this.$socket.player.push('hire_character', {
          character: this.character,
        }).receive('ok', () => {
          this.$emit('hired', this.character);
        }).receive('error', (err) => {
          this.$toastError(err.reason);
        });
      }
    },
    activate() {
      if (this.assignment) {
        const boundingBox = this.$refs.card.getBoundingClientRect();

        this.$emit('assign', {
          systemId: this.assignment.systemId,
          character: this.character,
          mode: this.assignment.mode,
          box: boundingBox,
        });
      }
    },
    manage() {
      if (this.character.status === 'governor' || this.character.status === 'on_board') {
        this.$emit('manage', this.character);
      }
    },
    select() {
      if (this.character.status === 'governor' || this.character.status === 'on_board') {
        this.$emit('select', this.character);
      }
    },
    deactivate() {
      if (this.character.status === 'governor' || this.character.status === 'on_board') {
        this.$socket.player.push('deactivate_character', {
          character_id: this.character.id,
        }).receive('ok', () => {
          this.$emit('deactivated', this.character);
        }).receive('error', (err) => {
          this.$toastError(err.reason);
        });
      }
    },
    dismiss() {
      if (this.character.status === 'in_deck') {
        const boundingBox = this.$refs.card.getBoundingClientRect();

        this.$emit('dismiss', {
          character: this.character,
          box: boundingBox,
        });
      }
    },
    specialization(character) {
      return `data.character.${character.type}.specializations.${character.specialization}`;
    },
  },
  components: {
    DynamicValue,
  },
};
</script>
