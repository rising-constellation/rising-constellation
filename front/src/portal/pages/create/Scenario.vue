<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <section
          v-if="mode === 'new'"
          class="panel-aside-info">
          <h2>Étape {{ step.number }}</h2>
          <p>{{ step.label }}</p>
        </section>

        <div class="panel-aside-bloc">
          <div class="default-input">
            <label for="name">Nom</label>
            <input
              id="name"
              type="text"
              autocomplete="off"
              placeholder="___"
              v-model="scenario.game_metadata.name" />
          </div>

          <div class="default-input">
            <label for="description">Description</label>
            <textarea
              id="description"
              v-model="scenario.game_metadata.description">
            </textarea>
          </div>

          <div class="checkbox-input">
            <input
              type="checkbox"
              id="official"
              v-model="scenario.is_official">
            <label for="official">Scénario officiel</label>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content is-square">
        <router-link
          class="close-button"
          to="/create/scenarios">
          Retour
        </router-link>

        <div
          class="content"
          ref="container">
          <svg
            :width="containerSize"
            :height="containerSize"
            version="1.1"
            xmlns="http://www.w3.org/2000/svg"
            class="map-container">
            <line
              v-for="i in Math.round(scenario.game_metadata.size / 12)"
              :key="`v-${i}`"
              x1="0" :y1="resize(i * 12)"
              x2="100%" :y2="resize(i * 12)"
              class="map-grid" />
            <line
              v-for="i in Math.round(scenario.game_metadata.size / 12)"
              :key="`h-${i}`"
              y1="0" :x1="resize(i * 12)"
              y2="100%" :x2="resize(i * 12)"
              class="map-grid" />

            <circle
              v-for="s in scenario.game_data.systems"
              :key="`system-${s.key}`"
              :cx="resize(s.position.x)"
              :cy="resize(s.position.y)"
              :class="s.type"
              class="map-system" />

            <circle
              v-for="b in scenario.game_data.blackholes"
              :key="`map-blackhole-${b.key}`"
              :cx="resize(b.position.x)"
              :cy="resize(b.position.y)"
              :r="resize(b.radius)"
              class="map-blackhole" />

            <polygon
              v-for="s in scenario.game_data.sectors"
              :key="`sector-${s.key}`"
              :points="offsetPolygon(s.points, 0.5).flat().map(p => resize(p)).join()"
              class="map-sector"
              :class="getTheme(s.faction)"
              @click="toggleSectorToFaction(s.key)" />

            <text
              v-for="s in scenario.game_data.sectors"
              :key="`sector-name-${s.key}`"
              :x="resize(s.centroid[0])"
              :y="resize(s.centroid[1])"
              class="map-sector-name"
              text-anchor="middle"
              :class="getTheme(s.faction)"
              @click="toggleSectorToFaction(s.key)">
              [{{ s.victory_points }}] {{ s.name }} ({{ s.systems.length }})
            </text>
          </svg>

          <hr class="margin">
        </div>
      </div>

      <v-scrollbar class="panel-aside">
        <template v-if="currentStep === 0">
          <div class="panel-aside-bloc">
            <div class="radio-input is-horizontal">
              <div class="label">
                Vitesse du scénario
              </div>
              <div class="content">
                <div
                  v-for="{ key } in data.speed"
                  :key="`speed-${key}`"
                  class="content-item">
                  <input
                    type="radio"
                    :id="`speed-${key}`"
                    :value="key"
                    v-model="step.speed">
                  <label :for="`speed-${key}`">
                    <strong>{{ $t(`data.speed.${key}.name`) }}</strong>
                    {{ $t(`data.speed.${key}.description`) }}
                  </label>
                </div>
              </div>
            </div>

            <div class="radio-input is-horizontal">
              <div class="label">
                Mode du scénario
              </div>
              <div class="content">
                <div
                  v-for="{ value, label } in step.mode.choices"
                  :key="`mode-${value}`"
                  class="content-item">
                  <input
                    type="radio"
                    :id="`mode-${value}`"
                    :value="value"
                    v-model="step.mode.value">
                  <label :for="`mode-${value}`">
                    <strong>{{ label }}</strong>
                  </label>
                </div>
              </div>
            </div>

            <!--
            <div class="default-input">
              <label>TODO: Resources Starter</label>
            </div>
            -->

            <div class="default-input">
              <label for="date">Année de début</label>
              <input
                id="date"
                type="number"
                v-model.number="scenario.game_data.date" />
            </div>

            <div class="default-input">
              <label for="seed">Graine</label>
              <input
                id="seed"
                type="text"
                disabled
                v-model="scenario.game_data.seed" />
              <button
                @click="scenario.game_data.seed = newSeed()"
                class="default-button action">
                ↺
              </button>
            </div>
          </div>

          <div class="panel-aside-bloc">
            <button
              @click="toStep1"
              class="default-button">
              Étape suivante
            </button>
          </div>
        </template>

        <template v-if="currentStep === 1">
          <section class="panel-aside-info">
            <h2>Factions</h2>
            <p>Il faut au minimum <strong>2 factions</strong> avec au moins un secteur.</p>
            <p>Les factions sans secteurs sont retirées du scénario.</p>
          </section>

          <div class="panel-aside-bloc">
            <div
              v-for="f in step.factions"
              :key="`faction-${f.key}`"
              :class="[
                { 'active': step.selected === f.key },
                `theme-${f.theme}`,
              ]"
              @click="selectFaction(f.key)"
              class="selectable-item">
              <div class="selectable-item-select"></div>
              <div class="selectable-item-faction">
                <strong>{{ f.key }}</strong>
                <em>{{f.sectors.length }} secteurs</em>
              </div>
            </div>
          </div>

          <div class="panel-aside-bloc">
            <button
              @click="toStep2"
              class="default-button">
              Étape suivante
            </button>
          </div>
        </template>

        <template v-if="currentStep === 2">
          <div class="panel-aside-bloc">
            <div class="default-input">
              <label for="grid">
                Durée maximum
                <strong>{{ minutesToTime(scenario.game_data.time_limit) }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[2].timeLimits[scenario.game_metadata.speed].min"
                  :max="steps[2].timeLimits[scenario.game_metadata.speed].max"
                  :interval="steps[2].timeLimits[scenario.game_metadata.speed].interval"
                  :dotSize="16" :height="8"
                  :hideLabel="true" tooltip="none"
                  v-model.number="scenario.game_data.time_limit">
                </vue-slider>
              </div>
            </div>
          </div>

          <hr class="separator">

          <div class="panel-aside-bloc">
            <div
              v-for="(s, i) in scenario.game_data.sectors"
              :key="`s-${s.key}`"
              :class="s.color"
              class="sectors-points">
              <div class="default-input">
                <label :for="`s-${s.key}`">
                  {{ s.name }}
                  <strong>{{ s.victory_points }} points</strong>
                </label>
                <div class="input-slider">
                  <vue-slider
                    :id="`s-${s.key}`"
                    :min="0" :max="10" :interval="1"
                    :dotSize="16" :height="8"
                    :hideLabel="true" tooltip="none"
                    v-model.number="scenario.game_data.sectors[i].victory_points">
                  </vue-slider>
                </div>
              </div>
            </div>
          </div>

          <div class="panel-aside-bloc">
            <button
              @click="toStep3"
              class="default-button">
              Étape suivante
            </button>
          </div>
        </template>

        <template v-if="currentStep === 3">
          <div class="panel-aside-bloc">
            <button
              v-if="mode === 'new'"
              @click="create"
              :disabled="!isValid"
              class="default-button">
              <template v-if="waiting">...</template>
              <template v-else>Enregistrer le scénario</template>
            </button>
            <button
              v-else
              @click="update"
              :disabled="!isValid"
              class="default-button">
              <template v-if="waiting">...</template>
              <template v-else>Enregistrer les modifications</template>
            </button>
          </div>

          <div class="panel-aside-info">
            <p>
              Taille :
              <strong>{{ $t(`map.size.${scenario.game_metadata.size}.toast`) }}</strong>
            </p>
            <p>
              Mode :
              <strong>{{ scenario.game_data.mode }}</strong>
            </p>
            <p>
              Vitesse :
              <strong>{{ $t(`data.speed.${scenario.game_metadata.speed}.name`) }}</strong>
            </p>
            <p>
              Année de départ :
              <strong>{{ scenario.game_data.date }}</strong>
            </p>
            <p>
              Limite de temps :
              <strong>{{ minutesToTime(scenario.game_data.time_limit) }}</strong>
            </p>
            <p><strong>{{ scenario.game_data.sectors.length }}</strong> secteurs</p>
            <p><strong>{{ scenario.game_data.systems.length }}</strong> systèmes</p>
            <p><strong>{{ scenario.game_data.factions.length }}</strong> factions</p>
          </div>

          <div
            v-if="mode === 'edit'"
            class="panel-aside-bloc">
            <button
              @click="destroy"
              :disabled="!isValid"
              class="default-button">
              <template v-if="waiting">...</template>
              <template v-else>Supprimer le scénario</template>
            </button>
          </div>
        </template>

        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import Offset from 'polygon-offset';

import DefaultLayout from '@/portal/layouts/Default.vue';
import VueSlider from 'vue-slider-component';

import newSeed from '@/portal/utils';

export default {
  name: 'create-scenario',
  data() {
    return {
      mode: 'new',
      waiting: false,
      currentStep: 0,
      containerSize: 0,
      steps: [
        {
          number: 'I',
          label: 'Généralité',
          speed: undefined,
          mode: {
            value: 'prod',
            choices: [
              { value: 'dev', label: 'Développement' },
              { value: 'prod', label: 'Production' },
            ],
          },
        },
        {
          number: 'II',
          label: 'Factions',
          factions: [],
          selected: undefined,
        },
        {
          number: 'III',
          label: 'Victoires',
          timeLimits: {
            fast: { default: 120, min: 60, max: 180, interval: 5 },
            medium: { default: 600, min: 300, max: 720, interval: 30 },
            slow: { default: 43200, min: 10080, max: 129600, interval: 1440 },
          },
        },
        {
          number: 'IV',
          label: 'Validation',
        },
      ],
      scenario: {
        is_map: false,
        is_official: false,
        game_data: {
          systems: [],
          sectors: [],
          factions: [],
          speed: undefined,
          size: 0,
          mode: undefined,
          seed: undefined,
          date: undefined,
          time_limit: undefined,
          victory_points: 0,
        },
        game_metadata: {
          name: '',
          description: '',
          size: 0,
          system_number: undefined,
          sector_number: undefined,
          factions: [],
          speed: undefined,
          mode: undefined,
        },
        thumbnail: undefined,
      },
    };
  },
  computed: {
    data() { return this.$store.state.portal.data; },
    step() { return this.steps[this.currentStep]; },
    isValid() { return !this.waiting; },
  },
  methods: {
    async create() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.post('/scenarios', { scenario: this.scenario });
          this.$toasted.success('Scénario créé');
          this.$router.push('/create/scenarios');
        } catch (err) {
          this.$toastError('Erreur');
        }

        this.waiting = false;
      }
    },
    async update() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.put(`/scenarios/${this.scenario.id}`, { scenario: this.scenario });
          this.$toasted.success('Scénario enregistré');
          this.$router.push('/create/scenarios');
        } catch (err) {
          this.$toastError('Erreur');
        }

        this.waiting = false;
      }
    },
    async destroy() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.delete(`/scenarios/${this.scenario.id}`);
          this.$toasted.success('Scénario supprimé');
          this.$router.push('/create/scenarios');
        } catch (err) {
          this.$toastError('Erreur');
        }

        this.waiting = false;
      }
    },
    toStep1() {
      if (this.step.speed && this.step.mode.value) {
        this.scenario.game_data.speed = this.step.speed;
        this.scenario.game_data.mode = this.step.mode.value;
        this.scenario.game_metadata.speed = this.step.speed;
        this.scenario.game_metadata.mode = this.step.mode.value;
        this.scenario.game_data.time_limit = this.steps[2].timeLimits[this.step.speed].default;
        this.steps[1].factions = this.data.faction.map((f) => ({ key: f.key, theme: f.theme, sectors: [] }));
        this.currentStep = 1;
      }
    },
    toStep2() {
      const validFactioNumber = this.step.factions
        .filter((f) => f.sectors.length > 0).length;

      if (validFactioNumber >= 2) {
        const factions = this.step.factions
          .filter((f) => f.sectors.length > 0)
          .map((f) => ({ key: f.key, sector_number: f.sectors.length }));

        this.scenario.game_data.factions = factions;
        this.scenario.game_metadata.factions = factions;

        this.currentStep = 2;
      }
    },
    toStep3() {
      const sectorsPoints = this.scenario.game_data.sectors.reduce((sum, s) => sum + s.victory_points, 0);

      if (sectorsPoints >= this.scenario.game_data.victory_points) {
        this.currentStep = 3;
      }
    },
    selectFaction(key) {
      this.step.selected = this.step.selected === key
        ? undefined : key;
    },
    getFaction(key) {
      return this.step.factions.find((f) => f.key === key);
    },
    toggleSectorToFaction(key) {
      if (this.step.selected) {
        const faction = this.getFaction(this.step.selected);
        const sector = this.scenario.game_data.sectors.find((s) => s.key === key);

        if (sector.faction) {
          if (this._.includes(faction.sectors, sector)) {
            sector.faction = null;
            this._.remove(faction.sectors, (s) => s.key === sector.key);
          } else {
            this.step.factions.forEach((f) => {
              this._.remove(f.sectors, (s) => s.key === sector.key);
            });

            sector.faction = faction.key;
            faction.sectors.push(sector);
          }
        } else {
          sector.faction = faction.key;
          faction.sectors.push(sector);
        }
      }
    },
    getTheme(key) {
      return key
        ? `theme-${this.data.faction.find((f) => f.key === key).theme}`
        : '';
    },
    getSector(key) {
      return this.scenario.game_data.sectors.find((s) => s.key === key);
    },
    offsetPolygon(points, size = 0.2) {
      const offset = new Offset();
      const p = offset.data(points).padding(0);

      return offset.data(p).padding(size)[0];
    },
    minutesToTime(minutes) {
      const d = Math.floor(minutes / 1440);
      const h = Math.floor((minutes - (d * 1440)) / 60);
      const m = `${Math.round(minutes % 60)}`.padStart(2, '0');

      if (d > 0) { return `${d}j ${h}h${m}`; }
      if (h > 0) { return `${h}h${m}`; }
      return `${m} minutes`;
    },
    resize(value) {
      return value * (this.containerSize / this.scenario.game_metadata.size);
    },
    newSeed() {
      return newSeed();
    },
  },
  async mounted() {
    this.containerSize = this.$refs.container.clientWidth - (25 * 2);
    const mode = this.$route.params.mode;

    try {
      if (mode === 'new') {
        const { data } = await this.$axios.get(`/maps/${this.$route.params.id}`);

        this.mode = 'new';

        this.scenario.game_data.size = data.game_data.size;
        this.scenario.game_data.seed = this.newSeed();
        this.scenario.game_data.date = 4000;
        this.scenario.game_data.time_limit = 60;
        this.scenario.game_data.victory_points = 2;
        this.scenario.game_data.systems = data.game_data.systems;
        this.scenario.game_data.blackholes = data.game_data.blackholes;
        this.scenario.game_data.sectors = data.game_data.sectors
          .map((s) => Object.assign(s, { faction: null, victory_points: 1 }));

        this.scenario.game_metadata.name = data.game_metadata.name;
        this.scenario.game_metadata.description = data.game_metadata.description;
        this.scenario.game_metadata.size = data.game_metadata.size;
        this.scenario.game_metadata.system_number = data.game_metadata.system_number;
        this.scenario.game_metadata.sector_number = data.game_metadata.sector_number;
      } else if (mode === 'edit') {
        const { data } = await this.$axios.get(`/scenarios/${this.$route.params.id}`);

        this.mode = 'edit';
        this.currentStep = 3;
        this.scenario = data;
      } else {
        throw new Error('Error');
      }
    } catch (err) {
      this.$router.push('/create/scenarios');
      this.$toastError('Scénario inconnu');
    }
  },
  components: {
    DefaultLayout,
    VueSlider,
  },
};
</script>
