// ── CONFIG ────────────────────────────────────────────────
const API = 'api';
let helpers = {};  // categories, units, suppliers, ingredients

// ── BOOTSTRAP ─────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  try {
    helpers = await get(`${API}/helpers.php`);
    if (helpers.error) throw new Error(helpers.error);
    setupNav();
    navigate('dashboard');
  } catch (e) {
    document.getElementById('app').innerHTML = `
      <div style="padding:48px;text-align:center">
        <div style="font-size:48px;margin-bottom:16px">⚠️</div>
        <div style="font-size:18px;font-weight:700;color:#c0392b;margin-bottom:8px">Cannot connect to database</div>
        <div style="font-size:14px;color:#7a5c42;max-width:420px;margin:0 auto;line-height:1.8">
          <b>Error:</b> ${e.message}<br><br>
          Check that:<br>
          1. LAMPP Apache &amp; MySQL are running<br>
          2. Database <b>bakery_inventory</b> exists in phpMyAdmin<br>
          3. Credentials in <b>api/config.php</b> are correct
        </div>
      </div>`;
  }
});

function setupNav() {
  document.querySelectorAll('.nav-item').forEach(el => {
    el.addEventListener('click', () => navigate(el.dataset.page));
  });
}

function navigate(page) {
  document.querySelectorAll('.nav-item').forEach(el =>
    el.classList.toggle('active', el.dataset.page === page));
  const app = document.getElementById('app');
  app.innerHTML = '<div class="empty"><div class="empty-icon">⏳</div><div>Loading…</div></div>';
  pages[page]();
}

// ── API HELPERS ───────────────────────────────────────────
async function get(url) {
  const r = await fetch(url);
  return r.json();
}
async function post(url, data) {
  const r = await fetch(url, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(data) });
  return r.json();
}
async function put(url, data) {
  const r = await fetch(url, { method:'PUT', headers:{'Content-Type':'application/json'}, body:JSON.stringify(data) });
  return r.json();
}
async function del(url) {
  const r = await fetch(url, { method:'DELETE' });
  return r.json();
}

// ── MODAL ─────────────────────────────────────────────────
function openModal(title, html) {
  document.getElementById('modal-title').textContent = title;
  document.getElementById('modal-body').innerHTML = html;
  document.getElementById('modal-overlay').classList.remove('hidden');
}
function closeModal() {
  document.getElementById('modal-overlay').classList.add('hidden');
}
document.getElementById('modal-overlay').addEventListener('click', e => {
  if (e.target === document.getElementById('modal-overlay')) closeModal();
});

// ── TOAST ──────────────────────────────────────────────────
function toast(msg, type='success') {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.className = `toast ${type}`;
  t.classList.remove('hidden');
  setTimeout(() => t.classList.add('hidden'), 3000);
}

// ── HELPERS ───────────────────────────────────────────────
function catOptions(type) {
  return helpers.cats
    .filter(c => type ? c.type === type : true)
    .map(c => `<option value="${c.category_id}">${c.name}</option>`).join('');
}
function unitOptions() {
  return helpers.units.map(u => `<option value="${u.unit_id}">${u.name} (${u.abbreviation})</option>`).join('');
}
function supplierOptions() {
  return helpers.sups.map(s => `<option value="${s.supplier_id}">${s.name}</option>`).join('');
}
function ingredientOptions() {
  return helpers.ings.map(i => `<option value="${i.ingredient_id}" data-unit="${i.unit_id}">${i.name}</option>`).join('');
}
function stockBadge(qty, reorder) {
  if (qty <= 0)       return `<span class="badge badge-red">Out of Stock</span>`;
  if (qty <= reorder) return `<span class="badge badge-amber">Low Stock</span>`;
  return `<span class="badge badge-green">In Stock</span>`;
}
function fmt(n) { return parseFloat(n).toFixed(2); }

