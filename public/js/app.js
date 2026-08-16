// Tiny vanilla JS client — no framework, no build step.

async function api(path, opts = {}) {
  const res = await fetch(path, {
    headers: { 'Content-Type': 'application/json' },
    ...opts,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || res.statusText);
  }
  return res.json();
}

async function refreshHealth() {
  try {
    const h = await api('/api/health');
    document.getElementById('health').textContent = JSON.stringify(h, null, 2);
  } catch (e) {
    document.getElementById('health').textContent = 'ERROR: ' + e.message;
  }
}

async function refreshItems() {
  const ul = document.getElementById('items');
  try {
    const { items } = await api('/api/items');
    if (items.length === 0) {
      ul.innerHTML = '<li class="empty">No items yet. Create one above.</li>';
      return;
    }
    ul.innerHTML = items.map(i => `
      <li>
        <span>#${i.id} · ${escapeHtml(i.name)}</span>
        <button class="del" data-id="${i.id}">delete</button>
      </li>
    `).join('');
    ul.querySelectorAll('.del').forEach(btn => {
      btn.onclick = async () => {
        await api('/api/items/' + btn.dataset.id, { method: 'DELETE' });
        refreshItems();
      };
    });
  } catch (e) {
    ul.innerHTML = '<li class="empty">ERROR: ' + escapeHtml(e.message) + '</li>';
  }
}

function escapeHtml(s) {
  const d = document.createElement('div');
  d.textContent = s;
  return d.innerHTML;
}

document.getElementById('createForm').onsubmit = async (e) => {
  e.preventDefault();
  const input = e.target.name;
  try {
    await api('/api/items', {
      method: 'POST',
      body: JSON.stringify({ name: input.value }),
    });
    input.value = '';
    refreshItems();
  } catch (err) {
    alert(err.message);
  }
};

document.getElementById('refresh').onclick = refreshItems;

refreshHealth();
refreshItems();
setInterval(refreshHealth, 30000);
