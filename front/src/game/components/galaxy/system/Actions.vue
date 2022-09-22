<template>
  <div ref="container">
    <div
      class="system-actions top-shifted"
      v-if="actions.length > 0">
      <div
        v-for="action in actions"
        :key="action.icon"
        class="action-item">
        <div class="action-item-container">
          <div
            v-if="action.status === 'available'"
            class="round-icon is-active has-hover"
            @click="doAction(action.icon)"
            @mouseover="hoveredAction = action.name"
            @mouseleave="hoveredAction = null">
            <svgicon :name="`action/${action.icon}_alt`" />
          </div>
          <div
            v-if="action.status === 'unavailable'"
            v-tooltip="action.reasons"
            class="round-icon is-disabled">
            <svgicon :name="`action/${action.icon}_alt`" />
          </div>
          <div
            v-if="action.overview && hoveredAction === action.name"
            class="toolbox-actions">
            <action-overview :data="action.overview" />
          </div>
          <div class="action-label">
            <div class="name">{{ $t(`galaxy.system.actions.${action.name}`) }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="system-actions">
      <div
        v-if="isOwnSystem"
        class="action-item">
        <div class="action-item-container">
          <div
            v-if="tutorialStep === 14"
            class="tutorial-pointer is-right">
          </div>
          <div
            @click="prepareAgentAssignment()"
            class="round-icon has-hover">
          </div>
          <div
            @click="prepareAgentAssignment()"
            class="action-label">
            <div class="name">{{ $t('galaxy.system.actions.deploy') }}</div>
          </div>
        </div>
      </div>

      <div
        v-for="{ character, actions } in systemCharacters"
        class="action-item"
        :key="character.id">
        <div
          :class="[
            `force-${getTheme(character.owner.faction)}`,
            { 'is-active': system.siege !== null && character.id === system.siege.besieger_id },
          ]"
          class="action-item-container">
          <div
            class="round-icon is-active has-hover"
            :class="{
              'has-border': character.owner.id === player.id,
              'has-circle': selectedCharacter && selectedCharacter.id === character.id,
            }"
            @click="clickCharacter(character)">
            <svgicon :name="`agent/${character.type}`" />
            <span class="number">
              {{ character.level }}
            </span>
          </div>
          <div
            v-if="actions.length > 0"
            class="toolbox-actions">
            <div
              v-for="action in actions"
              :key="`${character.id}-${action.name}-overview`"
              class="actions">
              <action-overview
                v-if="action.overview && hoveredAction === `${character.id}-${action.name}`"
                class="is-top-shifted"
                :theme="getTheme(character.owner.faction)"
                :name="hoveredAction"
                :data="action.overview" />
            </div>
            <div
              v-for="action in actions"
              :key="`${character.id}-${action.name}-actions`"
              class="actions">
              <div
                v-if="action.status === 'available'"
                v-tooltip="action.tooltip"
                class="actions-item is-active has-hover"
                @click="doCharacterAction(action.icon, character.id)"
                @mouseover="hoveredAction = `${character.id}-${action.name}`"
                @mouseleave="hoveredAction = null">
                <svgicon :name="`action/${action.icon}_alt`" />
              </div>
              <div
                v-if="action.status === 'unavailable'"
                v-tooltip="action.reasons"
                class="actions-item is-disabled">
                <svgicon :name="`action/${action.icon}_alt`" />
              </div>
            </div>
          </div>
          <div class="action-label colored">
            <div class="name">{{ character.name }}</div>
            <div
              class="info"
              @click="openPlayer(character.owner.id)"
              v-if="character.owner.id !== player.id">
              {{ character.owner.name }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="system.siege !== null"
      class="siege"
      v-tooltip="$t(`data.character_action_status.${system.siege.type}.name`)">
      <svgicon :name="`action/${system.siege.type}_alt`" />
      <counter
        class="counter"
        :current="system.siege.days.value"
        :receivedAt="system.receivedAt" />
      <circle-progress-value
        :current="system.siege.days.value"
        :total="system.siege.duration"
        :increase="system.siege.days.change"
        :size="98"
        :width="4"
        :theme="systemTheme" />
    </div>
  </div>
</template>

<script>
import { TimelineLite, Expo } from 'gsap';

import actionValidation from '@/utils/actionValidation';

import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';
import CircleProgressValue from '@/game/components/generic/CircleProgressValue.vue';
import Counter from '@/game/components/generic/Counter.vue';

export default {
  name: 'system-actions',
  props: {
    system: Object,
    isOwnSystem: Boolean,
    isOwnProperty: Boolean,
  },
  data() {
    return {
      hoveredAction: null,
    };
  },
  computed: {
    tutorialStep() { return this.$store.state.game.tutorialStep; },
    systemTheme() {
      return this.system.owner
        ? this.getTheme(this.system.owner.faction)
        : null;
    },
    selectedCharacterTheme() {
      return this.selectedCharacter
        ? this.getTheme(this.selectedCharacter.owner.faction)
        : null;
    },
    player() { return this.$store.state.game.player; },
    characters() { return this.$store.state.game.player.characters; },
    selectedCharacter() { return this.$store.state.game.selectedCharacter; },
    sectors() { return this.$store.state.game.galaxy.sectors; },
    actions() {
      const actions = [];
      const context = {
        vm: this,
        selectedCharacter: this.selectedCharacter,
        system: this.system,
        sectors: this.sectors,
        themes: {
          system: this.systemTheme,
          character: this.selectedCharacterTheme,
        },
      };

      if (!this.selectedCharacter) {
        return actions;
      }

      if (this.selectedCharacter.type === 'admiral' && !this.isOwnProperty) {
        if (this.system.owner === null && this.system.status === 'uninhabited') {
          actionValidation.colonization(actions, context, this.hasSystemSlot);
        }

        if (['inhabited_neutral', 'inhabited_dominion', 'inhabited_player'].includes(this.system.status)) {
          const defense = this.system.defense ? this.system.defense.value : null;
          const overview = {
            attacker: this.selectedCharacter.army.raid_coef.value,
            attackerIcon: 'ship/raid',
            attackerModifier: this.selectedCharacter.level,
            attackerTheme: context.themes.character,
            defender: defense,
            defenderIcon: 'resource/defense',
            defenderTheme: context.themes.system,
          };

          actionValidation.conquest(actions, context, this.hasSystemSlot, this.systemTheme);
          actionValidation.raid(actions, context, overview);
          actionValidation.loot(actions, context, overview);
        }
      }

      if (this.selectedCharacter.type === 'spy' && !this.isOwnProperty) {
        if (['inhabited_neutral', 'inhabited_dominion', 'inhabited_player'].includes(this.system.status)) {
          actionValidation.infiltrate(actions, context);
        }
      }

      if (this.selectedCharacter.type === 'speaker' && !this.isOwnProperty) {
        if (['inhabited_neutral', 'inhabited_dominion'].includes(this.system.status)) {
          actionValidation.makeDominion(actions, context, this.hasDominionSlot);
        }

        if (['inhabited_neutral', 'inhabited_dominion', 'inhabited_player'].includes(this.system.status)) {
          actionValidation.encourageHate(actions, context);
        }
      }

      // move action
      if (this.selectedCharacter.actions && this.selectedCharacter.actions.virtual_position !== this.system.id) {
        actions.push({ status: 'available', icon: 'jump', name: 'move', reasons: '' });
      }

      return actions;
    },
    systemCharacters() {
      if (this.system.characters) {
        const context = {
          vm: this,
          selectedCharacter: this.selectedCharacter,
          system: this.system,
          characterTheme: this.selectedCharacterTheme,
        };

        return this.system.characters.map((character) => {
          const actions = { character, actions: [] };
          const targetTheme = this.getTheme(character.owner.faction);

          if (!this.selectedCharacter) {
            return actions;
          }

          if (this.selectedCharacter.owner.id !== character.owner.id) {
            if (this.selectedCharacter.type === 'admiral'
              && character.type === 'admiral'
              && (this.selectedCharacter.action_status === 'idle'
                || (this.selectedCharacter.action_status === 'docking'
                  && this.selectedCharacter.system === this.system.id)
              )) {
              actionValidation.fight(actions, context);
            }

            if (this.selectedCharacter.type === 'spy') {
              actionValidation.assassination(actions, context, character, targetTheme);

              if (character.type === 'admiral') {
                actionValidation.sabotage(actions, context, character, targetTheme);
              }
            }

            if (this.selectedCharacter.type === 'speaker') {
              actionValidation.conversion(actions, context, character, this.player, targetTheme);
            }
          }

          return actions;
        });
      }

      return [];
    },
    hasSystemSlot() {
      return this.player.stellar_systems.length < this.player.max_systems.value;
    },
    hasDominionSlot() {
      return this.player.dominions.length < this.player.max_dominions.value;
    },
  },
  methods: {
    getTheme(faction) {
      return this.$store.getters['game/themeByKey'](faction);
    },
    clickCharacter(character) {
      if (this.characters.find((c) => c.id === character.id)) {
        if (this.selectedCharacter && this.selectedCharacter.id === character.id) {
          this.$store.dispatch('game/unselectCharacter');
        } else {
          this.$store.dispatch('game/selectCharacter', { vm: this, id: character.id });
        }
      } else {
        this.$store.dispatch('game/openCharacter', { vm: this, id: character.id });
      }
    },
    openPlayer(playerId) {
      this.$store.dispatch('game/openPlayer', { vm: this, id: playerId });
    },
    doAction(action) {
      this.hoveredAction = null;
      this.$root.$emit('map:addAction', action, { system: this.system });
    },
    doCharacterAction(action, targetId) {
      this.hoveredAction = null;
      this.$root.$emit('map:addAction', action, { character: targetId, system: this.system });
    },
    prepareAgentAssignment() {
      const mode = 'on_board';
      const systemId = this.system.id;

      this.$root.$emit('openBottomMiniPanel', 'character-deck');
      this.$store.commit('game/prepareAssignment', { systemId, mode });
    },
  },
  mounted() {
    new TimelineLite()
      .set(this.$refs.container, { css: { opacity: 0 } })
      .to(this.$refs.container, { css: { opacity: 1 }, ease: Expo.linear, duration: 1 }, 0);
  },
  components: {
    ActionOverview,
    CircleProgressValue,
    Counter,
  },
};
</script>
