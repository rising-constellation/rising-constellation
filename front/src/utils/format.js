const addSign = (value = 0, bothSign) => {
  if (bothSign && !value.startsWith('-')) {
    return `+${value}`;
  }
  return value.replace('-', '−');
};

const integer = (value = 0, bothSign = false) => addSign(
    Math.round(value).toLocaleString(),
    bothSign,
  );

const float = (value = 0, decimals = 2, bothSign = false) => addSign(
    value.toFixed(decimals).toLocaleString().replace('.', ','),
    bothSign,
  );

const obfuscate = (value = 0, number, hidden) => (value === null || value === 'hidden'
    ? hidden
    : number);

const mixed = (value = 0, decimals = 1, bothSign = false) => (Number.isInteger(value)
    ? integer(value, bothSign)
    : float(value, decimals, bothSign));

export default {
  addSign,
  integer,
  float,
  obfuscate,
  mixed,
};
