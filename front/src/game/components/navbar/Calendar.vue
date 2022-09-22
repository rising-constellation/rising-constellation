<template>
  <div class="navbar-calendar navbar-central-box">
    <div class="date">
      <div class="day">
        {{ date.day + 1 }}
      </div>
      <div class="month">
        {{
          $t(`data.calendar.${calendar.key}.months_prefix[${date.month % 6}]`)
        }}{{
          $t(`data.calendar.${calendar.key}.months_name[${Math.floor(date.month / 6)}]`)
        }}
      </div>
      <div class="year">
        {{ date.year }}
      </div>
    </div>
  </div>
</template>

<script>
import Calendar from '@/utils/calendar';
import TimeMixin from '@/game/mixins/TimeMixin';

export default {
  name: 'calendar',
  mixins: [TimeMixin],
  data() {
    return {
      now: 0,
    };
  },
  computed: {
    calendar() {
      return this.$store.state.game.data.calendar.find((i) => i.key === 'tetrarch');
    },
    date() {
      return Calendar.fromUtDays(this.calendar, this.now);
    },
  },
  watch: {
    time(value) {
      this.now = value.now.value;
    },
  },
  methods: {
    updateValue(factor) {
      this.now += (this.time.now.change * factor);
    },
  },
  mounted() {
    this.now = this.time.now.value;
  },
};
</script>
