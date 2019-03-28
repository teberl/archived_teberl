import 'phoenix_html';

import socket from './socket';
import liveSocket from './live_view';

import lazySizes from 'lazysizes';
lazySizes.init();

import css from '../css/app.scss';

const baseUrl = location.origin;

console.info('%cHey there, good to see you!', 'font-weight: bold;');
console.info('Navigation:');
console.info(`• ${baseUrl}/todos → A phoenix_live_view TodoMVC example ${'\n'}
• ${baseUrl}/counter → The legendary phoenix_live_view Counter${'\n'}
• ${baseUrl}/heartbeat → My first route and websocket playground with phoenix${'\n'}`);
