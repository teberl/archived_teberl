import 'phoenix_html';

import socket from './socket';
import liveSocket from './live_view';

import lazySizes from 'lazysizes';
lazySizes.init();

import css from '../css/app.scss';

console.info('%cHey there, good to see you!', 'font-weight: bold;');
console.info('Navigation:');
console.info(`• https://teberl.de/todos → A phoenix_live_view TodoMVC example ${'\n'}
• https://teberl.de/counter → The legendary phoenix_live_view Counter${'\n'}
• https://teberl.de/heartbeat → My first route and websocket playground with phoenix${'\n'}`);
