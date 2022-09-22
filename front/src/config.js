// General configurations

// env constant
const mode = process.env.NODE_ENV;
const baseUrl = mode === 'production'
  ? `${process.env.VUE_APP_BASE_URL}`
  : 'http://localhost:4000';

let wsUrl = 'ws://localhost:4000/socket';
if (mode === 'production') {
  const url = new URL(baseUrl);
  const protocol = url.protocol.startsWith('https') ? 'wss' : 'ws';
  wsUrl = `${protocol}://${url.host}/socket`;
}

export default {
  IS_STEAM: false,
  MODE: mode,
  BASE_URL: baseUrl,
  WEBSOCKET: {
    URL: wsUrl,
  },
  POLLING: {
    SHORT: 5000,
    LONG: 15000,
  },
  TIME: {
    REFRESH_RATE: 8,
    UNIT_TIME_DIVIDER: 180,
  },
  MAP: {
    Z_DEFAULT: 70,

    Z_FLOOR: -0.2,

    Z_SECTOR_NEAR: -0.1,
    Z_RADAR_NEAR: -0.1,
    Z_BLACKHOLE: 0,
    Z_CHARACTER_NEAR_LINE: 0,
    Z_SYSTEM_NEAR_HOVER: 0,
    Z_SYSTEM_NEAR_OWN: 0.1,
    Z_SYSTEM_NEAR_STAR: 0.2,
    Z_SYSTEM_NEAR_LABEL: 0.3,
    Z_CHARACTER_NEAR_SPRITE: 0.3,
    Z_CHARACTER_NEAR_LABEL: 0.3,

    Z_SECTOR_FAR: 0,
    Z_SYSTEM_FAR_OWN: 0.025,
    Z_SECTOR_FAR_LABEL: 0.05,
    Z_SYSTEM_FAR_STAR: 0.05,
  },
};