// ── SEARCH FILTER ─────────────────────────────────────────
function filterTable(inputId, tableId) {
  const q = document.getElementById(inputId).value.toLowerCase();
  document.querySelectorAll(`#${tableId} tbody tr`).forEach(row => {
    row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}

// ══════════════════════════════════════════════════════════
// PAGES
// ══════════════════════════════════════════════════════════
const pages = {};

// ── DASHBOARD ─────────────────────────────────────────────
pages.dashboard = async () => {
  const d = await get(`${API}/dashboard.php`);
  const app = document.getElementById('app');

  const alertRows = d.low_stock.length
    ? d.low_stock.map(a => `
        <li class="alert-item">
          <div>
            <div class="alert-name">${a.name}</div>
            <div class="alert-meta">${a.item_type} · In stock: <b>${fmt(a.quantity_in_stock)}</b> · Reorder at: ${fmt(a.reorder_level)}</div>
          </div>
          <span class="badge ${a.shortage > 0 ? 'badge-red' : 'badge-amber'}">${a.shortage > 0 ? '−'+fmt(a.shortage)+' short' : 'At threshold'}</span>
        </li>`).join('')
    : `<li class="alert-item"><div class="empty"><div class="empty-icon">✅</div><div>All stock levels are healthy</div></div></li>`;

  const mvRows = d.recent_movements.length
    ? d.recent_movements.map(m => `
        <tr>
          <td><span class="mv-type mv-${m.movement_type}">${m.movement_type}</span></td>
          <td>${m.item_type}</td>
          <td>${m.quantity_change > 0 ? '+' : ''}${fmt(m.quantity_change)}</td>
          <td style="color:var(--text2);font-size:12px">${m.notes || '—'}</td>
          <td style="font-size:12px;color:var(--text3)">${m.moved_at}</td>
        </tr>`).join('')
    : `<tr><td colspan="5" class="empty">No movements recorded yet.</td></tr>`;

  const costRows = d.recipe_costs.length
    ? d.recipe_costs.map(c => `
        <div class="cost-row">
          <div class="cost-name">${c.recipe_name}</div>
          <div class="cost-vals">
            <span class="cost-val">Yield: ${c.yield_quantity}</span>
            <span class="cost-val">Total: $${fmt(c.total_ingredient_cost)}</span>
            <span class="cost-highlight">$${fmt(c.cost_per_unit)}/unit</span>
          </div>
        </div>`).join('')
    : `<div class="empty"><div>No recipes configured.</div></div>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Dashboard</div><div class="page-subtitle">Bakery Inventory Overview</div></div>
    </div>

    <div class="stats-grid">
      <div class="stat-card"><div class="stat-label">Ingredients</div><div class="stat-value">${d.total_ingredients}</div><div class="stat-icon">🌾</div></div>
      <div class="stat-card"><div class="stat-label">Products</div><div class="stat-value">${d.total_products}</div><div class="stat-icon">🍞</div></div>
      <div class="stat-card"><div class="stat-label">Suppliers</div><div class="stat-value">${d.total_suppliers}</div><div class="stat-icon">🚚</div></div>
      <div class="stat-card"><div class="stat-label">Pending Orders</div><div class="stat-value">${d.pending_orders}</div><div class="stat-icon">📋</div></div>
    </div>

    <div class="grid-2">
      <div class="card">
        <div class="card-header"><span class="card-title">⚠️ Low Stock Alerts</span></div>
        <ul class="alert-list">${alertRows}</ul>
      </div>
      <div class="card">
        <div class="card-header"><span class="card-title">💰 Recipe Cost Estimator</span></div>
        ${costRows}
      </div>
    </div>

    <div class="card">
      <div class="card-header"><span class="card-title">📊 Recent Stock Movements</span></div>
      <div class="table-wrap">
        <table><thead><tr><th>Type</th><th>Item</th><th>Qty Change</th><th>Notes</th><th>Date</th></tr></thead>
        <tbody>${mvRows}</tbody></table>
      </div>
    </div>`;
};

// ── INGREDIENTS ───────────────────────────────────────────
pages.ingredients = async () => {
  const data = await get(`${API}/ingredients.php`);
  const app  = document.getElementById('app');

  const rows = data.map(i => `
    <tr>
      <td><b>${i.name}</b></td>
      <td>${i.category_name || '—'}</td>
      <td>${fmt(i.quantity_in_stock)} ${i.unit_abbr || ''}</td>
      <td>${stockBadge(i.quantity_in_stock, i.reorder_level)}</td>
      <td>$${fmt(i.cost_per_unit)}</td>
      <td>${i.supplier_name || '—'}</td>
      <td>
        <button class="btn btn-ghost btn-sm" onclick='editIngredient(${JSON.stringify(i)})'>Edit</button>
        <button class="btn btn-red btn-sm" onclick="delIngredient(${i.ingredient_id})">Delete</button>
      </td>
    </tr>`).join('') || `<tr><td colspan="7"><div class="empty"><div class="empty-icon">🌾</div><div>No ingredients yet.</div></div></td></tr>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Ingredients</div><div class="page-subtitle">${data.length} raw materials in database</div></div>
      <button class="btn btn-primary" onclick="addIngredient()">+ Add Ingredient</button>
    </div>
    <div class="search-bar">
      <input class="search-input" id="ing-search" placeholder="Search ingredients…" oninput="filterTable('ing-search','ing-table')">
    </div>
    <div class="card">
      <div class="table-wrap">
        <table id="ing-table">
          <thead><tr><th>Name</th><th>Category</th><th>In Stock</th><th>Status</th><th>Cost/Unit</th><th>Supplier</th><th>Actions</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </div>`;
};

function ingForm(i={}) {
  return `
    <div class="form-grid">
      <div class="form-group full"><label>Ingredient Name *</label><input id="f-name" value="${i.name||''}" placeholder="e.g. All-Purpose Flour"></div>
      <div class="form-group"><label>Category *</label><select id="f-cat">${catOptions('ingredient')}</select></div>
      <div class="form-group"><label>Unit *</label><select id="f-unit">${unitOptions()}</select></div>
      <div class="form-group"><label>Quantity In Stock</label><input id="f-qty" type="number" step="0.001" value="${i.quantity_in_stock||0}"></div>
      <div class="form-group"><label>Reorder Level</label><input id="f-reorder" type="number" step="0.001" value="${i.reorder_level||0}"></div>
      <div class="form-group"><label>Cost Per Unit ($)</label><input id="f-cost" type="number" step="0.0001" value="${i.cost_per_unit||0}"></div>
      <div class="form-group"><label>Supplier</label><select id="f-sup"><option value="">— None —</option>${supplierOptions()}</select></div>
      <div class="form-group full"><label>Notes</label><textarea id="f-notes">${i.notes||''}</textarea></div>
    </div>
    <div class="form-actions">
      <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="saveIngredient(${i.ingredient_id||0})">Save</button>
    </div>`;
}

function addIngredient() { openModal('Add Ingredient', ingForm()); }

function editIngredient(i) {
  openModal('Edit Ingredient', ingForm(i));
  setTimeout(() => {
    document.getElementById('f-cat').value   = i.category_id;
    document.getElementById('f-unit').value  = i.unit_id;
    document.getElementById('f-sup').value   = i.supplier_id || '';
  }, 50);
}

async function saveIngredient(id) {
  const d = {
    name: document.getElementById('f-name').value,
    category_id: document.getElementById('f-cat').value,
    unit_id: document.getElementById('f-unit').value,
    quantity_in_stock: document.getElementById('f-qty').value,
    reorder_level: document.getElementById('f-reorder').value,
    cost_per_unit: document.getElementById('f-cost').value,
    supplier_id: document.getElementById('f-sup').value || null,
    notes: document.getElementById('f-notes').value,
  };
  if (!d.name) return toast('Name is required', 'error');
  if (id) await put(`${API}/ingredients.php?id=${id}`, d);
  else    await post(`${API}/ingredients.php`, d);
  closeModal();
  toast(id ? 'Ingredient updated!' : 'Ingredient added!');
  pages.ingredients();
}

async function delIngredient(id) {
  if (!confirm('Delete this ingredient?')) return;
  await del(`${API}/ingredients.php?id=${id}`);
  toast('Ingredient deleted');
  pages.ingredients();
}

// ── PRODUCTS ──────────────────────────────────────────────
pages.products = async () => {
  const data = await get(`${API}/products.php`);
  const app  = document.getElementById('app');

  const rows = data.map(p => `
    <tr>
      <td><b>${p.name}</b></td>
      <td>${p.category_name || '—'}</td>
      <td>${fmt(p.quantity_in_stock)} ${p.unit_abbr || ''}</td>
      <td>${stockBadge(p.quantity_in_stock, p.reorder_level)}</td>
      <td>$${fmt(p.sale_price)}</td>
      <td>
        <button class="btn btn-ghost btn-sm" onclick='editProduct(${JSON.stringify(p)})'>Edit</button>
        <button class="btn btn-red btn-sm" onclick="delProduct(${p.product_id})">Delete</button>
      </td>
    </tr>`).join('') || `<tr><td colspan="6"><div class="empty"><div class="empty-icon">🍞</div><div>No products yet.</div></div></td></tr>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Products</div><div class="page-subtitle">${data.length} finished goods in database</div></div>
      <button class="btn btn-primary" onclick="addProduct()">+ Add Product</button>
    </div>
    <div class="search-bar">
      <input class="search-input" id="prod-search" placeholder="Search products…" oninput="filterTable('prod-search','prod-table')">
    </div>
    <div class="card">
      <div class="table-wrap">
        <table id="prod-table">
          <thead><tr><th>Name</th><th>Category</th><th>In Stock</th><th>Status</th><th>Sale Price</th><th>Actions</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </div>`;
};

function prodForm(p={}) {
  return `
    <div class="form-grid">
      <div class="form-group full"><label>Product Name *</label><input id="f-name" value="${p.name||''}" placeholder="e.g. Classic White Bread"></div>
      <div class="form-group"><label>Category *</label><select id="f-cat">${catOptions('product')}</select></div>
      <div class="form-group"><label>Unit *</label><select id="f-unit">${unitOptions()}</select></div>
      <div class="form-group"><label>Quantity In Stock</label><input id="f-qty" type="number" step="0.001" value="${p.quantity_in_stock||0}"></div>
      <div class="form-group"><label>Reorder Level</label><input id="f-reorder" type="number" step="0.001" value="${p.reorder_level||0}"></div>
      <div class="form-group"><label>Sale Price ($)</label><input id="f-price" type="number" step="0.01" value="${p.sale_price||0}"></div>
      <div class="form-group full"><label>Notes</label><textarea id="f-notes">${p.notes||''}</textarea></div>
    </div>
    <div class="form-actions">
      <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="saveProduct(${p.product_id||0})">Save</button>
    </div>`;
}

function addProduct()    { openModal('Add Product', prodForm()); }
function editProduct(p)  {
  openModal('Edit Product', prodForm(p));
  setTimeout(() => {
    document.getElementById('f-cat').value  = p.category_id;
    document.getElementById('f-unit').value = p.unit_id;
  }, 50);
}

async function saveProduct(id) {
  const d = {
    name: document.getElementById('f-name').value,
    category_id: document.getElementById('f-cat').value,
    unit_id: document.getElementById('f-unit').value,
    quantity_in_stock: document.getElementById('f-qty').value,
    reorder_level: document.getElementById('f-reorder').value,
    sale_price: document.getElementById('f-price').value,
    notes: document.getElementById('f-notes').value,
  };
  if (!d.name) return toast('Name is required', 'error');
  if (id) await put(`${API}/products.php?id=${id}`, d);
  else    await post(`${API}/products.php`, d);
  closeModal();
  toast(id ? 'Product updated!' : 'Product added!');
  pages.products();
}

async function delProduct(id) {
  if (!confirm('Delete this product?')) return;
  await del(`${API}/products.php?id=${id}`);
  toast('Product deleted');
  pages.products();
}

// ── SUPPLIERS ─────────────────────────────────────────────
pages.suppliers = async () => {
  const data = await get(`${API}/suppliers.php`);
  const app  = document.getElementById('app');

  const rows = data.map(s => `
    <tr>
      <td><b>${s.name}</b></td>
      <td>${s.contact_name || '—'}</td>
      <td>${s.email || '—'}</td>
      <td>${s.phone || '—'}</td>
      <td><span class="badge badge-gray">${s.ingredient_count} ingredients</span></td>
      <td>
        <button class="btn btn-ghost btn-sm" onclick='editSupplier(${JSON.stringify(s)})'>Edit</button>
      </td>
    </tr>`).join('') || `<tr><td colspan="6"><div class="empty"><div class="empty-icon">🚚</div><div>No suppliers yet.</div></div></td></tr>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Suppliers</div><div class="page-subtitle">${data.length} suppliers on record</div></div>
      <button class="btn btn-primary" onclick="addSupplier()">+ Add Supplier</button>
    </div>
    <div class="search-bar">
      <input class="search-input" id="sup-search" placeholder="Search suppliers…" oninput="filterTable('sup-search','sup-table')">
    </div>
    <div class="card">
      <div class="table-wrap">
        <table id="sup-table">
          <thead><tr><th>Company Name</th><th>Contact Person</th><th>Email</th><th>Phone</th><th>Supplies</th><th>Actions</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </div>`;
};

function supForm(s={}) {
  return `
    <div class="form-grid">
      <div class="form-group full"><label>Company Name *</label><input id="f-name" value="${s.name||''}" placeholder="e.g. Golden Grain Co."></div>
      <div class="form-group"><label>Contact Person</label><input id="f-contact" value="${s.contact_name||''}" placeholder="Full name"></div>
      <div class="form-group"><label>Email</label><input id="f-email" type="email" value="${s.email||''}" placeholder="email@company.com"></div>
      <div class="form-group"><label>Phone</label><input id="f-phone" value="${s.phone||''}" placeholder="+256 ..."></div>
      <div class="form-group full"><label>Address</label><textarea id="f-address">${s.address||''}</textarea></div>
    </div>
    <div class="form-actions">
      <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="saveSupplier(${s.supplier_id||0})">Save</button>
    </div>`;
}

function addSupplier()   { openModal('Add Supplier', supForm()); }
function editSupplier(s) { openModal('Edit Supplier', supForm(s)); }

async function saveSupplier(id) {
  const d = {
    name:         document.getElementById('f-name').value,
    contact_name: document.getElementById('f-contact').value,
    email:        document.getElementById('f-email').value,
    phone:        document.getElementById('f-phone').value,
    address:      document.getElementById('f-address').value,
  };
  if (!d.name) return toast('Company name is required', 'error');
  if (id) await put(`${API}/suppliers.php?id=${id}`, d);
  else    await post(`${API}/suppliers.php`, d);
  helpers = await get(`${API}/helpers.php`); // refresh supplier list
  closeModal();
  toast(id ? 'Supplier updated!' : 'Supplier added!');
  pages.suppliers();
}

// ── PURCHASE ORDERS ───────────────────────────────────────
pages.orders = async () => {
  const data = await get(`${API}/orders.php`);
  const app  = document.getElementById('app');

  const statusBadge = s =>
    s==='pending'   ? `<span class="badge badge-amber">Pending</span>`  :
    s==='received'  ? `<span class="badge badge-green">Received</span>` :
                     `<span class="badge badge-red">Cancelled</span>`;

  const rows = data.map(o => `
    <tr>
      <td><b>#${o.po_id}</b></td>
      <td>${o.supplier_name}</td>
      <td>${o.order_date}</td>
      <td>${o.expected_date || '—'}</td>
      <td>${o.item_count} items</td>
      <td>$${fmt(o.total_cost || 0)}</td>
      <td>${statusBadge(o.status)}</td>
      <td>
        ${o.status === 'pending'
          ? `<button class="btn btn-green btn-sm" onclick="receiveOrder(${o.po_id})">✓ Receive</button>`
          : ''}
      </td>
    </tr>`).join('') || `<tr><td colspan="8"><div class="empty"><div class="empty-icon">📋</div><div>No orders yet.</div></div></td></tr>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Purchase Orders</div><div class="page-subtitle">${data.length} orders total</div></div>
      <button class="btn btn-primary" onclick="addOrder()">+ New Order</button>
    </div>
    <div class="card">
      <div class="table-wrap">
        <table>
          <thead><tr><th>PO #</th><th>Supplier</th><th>Order Date</th><th>Expected</th><th>Items</th><th>Total Cost</th><th>Status</th><th>Actions</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </div>`;
};

let orderItems = [];

function addOrder() {
  orderItems = [{ ingredient_id:'', quantity_ordered:'', unit_id:'', cost_per_unit:'' }];
  openModal('New Purchase Order', orderForm());
}

function orderForm() {
  const today = new Date().toISOString().slice(0,10);
  return `
    <div class="form-grid">
      <div class="form-group"><label>Supplier *</label><select id="f-sup">${supplierOptions()}</select></div>
      <div class="form-group"><label>Order Date *</label><input id="f-date" type="date" value="${today}"></div>
      <div class="form-group full"><label>Expected Delivery Date</label><input id="f-exp" type="date"></div>
    </div>
    <hr style="border:none;border-top:1px solid var(--border);margin:14px 0">
    <div style="font-weight:700;margin-bottom:10px;font-size:13.5px">Order Items</div>
    <div class="oi-header"><span>Ingredient</span><span>Qty</span><span>Unit</span><span>Cost/Unit ($)</span><span></span></div>
    <div id="oi-rows">${renderOrderItems()}</div>
    <button class="btn-add-row" onclick="addOrderItem()">+ Add Item</button>
    <div class="form-group" style="margin-top:14px"><label>Notes</label><textarea id="f-notes"></textarea></div>
    <div class="form-actions">
      <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
      <button class="btn btn-primary" onclick="saveOrder()">Place Order</button>
    </div>`;
}

function renderOrderItems() {
  return orderItems.map((item, idx) => `
    <div class="oi-row">
      <select onchange="oiChange(${idx},'ingredient_id',this.value)" style="padding:8px;border:1.5px solid var(--border);border-radius:8px;font-size:13px">
        <option value="">— Select —</option>${ingredientOptions()}
      </select>
      <input type="number" step="0.01" placeholder="Qty" value="${item.quantity_ordered}"
        oninput="oiChange(${idx},'quantity_ordered',this.value)"
        style="padding:8px;border:1.5px solid var(--border);border-radius:8px;font-size:13px">
      <select onchange="oiChange(${idx},'unit_id',this.value)" style="padding:8px;border:1.5px solid var(--border);border-radius:8px;font-size:13px">
        ${unitOptions()}
      </select>
      <input type="number" step="0.0001" placeholder="0.00" value="${item.cost_per_unit}"
        oninput="oiChange(${idx},'cost_per_unit',this.value)"
        style="padding:8px;border:1.5px solid var(--border);border-radius:8px;font-size:13px">
      <button class="btn-icon" onclick="removeOrderItem(${idx})">✕</button>
    </div>`).join('');
}

function oiChange(idx, field, val) { orderItems[idx][field] = val; }
function addOrderItem() {
  orderItems.push({ ingredient_id:'', quantity_ordered:'', unit_id:'', cost_per_unit:'' });
  document.getElementById('oi-rows').innerHTML = renderOrderItems();
}
function removeOrderItem(idx) {
  orderItems.splice(idx, 1);
  document.getElementById('oi-rows').innerHTML = renderOrderItems();
}

async function saveOrder() {
  const d = {
    supplier_id:   document.getElementById('f-sup').value,
    order_date:    document.getElementById('f-date').value,
    expected_date: document.getElementById('f-exp').value || null,
    notes:         document.getElementById('f-notes').value,
    items:         orderItems.filter(i => i.ingredient_id && i.quantity_ordered),
  };
  if (!d.supplier_id || !d.order_date) return toast('Supplier and date required', 'error');
  if (!d.items.length) return toast('Add at least one item', 'error');
  await post(`${API}/orders.php`, d);
  closeModal();
  toast('Purchase order placed!');
  pages.orders();
}

async function receiveOrder(id) {
  if (!confirm(`Mark Order #${id} as received? This will update ingredient stock.`)) return;
  await post(`${API}/orders.php`, { action: 'receive', po_id: id });
  toast('Order received! Stock updated automatically.');
  pages.orders();
}

// ── STOCK MOVEMENTS ───────────────────────────────────────
pages.movements = async () => {
  const data = await get(`${API}/movements.php`);
  const app  = document.getElementById('app');

  const rows = data.map(m => `
    <tr>
      <td>${m.movement_id}</td>
      <td><span class="mv-type mv-${m.movement_type}">${m.movement_type}</span></td>
      <td><span class="badge badge-gray">${m.item_type}</span></td>
      <td>ID: ${m.item_id}</td>
      <td style="font-weight:600;color:${m.quantity_change>0?'var(--green)':'var(--red)'}">
        ${m.quantity_change>0?'+':''}${fmt(m.quantity_change)}
      </td>
      <td style="font-size:12.5px;color:var(--text2)">${m.notes || '—'}</td>
      <td style="font-size:12px;color:var(--text3)">${m.moved_at}</td>
    </tr>`).join('') || `<tr><td colspan="7"><div class="empty"><div class="empty-icon">📊</div><div>No movements recorded yet.</div></div></td></tr>`;

  app.innerHTML = `
    <div class="page-header">
      <div><div class="page-title">Stock Movements</div><div class="page-subtitle">Complete audit trail of all stock changes</div></div>
    </div>
    <div class="search-bar">
      <input class="search-input" id="mv-search" placeholder="Filter by type, item…" oninput="filterTable('mv-search','mv-table')">
    </div>
    <div class="card">
      <div class="table-wrap">
        <table id="mv-table">
          <thead><tr><th>#</th><th>Type</th><th>Item Type</th><th>Item</th><th>Qty Change</th><th>Notes</th><th>Date & Time</th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </div>`;
};
