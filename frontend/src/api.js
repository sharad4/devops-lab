const headers = { 'Content-Type': 'application/json', Accept: 'application/json' };

async function request(path, options = {}) {
  const res = await fetch(`/api${path}`, { headers, ...options });
  if (!res.ok) throw new Error(`API ${res.status}`);
  return res.status === 204 ? null : res.json();
}

export const listTasks = () => request('/tasks');
export const addTask = (title) => request('/tasks', { method: 'POST', body: JSON.stringify({ title }) });
export const toggleTask = (t) => request(`/tasks/${t.id}`, { method: 'PUT', body: JSON.stringify({ done: !t.done }) });
export const removeTask = (id) => request(`/tasks/${id}`, { method: 'DELETE' });
