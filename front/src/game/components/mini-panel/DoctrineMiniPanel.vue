<template>
  <div
    class="mp-container"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.doctrine.title') }}
        <span class="small">
          {{ purchasedDoctrines.length }}/{{ doctrines.length }}
        </span>
      </div>
      <div
        v-if="purchasedDoctrines.length > 0"
        class="mph-nav">
        <div
          v-for="tab in tabs"
          :key="tab"
          :class="{ 'active': activeTab === tab }"
          class="mph-nav-item"
          @click="switchTab(tab)">
          {{ $t(`data.doctrine_class.${tab}.name`) }}
        </div>
      </div>
      <div class="mph-close-button" @click="close"></div>
    </div>

    <div
      v-if="purchasedDoctrines.length > 0"
      class="mini-panel-policies">
      <div>
        <div class="mpp-header">
          <div class="mpp-header-title">
            {{ $t(`minipanel.doctrine.policies_title`) }}
          </div>
          <div
            v-if="hasUpdate || !hasCooldownFinished"
            class="mpp-header-apply"
            :class="{ 'active': canUpdatePolicies && hasUpdate }"
            @click="updatePolicies">
            <div
              v-if="tutorialStep === 13"
              class="tutorial-pointer is-right">
            </div>
            <circle-progress-value
              :current="player.policies_cooldown.value"
              :total="player.policies_cooldown.initial"
              :increase="-1"
              :width="4"
              :size="50"
              @finished="hasCooldownFinished = true" />
            <span
              v-if="!canUpdatePolicies"
              class="timer">
              <counter
                :current="player.policies_cooldown.value"
                :receivedAt="player.receivedAt" />
            </span>
            <svgicon
              v-if="!canUpdatePolicies"
              name="unlock" />
            <svgicon
              v-else-if="hasUpdate"
              v-tooltip="`${$t(`minipanel.doctrine.apply_policies`)}`"
              name="doctrine_stamp" />
          </div>
        </div>
        <div class="mpp-lex">
          <div class="mpp-lex-number">
            {{ newPolicies.length }}<span class="small">/{{ player.max_policies }}</span>
          </div>
          <div class="mpp-lex-title">
            {{ $t(`minipanel.doctrine.active`) }}
          </div>
          <button
            class="mpp-lex-button"
            @click="buySlot">
            <div>{{ $t(`minipanel.doctrine.buy_slot`) }}</div>
            <div class="icon-value">
              {{ nextPolicyCost | integer }}
              <svgicon name="resource/ideology" />
            </div>
          </button>
        </div>
      </div>

      <div class="mpp-actions">
        <button
          class="reversed "
          :class="{ 'transparent disabled': !hasUpdate }"
          @click="resetPolicies">
          <div :class="{ 'dashed': !hasUpdate }">
            {{ $t(`minipanel.doctrine.reset_policies`) }}
          </div>
        </button>
        <button
          class="reversed"
          :class="{ 'transparent disabled': newPolicies.length === 0 }"
          @click="clearPolicies">
          <div :class="{ 'dashed': newPolicies.length === 0 }">
            {{ $t(`minipanel.doctrine.clear_policies`) }}
          </div>
        </button>
      </div>
    </div>

    <v-scrollbar
      class="mp-scrollbar"
      :settings="{
        wheelPropagation: false,
        suppressScrollY: true,
        useBothWheelAxes: true,
      }">
      <div
        class="mp-content"
        :style="{ height: `${height}px` }">
        <template v-if="purchasedDoctrines.length > 0">
          <div class="mpc-header">
            <div class="info">
              {{ $t('minipanel.doctrine.price_factor') }}
              <strong>+{{ costFactor * 100 | integer }}%</strong>
            </div>
          </div>
          <div class="mpc-tree">
            <div
              class="tree-column"
              v-for="(col, i) in doctrinesAsGrid"
              :key="`${counter}-col-${i}`">
              <div
                class="tree-row"
                v-for="(row, j) in col"
                :key="`row-${j}`">
                <template v-if="row">
                  <div
                    class="tree-node"
                    :class="row.status">
                    <div class="tree-node-effect"></div>
                    <div class="tree-node-links">
                      <div
                        class="link middle"
                        v-if="[1, 3].includes(row.children.length)">
                      </div>
                      <template v-if="[2, 3].includes(row.children.length)">
                        <div class="link top"></div>
                        <div class="link bottom"></div>
                      </template>
                    </div>
                    <div
                      @click="clickDoctrine(row)"
                      class="tree-node-icon">
                      <svgicon
                        class="main-icon"
                        :name="`doctrine/${row.key}`" />
                      <svgicon
                        v-if="row.status === 'locked'"
                        class="toast-icon"
                        name="unlock" />
                      <svgicon
                        v-if="row.status === 'chosen'"
                        class="toast-icon colored"
                        name="bookmark" />
                    </div>
                    <div
                      class="tree-node-label"
                      :class="{ 'shifted': [1, 3].includes(row.children.length) }">
                      {{ $t(`data.doctrine.${row.key}.name`) }}
                    </div>
                  </div>
                  <div class="tree-node-card">
                    <doctrine-card
                      :doctrine="row"
                      :emptyPolicies="hasEmptyPolicies"
                      :costFactor="costFactor"
                      :theme="theme"
                      @choose="choosePolicy"
                      @purchase="purchaseDoctrine" />
                  </div>
                </template>
              </div>
            </div>
          </div>
        </template>
        <div
          class="mpc-splashscreen"
          v-else>
          <div class="tree-node available">
            <div
              @click="clickDoctrine(root)"
              class="tree-node-icon">
              <svgicon
                class="main-icon"
                :name="`doctrine/${root.key}`" />
            </div>
            <div class="tree-node-label">
              {{ $t(`data.doctrine.${root.key}.name`) }}
            </div>
            <div class="tree-node-card">
              <doctrine-card
                :doctrine="root"
                :emptyPolicies="hasEmptyPolicies"
                :costFactor="costFactor"
                :theme="theme"
                @choose="choosePolicy"
                @purchase="purchaseDoctrine" />
            </div>
          </div>
        </div>
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
import Tree from '@/utils/tree';

