<template>
  <div
    class="system-svg"
    @click="closeProduction">
    <div
      ref="svgBackground"
      class="svg-background"></div>
    <svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'>
      <defs>
        <filter id="blur8">
          <feGaussianBlur in="SourceGraphic" stdDeviation="8" />
        </filter>
        <filter id="blur6">
          <feGaussianBlur in="SourceGraphic" stdDeviation="6" />
        </filter>
        <filter id="blur2">
          <feGaussianBlur in="SourceGraphic" stdDeviation="2" />
        </filter>
      </defs>

      <mask id="global-mask">
        <circle
          ref="circleMask"
          cx="50%"
          cy="50%"
          r="0%"
          fill="white" />
      </mask>

      <!-- cosmetic background -->
      <g mask="url(#global-mask)">
        <circle
          v-for="i in 9"
          :key="`cc-${i}`"
          class="aesthetic-circle"
          cx="50%" cy="50%"
          :r="`${i * 5}%`" />

        <text
          v-for="i in 7"
          :key="`ct-${i}`"
          class="aesthetic-circle-label"
          :x="`${50.6 + (i * 5)}%`"
          y="49.6%">
          {{ i * i * 0.5 }}ua
        </text>

        <!-- star -->
        <circle
          class="star-halo"
          cx="50%" cy="50%"
          filter="url(#blur6)"
          :style="`fill: ${stellarBodies.star.color}`"
          :r="stellarBodies.star.size + 10" />
        <circle
          class="star-white-halo"
          cx="50%" cy="50%"
          filter="url(#blur2)"
          :r="stellarBodies.star.size" />
        <circle
          class="star-main"
          cx="50%" cy="50%"
          :style="`fill: ${stellarBodies.star.color}`"
          :r="stellarBodies.star.size" />
        <circle
          class="star-main-darker"
          cx="50%" cy="50%"
          filter="url(#blur8)"
          :style="`fill: ${lighten(stellarBodies.star.color)}`"
          :r="stellarBodies.star.size - 10" />

        <template v-if="system.contact.value > 0">
          <!-- hovered circle -->
          <circle
            v-for="body in stellarBodies.bodies"
            :key="`h-${body.key}`"
            class="hover-circle"
            :class="{ 'hovered': isOrbitHovered(body.id) }"
            cx="50%" cy="50%"
            :r="`${toPercentage(body.position)}%`" />

          <!-- primary orbit -->
          <g
            v-for="body in stellarBodies.bodies"
            :key="body.key"
            :ref="body.key">
            <!-- Bugfix: structural circle -->
            <circle class="invisible" cx="50%" cy="50%" r="50%" />

            <g :style="`
                transform: rotate(${changeRotationSpace(body.rotation)}deg);
                transform-origin: 50% 50%;
              `">

              <!-- special case: asteroid belt -->
              <g v-if="body.type === 'asteroid_belt'">
                <!-- primary body -->
                <circle
                  class="asteroid-belt"
                  cx="50%" cy="50%"
                  :style="`stroke-width: ${body.size}; stroke: ${body.color}`"
                  :r="`${toPercentage(body.position)}%`" />

                <!-- secondary body -->
                <rect
                  class="asteroid"
                  v-for="asteroid in body.subbodies"
                  :key="asteroid.key"
                  y="50%"
                  :x="`${50 + toPercentage(body.position - 1)}%`"
                  :width="asteroid.size"
                  :height="asteroid.size"
                  :style="`
                    fill: ${asteroid.color};
                    transform: rotate(${changeRotationSpace(asteroid.rotation)}deg);
                    transform-origin: 50% 50%;
                  `" />
              </g>

              <!-- normal case: planet -->
              <g v-else>
                <!-- orbit line -->
                <circle
                  class="primary-orbit short"
                  cx="50%" cy="50%"
                  :r="`${toPercentage(body.position)}%`" />
                <circle
                  class="primary-orbit medium"
                  cx="50%" cy="50%"
                  :r="`${toPercentage(body.position)}%`" />
                <circle
                  class="primary-orbit long"
                  cx="50%" cy="50%"
                  :r="`${toPercentage(body.position)}%`" />

                <!-- primary body -->
                <circle
                  class="primary-body-halo"
                  cy="50%"
                  filter="url(#blur)"
                  :cx="`${50 + toPercentage(body.position)}%`"
                  :r="body.size" />
                <circle
                  class="primary-body"
                  cy="50%"
                  :cx="`${50 + toPercentage(body.position)}%`"
                  :r="body.size"
                  :style="`fill: ${body.color}`" />
                <circle
                  class="primary-body-darker"
                  filter="url(#blur2)"
                  cy="50%"
                  :cx="`${50 + toPercentage(body.position)}%`"
                  :r="body.size - 3"
                  :style="`fill: ${darken(body.color)}`" />

                <!-- primary body shadow -->
                <defs>
                  <mask
                    maskUnits="userSpaceOnUse"
                    maskContentUnits="userSpaceOnUse"
                    :id="body.key">
                    <circle
                      cy="50%"
                      :cx="`${50 + toPercentage(body.position)}%`"
                      :r="body.size"
                      fill="white" />
                  </mask>
                </defs>
                <rect
                  class="primary-body-mask"
                  y="47%"
                  width="60px" height="60px"
                  :x="`${50 + toPercentage(body.position)}%`"
                  :mask="`url(#${body.key})`" />

                <!-- secondary orbit -->
                <g
                  v-for="moon in body.subbodies"
                  :key="moon.key"
                  :ref="moon.key">
                  <g :style="`
                      transform: rotate(${changeRotationSpace(moon.rotation)}deg);
                      transform-origin: ${50 + toPercentage(body.position)}% 50%;
                    `">
                    <!-- secondary body -->
                    <circle
                      class="secondary-body"
                      cy="50%"
                      :cx="`${50 + toPercentage(body.position + moon.position)}%`"
                      :r="moon.size"
                      :style="`fill: ${moon.color}`" />
                    <!-- secondary orbit line -->
                    <circle
                      class="secondary-orbit"
                      :cx="`${50 + toPercentage(body.position)}%`"
                      cy="50%"
                      :r="`${moon.position * 4.1}px`" />
                  </g>
                </g>
              </g>
            </g>
          </g>

          <circle
            class="event-circle"
            v-for="(body, i) in system.bodies"
            :key="`e-${body.id}`"
            @click="clickOrbit([body])"
            @mouseover="$emit('enterOrbit', body.id)"
            @mouseleave="$emit('leaveOrbit')"
            cx="50%" cy="50%"
            :r="`${toPercentage(stellarBodies.bodies[i].position)}%`">
          </circle>
        </template>

        <template v-else>
          <defs>
            <path d="M-200,0a200,200 0 1,0 400,0a200,200 0 1,0 -400,0" id="no-data-orbit" />
          </defs>

          <circle
            class="no-data-circle"
            cx="50%" cy="50%"
            r="195" />
          <g
            ref="noData"
            :style="`
              transform: translate(50%, 50%);
            `">
            <circle class="invisible" cx="0" cy="0" r="50%" />
            <text class="no-data-text">
              <textPath xlink:href="#no-data-orbit">
                {{ $t('galaxy.system.svg.no_data') }}
              </textPath>
            </text>
          </g>
        </template>
      </g>
    </svg>
  </div>
</template>

<script>
import { TweenMax, Sine } from 'gsap';

import Prando from 'prando';
import Color from 'tinycolor2';

export default {
  name: 'system-svg',
  data() {
    return {
      orbitBoundary: {
        min: 4,
        max: 40,
      },
      orbitSize: {
        min: 10,
        max: 50,
      },
      starSize: [20, 30],
      starSpecs: [
        { colors: ['#d4f4ff'], orbitSize: { min: 4, max: 50 }, type: 'white_dwarf' },
        { colors: ['#fa8064'], orbitSize: { min: 6, max: 50 }, type: 'red_dwarf' },
        { colors: ['#ffd1a3'], orbitSize: { min: 8, max: 50 }, type: 'orange_dwarf' },
        { colors: ['#ffe880'], orbitSize: { min: 12, max: 50 }, type: 'yellow_dwarf' },
        { colors: ['#f2183c'], orbitSize: { min: 16, max: 50 }, type: 'red_giant' },
        { colors: ['#1fa8ed'], orbitSize: { min: 18, max: 50 }, type: 'blue_giant' },
      ],
      bodySpecs: [
        { type: 'habitable_planet', size: [5, 10], colors: ['#13b7bf', '#26a9c7', '#40b8f5', '#39a3db'] },
        { type: 'sterile_planet', size: [5, 10], colors: ['#feffd2', '#e9fefe', '#ede4c7'] },
        { type: 'gaseous_giant', size: [10, 16], colors: ['#fffe99', '#feffd2', '#fcf09a', '#f2ba85'] },
        { type: 'asteroid_belt', size: [10, 16], colors: ['#e3e3e3', '#f5f5f5', '#cceef0'] },
        { type: 'moon', size: [2, 3], colors: ['#9c9c9c', '#6a6a6a'] },
        { type: 'asteroid', size: [5, 10], colors: ['#9c9c9c', '#6a6a6a'] },
      ],
    };
  },
  props: {
    system: Object,
    hoveredOrbit: Number,
  },
  computed: {
    systemData() {
      return this.$store.state.game.data.stellar_system
        .filter((s) => s.key === this.system.type)[0];
    },
    stellarBodies() {
      const rng = new Prando(this.system.id);
      const orbitRegionSize = 100 / this.system.bodies.length;
      const starSpecs = this.starSpecs.find((x) => x.type === this.systemData.key);
      const orbitSize = {
        min: starSpecs.orbitSize.min,
        max: (orbitRegionSize > starSpecs.orbitSize.max
          ? starSpecs.orbitSize.max
          : orbitRegionSize),
      };

      let cursor = 0;
      const bodies = [];

      for (let i = 0; i < this.system.bodies.length; i += 1) {
        const body = this.system.bodies[i];
        const subbodies = [];
        const orbitPosition = cursor
          + this.floatToInterval(rng.next(), orbitSize.min, orbitSize.max);
        cursor = orbitPosition;

        const bodySize = this.bodySpecs
          .filter((b) => b.type === body.type)
          .map((b) => this.takeRandomFromFloat(b.size, rng.next()))
          .shift();
        const bodyColor = this.bodySpecs
          .filter((b) => b.type === body.type)
          .map((b) => this.takeRandomFromFloat(b.colors, rng.next()))
          .shift();

        let subcursor = bodySize / 3;

        for (let j = 0; j < body.bodies.length; j += 1) {
          const subbody = body.bodies[j];
          const suborbitPosition = subcursor + 2;
          subcursor = suborbitPosition;

          subbodies.push({
            id: subbody.id,
            key: `b2-${j + 1}`,
            position: suborbitPosition,
            type: subbody.type,
            rotation: this.floatToInterval(rng.next(), 0, 360),
            rotationSpeed: this.floatToInterval(rng.next(), 10, 40),
            size: this.bodySpecs
              .filter((b) => b.type === subbody.type)
              .map((b) => this.takeRandomFromFloat(b.size, rng.next()))
              .shift(),
            color: this.bodySpecs
              .filter((b) => b.type === subbody.type)
              .map((b) => this.takeRandomFromFloat(b.colors, rng.next()))
              .shift(),
          });
        }

        bodies.push({
          id: body.id,
          key: `b1-${i + 1}`,
          position: orbitPosition,
          type: body.type,
          rotation: this.floatToInterval(rng.next(), 0, 360),
          rotationSpeed: this.floatToInterval(rng.next(), 100, 500),
          size: bodySize,
          color: bodyColor,
          subbodies,
        });
      }

      return {
        star: {
          color: starSpecs.colors[this.floatToInterval(rng.next(), 0, starSpecs.colors.length - 1)],
          size: this.floatToInterval(rng.next(), this.starSize[0], this.starSize[1])
            * this.systemData.display_size_factor,
        },
        bodies,
      };
    },
  },
  methods: {
    clickOrbit(bodies) {
      if (this.system.contact.value >= 3) {
        this.$emit('clickOrbit', bodies);
      }
    },
    closeProduction() {
      this.$store.commit('game/clearProduction');
    },
    isOrbitHovered(orbitId) {
      return orbitId === this.hoveredOrbit;
    },
    floatToInterval(x, min, max) {
      return Math.round((x * (max - min)) + min);
    },
    takeRandomFromFloat(arr, x) {
      return arr[this.floatToInterval(x, 0, arr.length - 1)];
    },
    toPercentage(x) {
      return (x * (this.orbitBoundary.max - this.orbitBoundary.min) + this.orbitBoundary.min) / 100;
    },
    changeRotationSpace(x) {
      return (x * (270 / 360)) - 45;
    },
    darken(color) {
      return Color(color)
        .brighten(-25)
        .toString();
    },
    lighten(color) {
      return Color(color)
        .brighten(25)
        .toString();
    },
  },
  mounted() {
    const rng = new Prando(this.system.id);
    let duration = 0.5;

    const {
      circleMask,
      svgBackground,
    } = this.$refs;

    TweenMax.to(circleMask, 0.5, {
      attr: { r: '50%' },
      ease: Sine.easeOut,
    });

    TweenMax.to(svgBackground, 0.5, {
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      opacity: 1,
      ease: Sine.easeOut,
    });

    if (this.stellarBodies.bodies) {
      this.stellarBodies.bodies.forEach((body) => {
        duration = (this.floatToInterval(rng.next(), 1, 5) / 10) + 0.3;

        TweenMax.to(this.$refs[body.key], duration, {
          rotation: '-360',
          transformOrigin: '50% 50%',
          ease: Sine.easeOut,
        });
      });
    }
  },
};
</script>
