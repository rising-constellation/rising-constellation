<template>
  <div class="navbar-container">
    <div class="navbar bottom">
      <div class="navbar-left">
        <!-- TODO: should be a component -->
        <div class="navbar-main-button">
          <div class="navbar-main-button-toolbox">
            <div
              class="button"
              v-if="ownSystems.length > 0"
              @click="toggleSystemList">
              <template v-if="isSystemListOpen">
                <svgicon class="icon" name="caret-down" />
              </template>
              <template v-else>
                <svgicon class="icon" name="caret-up" />
              </template>
            </div>
          </div>

          <div
            @click="togglePanel('empire')"
            class="navbar-main-button-icon">
            <svgicon class="icon" name="empire" />
          </div>
        </div>

        <div class="navbar-group-buttons left">
          <div
            v-if="tutorialStep === 6"
            class="tutorial-pointer is-technology is-bottom">
          </div>
          <div
            v-if="tutorialStep === 10"
            class="tutorial-pointer is-ideology is-bottom">
          </div>
          <v-popover trigger="hover">
            <navbar-maxed-value
              :label="$t('navbar.bottombar.systems')"
              :value="player.stellar_systems.length"
              :maximum="player.max_systems.value" />
            <resource-detail
              slot="popover"
              :title="$t('navbar.bottombar.systems_limit')"
              :precision="0"
              :value="player.max_systems.value"
              :details="player.max_systems.details" />
          </v-popover>

          <v-popover trigger="hover">
            <navbar-maxed-value
              :label="$t('navbar.bottombar.dominions')"
              :value="player.dominions.length"
              :maximum="player.max_dominions.value" />
            <resource-detail
              slot="popover"
              :title="$t('navbar.bottombar.dominions_limit')"
              :precision="0"
              :value="player.max_dominions.value"
              :details="player.max_dominions.details" />
          </v-popover>

          <v-popover trigger="hover">
            <navbar-dynamic-value
              icon="resource/credit"
              :initial="player.credit" />
            <resource-detail
              slot="popover"
              :title="$t('data.bonus_pipeline_in.player_credit.name')"
              :description="$t(`resource-description.credit`)"
              :value="player.credit.change"
              :details="player.credit.details" />
          </v-popover>

          <v-popover trigger="hover">
            <navbar-dynamic-value
              icon="resource/technology"
              :initial="player.technology" />
            <resource-detail
              slot="popover"
              :title="$t('data.bonus_pipeline_in.player_technology.name')"
              :description="$t(`resource-description.technology`)"
              :value="player.technology.change"
              :details="player.technology.details" />
          </v-popover>

          <v-popover trigger="hover">
            <navbar-dynamic-value
              icon="resource/ideology"
              :initial="player.ideology" />
            <resource-detail
              slot="popover"
              :title="$t('data.bonus_pipeline_in.player_ideology.name')"
              :description="$t(`resource-description.ideology`)"
              :value="player.ideology.change"
              :details="player.ideology.details" />
          </v-popover>
        </div>
      </div>

      <div class="navbar-center">
        <div
          v-if="tutorialStep === 7"
          class="tutorial-pointer is-patent is-bottom">
        </div>
        <div
          v-if="tutorialStep === 11"
          class="tutorial-pointer is-doctrine is-bottom">
        </div>

        <div
          @click="switchSystem('prev')"
          v-if="ownSystems.length > 1"
          v-tooltip="$t('navbar.bottombar.previous_system')"
          class="mini-panel-switcher left">
          <svgicon name="caret-left" />
        </div>

        <div
          @click="toggleMiniPanel('patent')"
          :class="{
            'active': activeMiniPanel.name === 'patent',
            'visible': player.technology.change > 0,
          }"
          v-tooltip="$t('navbar.bottombar.patents')"
          class="mini-panel-button left">
          <svgicon name="patent/frame_patent" />
        </div>

        <navbar-player />

        <div
          @click="toggleMiniPanel('doctrine')"
          :class="{
            'active': activeMiniPanel.name === 'doctrine',
            'visible': player.ideology.change > 0,
          }"
          v-tooltip="$t('navbar.bottombar.lexes')"
          class="mini-panel-button right">
          <svgicon name="doctrine/frame_doctrine" />
        </div>

        <div
          @click="switchSystem('next')"
          v-if="ownSystems.length > 1"
          v-tooltip="$t('navbar.bottombar.next_system')"
          class="mini-panel-switcher right">
          <svgicon name="caret-right" />
        </div>
      </div>

      <div class="navbar-right">
        <div class="navbar-group-buttons right">
          <div
            class="navbar-deploy-button"
            @click="toggleMiniPanel('character-deck')">
            <strong>{{ $t('navbar.bottombar.agents') }}</strong>
            {{ $t('navbar.bottombar.n_available', {n: playerDeck.length}) }}
          </div>

          <v-popover
            v-for="type in characterData"
            :key="type.key"
            trigger="hover">
            <navbar-maxed-value
              :label="$tc(`data.character.${type.key}.name`, type.activeNumber)"
              :value="type.activeNumber"
              :maximum="type.maxNumber" />
            <resource-detail
              slot="popover"
              :title="$t('navbar.bottombar.character_type_limit', {characterType: $tc(`data.character.${type.key}.name`, 2)})"
              :precision="0"
              :value="player[charactersBonusName[type.key]].value"
              :details="player[charactersBonusName[type.key]].details" />
          </v-popover>
        </div>

        <!-- TODO: should be a component -->
        <div class="navbar-main-button">
          <div class="navbar-main-button-toolbox">
            <div
              class="button"
              v-if="onBoardCharacters.length > 0"
              @click="toggleActiveCharacterList">
              <template v-if="isActiveCharacterListOpen">
                <svgicon class="icon" name="caret-down" />
              </template>
              <template v-else>
                <svgicon class="icon" name="caret-up" />
              </template>
            </div>
          </div>

          <div
            @click="togglePanel('operations')"
            class="navbar-main-button-icon">
            <svgicon class="icon" name="operation" />
          </div>
        </div>
      </div>
    </div>

    <div
      class="navbar-panel"
      v-show="isActiveCharacterListOpen && onBoardCharacters.length > 0 && !selection">
      <div
        v-for="type in characterData"
        :key="type.key">
        <navbar-panel-block
          v-show="type.onBoardNumber > 0"
          :title="`
            ${type.onBoardNumber}
            ${$tc(`data.character.${type.key}.name`, type.onBoardNumber)}
          `">
          <closed-character-card
            v-for="character in type.onBoard"
            :key="character.id"
            :character="character"
            :theme="theme"
            @select="selectCharacter" />
        </navbar-panel-block>
      </div>
    </div>

    <div
      class="navbar-panel"
      v-show="!selectedSystem && isSystemListOpen"
      style="left: 0; right: auto;">
      <navbar-panel-block
        v-if="ownDominions.length"
        :title="`
          ${ ownDominions.length }
          ${ $tc('system.dominion', ownDominions.length) }
        `">
        <closed-system-card
          v-for="system in ownDominions"
          :key="system.id"
          :system="system"
          :theme="theme"
          @select="selectSystem" />
      </navbar-panel-block>

      <navbar-panel-block
        v-if="ownSystems.length"
        :title="`
          ${ ownSystems.length }
          ${ $tc('system.system', ownSystems.length) }
        `">
        <closed-system-card
          v-for="system in ownSystems"
          :key="system.id"
          :system="system"
          :theme="theme"
          @select="selectSystem" />
      </navbar-panel-block>
    </div>

    <div
      class="mini-panels-container"
      ref="miniPanelsContainer"
      @click.self="closeMiniPanel">
      <character-deck-mini-panel
        v-show="activeMiniPanel.name === 'character-deck'"
        :height="activeMiniPanel.height"
        @close="closeMiniPanel" />
      <patent-mini-panel
        v-show="activeMiniPanel.name === 'patent'"
        :height="activeMiniPanel.height"
        @close="closeMiniPanel" />
      <doctrine-mini-panel
        v-show="activeMiniPanel.name === 'doctrine'"
        :active-panel="activeMiniPanel.name"
        :height="activeMiniPanel.height"
        @close="closeMiniPanel" />
    </div>
  </div>
</template>

<script>
import { TimelineLite, Expo } from 'gsap';

import NavbarDynamicValue from '@/game/components/navbar/NavbarDynamicValue.vue';
import NavbarMaxedValue from '@/game/components/navbar/NavbarMaxedValue.vue';
import NavbarPanelBlock from '@/game/components/navbar/NavbarPanelBlock.vue';

import NavbarPlayer from '@/game/components/navbar/NavbarPlayer.vue';
import ResourceDetail from '@/game/components/generic/ResourceDetail.vue';

import ClosedCharacterCard from '@/game/components/card/ClosedCharacterCard.vue';
import ClosedSystemCard from '@/game/components/card/ClosedSystemCard.vue';

import CharacterDeckMiniPanel from '@/game/components/mini-panel/CharacterDeckMiniPanel.vue';
import PatentMiniPanel from '@/game/components/mini-panel/PatentMiniPanel.vue';
import DoctrineMiniPanel from '@/game/components/mini-panel/DoctrineMiniPanel.vue';

export default {
  name: 'bottombar',
  data() {
    return {
      activeMiniPanel: { name: '' },
      isMiniPanelOpen: false,
      miniPanels: [
        { name: 'character-deck', height: 480 },
        { name: 'patent', height: 480 },
        { name: 'doctrine', height: 480 },
      ],
      isActiveCharacterListOpen: true,
      isSystemListOpen: true,
      characterDeck: false,
      charactersBonusName: {
        admiral: 'max_admirals',
        spy: 'max_spies',
        speaker: 'max_speakers',
      },
    };
  },
  computed: {
    tutorialStep() { return this.$store.state.game.tutorialStep; },
    theme() { return this.$store.getters['game/theme']; },
    view() { return this.$store.state.game.view; },
    player() { return this.$store.state.game.player; },
    ownSystems() { return this.player.stellar_systems; },
    ownDominions() { return this.player.dominions; },
    selection() { return this.$store.state.game.selectedCharacter; },
    selectedSystem() { return this.$store.state.game.selectedSystem; },
    onBoardCharacters() { return this.player.characters.filter((p) => p.status === 'on_board'); },
    playerDeck() { return this.$store.state.game.player.character_deck; },
    characterData() {
      return this.$store.state.game.data.character.map((data) => {
        const onBoard = this.onBoardCharacters
          .filter((c) => c.type === data.key)
          .map((c) => (({ ...c, receivedAt: this.player.receivedAt })));

        const activeNumber = this.player.characters.filter((c) => c.type === data.key).length;
        const onBoardNumber = onBoard.length;
        const maxNumber = this.player[this.charactersBonusName[data.key]].value;

        return { ...data, ...{ onBoard, activeNumber, onBoardNumber, maxNumber } };
      });
    },
  },
  methods: {
    toggleActiveCharacterList() {
      this.isActiveCharacterListOpen = !this.isActiveCharacterListOpen;
    },
    toggleSystemList() {
      this.isSystemListOpen = !this.isSystemListOpen;
    },
    toggleMiniPanel(name) {
      if (this.isMiniPanelOpen && this.activeMiniPanel.name === name) {
        this.closeMiniPanel();
      } else {
        this.openMiniPanel(name);
      }
    },
    openMiniPanel(name) {
      this.$root.$emit('closePanel');
      this.$root.$emit('closeTopMiniPanel');

      this.animateCloseMiniPanelContainer().then(() => {
        this.animateOpenMiniPanelContainer(name);
      });
    },
    closeMiniPanel() {
      this.$store.commit('game/clearAssignment');

      this.animateCloseMiniPanelContainer().then(() => {
        this.isMiniPanelOpen = false;
        this.activeMiniPanel = { name: '' };
      });
    },
    switchSystem(mode) {
      let nextSystemId;

      if (mode === 'first') {
        nextSystemId = this.ownSystems[0].id;
      } else {
        const i = this.selectedSystem
          ? this.ownSystems.findIndex((s) => s.id === this.selectedSystem.id)
          : -1;

        nextSystemId = mode === 'prev'
          ? this.ownSystems[(i + this.ownSystems.length - 1) % this.ownSystems.length].id
          : this.ownSystems[(i + 1) % this.ownSystems.length].id;
      }

      this.$store.dispatch('game/openSystem', { vm: this, id: nextSystemId });
    },
    animateOpenMiniPanelContainer(name) {
      return new Promise((resolve) => {
        this.$ambiance.sound('mini-panel-open');

        this.$refs.miniPanelsContainer.style.display = 'flex';
        this.activeMiniPanel = this.miniPanels.find((p) => p.name === name);
        this.isMiniPanelOpen = true;

        new TimelineLite({
          onComplete() { resolve(); },
        }).set(this.$refs.miniPanelsContainer, { bottom: `-${this.activeMiniPanel.height}px` })
          .to(this.$refs.miniPanelsContainer, { bottom: '52px', ease: Expo.easeOut, duration: 0.8 }, 0);
      });
    },
    animateCloseMiniPanelContainer() {
      if (!this.isMiniPanelOpen) {
        return Promise.resolve();
      }

      return new Promise((resolve) => {
        this.$ambiance.sound('mini-panel-close');

        const self = this;

        if (!this.isMiniPanelOpen) {
          resolve();
        } else {
          const position = `-${this.activeMiniPanel.height}px`;

          new TimelineLite({
            onComplete() {
              self.$refs.miniPanelsContainer.style.display = 'none';
              resolve();
            },
          }).to(this.$refs.miniPanelsContainer, { bottom: position, ease: Expo.linear, duration: 0.4 }, 0);
        }
      });
    },
    selectSystem(system) {
      this.$store.dispatch('game/openSystem', { vm: this, id: system.id });
    },
    selectCharacter(character) {
      this.$store.dispatch('game/selectCharacter', { vm: this, id: character.id });
    },
    togglePanel(name) {
      this.$root.$emit('togglePanel', name);
    },
  },
  mounted() {
    this.$root.$on('openBottomMiniPanel', (name) => { this.openMiniPanel(name); });
    this.$root.$on('closeBottomMiniPanel', () => { this.closeMiniPanel(); });
    this.$root.$on('switchSystem', (mode) => { this.switchSystem(mode); });
  },
  components: {
    NavbarDynamicValue,
    NavbarMaxedValue,
    NavbarPanelBlock,
    NavbarPlayer,
    ResourceDetail,
    ClosedCharacterCard,
    ClosedSystemCard,
    CharacterDeckMiniPanel,
    PatentMiniPanel,
    DoctrineMiniPanel,
  },
};
</script>
