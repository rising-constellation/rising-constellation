<template>
  <div class="resource-detail">
    <div class="label-value main">
      <span>
        <span
          class="info"
          v-if="description"
          v-tooltip="description">
          ?
        </span>
        {{ title }}
      </span>
      <span v-if="value !== undefined">
        {{ value | float(precision) }}
      </span>
    </div>

    <template v-if="Array.isArray(details)">
      <div
        v-for="(detail, i) in details"
        :key="i"
        :class="{ 'active': detail.active }"
        class="label-value">
        <template v-if="detail === 'separator'">
          <hr />
        </template>
        <template v-else>
          <span>
            {{ detail.reason }}
          </span>
          <span v-if="Number.isInteger(detail.value)">
            {{ detail.value | float(precision) }}
          </span>
          <span v-else>
            {{ detail.value }}
          </span>
        </template>
      </div>

      <div
        class="label-value"
        v-if="Object.keys(details).length === 0">
        <span>{{ $t('resource-detail.unknown_detail') }}</span>
        <span>░░</span>
      </div>
    </template>

    <template v-else>
      <div
        v-for="(values, type) in objectDetails"
        :key="type">
        <div class="label-value-subtitle">
          {{ $t(`resource-detail.type.${type}`) }}
        </div>
        <div
          v-for="(detail, i) in values"
          :key="i"
          :class="{ 'active': detail.active }"
          class="label-value">
          <span>
            <template v-if="type === 'building'">
              {{ $t(`data.building.${detail.reason}.name`) }}
            </template>
            <template v-else-if="type === 'misc'">
              {{ $t(`resource-detail.misc.${detail.reason}`) }}
            </template>
            <template v-else-if="type === 'happiness_penalties'">
              {{ $t(`resource-detail.happiness_penalties.${detail.reason}`) }}
            </template>
            <template v-else-if="type === 'doctrine'">
              {{ $t(`data.doctrine.${detail.reason}.name`) }}
            </template>
            <template v-else-if="type === 'tradition'">
              {{ $t(`data.tradition.${detail.reason}.name`) }}
            </template>
            <template v-else-if="type === 'ship'">
              {{ $t(`data.ship.${detail.reason}.name`) }}
            </template>
            <template v-else>{{ detail.reason }}</template>
          </span>
          <span>
            {{ detail.value | float(precision) }}
          </span>
        </div>
      </div>

      <div
        class="label-value"
        v-if="Object.keys(details).length === 0">
        —
      </div>
    </template>

    <template v-if="minimum && minimum.length > 0">
      <div class="label-value-subtitle">
        {{ $t('resource-detail.minimum.title') }}
      </div>
      <div class="label-value">
        <span>{{ $t(`resource-detail.minimum.${minimum[0].reason}`) }}</span>
        <span>{{ $t(`resource-detail.minimum.min`, [minimum[0].value]) }}</span>
      </div>
    </template>
  </div>
</template>

<script>
export default {
  name: 'resource-detail',
  props: {
    title: String,
    value: Number,
    details: [Object, Array],
    minimum: {
      type: Array,
      required: false,
    },
    precision: {
      type: Number,
      default: 1,
    },
    description: {
      type: String,
      default: undefined,
    },
  },
  computed: {
    objectDetails() {
      if (!Array.isArray(this.details)) {
        const d = this.details;

        Object.keys(d).forEach((key) => {
          d[key] = d[key].filter((o) => o.value !== 0);

          if (d[key].length === 0) {
            delete d[key];
          }
        });

        return d;
      }

      return undefined;
    },
  },
};
</script>
