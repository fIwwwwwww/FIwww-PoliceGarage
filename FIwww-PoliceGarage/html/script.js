let UI = {
  categories: {},
  leaders: [],
  ranks: {},
  playerGrade: 0,
  currentTab: 'patrol'
};

const app = document.getElementById('app') || document.getElementById('uiRoot') || document.body;
const vehicleGrid = document.getElementById('vehicleGrid');
const leaderGrid = document.getElementById('leaderGrid');
const exitBtn = document.getElementById('exitBtn');
const title = document.getElementById('locationTitle');

function escapeHtml(t){return t?.toString().replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[m])) || ''}

function setActiveTab(tab){
  UI.currentTab = tab;
  document.querySelectorAll('.tab-btn').forEach(b=>{
    b.classList.toggle('active', b.dataset.tab === tab);
  });
  renderVehicles();
}

function renderVehicles(){
  const cat = UI.categories[UI.currentTab];
  if(!cat){ vehicleGrid.innerHTML = '<p>No vehicles in this category.</p>'; return;}
  vehicleGrid.innerHTML = '';
  cat.vehicles.forEach(v => {
    const requiredGrade = UI.ranks[v.requiredRank] ?? 0;
    const allowed = UI.playerGrade >= requiredGrade;
    const el = document.createElement('div');
    el.className = 'card';
    el.innerHTML = `
      <img src="img/vehicles/${escapeHtml(v.image||'placeholder.png')}" alt="car">
      <div class="title">${escapeHtml(v.label)}</div>
      <div class="meta">Rank Required: <b>${escapeHtml(v.requiredRank)}</b></div>
      <div class="meta">Fuel: <b>${escapeHtml(v.fuel)}%</b></div>
      <div class="actions"><button class="spawn-btn" ${allowed ? '' : 'disabled'}>${allowed ? 'Spawn' : 'Insufficient Rank'}</button></div>
    `;
    const btn = el.querySelector('.spawn-btn');
    btn.addEventListener('click', () => {
      fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: JSON.stringify(v)
      }).then(()=>{ /* UI will be closed by Lua */ });
    });
    vehicleGrid.appendChild(el);
  });
}

function renderLeaders(){
  if (!leaderGrid) return;
  leaderGrid.innerHTML = '';
  UI.leaders.forEach(p => {
    const el = document.createElement('div');
    el.className = 'leader';
    el.innerHTML = `
      <img src="img/leaders/${escapeHtml(p.image||'leader.png')}" alt="leader">
      <div class="title">${escapeHtml(p.title)}</div>
      <div class="name">${escapeHtml(p.name||'')}</div>
    `;
    leaderGrid.appendChild(el);
  });
}

function showExtrasList(extras) {
  if (!vehicleGrid) return;
  vehicleGrid.innerHTML = '';
  const header = document.createElement('div');
  header.style.display = 'flex';
  header.style.justifyContent = 'space-between';
  header.style.alignItems = 'center';
  header.style.marginBottom = '10px';
  header.innerHTML = `<div style="font-weight:700">Vehicle Extras</div><button id="extrasBack" class="btn">Back</button>`;
  vehicleGrid.appendChild(header);

  const list = document.createElement('div');
  list.style.display = 'grid';
  list.style.gap = '8px';
  list.style.marginTop = '8px';

  extras.forEach(ex => {
    const row = document.createElement('div');
    row.className = 'card';
    row.style.display = 'flex';
    row.style.justifyContent = 'space-between';
    row.style.alignItems = 'center';
    row.innerHTML = `<div>Extra #${ex.id}</div><button class="toggle-btn">${ex.state ? 'ON' : 'OFF'}</button>`;
    const toggleBtn = row.querySelector('.toggle-btn');
    toggleBtn.style.padding = '8px 12px';
    toggleBtn.style.borderRadius = '8px';
    toggleBtn.style.border = 'none';
    toggleBtn.style.cursor = 'pointer';
    if (ex.state) {
      toggleBtn.style.background = '#10b981';
      toggleBtn.style.color = '#fff';
    } else {
      toggleBtn.style.background = '#ef4444';
      toggleBtn.style.color = '#fff';
    }

    toggleBtn.addEventListener('click', () => {
      fetch(`https://${GetParentResourceName()}/toggleExtra`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: JSON.stringify({ id: ex.id, state: ex.state })
      }).then(resp => resp.json?.() || resp).then(() => {
        ex.state = !ex.state;
        toggleBtn.textContent = ex.state ? 'ON' : 'OFF';
        if (ex.state) {
          toggleBtn.style.background = '#10b981';
          toggleBtn.style.color = '#fff';
        } else {
          toggleBtn.style.background = '#ef4444';
          toggleBtn.style.color = '#fff';
        }
      });
    });

    list.appendChild(row);
  });

  vehicleGrid.appendChild(list);

  document.getElementById('extrasBack').addEventListener('click', () => {
    renderVehicles();
  });
}

function requestExtras() {
  fetch(`https://${GetParentResourceName()}/getVehicleExtras`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: JSON.stringify({})
  }).then(r => r.json()).then(resp => {
    if (resp && resp.ok && Array.isArray(resp.extras)) {
      showExtrasList(resp.extras);
    } else {
      vehicleGrid.innerHTML = '<p>No extras available or you are not in a vehicle.</p>';
    }
  }).catch(() => {
    vehicleGrid.innerHTML = '<p>Error fetching extras.</p>';
  });
}

(function injectExtrasTab(){
  const nav = document.querySelector('.sidebar nav') || document.querySelector('.tabs') || document.getElementById('tabs') || document.querySelector('aside.sidebar');
  if (!nav) return;
  const btn = document.createElement('button');
  btn.className = 'tab-btn';
  btn.dataset.tab = 'extras';
  btn.textContent = 'Vehicle Extras';
  btn.addEventListener('click', () => {
    requestExtras();
  });
  nav.appendChild(btn);
})();


if (exitBtn) {
  exitBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
  });
}

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'open'){
    UI.categories = data.categories || {};
    UI.leaders = data.leaders || [];
    UI.ranks = data.ranks || {};
    UI.playerGrade = data.grade || 0;
    title.textContent = `${data.locationLabel || '*Location*'} - Police Department Garage`;
    const root = document.getElementById('app') || document.getElementById('uiRoot');
    if (root) root.classList.remove('hidden');
    setActiveTab('patrol');
    renderLeaders();
  } else if (data.action === 'close'){
    const root = document.getElementById('app') || document.getElementById('uiRoot');
    if (root) root.classList.add('hidden');
  }
  else if (data.action === 'openExtras') {
    app.classList.remove('hidden');
    setActiveTab('extras'); 
}
});

document.addEventListener("keydown", function(e) {
    if (e.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: "POST"
        });
    }
});


document.querySelectorAll('.tab-btn').forEach(b => {
  if (b.dataset.tab && b.dataset.tab !== 'extras') {
    b.addEventListener('click', () => setActiveTab(b.dataset.tab));
  }
});



