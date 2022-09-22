import { escape } from '@/plugins/filters';
import marked from 'marked';

// eslint-disable-next-line import/prefer-default-export
export function renderMd(md) {
  return marked(escape(md));
}
