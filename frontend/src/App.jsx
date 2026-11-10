import { useEffect, useState } from 'react';
import { addTask, listTasks, removeTask, toggleTask } from './api.js';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [error, setError] = useState('');

  const load = () => listTasks().then(setTasks).catch((e) => setError(e.message));
  useEffect(() => { load(); }, []);

  const submit = async (e) => {
    e.preventDefault();
    if (!title.trim()) return;
    try { await addTask(title); setTitle(''); await load(); } catch (err) { setError(err.message); }
  };

  return (
    <main style={{ maxWidth: 480, margin: '2rem auto', fontFamily: 'sans-serif' }}>
      <h1>DevOps Lab Tasks</h1>
      {error && <p role="alert">Error: {error}</p>}
      <form onSubmit={submit}>
        <input aria-label="title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="New task" />
        <button type="submit">Add</button>
      </form>
      <ul>
        {tasks.map((t) => (
          <li key={t.id}>
            <label style={{ textDecoration: t.done ? 'line-through' : 'none' }}>
              <input type="checkbox" checked={t.done} onChange={() => toggleTask(t).then(load)} /> {t.title}
            </label>
            <button onClick={() => removeTask(t.id).then(load)} aria-label={`delete ${t.title}`}>x</button>
          </li>
        ))}
      </ul>
    </main>
  );
}
