<template>
  <div
    class="panel-container is-right"
    :class="theme"
    @click.self="close">
    <div class="panel-content is-small">
      <v-scrollbar
        @ps-y-reach-end="loadEvents"
        class="has-padding">
        <h1 class="panel-default-title">{{ $t('panel.event.title') }}</h1>
        <div
          v-for="(month, i) in groupedEvents"
          :key="i">
          <h2 class="event-title">
            {{
              $t(`data.calendar.${calendar.key}.months_prefix[${month[0].calendarDate.month % 6}]`)
            }}{{
              $t(`data.calendar.${calendar.key}.months_name[${Math.floor(month[0].calendarDate.month / 6)}]`)
            }} {{ month[0].calendarDate.year }}
          </h2>

          <div
            class="event-item"
            v-for="(event, j) in month"
            :key="`${i}-${j}`">
            <span class="event-day">
              <div
                class="event-day-number"
                v-if="!month[j - 1] || month[j - 1].calendarDate.day !== event.calendarDate.day">
                {{ event.calendarDate.day + 1 }}
              </div>
            </span>
            <span class="event-text">
              <span
                v-if="event.type === 'text'"
                v-html="$tmd(`notification.text.${event.key}`, event.data)"></span>
              <template v-else-if="event.type === 'box'">
                <svgicon :name="`action/${event.key}`" />
                <svgicon
                  v-show="event.data.side === 'defender'"
                  name="resource/defense" />
                <span v-html="$tmd(`notification.short_box.${event.key}`, { system: event.data.system.name })"></span>
                <template v-if="event.data.outcome">
                  <span class="event-text-outcome">
                    <template v-if="event.key === 'fight'">
                      {{ $t(`notification.box.fight.outcome.${event.data.outcome}`) }}
                    </template>
                    <template v-else>
                      {{ $t(`notification.box.outcome.${event.data.side}.${event.data.outcome}`) }}
                    </template>
                  </span>
                </template>
              </template>
              <span
                v-else-if="event.type === 'faction'"
                v-html="$t(`event.faction.${event.key}`, event.data)">
              </span>
              <span
                v-else-if="event.type === 'global'"
                v-html="$t(`event.global.${event.key}`, event.data)">
              </span>
            </span>
            <span class="event-date">{{ event.inserted_at | datetime-long }}</span>
            <div
              v-if="event.type === 'box'"
              class="box-notification-item">
              <notif-dispatcher :notification="event" />
            </div>
          </div>
        </div>
      </v-scrollbar>
    </div>

    <div class="panel-navbar">
      <button
        v-for="panel in panels"
        v-tooltip.right="$t(`panel.ranking.${panel}`)"
        :key="panel"
        :class="{ 'is-active': activePanel === panel }"
        @click="activePanel = panel">
      </button>
    </div>
  </div>
</template>

<script>
import Calendar from '@/utils/calendar';
import NotifDispatcher from '@/game/components/box-notification/NotifDispatcher.vue';

export default {
  name: 'event-panel',
  data() {
    return {
      activePanel: 'player',
      panels: ['player'],
      currentPage: 1,
      maxPage: 2,
      loading: false,
      events: [],
    };
  },
  computed: {
    theme() { return this.$store.getters['game/theme']; },
    time() { return this.$store.state.game.time; },
    speed() { return this.$store.state.game.data.speed.find((i) => i.key === this.time.speed); },
    utInSeconds() { return this.speed.factor / this.$config.TIME.UNIT_TIME_DIVIDER; },
    calendar() { return this.$store.state.game.data.calendar.find((i) => i.key === 'tetrarch'); },
    groupedEvents() { return this.groupByMonth(this.events); },
  },
  methods: {
    open(_data) {
      this.currentPage = 1;
      this.maxPage = 2;
      this.loading = false;
      this.events = [];
      this.loadEvents();
    },
    close() {
      this.loading = true;
      this.$emit('close');
    },
    loadEvents() {
      if (!this.loading && this.currentPage <= this.maxPage) {
        this.loading = true;
        this.$socket.player
          .push('get_events', { page: this.currentPage })
          .receive('ok', (data) => {
            const events = data.events.map((e) => {
              const utTime = Calendar.datetimeToUtDays(e.inserted_at, this.time, this.utInSeconds);
              const calendarDate = Calendar.fromUtDays(this.calendar, utTime);
              
              e.calendarDate = calendarDate;
              e.data = JSON.parse(e.data);

              if (e.type === 'global') {
                e.data.old_faction = e.data.old_faction ? this.$t(`data.faction.${e.data.old_faction}.name`) : '';
                e.data.new_faction = e.data.new_faction ? this.$t(`data.faction.${e.data.new_faction}.name`) : '';
              }

              return e;
            });

            this.events.push(...events);
            this.currentPage += 1;
            this.maxPage = data.total_pages;
            this.loading = false;
          })
          .receive('error', (data) => { this.$toastError(data.reason); });
      }
    },
    groupByMonth(events) {
      const grouped = events.reduce((acc, event) => {
        const month = `${event.calendarDate.month}`.padStart(2, '0');
        const key = `${event.calendarDate.year}-${month}`;
        if (!acc[key]) {
          acc[key] = [];
        }
        acc[key].push(event);
        return acc;
      }, {});

      return Object
        .keys(grouped)
        .sort((a, b) => b.localeCompare(a))
        .map((key) => grouped[key]);
    },
  },
  components: {
    NotifDispatcher,
  },
};
</script>
