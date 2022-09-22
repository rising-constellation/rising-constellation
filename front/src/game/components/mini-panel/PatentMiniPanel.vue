<template>
  <div
    class="mp-container"
    :class="`f-${theme}`">
    <div class="mp-header">
      <div class="mph-title">
        {{ $t('minipanel.patent.title') }}
        <span class="small">
          {{ purchasedPatentsNumber }}/{{ dataPatents.length }}
        </span>
      </div>
      <div
        v-if="purchasedPatentsNumber > 0"
        class="mph-nav">
        <div
          v-for="tab in tabs"
          :key="tab"
          :class="{ 'active': activeTab === tab }"
          class="mph-nav-item"
          @click="switchTab(tab)">
          {{ $t(`data.patent_class.${tab}.name`) }}
        </div>
      </div>
      <div class="mph-close-button" @click="close"></div>
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
        <template v-if="purchasedPatentsNumber > 0">
          <div class="mpc-header">
            <div class="info">
              {{ $t(`minipanel.patent.price_factor`) }}
              <strong>+{{ costFactor * 100 | integer }}%</strong>
            </div>
          </div>

          <div class="mpc-tree">
            <div
              class="tree-column"
              v-for="(col, i) in patentsAsGrid"
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
                      class="tree-node-icon"
                      @click="tryPurchasePatent(row)">
                      <svgicon
                        class="main-icon"
                        :name="`patent/${row.key}`" />
                      <svgicon
                        v-if="row.status === 'locked'"
                        class="toast-icon"
                        name="unlock" />
                    </div>
                    <div
                      class="tree-node-label"
                      :class="{ 'shifted': [1, 3].includes(row.children.length) }">
                      {{ $t(`data.patent.${row.key}.name`) }}
                    </div>
                  </div>
                  <div class="tree-node-card">
                    <patent-card
                      :patent="row"
                      :costFactor="costFactor"
                      :theme="theme"
                      @purchase="purchasePatent" />
                  </div>
                </template>
              </div>
            </div>
          </div>
        </template>

        <div
          class="mpc-splashscreen"
          v-else>
          <div
            @click="tryPurchasePatent(root)"
            class="tree-node available">
            <div class="tree-node-icon">
              <svgicon
                class="main-icon"
                :name="`patent/${root.key}`" />
            </div>
            <div class="tree-node-label">
              {{ $t(`data.patent.${root.key}.name`) }}
            </div>
            <div class="tree-node-card">
              <patent-card
                :patent="root"
                :costFactor="costFactor"
                :theme="theme"
                @purchase="purchasePatent" />
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

import PatentCard from '@/game/components/card/PatentCard.vue';

export default {
  name: 'patent-mini-panel',
  mixins: [MiniPanelMixin],
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    constant() { return this.$store.state.game.data.constant[0]; },
    dataPatents() { return this.$store.state.game.data.patent; },
    purchasedPatents() { return this.$store.state.game.player.patents; },
    purchasedPatentsNumber() { return this.purchasedPatents.length; },
    costFactor() {
      return this.purchasedPatentsNumber * this.constant.patent_level_price_increase;
    },
    tabs() {
      return Array.from(new Set(this.dataPatents.map((d) => d.class)))
        .filter((tab) => tab !== 'root');
    },
    patents() {
      return this.dataPatents
        .filter((patent) => ['root', this.activeTab].includes(patent.class))
        .map((patent) => {
          let status = 'purchased';
          if (this.purchasedPatents.find((p) => p === patent.key) === undefined) {
            status = this.purchasedPatents.find((p) => p === patent.ancestor) === undefined
              ? 'locked' : 'available';

            if (patent.class === 'root') {
              status = 'available';
            }
          }

          return { ...{ status }, ...patent };
        });
    },
    root() {
      return this.patentsAsTree[0];
    },
    patentsAsTree() {
      return Tree.fromList(this.patents);
    },
    patentsAsGrid() {
      return Tree.trimGrid(Tree.toGrid(this.root));
    },
  },
  methods: {
    patentsByClass(name) {
      return this.patents.filter((patent) => patent.class === name);
    },
    tryPurchasePatent(patent) {
      if (patent.status === 'available') {
        this.purchasePatent(patent.key);
      }
    },
    purchasePatent(patentKey) {
      this.$socket.player
        .push('purchase_patent', { patent_key: patentKey })
        .receive('ok', () => { this.$ambiance.sound('buy-patent'); })
        .receive('error', (data) => { this.$toastError(data.reason); });
    },
  },
  components: {
    PatentCard,
  },
};
</script>
