import greenworks from 'greenworks';

const isDevelopment = false;
const baseUrl = isDevelopment ? 'http://localhost:4000/api' : 'https://rising-constellation.com/api';
const backendTicketAuthEndpoint = isDevelopment ? `${baseUrl}/steam/ticket` : `${baseUrl}/steam/ticket`;
const backendUserAuthEndpoint = isDevelopment ? `${baseUrl}/auth/identity/callback` : `${baseUrl}/auth/identity/callback`;

async function getAuthSessionTicket() {
  return new Promise((resolve, reject) => greenworks.getAuthSessionTicket(resolve, reject));
}

export async function steamTicket() {
  console.log('starting auth');
  try {
    const { ticket: ticketBin, handle: _handle } = await getAuthSessionTicket();
    const ticketHex = ticketBin.toString('hex');
    console.log('auth success cb, now going to', backendTicketAuthEndpoint);

    const { steamid, result } = await (fetch(backendTicketAuthEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ticket: ticketHex }),
    }).then((res) => res.json()));

    console.log('signup result:', result);
    return { ticketHex, steamid };
  } catch (err) {
    console.log('error', 'steam auth failed');
    console.log(err.message);
    console.log(err.trace);
    throw err;
  }
}

export async function steamAuth({ ticketHex, steamid }) {
  console.log('auth');

  try {
    const { account, token } = await (fetch(backendUserAuthEndpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ticket: ticketHex, steam_id: steamid }),
    }).then((res) => res.json()));

    console.log('auth() done');
    console.log(JSON.stringify({ account, token }, null, 2));
    return { account, apiToken: token };
  } catch (err) {
    console.log(`${backendUserAuthEndpoint} failed`);
    console.log(err.message);
    console.log(err.trace);
  }
}