import MiniPanelMixin from '@/game/mixins/MiniPanelMixin';
import CircleProgressValue from '@/game/components/generic/CircleProgressValue.vue';
import DoctrineCard from '@/game/components/card/DoctrineCard.vue';

import Counter from '@/game/components/generic/Counter.vue';

export default {
  name: 'doctrine-mini-panel',
  mixins: [MiniPanelMixin],
  data() {
    return {
      newPolicies: [],
      hasCooldownFinished: false,
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    constant() { return this.$store.state.game.data.constant[0]; },
    tutorialStep() { return this.$store.state.game.tutorialStep; },
    player() { return this.$store.state.game.player; },
    costFactor() { return this.purchasedDoctrines.length * this.constant.doctrine_level_price_increase; },
    nextPolicyCost() {
      const cost = (2 ** (this.player.max_policies - 1)) * this.constant.initial_policy_slot_cost;
      return Math.min(cost, this.constant.policy_slot_maximum_cost);
    },
    purchasedDoctrines() { return this.$store.state.game.player.doctrines; },
    hasEmptyPolicies() { return (this.newPolicies.length - this.player.max_policies) < 0; },
    policies() { return this.player.policies; },
    canUpdatePolicies() { return this.player.policies_cooldown.value === 0 || this.hasCooldownFinished; },
    hasUpdate() { return [...this.newPolicies].sort().join(',') !== [...this.policies].sort().join(','); },
    doctrines() {
      return this.$store.state.game.data.doctrine
        .map((doctrine) => {
          let status = '';
          if (!this.purchasedDoctrines.find((p) => p === doctrine.key)) {
            status = !this.purchasedDoctrines.find((p) => p === doctrine.ancestor)
              ? 'locked' : 'available';

            if (doctrine.class === 'root') {
              status = 'available';
            }
          } else {
            status = !this.newPolicies.includes(doctrine.key)
              ? 'purchased' : 'chosen';
          }

          return { ...{ status }, ...doctrine };
        });
    },
    tabs() {
      return Array.from(new Set(this.$store.state.game.data.doctrine.map((d) => d.class)))
        .filter((tab) => tab !== 'root');
    },
    doctrinesAsTree() {
      return Tree.fromList(this.doctrines.filter((doctrine) => ['root', this.activeTab].includes(doctrine.class)));
    },
    doctrinesAsGrid() { return Tree.trimGrid(Tree.toGrid(this.root)); },
    root() { return this.doctrinesAsTree[0]; },
  },
  methods: {
    clickDoctrine(doctrine) {
      if (doctrine.status === 'available') {
        this.purchaseDoctrine(doctrine.key);
      }

      if (doctrine.status === 'purchased') {
        this.choosePolicy(doctrine.key);
      }

      if (doctrine.status === 'chosen') {
        this.discardPolicy(doctrine.key);
      }
    },
    purchaseDoctrine(doctrineKey) {
      this.$socket.player
        .push('purchase_doctrine', { doctrine_key: doctrineKey })
        .receive('ok', () => { this.$ambiance.sound('buy-doctrine'); })
        .receive('error', (data) => { this.$toastError(data.reason); });
    },
    buySlot() {
      this.$socket.player
        .push('purchase_policy_slot', {})
        .receive('ok', () => { this.$ambiance.sound('buy-doctrine-slot'); })
        .receive('error', (data) => { this.$toastError(data.reason); });
    },
    updatePolicies() {
      if (this.hasUpdate && this.canUpdatePolicies) {
        this.$socket.player
          .push('update_policies', { doctrines_key: this.newPolicies })
          .receive('ok', () => {
            this.resetPolicies();
            this.$ambiance.sound('apply-doctrine');
            this.hasCooldownFinished = false;
          })
          .receive('error', (data) => { this.$toastError(data.reason); });
      }
    },
    resetPolicies() {
      this.newPolicies = [...this.policies];
    },
    clearPolicies() {
      if (this.canUpdatePolicies) {
        this.newPolicies = [];
      } else {
        this.$toasted.error(this.$t('minipanel.doctrine.policies_locked'));
      }
    },
    choosePolicy(doctrineKey) {
      if (this.canUpdatePolicies && this.newPolicies.length < this.player.max_policies) {
        this.newPolicies.push(doctrineKey);
      } else {
        this.$toasted.error(this.$t('minipanel.doctrine.policies_locked'));
      }
    },
    discardPolicy(doctrineKey) {
      if (this.canUpdatePolicies) {
        this.newPolicies = this.newPolicies.filter((d) => d !== doctrineKey);
      } else {
        this.$toasted.error(this.$t('minipanel.doctrine.policies_locked'));
      }
    },
  },
  props: {
    activePanel: String,
  },
  watch: {
    activePanel(active, previouslyActive) {
      if (active === 'doctrine' && active !== previouslyActive) {
        this.resetPolicies();
      }
    },
  },
  components: {
    DoctrineCard,
    CircleProgressValue,
    Counter,
  },
};
</script>
