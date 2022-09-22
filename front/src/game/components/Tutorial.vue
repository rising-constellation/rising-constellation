<template>
  <div
    v-if="!isTutorialFinished"
    class="notification-center is-tutorial">
    <div class="box-notification-container">
      <div class="box-notification-header">
        <svgicon name="layers" />
        <div
          class="name"
          v-html="$t(`tutorial.step${stepCounter}.title`)">
        </div>
        <div class="outcome">
          <div class="generic-progress-container is-animated">
            <div
              class="generic-progress-bar"
              v-bind:style="`width: ${progression}%;`">
            </div>
          </div>
        </div>
      </div>

      <div class="box-notification-tabs">
        <v-scrollbar class="box-notification-tab-item">
          <div
            class="box-notification-bloc"
            v-html="$t(`tutorial.step${stepCounter}.content`)">
          </div>
          <div
            v-if="Object.keys(step.boxes).includes('building')"
            class="box-notification-bloc">
            <building-card
              :child="true"
              :buildingKey="step.boxes['building']"
              :level="1"
              :theme="theme" />
          </div>
          <div
            v-if="Object.keys(step.boxes).includes('patent')"
            class="box-notification-bloc">
            <patent-card
              :patent="$store.state.game.data.patent.find((p) => p.key === step.boxes['patent'])"
              :costFactor="1"
              :theme="theme" />
          </div>
          <div
            v-if="Object.keys(step.boxes).includes('doctrine')"
            class="box-notification-bloc">
            <doctrine-card
              :doctrine="$store.state.game.data.doctrine.find((p) => p.key === step.boxes['doctrine'])"
              :costFactor="1"
              :theme="theme" />
          </div>
          <div
            v-if="Object.keys(step.boxes).includes('ship')"
            class="box-notification-bloc">
            <ship-card
              :child="true"
              :shipKey="step.boxes['ship']"
              :theme="theme" />
          </div>
        </v-scrollbar>
      </div>

      <div class="box-notification-footer">
        <div
          v-if="isStepValid"
          @click="nextStep()"
          class="button">
          <template v-if="isLastStep">
            {{ $t(`tutorial.end_tutorial`) }}
          </template>
          <template v-else>
            {{ $t(`tutorial.next_step`) }}
          </template>
        </div>
        <div
          v-else
          v-tooltip="$t(`tutorial.next_step_tooltip`)"
          class="button disabled">
          {{ $t(`tutorial.next_step`) }}
        </div>
        <div
          v-if="stepCounter > 0"
          v-tooltip="$t(`tutorial.prev_step_tooltip`)"
          @click="prevStep()"
          class="button">
          <svgicon name="caret-left" />
        </div>
        <div
          v-else
          v-tooltip="$t(`tutorial.close_tooltip`)"
          @click="closeTutorial()"
          class="button">
          <svgicon name="close" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import BuildingCard from '@/game/components/card/BuildingCard.vue';
import PatentCard from '@/game/components/card/PatentCard.vue';
import DoctrineCard from '@/game/components/card/DoctrineCard.vue';
import ShipCard from '@/game/components/card/ShipCard.vue';

const steps = [
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: 'centerSystem', validate: () => true },
  {
    boxes: { building: 'hab_open_poor' },
    action: 'openSystem',
    validate: (player) => player.stellar_systems[0].habitation > 8,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { building: 'university_open' },
    action: null,
    validate: (player) => player.technology.change > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { patent: 'citadel' },
    action: null,
    validate: (player) => player.patents.length > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { building: 'ideo_open' },
    action: 'openSystem',
    validate: (player) => player.ideology.change > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { doctrine: 'agent' },
    action: null,
    validate: (player) => player.doctrines.length > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: {},
    action: null,
    validate: (player) => player.policies.length > 0,
  },
  {
    boxes: {},
    action: 'openSystem',
    validate: (player) => player.characters.filter((c) => c.status === 'on_board').length > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { building: 'hab_open_poor' },
    action: null,
    validate: (player) => player.stellar_systems[0].habitation > 30,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { patent: 'infra_open_1' },
    action: null,
    validate: (player) => player.stellar_systems[0].happiness > 0,
  },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { building: 'factory_orbital' },
    action: null,
    validate: (player) => player.stellar_systems[0].credit > 100,
  },
  {
    boxes: { building: 'mine_dome' },
    action: null,
    validate: (player) => player.stellar_systems[0].production > 200,
  },
  {
    boxes: {},
    action: null,
    validate: (player) => player.credit.change > 200 && player.ideology.change > 50 && player.technology.change > 50,
  },
  // Goal I : raid an autonomous system
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { patent: 'shipyard_1' },
    action: null,
    validate: (player) => player.patents.includes('shipyard_1'),
  },
  {
    boxes: { building: 'shipyard_1_orbital' },
    action: null,
    validate: () => true,
  },
  {
    boxes: { patent: 'fighter_3' },
    action: null,
    validate: (player) => player.patents.includes('fighter_3'),
  },
  {
    boxes: { ship: 'fighter_3' },
    action: null,
    validate: () => true,
  },
  { boxes: {}, action: 'centerClosestDominion', validate: () => true },
  { boxes: {}, action: 'openClosestDominion', validate: () => true },
  // Goal II : colonize an empty system
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { patent: 'transport_1' },
    action: null,
    validate: (player) => player.patents.includes('transport_1'),
  },
  {
    boxes: { ship: 'transport_1' },
    action: null,
    validate: () => true,
  },
  {
    boxes: { doctrine: 'system_1' },
    action: null,
    validate: (player) => player.max_systems.value >= 2,
  },
  { boxes: {}, action: 'centerClosestSystem', validate: () => true },
  {
    boxes: {},
    action: 'openClosestSystem',
    validate: (player) => player.stellar_systems.length >= 2,
  },
  { boxes: {}, action: null, validate: () => true },
  // Goal III : gain visibility
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: 'centerEnnemyDominion', validate: () => true },
  { boxes: {}, action: 'openEnnemyDominion', validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  // Goal IV : take control of an autonomous system
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { doctrine: 'speaker_2' },
    action: null,
    validate: () => true,
  },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: 'centerEnnemyDominion', validate: () => true },
  { boxes: {}, action: 'openEnnemyDominion', validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  { boxes: {}, action: null, validate: () => true },
  {
    boxes: { doctrine: 'dominion_1' },
    action: null,
    validate: () => true,
  },
  { boxes: {}, action: null, validate: () => true },
  // End
  { boxes: {}, action: null, validate: () => true },
];

