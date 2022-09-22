import Block from './block';

export default class Sample extends Block {
  constructor(map) {
    super(map, 'Sample');
  }

  _create(_data) {
  }

  _update() {
    this.log('updating Sample');
  }

  onZ(_z) {
  }
}
