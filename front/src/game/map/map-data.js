import stableStringify from 'json-stable-stringify';
import store from '@/store';

async function hashObject(obj) {
  const data = new TextEncoder().encode(stableStringify(obj));
  const hashBuffer = await window.crypto.subtle.digest('SHA-1', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
  return hashHex;
}

export default class MapData {
  constructor() {
    this.systems = [];
    this.systemsToRepaint = new Set([]);

    this.blackholes = [];

    this.sectors = [];
    this.sectorHash = '';
    this.hasToRepaintSectors = false;

    this.radars = [];
    this.radarsHash = '';
    this.hasToRepaintRadars = false;

    this.detectedObjects = [];
    this.hasToRepaintDetectedObjects = false;
  }

  update(data) {
    if (data.global_galaxy) {
      this.createSystem(data.global_galaxy.stellar_systems);
      this.updateSectors(data.global_galaxy.sectors);
      this.blackholes = data.global_galaxy.blackholes;
    }

    if (data.global_galaxy_system) {
      this.updateSystems([data.global_galaxy_system], {});
    }

    if (data.faction_faction) {
      this.updateSystems([], data.faction_faction.contacts);
      this.updateRadars(data.faction_faction.radars);
    }

    if (data.detected_objects) {
      this.updateDetectedObjects(data.detected_objects);
    }

    if (data.faction_faction_contact) {
      const formatedContact = {
        [data.faction_faction_contact.system_id]: data.faction_faction_contact.contact,
      };

      this.updateSystems([], formatedContact);
    }

    if (data.global_galaxy_sector) {
      this.updateSectors(data.global_galaxy_sector);
    }
  }

  createSystem(systems) {
    this.systems = systems.map((system) => ({ ...system, ...{ visibility: 0 } }));
    this.systemsToRepaint = new Set(systems.map((system) => system.id));
  }

  updateSystems(systems, contacts) {
    const ownFaction = store.state.game.player.faction;

    this.systems = this.systems.map((s) => {
      let system = systems.find((s2) => s.id === s2.id);

      // merge new version with old one if found
      if (system) {
        system = { ...s, ...system };
      } else {
        system = { ...s };
      }

      // update systems contacts if found
      if (contacts[system.id]) {
        system.visibility = contacts[system.id].value;
      }

      // override visibility for own systems
      if (system.faction === ownFaction) {
        system.visibility = 5;
      }

      if (JSON.stringify(system) !== JSON.stringify(s)) {
        this.systemsToRepaint.add(system.id);
      }

      return system;
    });
  }

  updateSectors(sectors) {
    hashObject(sectors).then((hash) => {
      if (hash !== this.sectorHash) {
        this.sectors = sectors;
        this.hasToRepaintSectors = true;
      }
    });
  }

  updateRadars(radars) {
    hashObject(radars).then((hash) => {
      if (hash !== this.radarsHash) {
        this.radars = radars;
        this.hasToRepaintRadars = true;
      }
    });
  }

  forceRedrawRadars() {
    this.hasToRepaintRadars = true;
  }

  updateDetectedObjects(detectedObjects) {
    const ownCharactersId = (store.state.game.player.characters || []).map((c) => c.id);
    this.detectedObjects = detectedObjects.filter((obj) => !ownCharactersId.includes(obj.character_id));
    this.hasToRepaintDetectedObjects = true;
  }
}
