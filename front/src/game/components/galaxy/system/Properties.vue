<template>
  <div
    ref="container"
    class="system-properties">
    <div class="header">
      {{ system.name }}
    </div>

    <div class="box-line info">
      <div
        v-if="!['uninhabitable', 'uninhabited'].includes(system.status)"
        class="box-aside left">
        <div v-if="!system.defense">
          <svgicon name="resource/defense" />
          ?
        </div>
        <v-popover
          trigger="hover"
          v-else>
          <div>
            <svgicon name="resource/defense" />
            {{ system.defense.value | integer }}
          </div>
          <resource-detail
            slot="popover"
            :title="$t('data.bonus_pipeline_in.sys_defense.name')"
            :value="system.defense.value"
            :details="system.defense.details" />
        </v-popover>
      </div>

      <div class="owner">
        <div
          v-if="!['uninhabitable', 'uninhabited'].includes(system.status)"
          :class="{ 'is-half': ['inhabited_neutral', 'inhabited_dominion'].includes(system.status) }"
          class="marker">
        </div>

        <div
          v-if="!['uninhabitable', 'uninhabited'].includes(system.status)"
          class="marker-label">
          <span v-if="!system.population_class">?</span>
          <v-popover
            v-else
            trigger="hover">
            <div>{{ populationClass.points }}</div>
            <resource-detail
              slot="popover"
              :title="$t(`data.population_class.${populationClass.key}`)"
              :value="populationClass.points"
              :precision="0"
              :description="$t('galaxy.system.pop_class.info')"
              :details="populationClasses" />
          </v-popover>
        </div>

        <div>
          <template v-if="['uninhabitable', 'uninhabited'].includes(system.status)">
            <div class="label">{{ $t('galaxy.system.properties.not_claimed') }}</div>
            <div class="value">—</div>
          </template>
          <template v-if="system.status === 'inhabited_neutral'">
            <div class="label">{{ $t('galaxy.system.properties.not_claimed') }}</div>
            <div class="value">{{ $t('galaxy.system.properties.autonomous_system') }}</div>
          </template>
          <template v-if="system.status === 'inhabited_dominion'">
            <div class="label">{{ $t('galaxy.system.properties.dominion_of') }}</div>
            <div
              @click="openPlayer"
              class="value">
              {{ system.owner.name }}
            </div>
          </template>
          <template v-if="system.status === 'inhabited_player'">
            <div class="label">{{ $t('galaxy.system.properties.system_of') }}</div>
            <div
              @click="openPlayer"
              class="value">
              {{ system.owner.name }}
            </div>
          </template>
        </div>
      </div>

      <div class="star">
        <div>
          <div class="value">
            {{ $t(`data.stellar_system.${system.type}.name`) }}
          </div>
          <div class="label">
            {{ system.position.x | integer }}:{{ system.position.y | integer }}
          </div>
        </div>
      </div>

      <div class="box-aside right">
        <v-popover trigger="hover">
          <div>
            <svgicon name="eye" />
            {{ system.contact.value }}
          </div>
          <resource-detail
            slot="popover"
            :title="$t('data.bonus_pipeline_in.sys_visibility.name')"
            :precision="0"
            :value="system.contact.value"
            :details="groupContactDetails(system.contact.details)"
            :minimum="system.contact.minimum" />
        </v-popover>
      </div>
    </div>

    <div class="box-line yields">
      <div v-if="!system.credit">
        <div class="yield-box">
          ░░░░ <svgicon name="resource/credit" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div class="yield-box">
          {{ system.credit.value | integer }}
          <svgicon name="resource/credit" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('data.bonus_pipeline_in.sys_credit.name')"
          :description="$t(`resource-description.credit`)"
          :value="system.credit.value"
          :details="system.credit.details" />
      </v-popover>

      <div v-if="!system.technology">
        <div class="yield-box">
          ░░░░ <svgicon name="resource/technology" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div class="yield-box">
          {{ system.technology.value | integer }}
          <svgicon name="resource/technology" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('data.bonus_pipeline_in.sys_technology.name')"
          :description="$t(`resource-description.technology`)"
          :value="system.technology.value"
          :details="system.technology.details" />
      </v-popover>

      <div v-if="!system.ideology">
        <div class="yield-box">
          ░░░░ <svgicon name="resource/ideology" />
        </div>
      </div>
      <v-popover v-else trigger="hover">
        <div class="yield-box">
          {{ system.ideology.value | integer }}
          <svgicon name="resource/ideology" />
        </div>
        <resource-detail
          slot="popover"
          :title="$t('data.bonus_pipeline_in.sys_ideology.name')"
          :description="$t(`resource-description.ideology`)"
          :value="system.ideology.value"
          :details="system.ideology.details" />
      </v-popover>
    </div>

    <template v-if="!['uninhabitable', 'uninhabited'].includes(system.status)">
      <div
        v-if="system.governor"
        class="governor-box"
        :class="`force-${color}`">
        <div
          @click="openCharacter"
          class="round-icon is-active has-hover">
          <svgicon :name="`agent/${system.governor.type}`" />
          <span class="number">
            {{ system.governor.level }}
          </span>
        </div>
        <div
          v-if="governorAction.actions.length > 0"
          class="toolbox-actions">
          <div
            v-for="action in governorAction.actions"
            :key="`${governorAction.character.id}-${action.name}-actions`"
            class="actions">
            <div
              v-if="action.status === 'available'"
              v-tooltip="action.tooltip"
              class="actions-item is-active has-hover"
              @click="doCharacterAction(action.icon, governorAction.character.id)"
              @mouseover="hoveredAction = `${governorAction.character.id}-${action.name}`"
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
          <div
            v-for="action in governorAction.actions"
            :key="`${governorAction.character.id}-${action.name}-overview`"
            class="actions">
            <action-overview
              v-if="action.overview && hoveredAction === `${governorAction.character.id}-${action.name}`"
              class="is-top-shifted"
              :data="action.overview" />
          </div>
        </div>
      </div>

      <div
        v-else-if="isOwnSystem"
        v-tooltip.bottom="$t('galaxy.system.properties.deploy_governor')"
        @click="prepareGovernorAssignment()"
        class="governor-box round-icon has-hover">
      </div>
      <div
        v-else
        class="governor-box round-icon is-disabled">
      </div>

      <div class="production-box">
        <div class="production-value">
          <template v-if="!system.production">
            <div class="yield-box">
              ░░░
              <svgicon name="resource/production" />
            </div>
          </template>
          <v-popover v-else trigger="hover">
            <div class="yield-box">
              {{ system.production.value | integer }}
              <svgicon name="resource/production" />
            </div>
            <resource-detail
              slot="popover"
              :title="$t('data.bonus_pipeline_in.sys_production.name')"
              :description="$t(`resource-description.production`)"
              :value="system.production.value"
              :details="system.production.details" />
          </v-popover>
        </div>
        <div
          v-if="isOwnProperty && system.queue && system.queue.queue.length > 0"
          class="production-counter">
          <counter
            :current="this.system.queue.queue[0].remaining_prod / this.system.production.value"
            :receivedAt="system.receivedAt" />
        </div>
        <div
          v-if="system.queue"
          class="round-icon"
          :class="{
            'is-disabled': system.queue.queue.length === 0,
            'has-hover': system.queue.queue.length > 0,
            'is-pulsing': system.queue.queue.length > 0,
          }"
          @click="$emit('toggleQueue')">
          <template v-if="system.queue.queue.length > 0">
            <circle-progress-value
              :current="system.queue.queue[0].total_prod - system.queue.queue[0].remaining_prod"
              :total="system.queue.queue[0].total_prod"
              :increase="system.production.value"
              :size="46"
              :width="4"
              :theme="color" />
            <svgicon
              v-if="this.system.queue.queue[0].type === 'ship'"
              :name="`ship/${this.system.queue.queue[0].prod_key}`" />
            <svgicon
              v-else
              :name="`building/${this.system.queue.queue[0].prod_key}`" />
            <span
              v-if="system.queue.queue.length - 1 > 0"
              class="number">
              {{ system.queue.queue.length - 1 }}
            </span>
          </template>
        </div>
        <div
          v-else
          class="round-icon is-disabled">
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { TimelineLite, Expo } from 'gsap';

