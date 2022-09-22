export default {
  upgradeBuildingStatus(tile, body, patents, buildingData) {
    if (!buildingData) {
      return false;
    }

    if (tile.building_key === null
      || tile.construction_status === 'new'
      || tile.construction_status === 'upgrade') {
      return false;
    }

    const nextLevel = tile.building_level + 1;
    if (nextLevel > buildingData.levels.length) {
      return false;
    }

    const { patent } = buildingData.levels[nextLevel - 1];
    if (patent !== null && patents.find((p) => p === patent) === undefined) {
      return false;
    }

    if (body.type !== 'asteroid' && body.type !== 'moon'
      && tile.id !== 1 && nextLevel > body.tiles[0].building_level) {
      return false;
    }

    return true;
  },
  isBuildable(tile, body, { playerPatents, bodiesData, buildingsData }) {
    const bodyData = bodiesData.find((b) => b.key === body.type);

    if (tile && tile.building_status === 'empty') {
      if (bodyData.biome === 'orbital') {
        const patents = buildingsData
          .filter((b) => b.biome === bodyData.biome)
          .reduce((acc, b) => acc.add(b.levels[0].patent), new Set());
        return Array.from(patents).filter((p) => playerPatents.some((p2) => p2 === p)).length > 0;
      }

      if (tile.id === 1) {
        const patents = buildingsData
          .filter((b) => b.biome === bodyData.biome && b.type === 'infrastructure')
          .reduce((acc, b) => acc.add(b.levels[0].patent), new Set());
        return Array.from(patents).filter((p) => playerPatents.some((p2) => p2 === p)).length > 0;
      }

      return body.tiles[0].building_status !== 'empty';
    }

    return false;
  },
  findEmptyTile(bodies, bodyUId, tileId, intial, data, root = true) {
    let firstTry = bodies.reduce((acc, body) => {
      if (!acc.found && (acc.lookingNext || body.uid === bodyUId)) {
        const tile = acc.lookingNext
          ? body.tiles.find((t) => t.building_key === null)
          : body.tiles.find((t) => t.building_key === null && t.id > tileId);

        if (tile && this.isBuildable(tile, body, data)) {
          return { body, tile, found: true, lookingNext: acc.lookingNext };
        }

        acc.lookingNext = true;
      }

      return this.findEmptyTile(body.bodies, bodyUId, tileId, acc, data, false);
    }, intial);

    if (root && !firstTry.found) {
      intial.lookingNext = true;
      const secondTry = this.findEmptyTile(bodies, '1', 0, intial, data, false);

      if (secondTry.found && secondTry.body.uid !== bodyUId && secondTry.tile.id !== tileId) {
        firstTry = secondTry;
      }
    }

    return firstTry;
  },
};
