<template>
  <default-layout>
    <div class="fluid-panel">
      <v-scrollbar class="panel-aside">
        <div class="panel-aside-bloc">
          <div
            v-if="mode === 'new'"
            class="default-input">
            <label for="name">
              Étape {{ step.number }}
              <strong>{{ step.label }}</strong>
            </label>
            <div class="input-slider">
              <vue-slider
                :lazy="true"
                :min="0" :max="5"
                :interval="1"
                :marks="true"
                :disabled="true"
                :dotSize="16" :height="8"
                :hideLabel="true" tooltip="none"
                v-model="stepCursor">
              </vue-slider>
            </div>
          </div>

          <button
            v-if="stepCursor < 5"
            class="default-button fullsized"
            @click="nextStep">
            Étape suivante
            <svgicon name="caret-right" />
          </button>
          <template v-else>
            <button
              v-if="mode === 'new'"
              class="default-button fullsized"
              :disabled="!isValid"
              @click="create">
              <template v-if="waiting">...</template>
              <template v-else>Enregistrer</template>
            </button>
            <template v-else>
              <button
                class="default-button fullsized"
                :disabled="!isValid"
                @click="update">
                <template v-if="waiting">...</template>
                <template v-else>Modifier</template>
              </button>
              <hr class="separator">
              <button
                class="default-button fullsized"
                @click="destroy">
                <template v-if="waiting">...</template>
                <template v-else>Supprimer</template>
              </button>
            </template>
          </template>
        </div>

        <hr class="separator">

        <div class="panel-aside-bloc">
          <div class="default-input">
            <label for="name">Nom</label>
            <input
              id="name"
              type="text"
              autocomplete="off"
              placeholder="___"
              v-model="steps[5].map.game_metadata.name" />
          </div>

          <div class="default-input">
            <label for="description">Description</label>
            <textarea
              id="description"
              v-model="steps[5].map.game_metadata.description">
            </textarea>
          </div>

          <div class="checkbox-input">
            <input
              type="checkbox"
              id="official"
              v-model="steps[5].map.is_official">
            <label for="official">Carte officielle</label>
          </div>
        </div>

        <hr class="margin">
      </v-scrollbar>

      <div class="panel-content is-square">
        <router-link
          class="close-button"
          to="/create/maps">
          Retour
        </router-link>

        <div
          class="content"
          ref="container">
          <svg
            :width="container.width"
            :height="container.width"
            version="1.1"
            xmlns="http://www.w3.org/2000/svg"
            class="map-container">
            <g v-if="displayOptions.grid">
              <line
                v-for="i in Math.round(steps[0].size.value / 12)"
                :key="`v-${i}`"
                x1="0" :y1="resize(i * 12)"
                x2="100%" :y2="resize(i * 12)"
                class="map-grid" />
              <line
                v-for="i in Math.round(steps[0].size.value / 12)"
                :key="`h-${i}`"
                y1="0" :x1="resize(i * 12)"
                y2="100%" :x2="resize(i * 12)"
                class="map-grid" />
            </g>

            <circle
              v-if="displayOptions.circleCursor"
              :cx="mouse.x - container.x"
              :cy="mouse.y - container.y"
              :r="resize(12)"
              class="map-circle-cursor" />
            <circle
              v-if="steps[4].deleteMode"
              :cx="mouse.x - container.x"
              :cy="mouse.y - container.y"
              :r="resize(steps[4].deleteRadius.value)"
              class="map-circle-delete" />
            <circle
              v-if="steps[4].blackholeMode"
              :cx="mouse.x - container.x"
              :cy="mouse.y - container.y"
              :r="resize(steps[4].blackholeRadius.value)"
              class="map-circle-blackhole" />

            <path
              v-if="displayOptions.edges"
              class="map-edges"
              :d="edgesPath(edges)" />

            <g v-if="[1, 2].includes(stepCursor)">
              <polygon
                v-for="t in steps[1].triangles"
                :key="`triangle-${t.key}`"
                :points="t.points.flat().map(p => resize(p)).join()"
                :class="t.color"
                class="map-voronoi-triangle"
                @mouseenter="hoverTriangle(t.key, $event)"
                @click="toggleTriangleToSector(t.key)" />
            </g>

            <g v-if="[3, 4, 5].includes(stepCursor)">
              <polygon
                v-for="s in (steps[5].map.game_data ? steps[5].map.game_data.sectors : steps[2].sectors)"
                :key="`map-sector-${s.key}`"
                :points="s.points03.flat().map(p => resize(p)).join()"
                :class="s.color"
                class="map-sector" />

              <circle
                v-for="b in (steps[5].map.game_data ? steps[5].map.game_data.blackholes : steps[4].blackholes)"
                :key="`map-blackhole-${b.key}`"
                :cx="resize(b.position.x)"
                :cy="resize(b.position.y)"
                :r="resize(b.radius)"
                class="map-blackhole" />

              <circle
                v-for="s in (steps[5].map.game_data ? steps[5].map.game_data.systems : steps[3].systems)"
                :key="`map-system-${s.key}`"
                :cx="resize(s.position.x)"
                :cy="resize(s.position.y)"
                :class="s.type"
                class="map-system" />

              <g v-if="displayOptions.sectorInfo">
                <text
                  v-for="s in (steps[5].map.game_data ? steps[5].map.game_data.sectors : steps[2].sectors)"
                  :key="`map-sector-text-${s.key}`"
                  :x="resize(s.centroid[0])"
                  :y="resize(s.centroid[1])"
                  text-anchor="middle"
                  class="map-sector-name">
                  {{ s.name }} ({{ s.systems.length }})
                </text>
              </g>
            </g>
          </svg>

          <hr class="margin">
        </div>
      </div>

      <v-scrollbar class="panel-aside">
        <div class="panel-aside-bloc">
          <div class="checkbox-input has-small-bm">
            <input
              type="checkbox"
              id="grid-option"
              v-model="displayOptions.grid">
            <label for="grid-option">Afficher la grille</label>
          </div>

          <div class="checkbox-input has-small-bm">
            <input
              type="checkbox"
              id="circle-cursor-option"
              v-model="displayOptions.circleCursor">
            <label for="circle-cursor-option">Afficher la distance maximale de bond</label>
          </div>

          <div class="checkbox-input has-small-bm">
            <input
              type="checkbox"
              id="circle-sector-option"
              v-model="displayOptions.sectorInfo">
            <label for="circle-sector-option">Informations des secteurs</label>
          </div>

          <div class="checkbox-input">
            <input
              type="checkbox"
              id="circle-edges-option"
              v-model="displayOptions.edges">
            <label for="circle-edges-option">Connexions entre les systèmes</label>
          </div>
        </div>

        <hr class="separator">

        <template v-if="stepCursor === 0">
          <div class="panel-aside-bloc">
            <div class="radio-input is-horizontal">
              <div class="label">
                Taille de la carte
              </div>
              <div class="content">
                <div
                  v-for="value in steps[0].size.choices"
                  :key="`size-${value}`"
                  class="content-item">
                  <input
                    type="radio"
                    :id="`size-${value}`"
                    :value="value"
                    v-model="steps[0].size.value">
                  <label :for="`size-${value}`">
                    <strong>{{ $t(`map.size.${value}.label`) }}</strong>
                    {{ $t(`map.size.${value}.description`) }}
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div class="panel-aside-info">
            <h2>Info</h2>
            <p>La taille de la grille et le rayon du cercle autours de la souris correspondent à la distance maximale de saut.</p>
          </div>
        </template>

        <div
          v-if="stepCursor === 1"
          class="panel-aside-bloc">
          <div class="default-input">
            <label for="seed-step-1">Graine</label>
            <input
              id="seed-step-1"
              type="text"
              autocomplete="off"
              v-model="steps[1].seed"
              @input="genVoronoi()" />
            <button
              @click="steps[1].seed = newSeed(); genVoronoi();"
              class="default-button action">
              ↺
            </button>
          </div>

          <div class="default-input">
            <label for="grid">
              Taille des triangles
              <strong>{{ steps[1].grid.value }}</strong>
            </label>
            <div class="input-slider">
              <vue-slider
                :min="steps[1].grid.range.min"
                :max="steps[1].grid.range.max"
                :interval="1"
                :dotSize="16" :height="8"
                :hideLabel="true" tooltip="none"
                @drag-end="genVoronoi()"
                v-model="steps[1].grid.value">
              </vue-slider>
            </div>
          </div>
        </div>

        <template v-if="stepCursor === 2">
          <div class="panel-aside-bloc">
            <button
              @click="addSector"
              class="default-button">
              Ajouter un secteur
            </button>
          </div>

          <div class="panel-aside-bloc">
            <template v-if="steps[2].sectors.length > 0">
              <div
                v-for="s in steps[2].sectors.slice().reverse()"
                :key="`s-${s.key}`"
                :class="[
                  { 'active': steps[2].selected === s.key },
                  s.color,
                ]"
                @click="selectSector(s.key)"
                class="selectable-item">
                <div
                  @click.stop="removeSector(s.key)"
                  class="selectable-item-remove">
                  ×
                </div>
                <div class="selectable-item-select"></div>
                <div class="default-input">
                  <input
                    type="text"
                    autocomplete="off"
                    @click.prevent.stop
                    v-model="getSector(s.key).name" />
                </div>
              </div>
            </template>
            <div v-else>
              Ajoutez au moins un secteur.
            </div>
          </div>

          <div class="panel-aside-info">
            <h2>Info</h2>
            <p>Maintenez la touche CTRL enfoncée et passez le curseur sur les triangles pour les associer à la suite.</p>
          </div>
        </template>

        <template v-if="stepCursor === 3">
          <div class="panel-aside-bloc">
            <div class="default-input">
              <label for="seed-step-3">Graine</label>
              <input
                id="seed-step-3"
                type="text"
                autocomplete="off"
                v-model="steps[3].seed"
                @input="genSystem()" />
              <button
                @click="steps[3].seed = newSeed(); genSystem();"
                class="default-button action">
                ↺
              </button>
            </div>

            <div class="default-input">
              <label for="grid">
                Densité générale
                <strong>{{ steps[3].density.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[3].density.range.min"
                  :max="steps[3].density.range.max"
                  :interval="steps[3].density.interval"
                  :hideLabel="true" tooltip="none"
                  :dotSize="16" :height="8"
                  @drag-end="genSystem()"
                  v-model="steps[3].density.value">
                </vue-slider>
              </div>
            </div>

            <div class="default-input">
              <label for="grid">
                Densité par groupe
                <strong>{{ steps[3].maxDensity.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[3].maxDensity.range.min"
                  :max="steps[3].maxDensity.range.max"
                  :interval="steps[3].maxDensity.interval"
                  :hideLabel="true" tooltip="none"
                  :dotSize="16" :height="8"
                  @drag-end="genSystem()"
                  v-model="steps[3].maxDensity.value">
                </vue-slider>
              </div>
            </div>

            <div class="default-input">
              <label for="grid">
                Nombre de groupe
                <strong>{{ steps[3].points.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[3].points.range.min"
                  :max="steps[3].points.range.max"
                  :interval="steps[3].points.interval"
                  :hideLabel="true" tooltip="none"
                  :dotSize="16" :height="8"
                  @drag-end="genSystem()"
                  v-model="steps[3].points.value">
                </vue-slider>
              </div>
            </div>

            <div class="default-input">
              <label for="grid">
                Étalement des groupes
                <strong>{{ steps[3].spread.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[3].spread.range.min"
                  :max="steps[3].spread.range.max"
                  :interval="steps[3].spread.interval"
                  :hideLabel="true" tooltip="none"
                  :dotSize="16" :height="8"
                  @drag-end="genSystem()"
                  v-model="steps[3].spread.value">
                </vue-slider>
              </div>
            </div>

            <div class="default-input">
              <label for="grid">
                Atténuation des groupes
                <strong>{{ steps[3].attenuation.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[3].attenuation.range.min"
                  :max="steps[3].attenuation.range.max"
                  :interval="steps[3].attenuation.interval"
                  :hideLabel="true" tooltip="none"
                  :dotSize="16" :height="8"
                  @drag-end="genSystem()"
                  v-model="steps[3].attenuation.value">
                </vue-slider>
              </div>
            </div>
          </div>
        </template>

        <template v-if="stepCursor === 4">
          <div class="panel-aside-bloc">
            <div class="checkbox-input has-small-bm">
              <input
                type="checkbox"
                id="delete-mode"
                v-model="steps[4].deleteMode"
                @input="steps[4].blackholeMode = false">
              <label for="delete-mode">Outil de suppression de systèmes</label>
            </div>

            <div class="checkbox-input">
              <input
                type="checkbox"
                id="blackhole-mode"
                v-model="steps[4].blackholeMode"
                @input="steps[4].deleteMode = false">
              <label for="blackhole-mode">Outil de création de trou noir</label>
            </div>

            <div
              v-if="steps[4].deleteMode"
              class="default-input">
              <label for="grid">
                Taille du cercle de suppression
                <strong>{{ steps[4].deleteRadius.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[4].deleteRadius.range.min"
                  :max="steps[4].deleteRadius.range.max"
                  :interval="0.5"
                  :dotSize="16" :height="8"
                  :hideLabel="true" tooltip="none"
                  v-model="steps[4].deleteRadius.value">
                </vue-slider>
              </div>
            </div>

            <div
              v-if="steps[4].blackholeMode"
              class="default-input">
              <label for="grid">
                Taille du trou noir
                <strong>{{ steps[4].blackholeRadius.value }}</strong>
              </label>
              <div class="input-slider">
                <vue-slider
                  :min="steps[4].blackholeRadius.range.min"
                  :max="steps[4].blackholeRadius.range.max"
                  :interval="0.5"
                  :dotSize="16" :height="8"
                  :hideLabel="true" tooltip="none"
                  v-model="steps[4].blackholeRadius.value">
                </vue-slider>
              </div>
            </div>
          </div>

          <div class="panel-aside-bloc">
            <template v-if="steps[4].blackholes.length > 0">
              <div
                v-for="b in steps[4].blackholes.slice().reverse()"
                :key="`s-${b.key}`"
                class="selectable-item">
                <div
                  @click.stop="removeBlackhole(b.key)"
                  class="selectable-item-remove">
                  ×
                </div>
                <div class="default-input">
                  <input
                    type="text"
                    autocomplete="off"
                    @click.prevent.stop
                    v-model="getBlackhole(b.key).name" />
                </div>
              </div>
            </template>
            <div v-else>
              Aucun trou noir.
            </div>
          </div>
        </template>

        <hr class="margin">
      </v-scrollbar>
    </div>
  </default-layout>
</template>

<script>
import Prando from 'prando';
import VueSlider from 'vue-slider-component';

import DefaultLayout from '@/portal/layouts/Default.vue';
import editor from '@/utils/editor';

export default {
  name: 'create-map',
  data() {
    return {
      mode: 'new',
      waiting: false,
      mouse: { x: 0, y: 0 },
      container: { x: 0, y: 0, width: 0 },
      displayOptions: {
        grid: true,
        circleCursor: true,
        sectorInfo: false,
        edges: false,
      },
      edges: [],
      stepCursor: 0,
      steps: [
        {
          number: 'I',
          label: 'Taille de la carte',
          size: {
            value: 120,
            choices: [80, 120, 200, 360, 500, 750],
          },
        },
        {
          number: 'II',
          label: 'Création de la grille',
          seed: '',
          triangles: [],
          grid: {
            value: 15,
            range: { min: 5, max: 60 },
          },
        },
        {
          number: 'III',
          label: 'Assemblage des secteurs',
          cursor: 1,
          sectors: [],
          selected: undefined,
        },
        {
          number: 'IV',
          label: 'Génération des systèmes',
          seed: '',
          systems: [],
          density: {
            value: 50,
            interval: 1,
            range: { min: 0, max: 100 },
          },
          maxDensity: {
            value: 12,
            interval: 1,
            range: { min: 0, max: 100 },
          },
          points: {
            value: 5,
            interval: 1,
            range: { min: 1, max: 20 },
          },
          spread: {
            value: 1,
            interval: 0.05,
            range: { min: 0, max: 5 },
          },
          attenuation: {
            value: 2.5,
            interval: 0.1,
            range: { min: 1, max: 10 },
          },
        },
        {
          number: 'V',
          label: 'Derniers détails',
          deleteRadius: {
            value: 2,
            range: { min: 1, max: 5 },
          },
          deleteMode: false,
          blackholeRadius: {
            value: 5,
            range: { min: 1, max: 12 },
          },
          blackholeMode: false,
          cursor: 1,
          blackholes: [],
        },
        {
          number: 'VI',
          label: 'Finalisation',
          map: {
            is_map: true,
            is_official: false,
            game_data: null,
            game_metadata: {
              name: '',
              description: '',
              size: null,
              system_number: 0,
              sector_number: 0,
            },
            thumbnail: undefined,
          },
        },
      ],
    };
  },
  computed: {
    data() { return this.$store.state.portal.data; },
    step() { return this.steps[this.stepCursor]; },
    isValid() { return this.stepCursor === 5 && this.steps[5].map.game_metadata.name !== '' && !this.waiting; },
    extractEdges() { return this.steps[3].systems.length + this.steps[4].blackholes.length; },
  },
  watch: {
    extractEdges() {
      this.$axios.post('/maps/preview-edges', {
        systems: this.steps[3].systems,
        blackholes: this.steps[4].blackholes,
      }).then(({ data }) => {
        this.edges = data;
      });
    },
  },
  methods: {
    nextStep() {
      if (this.stepCursor === 0) {
        if (!this.steps[0].size.value) {
          this.$toastError('Taille de carte manquante');
          return false;
        }

        this.steps[1].seed = this.newSeed();
        this.genVoronoi();
      } else if (this.stepCursor === 1) {
        if (this.steps[1].triangles.length < 1) {
          this.$toastError('Aucun triangle généré');
          return false;
        }
      } else if (this.stepCursor === 2) {
        const { sectors, errors } = editor.assembleTriangles(this.steps[2].sectors);
        errors.forEach((error) => this.$toastError(error));

        if (this.steps[2].sectors.length < 2) {
          this.$toastError('Nombre de secteur insuffisant.');
          return false;
        }

        this.steps[1].triangles = [];
        this.steps[2].sectors = sectors;
        this.steps[3].seed = this.newSeed();
        this.genSystem();
      } else if (this.stepCursor === 3) {
        // TODO: check if there is at least one systems in each sectors
      } else if (this.stepCursor === 4) {
        // TODO: empty other steps data

        const sectors = this.steps[2].sectors.map((s) => ({
          key: s.key,
          name: s.name,
          area: s.area,
          centroid: s.centroid,
          points: s.points,
          points03: s.points03,
          systems: s.systems,
        }));

        const gameData = {
          size: this.steps[0].size.value,
          systems: this.steps[3].systems,
          sectors,
          blackholes: this.steps[4].blackholes,
        };

        this.steps[5].map.game_data = gameData;
        this.steps[5].map.game_metadata.system_number = this.steps[3].systems.length;
        this.steps[5].map.game_metadata.sector_number = sectors.length;
        this.steps[5].map.game_metadata.size = this.steps[0].size.value;
      }

      this.stepCursor += 1;
    },
    async create() {
      if (this.isValid) {
        this.waiting = true;

        try {
          await this.$axios.post('/maps', { map: this.steps[5].map });
          this.$toasted.success('Carte crée');
          this.$router.push('/create/maps');
        } catch (err) {
          this.$toastError('Erreur');
        }

        this.waiting = false;
      }
    },
    async update() {
      if (this.isValid) {
        this.waiting = true;
        const map = this.steps[5].map;

        try {
          await this.$axios.put(`/maps/${map.id}`, { map });
          this.$toasted.success('Carte enregistrée');
          this.$router.push('/create/maps');
        } catch (err) {
          this.$toastError('Erreur');
        }

        this.waiting = false;
      }
    },
    async destroy() {
      this.waiting = true;

      try {
        await this.$axios.delete(`/maps/${this.steps[5].map.id}`);
        this.$toasted.success('Carte supprimée');
        this.$router.push('/create/maps');
      } catch (err) {
        this.$toastError('Erreur');
      }

      this.waiting = false;
    },
    genVoronoi() {
      this.steps[1].triangles = editor.genVoronoi(
        new Prando(this.steps[1].seed),
        this.steps[0].size.value,
        this.steps[1].grid.value,
      );
    },
    genSystem() {
      this.edges = [];
      this.steps[3].systems = editor.genSystem(
        new Prando(this.steps[3].seed),
        this.steps[2].sectors,
        this.data.stellar_system,
        {
          density: this.steps[3].density.value,
          maxDensity: this.steps[3].maxDensity.value,
          points: this.steps[3].points.value,
          spread: this.steps[3].spread.value,
          attenuation: this.steps[3].attenuation.value,
        },
      );
    },
    getSector(key) {
      return this.steps[2].sectors.find((s) => s.key === key);
    },
    addSector() {
      this.$axios.get('/name/sector/1').then((response) => {
        const id = this.steps[2].cursor;
        const sector = editor.createSector(id, response.data[0]);

        this.steps[2].cursor += 1;
        this.steps[2].sectors.push(sector);
        this.selectSector(id);
      }).catch((err) => {
        this.$toastError(`Erreur: ${err}`);
      });
    },
    removeSector(key) {
      const sector = this.getSector(key);

      this.steps[1].triangles = this.steps[1].triangles.map((triangle) => {
        if (sector.triangles.find((t) => triangle.key === t.key)) {
          triangle.color = undefined;
        }

        return triangle;
      });

      this.steps[2].sectors = this.steps[2].sectors.filter((s) => s.key !== key);
    },
    selectSector(key) {
      this.steps[2].selected = this.steps[2].selected === key ? undefined : key;
    },
    getBlackhole(key) {
      return this.steps[4].blackholes.find((b) => b.key === key);
    },
    addBlackhole(x, y, radius) {
      this.$axios.get('/name/sector/1').then((response) => {
        const id = this.steps[4].cursor;
        const blackhole = editor.createBlackhole(id, response.data[0], { x, y }, radius);

        this.steps[4].cursor += 1;
        this.steps[4].blackholes.push(blackhole);
      }).catch((err) => {
        this.$toastError(`Erreur: ${err}`);
      });
    },
    removeBlackhole(key) {
      this.steps[4].blackholes = this.steps[4].blackholes.filter((b) => b.key !== key);
    },
    hoverTriangle(key, event) {
      if (event.ctrlKey) {
        this.toggleTriangleToSector(key, false);
      }
    },
    toggleTriangleToSector(key, toggle = true) {
      if (this.steps[2].selected) {
        const { triangles, sectors } = editor.toggleTriangleToSector(
          key,
          toggle,
          this.getSector(this.steps[2].selected),
          this.steps[1].triangles,
          this.steps[2].sectors,
        );

        this.steps[1].triangles = triangles;
        this.steps[2].sectors = sectors;
      }
    },
    resize(value) {
      return Math.round(value * (this.container.width / this.steps[0].size.value) * 100) / 100;
    },
    rresize(value) {
      return value * (this.steps[0].size.value / this.container.width);
    },
    newSeed(size = 8) {
      return Math.random().toString(36).substring(size);
    },
    edgesPath(edges) {
      return edges.reduce((acc, edge) => {
        const { s1, s2 } = edge;
        return acc
          + `M ${this.resize(s1.position.x)} ${this.resize(s1.position.y)} `
          + `L ${this.resize(s2.position.x)} ${this.resize(s2.position.y)}`;
      }, '');
    },
    deleteSystemsInRadius(x, y, radius) {
      const toRemove = this.steps[3].systems
        .filter((s) => {
          const sx = this.resize(s.position.x);
          const sy = this.resize(s.position.y);

          return ((sx - x) ** 2) + ((sy - y) ** 2) < radius ** 2;
        })
        .map((s) => s.key);

      this.steps[3].systems = this.steps[3].systems.filter((s) => !toRemove.includes(s.key));
      this.steps[2].sectors = this.steps[2].sectors.map((sector) => {
        sector.systems = sector.systems.filter((s) => !toRemove.includes(s.key));
        return sector;
      });
    },
    onClick() {
      if (this.stepCursor === 4) {
        const x = this.mouse.x - this.container.x;
        const y = this.mouse.y - this.container.y;

        if (this.steps[4].deleteMode) {
          const radius = this.resize(this.steps[4].deleteRadius.value);

          this.deleteSystemsInRadius(x, y, radius);
        } else if (this.steps[4].blackholeMode) {
          if (x > 0 && x < this.container.width && y > 0 && y < this.container.width) {
            const radius = this.resize(this.steps[4].blackholeRadius.value);

            this.addBlackhole(this.rresize(x), this.rresize(y), this.steps[4].blackholeRadius.value);
            this.deleteSystemsInRadius(x, y, radius + 5);
          }
        }
      }
    },
    setContainerSize() {
      const box = this.$refs.container.getBoundingClientRect();

      this.container = {
        x: box.left + 25,
        y: box.top + 25,
        width: this.$refs.container.clientWidth - (25 * 2),
      };
    },
    setMousePosition(event) {
      this.mouse = {
        x: event.clientX,
        y: event.clientY,
      };
    },
  },
  async mounted() {
    this.setContainerSize();
    window.addEventListener('resize', this.setContainerSize);
    window.addEventListener('mousemove', this.setMousePosition);
    window.addEventListener('click', this.onClick);

    if (this.$route.params.id !== 'new') {
      try {
        const { data } = await this.$axios.get(`/maps/${this.$route.params.id}`);

        this.mode = 'edit';
        this.stepCursor = 5;
        this.steps[5].map = data;
      } catch (err) {
        this.$router.push('/create/maps');
        this.$toastError('Carte inconnue');
      }
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.setContainerSize);
    window.removeEventListener('mousemove', this.setMousePosition);
    window.removeEventListener('click', this.onClick);
  },
  components: {
    DefaultLayout,
    VueSlider,
  },
};
</script>