export default {
  name: 'tutorial',
  data() {
    return {
      isTutorialFinished: false,
      ennemyDominionId: null,
    };
  },
  computed: {
    stepCounter() { return this.$store.state.game.tutorialStep; },
    step() { return steps[this.stepCounter]; },
    isLastStep() { return this.stepCounter + 1 >= steps.length; },
    isStepValid() { return this.step.validate(this.player); },
    theme() { return this.$store.getters['game/theme']; },
    mainSystem() { return this.$store.state.game.player.stellar_systems[0]; },
    player() { return this.$store.state.game.player; },
    progression() {
      const { progression } = [23, 8, 8, 9, 10, 1].reduce((acc, milestone) => {
        if (acc.progression) return acc;

        if (this.stepCounter < acc.cursor + milestone) {
          acc.progression = ((this.stepCounter - acc.cursor + 1) / milestone) * 100;
          return acc;
        }

        acc.cursor += milestone;
        return acc;
      }, { cursor: 0, progression: null });

      return progression;
    },
  },
  methods: {
    async nextStep() {
      if (this.isStepValid) {
        if (!this.isLastStep) {
          this.$store.commit('game/tutorialNextStep');

          if (this.step.action) {
            await this.doAction(this.step.action);
          }
        } else {
          this.isTutorialFinished = true;
        }
      }
    },
    prevStep() {
      if (this.stepCounter > 0) {
        this.$store.commit('game/tutorialPrevStep');
      }
    },
    closeTutorial() {
      this.isTutorialFinished = true;
    },
    async doAction(name) {
      switch (name) {
        case 'centerSystem':
          this.$root.$emit('map:centerToSystem', this.mainSystem.id);
          break;
        case 'openSystem':
          this.$store.dispatch('game/openSystem', { vm: this, id: this.mainSystem.id });
          break;
        case 'centerClosestDominion':
          if (this.$store.state.game.selectedSystem) {
            this.$store.dispatch('game/closeSystem', this);
            await this.wait(600);
          }
          this.$root.$emit('map:centerToSystem', this.getClosestSystemId('inhabited_neutral'));
          break;
        case 'openClosestDominion':
          this.$store.dispatch('game/openSystem', { vm: this, id: this.getClosestSystemId('inhabited_neutral') });
          break;
        case 'centerClosestSystem':
          if (this.$store.state.game.selectedSystem) {
            this.$store.dispatch('game/closeSystem', this);
            await this.wait(600);
          }
          this.$root.$emit('map:centerToSystem', this.getClosestSystemId('uninhabited'));
          break;
        case 'openClosestSystem':
          this.$store.dispatch('game/openSystem', { vm: this, id: this.getClosestSystemId('uninhabited') });
          break;
        case 'centerEnnemyDominion':
          if (this.$store.state.game.selectedSystem) {
            this.$store.dispatch('game/closeSystem', this);
            await this.wait(600);
          }
          this.$root.$emit('map:centerToSystem', this.ennemyDominionId);
          break;
        case 'openEnnemyDominion':
          this.$store.dispatch('game/openSystem', { vm: this, id: this.ennemyDominionId });
          break;
        default: break;
      }
    },
    getClosestSystemId(type) {
      const origin = this.mainSystem.position;
      const systems = this.$store.state.game.galaxy.stellar_systems
        .filter((s) => s.status === type)
        .sort((a, b) => this.distance(origin, a.position) - this.distance(origin, b.position));

      return systems[0].id;
    },
    initEnnemyDominionId() {
      const dominions = this.$store.state.game.galaxy.stellar_systems
        .filter((s) => s.sector_id === 2 && s.status === 'inhabited_neutral');

      this.ennemyDominionId = dominions[Math.floor(Math.random() * dominions.length)].id;
    },
    distance({ x: x1, y: y1 }, { x: x2, y: y2 }) {
      return Math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2);
    },
    wait(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },
  },
  mounted() {
    this.initEnnemyDominionId();
  },
  components: {
    BuildingCard,
    PatentCard,
    DoctrineCard,
    ShipCard,
  },
};
</script>
