import config from '@/config';

export async function maintenanceCheck() {
  try {
    const maintenance = await fetch(config.BASE_URL + '/api/maintenance').then((response) => response.json());
    return maintenance === true;
  } catch (_err) {
    //
  }
  return false;
}

export async function versionCheck() {
  try {
    const { data: { version } } = await fetch(config.BASE_URL + '/api/version').then((response) => response.json());
    if (version === 'dev') {
      return true;
    }
    let [major, minor, patch] = version.split('.');
    const backendVersion = { major, minor, patch };
    // eslint-disable-next-line no-undef
    [major, minor, patch] = __localVersion.split('.');
    const clientVersion = { major, minor, patch };
    const needsUpgrade = backendVersion.major > clientVersion.major
      || (backendVersion.major === clientVersion.major && backendVersion.minor > clientVersion.minor);
    return !needsUpgrade;
  } catch (_err) {
    //
  }
  return true;
}

export async function connectivityCheck() {
  try {
    await fetch('https://dns.google/resolve?name=steampowered.com');
    return true;
  } catch (err) {
    //
  }
  return false;
}
