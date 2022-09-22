const datetimeToUtDays = (datetime, time, utFactor) => {
  const timestamp = new Date(datetime).getTime();
  const delta = (Date.now() - timestamp) / 1000 * utFactor;
  const nowDelta = (Date.now() - time.receivedAt) / 1000 * utFactor;
  const correctedUtNow = time.now.value + (time.now.change * nowDelta);

  return correctedUtNow - delta;
};

const fromUtDays = (calendar, utDays) => {
  let rest = utDays;

  const year = Math.floor(utDays / calendar.days_in_month / calendar.months_in_year);
  rest -= year * calendar.days_in_month * calendar.months_in_year;
  const month = Math.floor(rest / calendar.days_in_month);
  rest -= month * calendar.days_in_month;
  const day = Math.floor(rest);

  return { year, month, day };
};

export default {
  datetimeToUtDays,
  fromUtDays,
};
