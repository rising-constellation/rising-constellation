// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html';
import { Socket } from 'phoenix';
import NProgress from 'nprogress';
import Cookies from 'js-cookie';
import { LiveSocket } from 'phoenix_live_view';
import statsCharts from './stats_charts';

const Hooks = {};
const APIHeaders = {
  Accept: 'application/json',
  'Content-Type': 'application/json',
};

Hooks.login = {
  async mounted() {
    const url = new URL(window.location.href);
    const action = url.searchParams.get('action');
    const token = url.searchParams.get('token');

    if (action === 'validate-registration' && token) {
      const infoContainer = document.getElementById('info-container');
      const info = document.getElementById('info');
      try {
        await fetch('/api/accounts/validate', {
          method: 'POST',
          headers: APIHeaders,
          body: JSON.stringify({ token }),
        });

        infoContainer.style.display = 'block';
        info.innerHTML = 'Your account has been validated.';
      } catch (_err) {
        infoContainer.style.display = 'block';
        info.innerHTML = 'Account confirmation error.';
      }
    }
  },
  async updated() {
    if (this.el.dataset.validated === 'true') {
      this.el.classList.add('hidden');
      try {
        const resp = await fetch('/api/auth/identity/callback', {
          method: 'POST',
          headers: APIHeaders,
          body: JSON.stringify({
            account: {
              email: this.el.dataset.email,
              password: this.el.dataset.password,
            },
          }),
        });

        const data = await resp.json();
        Cookies.set('user_token', data.token);

        const url = new URL(window.location.href);
        url.pathname = '/portal';

        window.location.replace(url.href);
      } catch (_err) {
        // console.error(_err);
      }
    }
  },
};

Hooks.signup = {
  mounted() {
    this.el.addEventListener('submit', async (e) => {
      e.preventDefault();

      const infoContainer = document.getElementById('info-container');
      const info = document.getElementById('info');
      const button = document.getElementById('button');

      button.disabled = true;

      const email = document.getElementById('email').value;
      const name = document.getElementById('name').value;
      const password1 = document.getElementById('password1').value;
      const password2 = document.getElementById('password2').value;

      document.getElementById('email').value = '';
      document.getElementById('name').value = '';
      document.getElementById('password1').value = '';
      document.getElementById('password2').value = '';

      if (email && name && password1 && password1 === password2) {
        const password = password1;

        try {
          const resp = await fetch('/api/accounts', {
            method: 'POST',
            headers: APIHeaders,
            body: JSON.stringify({ account: { email, name, password } }),
          });

          const { message } = await resp.json();
          infoContainer.style.display = 'block';
          infoContainer.classList.add('is-success');

          if (message === 'signup_with_validation') {
            info.innerHTML = 'Your registration has been successfully completed. Please wait for an administrator to validate your account.';
          }

          if (message === 'signup_with_mail') {
            info.innerHTML = 'Your registration has been successful, a confirmation email has been sent to you.';
          }

          if (message === 'direct_registration') {
            info.innerHTML = 'Your registration has been successful. You can now log in.';
          }
        } catch (_err) {
          infoContainer.style.display = 'block';
          infoContainer.classList.add('is-error');
          info.innerHTML = 'Internal error (contact the site administrators).';
          button.disabled = false;
        }
      } else {
        infoContainer.style.display = 'block';
        infoContainer.classList.add('is-error');
        info.innerHTML = 'Please fill in all fields correctly.';
        button.disabled = false;
      }
    });
  },
};

Hooks.requestPassword = {
  mounted() {
    this.el.addEventListener('submit', async (e) => {
      e.preventDefault();

      const infoContainer = document.getElementById('info-container');
      const info = document.getElementById('info');
      const button = document.getElementById('button');

      button.disabled = true;

      const email = document.getElementById('email').value;

      if (email !== '') {
        try {
          await fetch('/api/accounts/request-password-reset', {
            method: 'POST',
            headers: APIHeaders,
            body: JSON.stringify({ email }),
          });
          // const { message } = await resp.json();

          infoContainer.style.display = 'block';
          info.innerHTML = 'A password reset link has been sent to you.';
        } catch (_err) {
          infoContainer.style.display = 'block';
          info.innerHTML = 'Error in the request.';
          button.disabled = false;
        }
      } else {
        button.disabled = false;
      }
    });
  },
};

let validateTokenPassword = null;
Hooks.validateTokenPassword = {
  mounted() {
    const url = new URL(window.location.href);
    validateTokenPassword = url.searchParams.get('token');
  },
};

Hooks.resetPassword = {
  mounted() {
    this.el.addEventListener('submit', async (e) => {
      e.preventDefault();

      const infoContainer = document.getElementById('info-container');
      const info = document.getElementById('info');
      const button = document.getElementById('button');

      button.disabled = true;

      const password = document.getElementById('password').value;

      if (password) {
        try {
          const resp = await fetch('/api/accounts/reset-password', {
            method: 'POST',
            headers: APIHeaders,
            body: JSON.stringify({ token: validateTokenPassword, new_password: password }),
          });
          if (!resp.ok) {
            throw new Error('Error');
          }
          infoContainer.style.display = 'block';
          info.innerHTML = 'Your password has been changed.';
          setTimeout(() => {
            const url = new URL(window.location.href);
            url.pathname = '/login';

            window.location.replace(url.href);
          }, 2000);
        } catch (_err) {
          infoContainer.style.display = 'block';
          info.innerHTML = 'Error in the request.';
          button.disabled = false;
        }
      } else {
        button.disabled = false;
      }
    });
  },
};

Hooks.webBind = {
  mounted() {
    const button = document.getElementById('button');
    button.disabled = true;

    const passwordField = document.getElementById('password');
    const confirmField = document.getElementById('password-confirmation');

    confirmField.addEventListener('keyup', () => {
      if (confirmField.value === passwordField.value) {
        button.disabled = false;
      } else {
        button.disabled = true;
      }
    });

    this.el.addEventListener('submit', async (e) => {
      e.preventDefault();

      const infoContainer = document.getElementById('info-container');
      const info = document.getElementById('info');

      button.disabled = true;

      const password = document.getElementById('password').value;

      if (password) {
        try {
          const resp = await fetch('/api/accounts/bind', {
            method: 'POST',
            headers: APIHeaders,
            body: JSON.stringify({ token: validateTokenPassword, new_password: password }),
          });
          if (!resp.ok) {
            throw new Error('Error');
          }
          infoContainer.style.display = 'block';
          info.innerHTML = 'Your password has been saved.';

          setTimeout(() => {
            const url = new URL(window.location.href);
            url.pathname = '/login';

            window.location.replace(url.href);
          }, 2000);
        } catch (_err) {
          infoContainer.style.display = 'block';
          info.innerHTML = 'Error in the request.';
          button.disabled = false;
        }
      } else {
        button.disabled = false;
      }
    });
  },
};

Hooks.statsCharts = {
  mounted() {
    statsCharts.call(this);
    this.handleEvent('stats', (stats) => statsCharts.call(this, stats));
  },
};

const tokenMeta = document.querySelector("meta[name='csrf-token']");
const csrfToken = tokenMeta && tokenMeta.getAttribute('content');
const liveSocket = new LiveSocket('/live', Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } });

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', (_info) => NProgress.start());
window.addEventListener('phx:page-loading-stop', (_info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;
