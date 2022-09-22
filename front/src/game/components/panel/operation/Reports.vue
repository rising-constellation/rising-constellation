<template>
  <div class="panel-content is-medium">
    <v-scrollbar class="has-padding">
      <template v-if="!current">
        <div
          class="pcb-report"
          v-for="(report, i) in reports"
          :key="`report-${i}`"
          :class="{ 'active': current && current.id === report.id }"
          @click="toggleReport(report)">
          <div class="icon">
            <svgicon :name="`action/${report.type}`" />
          </div>
          <div class="title">
            <strong>{{ formatName(report) }}</strong>
            {{ $t(`report.${report.metadata.result}`) }}
          </div>
        </div>
      </template>
      <div
        class="report"
        v-else>
        <div class="report-toolbox">
          <div
            class="button"
            @click="current = null">
            <div>{{ $t('panel.operations.return') }}</div>
          </div>
          <div
            class="button"
            @click="deleteReport(current.id)">
            <div>{{ $t('panel.operations.delete') }}</div>
          </div>
        </div>
        <fight-report
          v-if="current.type === 'fight'"
          :report="current.report" />
      </div>
    </v-scrollbar>
  </div>
</template>

<script>
import FightReport from '@/game/components/panel/operation/report/FightReport.vue';

export default {
  name: 'operation-reports-panel',
  props: {
    initial: {
      type: Number,
      default: 0,
    },
  },
  data() {
    return {
      reports: [],
      current: null,
    };
  },
  methods: {
    loadReports() {
      this.$socket.player
        .push('get_reports', {})
        .receive('ok', (response) => {
          this.reports = response.reports.map((report) => {
            report.metadata = this.parseMetadata(report.metadata);
            return report;
          });

          if (this.initial !== 0) {
            const report = this.reports.find((r) => r.id === this.initial);
            this.toggleReport(report);
          }
        })
        .receive('error', (data) => {
          this.$toastError(data.reason);
        });
    },
    toggleReport(report) {
      this.current = this.current !== null && this.current.id === report.id
        ? null : report;
    },
    deleteReport(reportId) {
      this.$socket.player
        .push('hide_report', { report_id: reportId })
        .receive('ok', () => {
          this.current = null;
          this.loadReports();
        })
        .receive('error', (data) => {
          this.$toastError(data.reason);
        });
    },
    parseMetadata(metadata) {
      try {
        return JSON.parse(metadata);
      } catch (error) {
        this.$toastError(error);
      }

      return {};
    },
    formatName(report) {
      if (report.type === 'fight') {
        const { scale } = report.metadata;
        let scaleName = 'fight_scale_xsmall';

        if (scale > 2000) { scaleName = 'fight_scale_xxbig'; }
        if (scale > 1000) { scaleName = 'fight_scale_xbig'; }
        if (scale > 600) { scaleName = 'fight_scale_big'; }
        if (scale > 300) { scaleName = 'fight_scale_medium'; }
        if (scale > 100) { scaleName = 'fight_scale_small'; }

        return this.$t(`report.${scaleName}`, { name: report.metadata.system });
      }

      const { status } = report.metadata;
      return this.$t(`report.${report.type}_${status}`, { name: report.metadata.system });
    },
  },
  mounted() {
    this.loadReports();
  },
  components: {
    FightReport,
  },
};
</script>
