export default {
  colonization(actions, { vm, system, sectors, selectedCharacter }, hasSystemSlot) {
    let reasons = [];
    let status = 'available';

    if (system.siege) { reasons.push('fail_hint_siege'); }
    if (!hasSystemSlot) { reasons.push('fail_hint_system_limit'); }
    if (!this.hasCharacterColonizationShip(selectedCharacter)) { reasons.push('fail_hint_no_transport'); }
    if (!this.isSystemTakeable(selectedCharacter, system, sectors)) { reasons.push('fail_hint_untakeable'); }
    if (this.hasSameActionOnSamePlace(selectedCharacter, system, 'colonization')) {
      reasons.push('fail_already_one_colonization');
    }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_colonization', reasons, vm);
    }

    actions.push({ status, icon: 'colonization', name: 'colonize', reasons });
    return actions;
  },
  conquest(actions, { vm, system, sectors, selectedCharacter, themes }, hasSystemSlot) {
    const defense = system.defense ? system.defense.value : null;
    let reasons = [];
    let status = 'available';
    const overview = {
      attacker: selectedCharacter.army.invasion_coef.value,
      attackerIcon: 'ship/invasion',
      attackerModifier: selectedCharacter.level,
      attackerTheme: themes.character,
      defender: defense,
      defenderIcon: 'resource/defense',
      defenderTheme: themes.system,
    };

    if (selectedCharacter.army.invasion_coef.value === 0) { reasons.push('fail_hint_invasion_coef'); }
    if (!this.hasCharacterShip(selectedCharacter)) { reasons.push('fail_hint_no_ship'); }
    if (!this.isSystemTakeable(selectedCharacter, system, sectors)) { reasons.push('fail_hint_untakeable'); }
    if (system.siege) { reasons.push('fail_hint_siege'); }
    if (!hasSystemSlot) { reasons.push('fail_hint_system_limit'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_conquest', reasons, vm);
    }

    actions.push({ status, icon: 'conquest', name: 'conquer', reasons, overview });
    return actions;
  },
  raid(actions, { vm, system, selectedCharacter }, overview) {
    let reasons = [];
    let status = 'available';

    if (selectedCharacter.army.raid_coef.value === 0) { reasons.push('fail_hint_raid_coef'); }
    if (!this.hasCharacterShip(selectedCharacter)) { reasons.push('fail_hint_no_ship'); }
    if (system.siege) { reasons.push('fail_hint_siege'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_raid', reasons, vm);
    }

    actions.push({ status, icon: 'raid', name: 'raid', reasons, overview });
    return actions;
  },
  loot(actions, { vm, system, selectedCharacter }, overview) {
    let reasons = [];
    let status = 'available';

    if (selectedCharacter.army.raid_coef.value === 0) { reasons.push('fail_hint_raid_coef'); }
    if (!this.hasCharacterShip(selectedCharacter)) { reasons.push('fail_hint_no_ship'); }
    if (system.siege) { reasons.push('fail_hint_siege'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_loot', reasons, vm);
    }

    actions.push({ status, icon: 'loot', name: 'loot', reasons, overview });
    return actions;
  },
  infiltrate(actions, { system, selectedCharacter, themes }) {
    const ci = system.counter_intelligence ? system.counter_intelligence.value : null;

    const overview = {
      attacker: selectedCharacter.spy.infiltrate_coef.value,
      attackerIcon: 'action/infiltrate_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: themes.character,
      defender: ci,
      defenderIcon: 'resource/counter_intelligence',
      defenderTheme: themes.system,
    };

    actions.push({ status: 'available', icon: 'infiltrate', name: 'infiltrate', reasons: '', overview });
    return actions;
  },
  encourageHate(actions, { vm, system, selectedCharacter, themes }) {
    let reasons = [];
    let status = 'available';

    const happiness = system.happiness ? Math.max(system.happiness.value, 0) : null;

    if (selectedCharacter.speaker.cooldown.value !== 0) { reasons.push('fail_hint_speaker_cooldown'); }
    if (selectedCharacter.speaker.encourage_hate_coef.value === 0) { reasons.push('fail_hint_encourage_hate_coef'); }
    if (this.hasSameAction(selectedCharacter, 'encourage_hate')) { reasons.push('fail_hint_max_one_action'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_encourage_hate', reasons, vm);
    }

    const overview = {
      attacker: selectedCharacter.speaker.encourage_hate_coef.value,
      attackerIcon: 'action/encourage_hate_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: themes.character,
      defender: happiness,
      defenderIcon: 'resource/happiness',
      defenderTheme: themes.system,
    };

    actions.push({ status, icon: 'encourage_hate', name: 'encourage_hate', reasons, overview });
    return actions;
  },
  makeDominion(actions, { vm, system, sectors, selectedCharacter, themes }, hasDominionSlot) {
    let reasons = [];
    let status = 'available';

    const happiness = system.happiness ? Math.max(system.happiness.value, 0) : null;

    if (selectedCharacter.speaker.cooldown.value !== 0) { reasons.push('fail_hint_speaker_cooldown'); }
    if (!hasDominionSlot) { reasons.push('fail_hint_dominion_limit'); }
    if (!this.isSystemTakeable(selectedCharacter, system, sectors)) { reasons.push('fail_hint_untakeable'); }
    if (selectedCharacter.speaker.make_dominion_coef.value === 0) { reasons.push('fail_hint_make_dominion_coef'); }
    if (this.hasSameAction(selectedCharacter, 'make_dominion')) { reasons.push('fail_hint_max_one_action'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_make_dominion', reasons, vm);
    }

    const overview = {
      attacker: selectedCharacter.speaker.make_dominion_coef.value,
      attackerIcon: 'action/make_dominion_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: themes.character,
      defender: happiness,
      defenderIcon: 'resource/happiness',
      defenderTheme: themes.system,
    };

    actions.push({ status, icon: 'make_dominion', name: 'make_dominion', reasons, overview });
    return actions;
  },
  fight(actions, { vm }) {
    const reasons = [];
    const status = 'available';
    const tooltip = vm.$t('galaxy.system.actions.fight');

    actions.actions.push({ status, icon: 'fight', name: 'fight', tooltip, reasons });
    return actions;
  },
  sabotage(actions, { vm, selectedCharacter, system, characterTheme }, character, targetTheme) {
    let defense = null;

    if (character.protection && system.counter_intelligence) {
      const protection = character.protection || 0;
      const ci = system.counter_intelligence?.value || 0;

      defense = system.owner?.faction_id === character.owner.faction_id
        ? protection + ci : protection;
    }

    const tooltip = vm.$t('galaxy.system.actions.sabotage');

    let reasons = [];
    let status = 'available';

    const overview = {
      attacker: selectedCharacter.spy.sabotage_coef.value,
      attackerIcon: 'action/sabotage_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: characterTheme,
      defender: defense,
      defenderIcon: 'agent/protection',
      defenderTheme: targetTheme,
    };

    if (selectedCharacter.spy.sabotage_coef.value === 0) { reasons.push('fail_hint_sabotage_coeff'); }
    if (this.hasSameAction(selectedCharacter, 'sabotage')) { reasons.push('fail_hint_max_one_action'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_sabotage', reasons, vm);
    }

    actions.actions.push({ status, icon: 'sabotage', name: 'sabotage', tooltip, reasons, overview });
    return actions;
  },
  assassination(actions, { vm, selectedCharacter, system, characterTheme }, character, targetTheme) {
    let defense = null;

    if (character.protection && system.counter_intelligence) {
      const protection = character.protection || 0;
      const ci = system.counter_intelligence?.value || 0;

      defense = system.owner?.faction_id === character.owner.faction_id
        ? protection + ci : protection;
    }

    const tooltip = vm.$t('galaxy.system.actions.assassination');

    let reasons = [];
    let status = 'available';

    const overview = {
      attacker: selectedCharacter.spy.assassination_coef.value,
      attackerIcon: 'action/assassination_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: characterTheme,
      defender: defense,
      defenderIcon: 'agent/protection',
      defenderTheme: targetTheme,
    };

    if (selectedCharacter.spy.assassination_coef.value === 0) { reasons.push('fail_hint_assassination_coeff'); }
    if (this.hasSameAction(selectedCharacter, 'assassination')) { reasons.push('fail_hint_max_one_action'); }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_assassination', reasons, vm);
    }

    actions.actions.push({ status, icon: 'assassination', name: 'assassination', tooltip, reasons, overview });
    return actions;
  },
  conversion(actions, { vm, selectedCharacter, system, characterTheme }, character, player, targetTheme) {
    let defense = null;

    if (character.determination && system.happiness) {
      const determination = character.determination || 0;
      const happiness = system.happiness?.value || 0;

      defense = system.owner?.faction_id === character.owner.faction_id
        ? determination + happiness : determination;
    }

    const tooltip = vm.$t('galaxy.system.actions.conversion');

    let reasons = [];
    let status = 'available';

    const overview = {
      attacker: selectedCharacter.speaker.conversion_coef.value,
      attackerIcon: 'action/conversion_alt',
      attackerModifier: selectedCharacter.level,
      attackerTheme: characterTheme,
      defender: defense,
      defenderIcon: 'agent/determination',
      defenderTheme: targetTheme,
    };

    if (selectedCharacter.speaker.conversion_coef.value === 0) { reasons.push('fail_hint_conversion_coeff'); }
    if (selectedCharacter.speaker.cooldown.value !== 0) { reasons.push('fail_hint_speaker_cooldown'); }
    if (this.hasSameAction(selectedCharacter, 'conversion')) { reasons.push('fail_hint_max_one_action'); }

    if (character.type === 'admiral'
      && player.characters.filter((c) => c.type === 'admiral').length >= player.max_admirals.value) {
      reasons.push('fail_hint_conversion_admiral');
    }

    if (character.type === 'spy'
      && player.characters.filter((c) => c.type === 'spy').length >= player.max_spies.value) {
      reasons.push('fail_hint_conversion_spy');
    }

    if (character.type === 'speaker'
      && player.characters.filter((c) => c.type === 'speaker').length >= player.max_speakers.value) {
      reasons.push('fail_hint_conversion_speaker');
    }

    if (reasons.length > 0) {
      status = 'unavailable';
      reasons = this.formatReasons('fail_hint_conversion', reasons, vm);
    }

    actions.actions.push({ status, icon: 'conversion', name: 'conversion', tooltip, reasons, overview });
    return actions;
  },
  hasCharacterColonizationShip(character) {
    if (character.army && Array.isArray(character.army.tiles)) {
      return character.army.tiles.find((tile) => tile.ship && tile.ship.key === 'transport_1');
    }

    return false;
  },
  hasCharacterShip(character) {
    if (character.army && Array.isArray(character.army.tiles)) {
      return character.army.tiles.find((tile) => tile.ship_status === 'filled');
    }

    return false;
  },
  hasSameAction(character, action) {
    return character.actions.queue.find((q) => q.type === action);
  },
  hasSameActionOnSamePlace(character, system, action) {
    return character.actions.queue.find((q) => q.type === action && q.data.target === system.id);
  },
  isSystemTakeable(character, system, sectors) {
    const currentSector = sectors.find((s) => s.id === system.sector_id);
    const adjacentOwnSectors = sectors
      .filter((s) => s.adjacent.includes(currentSector.id) && s.owner === character.owner.faction);

    return currentSector.owner === character.owner.faction || adjacentOwnSectors.length > 0;
  },
  formatReasons(title, reasons, vm) {
    return vm.$t(`galaxy.system.actions.${title}`) + '<br>'
      + reasons.map((r) => '— ' + vm.$t(`galaxy.system.actions.${r}`)).join('<br>');
  },
};
