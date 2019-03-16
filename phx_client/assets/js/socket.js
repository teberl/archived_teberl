import { Socket } from 'phoenix';

let socket = new Socket('/socket', { params: { token: window.userToken } });

socket.connect();

let channel = socket.channel('heartbeat:listen', {});

const beats = document.getElementById('beats');

if (beats) {
  channel.on('beat', payload => {
    beats.innerHTML = payload.body;
  });
}

channel
  .join()
  .receive('ok', resp => {
    console.log('Joined successfully', resp);
  })
  .receive('error', resp => {
    console.log('Unable to join', resp);
  });

export default socket;