import actionValidation from '@/utils/actionValidation';

import ActionOverview from '@/game/components/galaxy/system/ActionOverview.vue';
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';
import CircleProgressValue from '@/game/components/generic/CircleProgressValue.vue';
import Counter from '@/game/components/generic/Counter.vue';

export default {
  name: 'system-properties',
  props: {
    system: Object,
    isOwnSystem: Boolean,
    isOwnProperty: Boolean,
    color: String,
  },
  data() {
    return {
      hoveredAction: null,
    };
  },
  computed: {
    selectedCharacter() { return this.$store.state.game.selectedCharacter; },
    player() { return this.$store.state.game.player; },
    populationClass() {
      return this.$store.state.game.data.population_class
        .find((pc) => pc.key === this.system.population_class);
    },
    populationClasses() {
      return this.$store.state.game.data.population_class.map((pc) => {
        const active = pc.key === this.populationClass.key;
        const label = this.$t(`data.population_class.${pc.key}`);
        return { reason: this.$t('galaxy.system.pop_class.label', { label, pop: pc.threshold }), value: pc.points, active };
      }).reverse();
    },
    governorAction() {
      const character = this.system.governor;
      const actions = { character, actions: [] };

      if (character && this.selectedCharacter) {
        const context = {
          vm: this,
          selectedCharacter: this.selectedCharacter,
          system: this.system,
          theme: this.getTheme(this.selectedCharacter.owner.faction),
        };

        if (this.selectedCharacter.type === 'spy') {
          const targetTheme = this.getTheme(character.owner.faction);
          actionValidation.assassination(actions, context, character, targetTheme);
        }
      }

      return actions;
    },
  },
  methods: {
    getTheme(faction) {
      return this.$store.getters['game/themeByKey'](faction);
    },
    prepareGovernorAssignment() {
      const mode = 'governor';
      const systemId = this.system.id;

      this.$root.$emit('openBottomMiniPanel', 'character-deck');
      this.$store.commit('game/prepareAssignment', { systemId, mode });
    },
    doCharacterAction(action, targetId) {
      this.hoveredAction = null;
      this.$root.$emit('map:addAction', action, { character: targetId, system: this.system });
    },
    openCharacter() {
      this.$store.dispatch('game/openCharacter', { vm: this, id: this.system.governor.id });
    },
    openPlayer() {
      this.$store.dispatch('game/openPlayer', { vm: this, id: this.system.owner.id });
    },
    groupContactDetails(details) {
      if (!details.informer) {
        return details;
      }

      const informers = details.informer.reduce((acc, informer) => {
        const existingReason = acc.find(({ reason }) => reason === informer.reason);
        if (existingReason) {
          existingReason.value += 1;
        } else {
          acc.push({ reason: informer.reason, value: informer.value });
        }
        return acc;
      }, []);

      return { informer: informers, explorer: details.explorer };
    },
  },
  mounted() {
    new TimelineLite()
      .set(this.$refs.container, { top: -100 })
      .to(this.$refs.container, { top: 50, ease: Expo.easeOut, duration: 1 }, 0);
  },
  components: {
    ActionOverview,
    ResourceDetail,
    CircleProgressValue,
    Counter,
  },
};
</script>
