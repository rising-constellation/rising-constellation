function shadeColor(color, percent) {
  let R = parseInt(color.substring(1, 3), 16);
  let G = parseInt(color.substring(3, 5), 16);
  let B = parseInt(color.substring(5, 7), 16);

  R = parseInt((R * (100 + percent)) / 100, 10);
  G = parseInt((G * (100 + percent)) / 100, 10);
  B = parseInt((B * (100 + percent)) / 100, 10);

  R = (R < 255) ? R : 255;
  G = (G < 255) ? G : 255;
  B = (B < 255) ? B : 255;

  const RR = ((R.toString(16).length === 1) ? '0' + R.toString(16) : R.toString(16));
  const GG = ((G.toString(16).length === 1) ? '0' + G.toString(16) : G.toString(16));
  const BB = ((B.toString(16).length === 1) ? '0' + B.toString(16) : B.toString(16));

  return '#' + RR + GG + BB;
}

const COLORS = [
  '#2364aa',
  '#73bfb8',
  '#aec3b0',
  '#fec601',
  '#ea7317',
  '#01161e',
  '#3da5d9',
  '#124559',
  '#598392',
  '#eff6e0',
];

export default function hook(stats) {
  // eslint-disable-next-line global-require
  const Chart = require('chart.js');

  const ctx = this.el.getContext('2d');
  if (!stats) {
    return;
  }

  const dates = Object.values(stats)[0].dates.map((date) => new Date(date));
  const datasets = [];

  Object.values(stats).forEach(({
    name, credit, technology, ideology,
  }, i) => {
    datasets.push({
      type: 'line',
      label: `${name} - credit`,
      data: credit,
      color: COLORS[i],
      backgroundColor: COLORS[i],
      fill: false,
    });
    datasets.push({
      type: 'line',
      label: `${name} - technology`,
      data: technology,
      color: shadeColor(COLORS[i], -30),
      backgroundColor: shadeColor(COLORS[i], -30),
      fill: false,
    });
    datasets.push({
      type: 'line',
      label: `${name} - ideology`,
      data: ideology,
      color: shadeColor(COLORS[i], 30),
      backgroundColor: shadeColor(COLORS[i], 30),
      fill: false,
    });
  });

  if (window.statsChart) {
    window.statsChart.destroy();
  }
  window.statsChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: dates,
      datasets,
    },
    options: {
      scales: {
        xAxes: [{
          type: 'time',
          time: {
            displayFormats: {
              minute: 'MMM DD HH:mm:ss',
              hour: 'MMM DD HH:mm:ss',
              day: 'MMM DD HH:mm:ss',
              week: 'MMM DD HH:mm:ss',
              month: 'MMM DD HH:mm:ss',
              quarter: 'MMM DD HH:mm:ss',
              year: 'MMM DD HH:mm:ss',
            },
          },
        }],
        yAxes: [{
          ticks: {
            beginAtZero: true,
          },
        }],
      },
      elements: {
        point: {
          radius: 2,
          hitRadius: 4,
        },
      },
    },
  });
}
