import _remove from 'lodash/remove';

export default {
  fromList(list) {
    const hashTable = Object.create(null);
    list.forEach((item) => {
      hashTable[item.key] = { ...item, children: [] };
    });

    const dataTree = [];
    list.forEach((item) => {
      if (item.ancestor) {
        hashTable[item.ancestor].children.push(hashTable[item.key]);
      } else {
        dataTree.push(hashTable[item.key]);
      }
    });

    return dataTree;
  },
  toGrid(item, grid = [], depth = 0, line = 3) {
    let lines;
    const rows = grid[depth] === undefined
      ? Array.from(Array(7))
      : grid[depth];

    rows[line] = item;
    grid[depth] = rows;

    switch (item.children.length) {
      case 1: lines = [line]; break;
      case 2: lines = [line - 1, line + 1]; break;
      case 3: lines = [line - 1, line, line + 1]; break;
      default: lines = [];
    }

    lines.forEach((l, i) => {
      grid = this.toGrid(item.children[i], grid, depth + 1, l);
    });

    return grid;
  },
  trimGrid(grid) {
    const emptyLines = [0, 1, 5, 6].reduce((acc, i) => {
      if (grid.every((el) => el[i] === undefined)) {
        acc.push(i);
      }

      return acc;
    }, []);

    const lineToRemove = emptyLines.length > 1
      ? [emptyLines[emptyLines.length - 1], emptyLines[0]]
      : [emptyLines[0]];

    lineToRemove.forEach((i) => {
      grid.forEach((el) => {
        _remove(el, ((val, index) => index === i)); // eslint-disable-line
      });
    });

    return grid;
  },
};
