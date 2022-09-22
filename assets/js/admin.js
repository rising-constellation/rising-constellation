setInterval(() => {
  const el = document.getElementById('admin-header').classList;
  fetch('/api/maintenance').then((resp) => {
    if (resp.status !== 200 && !el.contains('maintenance')) {
      el.add('maintenance');
    } else if (resp.status === 200) {
      el.remove('maintenance');
    }
  });
}, 3000);
